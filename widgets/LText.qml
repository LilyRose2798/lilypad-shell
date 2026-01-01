import QtQuick
import qs.common

Text {
  property bool active: true
  property string icon
  property string value: ""
  property bool mono: false
  property bool multiline: false
  color: active ? Style.textPrimaryColor : Style.textInactiveColor
  font.family: mono ? Style.monospaceFont : Style.sansSerifFont
  font.pointSize: Style.fontSize
  text: icon ? `${icon} ${value}` : value
  maximumLineCount: multiline ? undefined : 1
  wrapMode: multiline ? Text.Wrap : Text.NoWrap
  clip: true
}
