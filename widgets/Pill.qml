import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.common

WrapperRectangle {
  id: root
  default property alias data: rows.data
  property alias rows: rows
  implicitHeight: Style.pillHeight
  property double horizontalMargin: Style.pillMargin
  property double verticalMargin: (implicitHeight - rows.implicitHeight) / 2
  property bool roundLeft: true
  property bool roundRight: true
  radius: implicitHeight / 2
  topLeftRadius: roundLeft ? radius : 0
  bottomLeftRadius: roundLeft ? radius : 0
  topRightRadius: roundRight ? radius : 0
  bottomRightRadius: roundRight ? radius : 0
  leftMargin: root.horizontalMargin
  rightMargin: root.horizontalMargin
  topMargin: root.verticalMargin
  bottomMargin: root.verticalMargin
  color: Style.pillBgColor

  RowLayout {
    id: rows
    spacing: Style.pillSpacing
  }
}
