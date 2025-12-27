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
      implicitHeight: 32
      color: "#202035"

      Item {
        anchors.fill: parent
        anchors.margins: 10

        RowLayout {
          spacing: 10
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter

          Loader {
            active: bar.screenType === ScreenType.Laptop || bar.screenType === ScreenType.Primary
            sourceComponent: Clock {}
          }
        }

        RowLayout {
          spacing: 10
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter

          Workspaces {
            screen: bar.screen
          }
        }

        RowLayout {
          spacing: 10
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter

          Text {
            color: "#ffffff"
            font.family: "monospace"
            text: "Bar Right"
          }
        }
      }
    }
  }
}
