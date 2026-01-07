import QtQml
import QtQuick
import Quickshell
import qs.common

PanelWindow {
  id: root
  anchors.top: true
  anchors.bottom: true
  anchors.left: true
  anchors.right: true
  visible: true
  focusable: true
  exclusionMode: ExclusionMode.Ignore
  color: Style.transparent
  signal clicked(MouseEvent e)
  property alias mouse: mouse
  signal closed

  MouseArea {
    id: mouse
    anchors.fill: parent
    acceptedButtons: Qt.AllButtons
    onClicked: e => root.clicked(e)
    focus: true
    Keys.onEscapePressed: root.closed()
  }
}
