pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import Quickshell.Widgets
import qs.common

Pill {
  id: root
  horizontalMargin: 6
  spacing: 0
  clickable: false
  required property ShellScreen screen
  readonly property double menuOffset: ScreenType.isOnTop(ScreenType.get(screen)) ? Style.pillHeight
                                                                                    + Style.barPopupOffset :
                                                                                    -Style.barPopupOffset

  Repeater {
    model: ScriptModel {
      objectProp: "id"
      values: [...SystemTray.items.values]
    }
    delegate: Pill {
      id: item
      horizontalMargin: 6
      required property SystemTrayItem modelData
      tooltip: modelData.tooltipTitle
      onLeftClick: modelData.activate()
      onRightClick: menuOpener.menu = modelData.menu
      onMiddleClick: modelData.secondaryActivate()
      onWheel: wheel => {
        if (wheel.angleDelta.x !== 0)
        modelData.scroll(wheel.angleDelta.x, true)
        else if (wheel.angleDelta.y !== 0)
        modelData.scroll(wheel.angleDelta.y, false)
      }

      IconImage {
        source: item.modelData.icon
        implicitSize: Style.trayIconSize
      }
    }
  }

  QsMenuOpener {
    id: menuOpener
  }

  Loader {
    active: menuOpener.children.values.length
    sourceComponent: PanelWindow {
      anchors.top: true
      anchors.bottom: true
      anchors.left: true
      anchors.right: true
      visible: true
      WlrLayershell.layer: WlrLayer.Top
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
      WlrLayershell.exclusionMode: ExclusionMode.Ignore
      color: Style.transparent

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onClicked: menuOpener.menu = null
      }

      TrayMenu {
        id: tray
        target: root
        entries: menuOpener.children.values
        menuOpener: menuOpener
      }
    }
  }
}
