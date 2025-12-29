import QtQuick
import qs.common

Pill {
  IntervalPillText {
    icon: "󰅐"
    getter: Time.nowTimeString
    interval: 1000
  }
}
