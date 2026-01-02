import QtQuick
import QtQuick.Layouts
import qs.common

Rectangle {
  property bool vertical: false
  implicitHeight: vertical ? null : Style.dividerSize
  implicitWidth: vertical ? Style.dividerSize : null
  Layout.fillWidth: !vertical
  Layout.fillHeight: vertical
  color: Style.dividerColor
  antialiasing: true
}
