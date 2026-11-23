pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.common

Pill {
  id: root
  horizontalMargin: 0
  spacing: 0
  clickable: false
  readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)

  Repeater {
    model: ScriptModel {
      objectProp: "id"
      values: Hyprland.workspaces.values.filter(ws => ws.monitor == root.monitor)
    }
    delegate: Pill {
      id: item
      screen: root.screen
      required property HyprlandWorkspace modelData
      readonly property list<HyprlandToplevel> toplevels: modelData.toplevels.values
      readonly property bool isActive: root.monitor.activeWorkspace.id == modelData.id
      text: modelData.name
      tooltip: toplevels.length === 0 ? "No Windows" : `${toplevels.length} Window${toplevels.length === 1 ? "" : "s"}:
${toplevels.map(w => w.lastIpcObject).filter(w => w !== null).map(w => `${w.title} [${w.class}]`).join("\n")}`
      tooltipDelay: Style.workspacesTooltipDelay
      txt.active: modelData.active || toplevels.length > 0
      onLeftClick: {
        if (!item.isActive)
          Hyprland.dispatch("hl.dsp.focus({ workspace = " + modelData.id + " })")
      }
      clickable: true
      horizontalMargin: item.isActive && root.monitor.focused ? 20 : 10
      rect.color: modelData.urgent ? Style.workspacesUrgentColor : (item.isActive ? (root.monitor.focused ? Style.workspacesFocusedColor : Style.workspacesActiveColor) : Style.transparent)

      Behavior on horizontalMargin {
        NumberAnimation {
          duration: Style.workspacesAnimationSpeed
        }
      }
    }
  }
}
