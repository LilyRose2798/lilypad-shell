pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Wayland
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

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      Hyprland.refreshToplevels()
    }
  }

  Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
      id: bar
      required property ShellScreen modelData
      screen: modelData
      readonly property int screenType: ScreenType.get(screen)
      readonly property bool isOnTop: ScreenType.isOnTop(screenType)
      anchors {
        top: isOnTop
        bottom: !isOnTop
        left: true
        right: true
      }
      implicitHeight: Style.barHeight
      color: Style.barBgColor
      aboveWindows: false

      Component.onCompleted: {
        if (this.WlrLayershell != null)
          this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.OnDemand
      }

      Item {
        anchors.fill: parent
        anchors.leftMargin: Style.barHorizontalMargin
        anchors.rightMargin: Style.barHorizontalMargin

        RowLayout {
          spacing: Style.barSpacing
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter

          Loader {
            id: clock
            active: bar.screenType === ScreenType.Laptop || bar.screenType === ScreenType.Primary
            visible: active
            sourceComponent: Clock {
              screen: bar.screen
            }
          }

          Loader {
            id: mpris
            active: Mpris.players.values.length > 0 && bar.screenType === ScreenType.Laptop || bar.screenType === ScreenType.Primary
            visible: active
            sourceComponent: Mpris {
              screen: bar.screen
            }
          }

          Loader {
            id: weather
            active: bar.screenType === ScreenType.Tertiary
            visible: active
            sourceComponent: Weather {
              screen: bar.screen
            }
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

          Loader {
            id: tray
            active: bar.screenType === ScreenType.Laptop || bar.screenType === ScreenType.Primary
            visible: active
            sourceComponent: Tray {
              screen: bar.screen
            }
          }

          Pill {
            spacing: 0
            horizontalMargin: 0
            clickable: false
            screen: bar.screen

            Loader {
              id: battery
              active: UPower.devices.values.find(d => d.isLaptopBattery) !== null && bar.screenType === ScreenType.Laptop
              visible: active
              sourceComponent: Battery {
                screen: bar.screen
              }
            }

            Divider {
              visible: battery.active
              vertical: true
            }

            Loader {
              id: audio
              active: Pipewire.defaultAudioSink !== null && bar.screenType === ScreenType.Laptop || bar.screenType === ScreenType.Primary
              visible: active
              sourceComponent: Audio {
                screen: bar.screen
              }
            }

            Divider {
              visible: audio.active
              vertical: true
            }

            Loader {
              id: bluetooth
              active: bar.screenType === ScreenType.Laptop || bar.screenType === ScreenType.Primary
              visible: active
              sourceComponent: Bluetooth {
                screen: bar.screen
              }
            }

            Divider {
              visible: bluetooth.active
              vertical: true
            }

            Loader {
              active: bar.screenType === ScreenType.Laptop || bar.screenType === ScreenType.Primary
              visible: active
              sourceComponent: Network {
                screen: bar.screen
              }
            }
          }
        }
      }
    }
  }
}
