pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Widgets

Pill {
  id: root
  property BluetoothAdapter adapter: Bluetooth.defaultAdapter
  readonly property list<BluetoothDevice> connectedDevices: adapter?.devices?.values?.filter(d => d.connected) ?? []
  icon: !adapter?.enabled ? "󰂲" : adapter?.discoverable ? "󰂱" : "󰂯"
  tooltip: connectedDevices.map(d => `${d.name} (${d.address})${d.batteryAvailable ? `  󰥉 ${(100 * d.battery).toFixed(0)}%` : ""}`).join("\n") || "No devices connected"
  onLeftClick: Quickshell.execDetached(["foot", "bluetui"])
  onMiddleClick: {
    if (adapter !== null)
      adapter.discoverable = !adapter.discoverable
  }
  spacing: 6

  Repeater {
    model: adapter?.devices?.values?.filter(d => d.connected)
    delegate: IconImage {
      required property BluetoothDevice modelData
      source: Quickshell.iconPath(modelData.icon)
      implicitSize: 16
    }
  }
}
