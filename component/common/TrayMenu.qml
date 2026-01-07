pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.common

Popup {
  id: root
  verticalMargin: Style.menuVerticalMargin
  horizontalMargin: Style.menuHorizontalMargin
  radius: Style.menuRadius
  bgColor: Style.menuBgColor
  required property ObjectModel entries
  property list<ObjectModel> parentEntries: []

  function back() {
    const [first, ...rest] = parentEntries
    parentEntries = rest
    entries = first
  }

  function forward(newEntries: ObjectModel) {
    parentEntries = [entries, ...parentEntries]
    entries = newEntries
  }

  ColumnLayout {
    spacing: Style.menuItemSpacing

    Loader {
      sourceComponent: root.parentEntries.length > 0 ? backComponent : undefined
      visible: sourceComponent
      Layout.fillWidth: true

      Component {
        id: backComponent

        WrapperMouseArea {
          acceptedButtons: Qt.LeftButton
          cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
          hoverEnabled: true
          onClicked: root.back()
          onEntered: {
            textRect.color = Style.menuHoverBgColor
            hoverTimer.start()
          }
          onExited: {
            textRect.color = Style.transparent
            hoverTimer.stop()
          }

          Timer {
            id: hoverTimer
            interval: Style.tooltipDelay
            onTriggered: root.back()
          }

          WrapperRectangle {
            id: textRect
            color: Style.transparent
            leftMargin: Style.menuItemHorizontalMargin
            rightMargin: Style.menuItemHorizontalMargin
            topMargin: Style.menuItemVerticalMargin
            bottomMargin: Style.menuItemVerticalMargin
            radius: Style.menuItemRadius

            RowLayout {
              spacing: Style.menuItemIconSpacing

              LText {
                mono: root.mono
                icon: "󰅁"
                verticalAlignment: Text.AlignVCenter
              }

              LText {
                mono: root.mono
                value: "Back"
                verticalAlignment: Text.AlignVCenter
                Layout.fillWidth: true
              }
            }
          }
        }
      }
    }

    Repeater {
      model: ScriptModel {
        objectProp: "id"
        values: root.entries?.values.filter(e => e !== null) ?? []
      }
      delegate: Loader {
        id: entry
        required property int index
        required property QsMenuEntry modelData
        sourceComponent: entry.modelData.isSeparator ? separatorComponent : textComponent
        Layout.fillWidth: true

        Component {
          id: textComponent

          WrapperMouseArea {
            enabled: !!entry.modelData.enabled
            acceptedButtons: Qt.LeftButton
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            hoverEnabled: enabled
            onClicked: {
              entry.modelData.triggered()
              if (entry.modelData.hasChildren)
                root.forward(menuOpener.children)
              else
                root.closed()
            }
            onEntered: {
              textRect.color = Style.menuHoverBgColor
              if (entry.modelData.hasChildren)
                hoverTimer.start()
            }
            onExited: {
              textRect.color = Style.transparent
              hoverTimer.stop()
            }

            QsMenuOpener {
              id: menuOpener
              menu: entry.modelData
            }

            Timer {
              id: hoverTimer
              interval: Style.tooltipDelay
              onTriggered: root.forward(menuOpener.children)
            }

            WrapperRectangle {
              id: textRect
              color: Style.transparent
              leftMargin: Style.menuItemHorizontalMargin
              rightMargin: Style.menuItemHorizontalMargin
              topMargin: Style.menuItemVerticalMargin
              bottomMargin: Style.menuItemVerticalMargin
              radius: Style.menuItemRadius

              RowLayout {
                spacing: Style.menuItemIconSpacing

                LText {
                  mono: root.mono
                  text: entry.modelData.text ?? ""
                  color: entry.modelData.enabled ? Style.textPrimaryColor : entry.index === 0 ? Style.trayTitleColor : Style.textInactiveColor
                  verticalAlignment: Text.AlignVCenter
                  Layout.fillWidth: true
                }

                Loader {
                  id: iconLoader
                  sourceComponent: entry.modelData.icon !== "" ? imageIcon : entry.modelData.hasChildren ? arrowIcon : entry.modelData.buttonType !== QsMenuButtonType.None ? buttonIcon : undefined
                  visible: sourceComponent

                  Component {
                    id: imageIcon
                    IconImage {
                      source: entry.modelData.icon
                      implicitSize: Style.trayIconSize
                    }
                  }

                  Component {
                    id: arrowIcon
                    LText {
                      mono: root.mono
                      icon: "󰅂"
                    }
                  }

                  Component {
                    id: buttonIcon
                    LText {
                      mono: root.mono
                      icon: ({
                          [QsMenuButtonType.CheckBox]: entry.modelData.checkState === Qt.Unchecked ? "󰄱" : "󰄲",
                          [QsMenuButtonType.RadioButton]: entry.modelData.checkState === Qt.Unchecked ? "󰄰" : "󰐾"
                        })[entry.modelData.buttonType]
                    }
                  }
                }
              }
            }
          }
        }

        Component {
          id: separatorComponent
          WrapperItem {
            id: item
            topMargin: Style.menuSeparatorVerticalMargin
            bottomMargin: Style.menuSeparatorVerticalMargin
            Divider {}
          }
        }
      }
    }
  }
}
