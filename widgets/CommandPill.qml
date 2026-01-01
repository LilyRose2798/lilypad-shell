import QtQuick
import Quickshell.Io
import qs.common

Pill {
  id: root
  required property list<string> command
  property double interval: 5000
  property alias process: process
  property alias timer: timer
  Process {
    id: process
    command: root.command
    stdout: StdioCollector {
      onStreamFinished: root.text = Util.flattenString(this.text)
    }
  }
  Timer {
    id: timer
    triggeredOnStart: true
    interval: root.interval
    running: true
    repeat: true
    onTriggered: process.running = true
  }
}
