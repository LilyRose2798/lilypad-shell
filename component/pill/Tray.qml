pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.common
import qs.component.common

Pill {
  id: root
  horizontalMargin: 6
  spacing: 0
  clickable: false
  property Item item: null
  property ObjectModel entries: null

  Repeater {
    model: ScriptModel {
      objectProp: "id"
      values: [...SystemTray.items.values].sort((a, b) => a.tooltipTitle.localeCompare(b.tooltipTitle))
    }
    delegate: Pill {
      id: item
      screen: root.screen
      horizontalMargin: 6
      required property SystemTrayItem modelData
      tooltip: modelData?.tooltipTitle
      onLeftClick: modelData?.activate()
      onRightClick: {
        root.item = item
        root.entries = menuOpener.children
      }
      onMiddleClick: modelData?.secondaryActivate()
      onWheel: wheel => {
        if (wheel.angleDelta.x !== 0)
          modelData?.scroll(wheel.angleDelta.x, true)
        else if (wheel.angleDelta.y !== 0)
          modelData?.scroll(wheel.angleDelta.y, false)
      }

      IconImage {
        source: item.modelData?.icon ?? Quickshell.iconPath("image-missing-symbolic")
        implicitSize: Style.trayIconSize
      }

      QsMenuOpener {
        id: menuOpener
        menu: item.modelData?.menu
      }
    }
  }

  LazyLoader {
    active: root.entries !== null

    FullscreenWindow {
      onClicked: root.entries = null
      onClosed: root.entries = null

      TrayMenu {
        id: tray
        target: root.item
        above: !root.isOnTop
        entries: root.entries
        onClosed: root.entries = null
      }
    }
  }
}
