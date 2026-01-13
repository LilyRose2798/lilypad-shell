pragma ComponentBehavior: Bound
import QtQuick
import qs.common
import qs.component.common

Pill {
  id: root
  monoTooltip: true
  property string station: "IDV10753"
  property string area: "Sunbury"
  readonly property string fileName: `${station}.xml`
  readonly property string filePath: `/tmp/${fileName}`
  readonly property string url: `ftp://ftp.bom.gov.au/anon/gen/fwo/${fileName}`

  function findElement(element: var, name = null, where = null): var {
    const children = element.childNodes
    const numChildren = children.length
    for (let i = 0; i < numChildren; i++) {
      const child = matchingElement(children[i], name, where)
      if (child !== null)
        return child
    }
    return null
  }

  function findElements(element: var, name = null, where = null): list<var> {
    const children = element.childNodes
    const numChildren = children.length
    const res = []
    for (let i = 0; i < numChildren; i++) {
      const child = matchingElement(children[i], name, where)
      if (child !== null)
        res.push(child)
    }
    return res
  }

  function matchingElement(element: var, name = null, where = null): var {
    if (name === null || element.nodeName === name) {
      const e = root.element(element)
      if (where === null || where(e))
        return e
    }
    return null
  }

  function element(element: var): var {
    const attrs = element.attributes
    const numAttrs = attrs.length
    const attrObj = {}
    for (let j = 0; j < numAttrs; j++) {
      const {
        name,
        value
      } = attrs[j]
      attrObj[name] = value
    }
    element.attrs = attrObj
    element.findElement = (name = null, where = null) => root.findElement(element, name, where)
    element.findElements = (name = null, where = null) => root.findElements(element, name, where)
    return element
  }

  function handleResponse(res: var) {
    if (res.status !== 200)
      return
    const forecasts = matchingElement(res.xml.documentElement, "product")?.findElement("forecast")?.findElement("area", e => e.attrs.description === root.area)?.findElements("forecast-period")?.map(e => {
      const index = parseInt(e.attrs.index)
      const start = new Date(e.attrs["start-time-local"])
      const end = new Date(e.attrs["end-time-local"])
      const values = {}
      for (const val of [...e.findElements("element"), ...e.findElements("text")]) {
        if (!val.attrs.type || val.childNodes.length !== 1 || val.firstChild.nodeType !== 3)
          continue
        values[val.attrs.type] = val.firstChild.wholeText
      }
      const day = Qt.formatDateTime(start, "ddd")
      const minTemp = values.air_temperature_minimum === undefined ? "  " : Util.zeroPad(values.air_temperature_minimum, 2)
      const maxTemp = values.air_temperature_maximum === undefined ? "  " : Util.zeroPad(values.air_temperature_maximum, 2)
      const precip = values.probability_of_precipitation === undefined ? "??%" : Util.zeroPad(values.probability_of_precipitation, 3)
      const precipRange = values.precipitation_range === undefined ? "" : values.precipitation_range.replace(" to ", "-").replace(" mm", "mm")
      const precis = values.precis ?? ""
      return {
        index,
        start,
        end,
        values,
        day,
        minTemp,
        maxTemp,
        precip,
        precipRange,
        precis
      }
    }).sort((a, b) => a.index - b.index)
    root.text = forecasts.slice(1, 4).map(f => `${f.minTemp} ${f.maxTemp} (${f.precip})`).join(" | ")
    root.tooltip = forecasts.map(f => `${f.day} ${f.minTemp} ${f.maxTemp} (${f.precip}) ${f.precis}${f.precipRange ? ` (${f.precipRange})` : ""}`).join("\n")
  }

  RepeatedCommand {
    interval: 60000
    command: ["curl", "-s", root.url, "-o", root.filePath]
    onFinished: Util.httpGet(root.filePath, root.handleResponse)
  }
}
