import Quickshell
import Quickshell.Bluetooth

Pill {
  property BluetoothAdapter adapter: Bluetooth.defaultAdapter
  icon: !adapter.enabled ? "󰂲" : adapter.discoverable ? "󰂱" : "󰂯"
  text: adapter.devices.values.filter(d => d.connected).length || ""
  onLeftClick: Quickshell.execDetached(["foot", "bluetui"])
  onMiddleClick: adapter.discoverable = !adapter.discoverable
}
