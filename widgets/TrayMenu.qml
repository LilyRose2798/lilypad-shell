pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.common

PopupWindow {
  id: root
  required property Item target
  required property ObjectModel entries
  required property bool above
  property bool mono: false
  property list<ObjectModel> parentEntries: []
  signal closed
  visible: true
  anchor.item: target
  anchor.rect.x: -rect.implicitWidth / 2 + target.implicitWidth / 2
  anchor.rect.y: above ? -rect.implicitHeight - Style.barPopupOffset : target.implicitHeight + Style.barPopupOffset
  implicitWidth: rect.implicitWidth
  implicitHeight: rect.implicitHeight
  color: Style.transparent

  Component.onCompleted: {
    if (this.WlrLayershell != null)
    this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.OnDemand
  }

  WrapperRectangle {
    id: rect
    leftMargin: Style.menuHorizontalMargin
    rightMargin: Style.menuHorizontalMargin
    topMargin: Style.menuVerticalMargin
    bottomMargin: Style.menuVerticalMargin
    color: Style.pillBgColor
    radius: Style.menuRadius

    ColumnLayout {
      id: column
      spacing: 0

      Loader {
        visible: root.parentEntries.length > 0
        sourceComponent: visible ? backComponent : undefined

        Component {
          id: backComponent

          Rectangle {
            id: textRect
            implicitWidth: Style.menuItemWidth
            implicitHeight: Style.menuItemHeight
            color: Style.transparent
            radius: Style.menuItemRadius

            LText {
              mono: root.mono
              icon: "󰅁 "
              value: "Back"
              anchors.fill: textRect
              anchors.leftMargin: Style.menuHorizontalMargin
              anchors.rightMargin: Style.menuHorizontalMargin
              verticalAlignment: Text.AlignVCenter
            }

            Timer {
              id: hoverTimer
              interval: Style.tooltipDelay
              onTriggered: {
                const [first, ...rest] = root.parentEntries
                root.parentEntries = rest
                root.entries = first
              }
            }

            MouseArea {
              anchors.fill: textRect
              acceptedButtons: Qt.LeftButton
              cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
              hoverEnabled: true
              onClicked: {
                const [first, ...rest] = root.parentEntries
                root.parentEntries = rest
                root.entries = first
              }
              onEntered: {
                textRect.color = Style.menuHoverBgColor
                hoverTimer.start()
              }
              onExited: {
                textRect.color = Style.transparent
                hoverTimer.stop()
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

          Component {
            id: textComponent

            Rectangle {
              id: textRect
              color: Style.transparent
              radius: Style.menuItemRadius
              implicitWidth: Style.menuItemWidth
              implicitHeight: Style.menuItemHeight

              LText {
                mono: root.mono
                text: entry.modelData.text ?? ""
                color: entry.modelData.enabled ? Style.textPrimaryColor : entry.index === 0 ? Style.trayTitleColor :
                                                                                              Style.textInactiveColor
                anchors.fill: textRect
                anchors.leftMargin: Style.menuHorizontalMargin
                anchors.rightMargin: iconLoader.implicitWidth === 0 ? Style.menuHorizontalMargin : 2
                                                                      * Style.menuHorizontalMargin
                                                                      + iconLoader.implicitWidth
                verticalAlignment: Text.AlignVCenter
              }

              Loader {
                id: iconLoader
                sourceComponent: entry.modelData.icon !== "" ? imageIcon : textIcon
                anchors.right: textRect.right
                anchors.rightMargin: Style.menuHorizontalMargin
                anchors.verticalCenter: textRect.verticalCenter

                Component {
                  id: imageIcon

                  IconImage {
                    source: entry.modelData.icon
                    implicitSize: Style.trayIconSize
                  }
                }

                Component {
                  id: textIcon

                  LText {
                    icon: entry.modelData.hasChildren ? "󰅂" : {
                                                          [QsMenuButtonType.None]: "",
                                                          [QsMenuButtonType.CheckBox]: entry.modelData.checkState
                                                                                       === Qt.Unchecked ? "󰄱" : "󰄲",
                                                          [QsMenuButtonType.RadioButton]: entry.modelData.checkState
                                                                                          === Qt.Unchecked ? "󰄰" : "󰐾"
                                                        }[entry.modelData.buttonType]
                  }
                }
              }

              QsMenuOpener {
                id: menuOpener
                menu: entry.modelData
              }

              Timer {
                id: hoverTimer
                interval: Style.tooltipDelay
                onTriggered: {
                  root.parentEntries = [root.entries, ...root.parentEntries]
                  root.entries = menuOpener.children
                }
              }

              MouseArea {
                enabled: !!entry.modelData.enabled
                anchors.fill: textRect
                acceptedButtons: Qt.LeftButton
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                hoverEnabled: true
                onClicked: {
                  entry.modelData.triggered()
                  if (entry.modelData.hasChildren) {
                    root.parentEntries = [root.entries, ...root.parentEntries]
                    root.entries = menuOpener.children
                  } else
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
              }
            }
          }

          Component {
            id: separatorComponent

            Item {
              id: item
              implicitWidth: Style.menuItemWidth
              implicitHeight: Style.menuSeparatorHeight

              Divider {
                implicitWidth: entry.implicitWidth
                anchors.verticalCenter: item.verticalCenter
              }
            }
          }
        }
      }
    }
  }
}
