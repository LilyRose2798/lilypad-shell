import QtQuick

PillText {
  id: root
  required property var getter
  property double interval: 5000
  property alias timer: timer
  value: getter()

  Timer {
    id: timer
    interval: root.interval
    running: true
    repeat: true
    onTriggered: root.value = getter()
  }
}
