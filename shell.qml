pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.widgets

ShellRoot {
  Component.onCompleted: {
    Logger.info("Lilypad Shell", "Hello from Lilypad Shell!")
  }

  Connections {
    target: Quickshell
    function onReloadCompleted() {
      Quickshell.inhibitReloadPopup()
    }
    function onReloadFailed() {
      if (!Settings?.isDebug)
        Quickshell.inhibitReloadPopup()
    }
  }

  Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
      id: bar
      required property ShellScreen modelData
      screen: modelData
      readonly property int screenType: ScreenType.get(screen)
      readonly property bool isOnTop: screenType === ScreenType.Secondary || screenType === ScreenType.Tertiary
      anchors {
        top: isOnTop
        bottom: !isOnTop
        left: true
        right: true
      }
      implicitHeight: Style.barHeight
      color: Style.barBgColor

      Item {
        anchors.fill: parent
        anchors.leftMargin: Style.barHorizontalMargin
        anchors.rightMargin: Style.barHorizontalMargin

        RowLayout {
          spacing: Style.barSpacing
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter

          Loader {
            active: bar.screenType === ScreenType.Laptop || bar.screenType === ScreenType.Primary
            sourceComponent: Clock {}
          }
        }

        RowLayout {
          spacing: Style.barSpacing
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter

          Workspaces {
            screen: bar.screen
          }
        }

        RowLayout {
          spacing: Style.barSpacing
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter

          Pill {
            CommandPillText {
              icon: "󰃭"
              command: ["date"]
            }
          }
        }
      }
    }
  }
}
