pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.common

PopupWindow {
  id: root
  required property Item target
  required property string tooltip
  required property bool above
  property bool mono: false
  anchor.item: target
  anchor.edges: above ? Edges.Top : Edges.Bottom
  anchor.gravity: above ? Edges.Top : Edges.Bottom
  anchor.adjustment: PopupAdjustment.SlideX
  anchor.margins.bottom: -Style.barPopupOffset
  anchor.margins.top: -Style.barPopupOffset
  implicitWidth: rect.implicitWidth
  implicitHeight: rect.implicitHeight
  color: Style.transparent
  visible: true

  Component.onCompleted: {
    if (this.WlrLayershell != null)
      this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.OnDemand
  }

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
      multiline: true
    }
  }
}
