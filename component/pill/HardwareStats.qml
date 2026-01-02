import qs.common
import qs.component.common

Pill {
  id: root
  required property string name
  property double usagePercent: NaN
  property double temperatureC: NaN
  property double powerWatts: NaN
  property double memoryUsedGiB: NaN
  property double memoryTotalGiB: NaN
  property string usageTooltip: ""
  property string temperatureTooltip: ""
  property string powerTooltip: ""
  property string memoryTooltip: ""
  property alias usage: usage
  property alias temperature: temperature
  property alias power: power
  property alias memory: memory
  spacing: 0
  horizontalMargin: 0
  monoTooltip: true

  Pill {
    icon: ""
    text: root.name
    screen: root.screen
    monoTooltip: true
  }

  Divider {
    visible: !isNaN(root.usagePercent)
    vertical: true
  }

  Pill {
    id: usage
    visible: !isNaN(root.usagePercent)
    icon: ""
    text: Util.zeroPad(root.usagePercent.toFixed(0), 2)
    suffix: "%"
    tooltip: root.usageTooltip
    monoTooltip: true
    screen: root.screen
  }

  Divider {
    visible: !isNaN(root.temperatureC)
    vertical: true
  }

  Pill {
    id: temperature
    visible: !isNaN(root.temperatureC)
    icon: ""
    text: Util.zeroPad(root.temperatureC.toFixed(0), 2)
    suffix: "°C"
    tooltip: root.temperatureTooltip
    monoTooltip: true
    screen: root.screen
  }

  Divider {
    visible: !isNaN(root.powerWatts)
    vertical: true
  }

  Pill {
    id: power
    visible: !isNaN(root.powerWatts)
    icon: "󱐌"
    text: Util.zeroPad(root.powerWatts.toFixed(0), 2)
    suffix: "W"
    tooltip: root.powerTooltip
    monoTooltip: true
    screen: root.screen
  }

  Divider {
    visible: !isNaN(root.memoryUsedGiB)
    vertical: true
  }

  Pill {
    id: memory
    visible: !isNaN(root.memoryUsedGiB)
    icon: ""
    text: isNaN(root.memoryTotalGiB) ? root.memoryUsedGiB.toFixed(2) : `${root.memoryUsedGiB.toFixed(2)}/${root.memoryTotalGiB.toFixed(0)}`
    suffix: "GiB"
    tooltip: root.memoryTooltip
    monoTooltip: true
    screen: root.screen
  }
}
