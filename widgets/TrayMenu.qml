pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.common

PopupWindow {
  id: root
  required property Item target
  required property list<QsMenuEntry> entries
  required property QsMenuOpener menuOpener
  property bool mono: false
  anchor.item: target
  property bool above: !ScreenType.isOnTop(ScreenType.get(screen))
  anchor.rect.x: -rect.implicitWidth / 2 + target.implicitWidth / 2
  anchor.rect.y: above ? -rect.implicitHeight - Style.barPopupOffset : target.implicitHeight + Style.barPopupOffset
  implicitWidth: rect.implicitWidth
  implicitHeight: rect.implicitHeight
  color: Style.transparent
  visible: true
  WrapperRectangle {
    id: rect
    leftMargin: Style.tooltipHorizontalMargin
    rightMargin: Style.tooltipHorizontalMargin
    topMargin: Style.tooltipVerticalMargin
    bottomMargin: Style.tooltipVerticalMargin
    color: Style.pillBgColor
    radius: Style.tooltipRadius
    ColumnLayout {
      id: column
      spacing: 0

      Repeater {
        model: root.entries
        delegate: Rectangle {
          id: entry
          required property int index
          required property QsMenuEntry modelData
          color: Style.transparent
          radius: 10
          implicitWidth: 200 // possibly calculate dynamically from text widths
          implicitHeight: entry.modelData.isSeparator ? 9.5 : 30

          Loader {
            active: !entry.modelData.isSeparator
            sourceComponent: WrapperMouseArea {
              enabled: entry.modelData.enabled
              implicitWidth: entry.implicitWidth
              implicitHeight: entry.implicitHeight
              acceptedButtons: Qt.LeftButton
              cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
              hoverEnabled: true
              onClicked: {
                root.menuOpener.menu = null
                entry.modelData.triggered()
              }
              onEntered: entry.color = "#44ffffff"
              onExited: entry.color = Style.transparent
              WrapperItem {
                leftMargin: 10
                rightMargin: 10
                LText {
                  mono: root.mono
                  text: entry.modelData.text
                  active: entry.modelData.enabled
                  width: entry.implicitWidth
                  height: entry.implicitHeight
                  verticalAlignment: Text.AlignVCenter
                  clip: true
                }
              }
            }
          }

          Loader {
            active: entry.modelData.isSeparator
            sourceComponent: WrapperItem {
              topMargin: 4
              bottomMargin: 4
              Divider {
                implicitWidth: entry.implicitWidth
              }
            }
          }
        }
      }
    }
  }
}
