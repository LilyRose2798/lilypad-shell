import QtQuick
import Quickshell
import Quickshell.Io
import qs.common

Scope {
  id: root
  required property list<string> command
  property double interval: 5000
  property alias process: process
  property alias timer: timer
  property string output

  Process {
    id: process
    command: root.command
    stdout: StdioCollector {
      onStreamFinished: root.output = Util.flattenString(this.text)
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
