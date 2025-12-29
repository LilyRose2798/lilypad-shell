pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland

Pill {
  id: root
  horizontalMargin: 0
  rows.spacing: 0
  required property ShellScreen screen
  readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)

  Repeater {
    id: repeater
    model: ScriptModel {
      objectProp: "id"
      values: Hyprland.workspaces.values.filter(ws => ws.monitor === monitor)
    }
    delegate: Clickable {
      id: item
      required property int index
      required property HyprlandWorkspace modelData
      readonly property bool isFirst: index === 0
      readonly property bool isLast: index === repeater.count - 1
      readonly property bool isFocused: modelData === Hyprland.focusedWorkspace
      readonly property bool isActive: modelData.active
      onClicked: modelData.activate()

      Pill {
        horizontalMargin: item.isFocused ? 20 : 10
        color: item.isFocused ? "#488FCA" : item.isActive ? "#2A6A9E" : "#00000000"

        PillText {
          active: item.isActive || item.modelData.toplevels.values.length > 0
          text: item.modelData.name
        }

        Behavior on horizontalMargin {
          NumberAnimation {
            duration: 100
          }
        }
      }
    }
  }
}
