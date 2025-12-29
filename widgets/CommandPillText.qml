import QtQuick
import Quickshell.Io

PillText {
  id: root
  required property list<string> command
  property double interval: 5000
  property alias process: process
  property alias timer: timer

  Process {
    id: process
    running: true
    command: root.command
    stdout: StdioCollector {
      onStreamFinished: root.value = this.text
    }
  }

  Timer {
    id: timer
    interval: root.interval
    running: true
    repeat: true
    onTriggered: process.running = true
  }
}
