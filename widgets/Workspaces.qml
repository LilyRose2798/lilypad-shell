pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets

Pill {
  id: root
  margins: 0
  required property ShellScreen screen
  readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)

  RowLayout {
    id: rows
    spacing: 0

    Repeater {
      id: repeater
      model: ScriptModel {
        objectProp: "id"
        values: Hyprland.workspaces.values.filter(ws => ws.monitor === monitor)
      }
      delegate: Item {
        id: item
        required property int index
        required property HyprlandWorkspace modelData
        readonly property bool isFirst: index === 0
        readonly property bool isLast: index === repeater.count - 1
        readonly property bool isFocused: modelData === Hyprland.focusedWorkspace
        readonly property bool isActive: modelData.active
        implicitWidth: rect.implicitWidth
        height: root.height

        WrapperRectangle {
          id: rect
          property int margin: item.isFocused ? 16 : 10
          leftMargin: margin
          rightMargin: margin
          height: root.height
          topLeftRadius: item.isFirst ? root.radius : 0
          bottomLeftRadius: item.isFirst ? root.radius : 0
          topRightRadius: item.isLast ? root.radius : 0
          bottomRightRadius: item.isLast ? root.radius : 0
          color: item.isFocused ? "#488FCA" : item.isActive ? "#2A6A9E" : "#00000000"

          Behavior on margin {
            NumberAnimation {
              duration: 100
            }
          }

          Text {
            anchors.fill: rect
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: item.isFocused ? "#ffffff" : "#aaaaaa"
            font.family: "monospace"
            text: item.modelData.name
          }
        }

        MouseArea {
          anchors.fill: item
          cursorShape: Qt.PointingHandCursor
          onClicked: item.modelData.activate()
        }
      }
    }
  }
}
