import QtQuick
import qs.common

Pill {
  Text {
    id: text
    color: "#ffffff"
    font.family: "monospace"
    text: Time.nowTimeString()
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    Timer {
      interval: 1000
      running: true
      repeat: true
      onTriggered: parent.text = Time.nowTimeString()
    }
  }
}
