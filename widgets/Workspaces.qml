pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland

Pill {
  horizontalMargin: 0
  spacing: 0
  clickable: false
  required property ShellScreen screen
  readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)

  Repeater {
    model: ScriptModel {
      objectProp: "id"
      values: Hyprland.workspaces.values.filter(ws => ws.monitor === monitor)
    }
    delegate: Pill {
      id: item
      required property int index
      required property HyprlandWorkspace modelData
      readonly property list<HyprlandToplevel> toplevels: modelData.toplevels.values
      text: modelData.name
      tooltip: toplevels.length === 0 ? "No Windows" : `${toplevels.length} Window${toplevels.length === 1 ? "" : "s"}:
${toplevels.map(w => w.title).join("\n")}`
      txt.active: modelData.active || modelData.toplevels.values.length > 0
      onLeftClick: modelData.activate()
      clickable: true
      horizontalMargin: modelData === Hyprland.focusedWorkspace ? 20 : 10
      rect.color: modelData.urgent ? "#bb4e68" : modelData === Hyprland.focusedWorkspace ? "#488FCA" : modelData.active
                                                                                           ? "#2A6A9E" : "#00000000"

      Behavior on horizontalMargin {
        NumberAnimation {
          duration: 100
        }
      }
    }
  }
}
