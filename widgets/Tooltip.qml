pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.common

PopupWindow {
  id: root
  required property Item target
  required property string tooltip
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
    LText {
      id: txt
      mono: root.mono
      text: root.tooltip
    }
  }
}
