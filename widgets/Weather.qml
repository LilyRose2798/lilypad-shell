import QtQuick
import qs.common

Pill {
  id: root
  icon: "󰖐"
  monoTooltip: true
  property string url: "https://reg.bom.gov.au/fwo/IDV60901/IDV60901.94866.json"

  function windSpeedIcon(windSpeed: double): string {
    if (windSpeed < 1)
      return ""
    if (windSpeed < 4)
      return ""
    if (windSpeed < 7)
      return ""
    if (windSpeed < 11)
      return ""
    if (windSpeed < 17)
      return ""
    if (windSpeed < 22)
      return ""
    if (windSpeed < 28)
      return ""
    if (windSpeed < 34)
      return ""
    if (windSpeed < 41)
      return ""
    if (windSpeed < 48)
      return ""
    if (windSpeed < 56)
      return ""
    if (windSpeed < 64)
      return ""
    return ""
  }

  function windDirIcon(windDir: string): string {
    return {
      "N": "",
      "NNE": "",
      "NE": "",
      "ENE": "",
      "E": "",
      "ESE": "",
      "SE": "",
      "SSE": "",
      "S": "",
      "SSW": "",
      "SW": "",
      "WSW": "",
      "W": "",
      "WNW": "",
      "NW": "",
      "NNW": ""
    }[windDir]
  }

  function isDay(dateTime: string): bool {
    const hour = dateTime.slice(8, 10)
    return hour >= 6 && hour < 19
  }

  function weatherIcon(isDay: bool, weather: string): string {
    return {
      "-": "",
      "Fine": "",
      "Haze": isDay ? " 󰼰" : " 󰖑"
    }[weather]
  }

  function cloudIcon(isDay: bool, cloud: string): string {
    return {
      "-": "",
      "Clear": isDay ? " 󰖙" : " 󰖔",
      "Mostly clear": isDay ? " 󰖙" : " 󰖔",
      "Partly cloudy": isDay ? " 󰖕" : " 󰼱",
      "Cloudy": " 󰖐"
    }[cloud]
  }

  function formatDateTime(dateTime: string): string {
    return `${dateTime.slice(8, 10)}:${dateTime.slice(10, 12)} ${dateTime.slice(6, 8)}/${dateTime.slice(4, 6)}/${dateTime.slice(0, 4)}`
  }

  Timer {
    id: timer
    triggeredOnStart: true
    running: true
    repeat: true
    interval: 1800000
    onTriggered: {
      Util.httpGet(root.url, res => {
        const data = res.json().observations.data[0]
        const isDay = root.isDay(data.local_date_time_full)
        root.text = `󰔏 ${data.air_temp}°C (${data.apparent_t}°C)  ${data.rel_hum}% ${root.windSpeedIcon(data.wind_spd_kt)} ${root.windDirIcon(data.wind_dir)} ${root.weatherIcon(isDay, data.weather)} ${root.cloudIcon(isDay, data.cloud)}`
        root.tooltip = `Station Name:\t${data.name}
Obs. Date/Time:\t${root.formatDateTime(data.local_date_time_full)}
Temperature:\t${data.air_temp}°C
Feels Like:\t${data.apparent_t}°C
Humidity:\t${data.rel_hum}%
Wind:\t\t${data.wind_spd_kmh}km/h (${data.wind_spd_kt}kts) ${data.wind_dir}
Weather:\t\t${data.weather}
Cloud Cover:\t${data.cloud}`
      })
    }
  }
}
