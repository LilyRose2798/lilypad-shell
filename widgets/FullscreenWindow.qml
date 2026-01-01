import QtQml
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.common

PanelWindow {
  id: root
  anchors.top: true
  anchors.bottom: true
  anchors.left: true
  anchors.right: true
  visible: true
  exclusionMode: ExclusionMode.Ignore
  color: Style.transparent
  signal clicked(MouseEvent e)

  Component.onCompleted: {
    if (this.WlrLayershell != null)
      this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.OnDemand
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.AllButtons
    onClicked: e => root.clicked(e)
  }
}
