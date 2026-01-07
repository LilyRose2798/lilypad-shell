pragma Singleton
import QtQml
import QtQuick
import Quickshell

Singleton {
  readonly property string monospaceFont: "Maple Mono NFP CN"
  readonly property string sansSerifFont: "Roboto"
  readonly property double fontSize: 11
  readonly property string textPrimaryColor: "#FFFFFF"
  readonly property string textInactiveColor: "#77FFFFFF"
  readonly property string barBgColor: "#202035"
  readonly property double barHeight: 32
  readonly property double barHorizontalMargin: 10
  readonly property double barSpacing: 10
  readonly property string pillBgColor: "#282C34"
  readonly property double pillFontSize: 10.5
  readonly property double pillHeight: 24
  readonly property double pillMargin: 12
  readonly property double pillSpacing: 10
  readonly property string dividerColor: "#22FFFFFF"
  readonly property double dividerSize: 1.5
  readonly property string transparent: "#00000000"
  readonly property double trayIconSize: 16
  readonly property string trayTitleColor: "#D9CEFF"
  readonly property string workspacesUrgentColor: "#BB4E68"
  readonly property string workspacesFocusedColor: "#488FCA"
  readonly property string workspacesActiveColor: "#2A6A9E"
  readonly property double workspacesAnimationSpeed: 100
  readonly property double workspacesTooltipDelay: 1000
  readonly property double popupHorizontalMargin: 8
  readonly property double popupVerticalMargin: 8
  readonly property double popupRadius: 10
  readonly property double popupOffset: 4
  readonly property string popupBgColor: pillBgColor
  readonly property double tooltipDelay: 500
  readonly property double tooltipHorizontalMargin: popupHorizontalMargin + 4
  readonly property double tooltipVerticalMargin: popupVerticalMargin
  readonly property double tooltipRadius: popupRadius + 4
  readonly property string tooltipBgColor: popupBgColor
  readonly property double menuHorizontalMargin: popupHorizontalMargin
  readonly property double menuVerticalMargin: popupVerticalMargin
  readonly property double menuRadius: popupRadius
  readonly property string menuBgColor: popupBgColor
  readonly property double menuItemSpacing: 0
  readonly property double menuItemHorizontalMargin: menuHorizontalMargin
  readonly property double menuItemVerticalMargin: menuVerticalMargin
  readonly property double menuItemRadius: menuRadius
  readonly property double menuItemIconSpacing: menuItemHorizontalMargin
  readonly property double menuSeparatorVerticalMargin: menuVerticalMargin / 2
  readonly property string menuHoverBgColor: "#22FFFFFF"
  readonly property color hexInactiveColor: Qt.color("#66FFE6")
  readonly property color hexActiveColor: Qt.color("#DEB8CC")
  readonly property color hexLineInnerColor: Qt.color("#B1E3FF")
  readonly property color hexLineOuterColor: Qt.color("#DD79D2FF")
  readonly property double hexFps: 30 // max of 60
  readonly property double hexNodeWidth: 6
  readonly property double hexVisibilityFactor: 2.5
  readonly property double hexGridWidth: 100
  readonly property double hexDrawTolerance: 20
  readonly property int hexLightningPoints: 9
}
