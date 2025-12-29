import QtQuick
import qs.common

Text {
  property bool active: true
  property string icon
  property string value: ""
  color: active ? Style.textPrimaryColor : Style.textInactiveColor
  font.family: Style.fontFamily
  font.pointSize: Style.fontSize
  text: icon ? `${icon} ${value}` : value
}
