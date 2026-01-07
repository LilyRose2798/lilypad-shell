pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.common

FullscreenWindow {
  id: root
  property bool closeOnCast: false
  property bool closeOnSpell: true
  property alias canvas: canvas
  property list<var> spells: [
    {
      shape: [1, 2, 1, 2, 1],
      action: _ => Quickshell.execDetached(["ydotool", "type", "\n\nLIGHTNING!\n"])
    },
    {
      reversible: true,
      shape: [0, 1, 2, 3, 4, 5],
      action: _ => Quickshell.execDetached(["ydotool", "type", "\n\nTORNADO!\n"])
    },
    {
      reversible: true,
      shape: [0, 1, 2, 3, 4, 0],
      action: _ => Quickshell.execDetached(["ydotool", "type", "\n\nSPIRAL!\n"])
    },
    {
      reversible: true,
      shape: [1, 3, 5],
      action: _ => Quickshell.execDetached(["ydotool", "type", "\n\nFIREBALL!\n"])
    },
    {
      reversible: true,
      shape: [0, 2, 2, 0, 4, 4],
      action: _ => Quickshell.execDetached(["ydotool", "type", "\n\nINFERNO!\n"])
    },
  ]
  signal cast(row: int, col: int, shape: list<int>)
  mouse.hoverEnabled: true

  Canvas {
    id: canvas
    width: root.width
    height: root.height
    antialiasing: true
    focus: true
    property double prevRenderTimestamp
    property double prevOvershoot
    readonly property double fps: Style.hexFps
    readonly property double frameDelta: 1000 / fps
    readonly property double hexRatio: Math.sqrt(3) / 2
    readonly property double gridWidth: Style.hexGridWidth
    readonly property double gridHeight: hexRatio * gridWidth
    readonly property double gridWidthSquared: gridWidth * gridWidth
    readonly property double gridXOffset: gridWidth / 2
    readonly property double gridXStart: (width % gridWidth) / 2
    readonly property double gridYStart: (height % gridHeight) / 2
    readonly property int rowSize: Math.floor(width / gridWidth) - 1
    readonly property double visibleRadius: gridWidth * Style.hexVisibilityFactor
    readonly property double visibleRadiusSquared: visibleRadius * visibleRadius
    readonly property double nodeWidth: Style.hexNodeWidth
    readonly property double nodeHeight: hexRatio * nodeWidth
    readonly property double nodeXOffset: nodeWidth / 2
    readonly property double drawTolerance: Style.hexDrawTolerance
    readonly property double drawToleranceSquared: drawTolerance * drawTolerance
    readonly property int lightningPoints: Style.hexLightningPoints
    readonly property color inactiveColor: Style.hexInactiveColor
    readonly property color activeColor: Style.hexActiveColor
    readonly property color lineInnerColor: Style.hexLineInnerColor
    readonly property color lineOuterColor: Style.hexLineOuterColor
    property list<point> nodes: []
    property list<double> lightningOffsets: []
    renderStrategy: Canvas.Threaded

    function distanceSquared(from: point, to: point): double {
      const dx = Math.abs(from.x - to.x)
      const dy = Math.abs(from.y - to.y)
      return dx * dx + dy * dy
    }

    function lerpValue(from: double, to: double, factor: double): double {
      return (1 - factor) * from + factor * to
    }

    function lerpPoint(from: point, to: point, factor: double): point {
      return Qt.point(lerpValue(from.x, to.x, factor), lerpValue(from.y, to.y, factor))
    }

    function render(timestamp: double, delta: double) {
      const ctx = getContext("2d")
      ctx.reset()
      ctx.lineCap = "round"
      ctx.lineJoin = "round"
      if (!root.mouse.containsMouse)
        return
      const m = Qt.point(root.mouse.mouseX, root.mouse.mouseY)
      const bs = root.mouse.pressedButtons
      let closestDistSquared = Infinity
      let closestNode = undefined
      for (let y = gridYStart, i = 0; y < height; y += gridHeight, i++) {
        for (let x = gridXStart + i % 2 * gridXOffset; x < width; x += gridWidth) {
          const p = Qt.point(x, y)
          const distSquared = distanceSquared(m, p)
          if (distSquared >= visibleRadiusSquared)
            continue
          const normDist = distSquared / visibleRadiusSquared
          if (distSquared < closestDistSquared) {
            closestDistSquared = distSquared
            closestNode = Qt.point(x, y)
          }
          const scale = 1 - normDist
          const alpha = scale * scale * scale
          const width = scale * nodeWidth
          const height = scale * nodeHeight
          const xOffset = scale * nodeXOffset
          ctx.beginPath()
          ctx.moveTo(x - width, y)
          ctx.lineTo(x - xOffset, y - height)
          ctx.lineTo(x + xOffset, y - height)
          ctx.lineTo(x + width, y)
          ctx.lineTo(x + xOffset, y + height)
          ctx.lineTo(x - xOffset, y + height)
          ctx.closePath()
          ctx.fillStyle = inactiveColor.alpha(alpha)
          ctx.fill()
        }
      }
      if (bs & Qt.LeftButton) {
        if (closestDistSquared < drawToleranceSquared && (nodes.length === 0 || (closestNode !== nodes[nodes.length - 1] && Math.round(distanceSquared(nodes[nodes.length - 1], closestNode)) === gridWidthSquared))) {
          if (nodes.length > 1 && nodes[nodes.length - 2] === closestNode)
            nodes.pop()
          else if (nodes.length < 2)
            nodes.push(closestNode)
          else {
            const [startNode, ...restNodes] = nodes
            const lastNode = nodes[nodes.length - 1]
            let prev = startNode
            let isDuplicate = false
            for (const cur of restNodes) {
              if (prev === closestNode && cur === lastNode || cur === closestNode && prev === lastNode) {
                isDuplicate = true
                break
              }
              prev = cur
            }
            if (!isDuplicate)
              nodes.push(closestNode)
          }
        }
        if (nodes.length > 0) {
          const [startNode, ...restNodes] = nodes
          const numMouseLightning = Math.floor(lightningPoints * Math.sqrt(distanceSquared(m, nodes[nodes.length - 1])) / gridWidth)
          const numLightning = lightningPoints * restNodes.length + numMouseLightning
          const mousePoints = numMouseLightning + 1
          const pointsPerNode = lightningPoints + 1

          if (lightningOffsets.length > numLightning)
            lightningOffsets.splice(numLightning - lightningOffsets.length)
          else if (lightningOffsets.length < numLightning) {
            const toAdd = numLightning - lightningOffsets.length
            for (let i = 0; i < toAdd; i++)
              lightningOffsets.push(0)
          }
          for (let i = 0; i < lightningOffsets.length; i++)
            lightningOffsets[i] = Math.max(-0.25, Math.min(0.25, lightningOffsets[i] + 0.5 * (Math.random() - 0.5)))

          const points = []
          let prev = startNode
          let lightningOffset = 0
          for (const cur of restNodes) {
            const dx = (cur.x - prev.x) / pointsPerNode
            const dy = (cur.y - prev.y) / pointsPerNode
            for (let i = 1; i < pointsPerNode; i++) {
              const t = i / pointsPerNode
              const p = lerpPoint(prev, cur, t)
              const offset = lightningOffsets[lightningOffset++]
              points.push(Qt.point(p.x + dy * offset, p.y - dx * offset))
            }
            points.push(cur)
            prev = cur
          }
          const mdx = (m.x - prev.x) / mousePoints
          const mdy = (m.y - prev.y) / mousePoints
          for (let i = 1; i < mousePoints; i++) {
            const t = i / mousePoints
            const p = lerpPoint(prev, m, t)
            const offset = lightningOffsets[lightningOffset++]
            points.push(Qt.point(p.x + mdy * offset, p.y - mdx * offset))
          }
          points.push(m)
          ctx.beginPath()
          ctx.moveTo(startNode.x, startNode.y)
          for (const p of points)
            ctx.lineTo(p.x, p.y)
          ctx.lineWidth = 2.5 * nodeWidth
          ctx.strokeStyle = lineOuterColor
          ctx.stroke()
          ctx.beginPath()
          ctx.moveTo(startNode.x, startNode.y)
          for (const p of points)
            ctx.lineTo(p.x, p.y)
          ctx.lineWidth = nodeWidth
          ctx.strokeStyle = lineInnerColor
          ctx.stroke()
          ctx.fillStyle = activeColor
          for (const n of nodes) {
            ctx.beginPath()
            ctx.moveTo(n.x - nodeWidth, n.y)
            ctx.lineTo(n.x - nodeXOffset, n.y - nodeHeight)
            ctx.lineTo(n.x + nodeXOffset, n.y - nodeHeight)
            ctx.lineTo(n.x + nodeWidth, n.y)
            ctx.lineTo(n.x + nodeXOffset, n.y + nodeHeight)
            ctx.lineTo(n.x - nodeXOffset, n.y + nodeHeight)
            ctx.closePath()
            ctx.fill()
          }
        }
      } else if (nodes.length > 0) {
        const normNodes = nodes.map(n => {
          const y = Math.round((n.y - gridYStart) / gridHeight)
          const x = Math.round((n.x - gridXStart - y % 2 * gridXOffset) / gridWidth)
          return Qt.point(x, y)
        })
        const shape = []
        const [startNode, ...restNodes] = normNodes
        let prev = startNode
        for (const cur of restNodes) {
          shape.push(cur.y === prev.y ? (cur.x > prev.x ? 0 : 3) : (cur.x + cur.y % 2 > prev.x ? (cur.y > prev.y ? 1 : 5) : (cur.y > prev.y ? 2 : 4)))
          prev = cur
        }
        console.log(normNodes, shape)
        root.cast(startNode.y, startNode.x, shape)
        let spellCast = false
        const potentialSpells = root.spells.filter(s => s.shape.length === shape.length)
        if (potentialSpells.length > 0) {
          for (let i = 0; i < shape.length; i++) {
            for (const spell of potentialSpells) {
              if (shape.join("") === spell.shape.join("")) {
                spell.action({
                  row: startNode.y,
                  column: startNode.x,
                  rotation: i,
                  reversed: false
                })
                spellCast = true
              }
            }
            shape.unshift(shape.pop())
          }
        }
        const potentialReversibleSpells = potentialSpells.filter(s => s.reversible)
        if (potentialReversibleSpells.length > 0) {
          shape.reverse()
          for (let i = 0; i < shape.length; i++) {
            for (const spell of potentialSpells) {
              if (shape.join("") === spell.shape.join("")) {
                spell.action({
                  row: startNode.y,
                  column: startNode.x,
                  rotation: i,
                  reversed: true
                })
                spellCast = true
              }
            }
            shape.unshift(shape.pop())
          }
          shape.reverse()
        }
        nodes = []
        if (root.closeOnCast || (spellCast && root.closeOnSpell))
          root.closed()
      }
    }

    function animate(timestamp: double) {
      const delta = timestamp - prevRenderTimestamp
      const overshotDelta = delta + prevOvershoot
      if (overshotDelta >= frameDelta) {
        render(timestamp, delta)
        prevRenderTimestamp = timestamp
        if (overshotDelta > 4 * frameDelta)
          console.log(`Can't keep up, ${overshotDelta.toFixed(0)}ms behind`)
        prevOvershoot = overshotDelta - frameDelta
      }
      requestAnimationFrame(animate)
    }

    onPaint: requestAnimationFrame(timestamp => {
      prevRenderTimestamp = timestamp
      animate(timestamp)
    })
  }
}
