import QtQuick
import Quickshell
import qs.common

Pill {
  icon: "󰅐"
  monoTooltip: true
  text: Time.timeString(clock.date)
  tooltip: Time.dateTimeString(clock.date)
  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }
}
