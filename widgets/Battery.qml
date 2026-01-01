import Quickshell.Services.UPower
import qs.common

Pill {
  property UPowerDevice battery: UPower.devices.values.find(d => d.isLaptopBattery)
  property bool isIdle: battery.changeRate === 0
  property int chargeState: Math.floor(10 * battery.percentage)
  icon: ({
           [UPowerDeviceState.Charging]: ["󰢟", "󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"][chargeState],
           [UPowerDeviceState.Discharging]: ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂",
             "󰁹"][chargeState],
           [UPowerDeviceState.FullyCharged]: "󰁹",
           [UPowerDeviceState.Empty]: "󰂎",
           [UPowerDeviceState.PendingCharge]: "󰂐",
           [UPowerDeviceState.PendingDischarge]: "󰂍",
           [UPowerDeviceState.Unknown]: "󰂑"
         })[battery.state]
  text: `${(100 * battery.percentage).toFixed(0)}%`
  tooltip: `${{
             [UPowerDeviceState.Charging]: isIdle ? "Battery is idle" : `Time until full: ${Time.humanDuration(
                                                      battery.timeToFull)}
Charging rate: ${battery.changeRate.toFixed(2)}W`,
             [UPowerDeviceState.Discharging]: isIdle ? "Battery is idle" : `Time left: ${Time.humanDuration(
                                                         battery.timeToEmpty)}
Discharging rate: ${battery.changeRate.toFixed(2)}W`,
             [UPowerDeviceState.FullyCharged]: "Fully charged",
             [UPowerDeviceState.Empty]: "Battery is empty",
             [UPowerDeviceState.PendingCharge]: "Starting to charge",
             [UPowerDeviceState.PendingDischarge]: "Starting to discharge",
             [UPowerDeviceState.Unknown]: "Unknown battery state"
           }[battery.state]}
Health: ${battery.healthPercentage.toFixed(2)}%`
}
