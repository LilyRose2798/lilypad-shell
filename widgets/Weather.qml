import QtQuick
import qs.common

Pill {
  id: root
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
      "Haze": isDay ? "󰼰" : "󰖑"
    }[weather]
  }

  function cloudIcon(isDay: bool, cloud: string): string {
    return {
      "-": "",
      "Clear": isDay ? "󰖙" : "󰖔",
      "Mostly clear": isDay ? "󰖙" : "󰖔",
      "Partly cloudy": isDay ? "󰖕" : "󰼱",
      "Cloudy": "󰖐"
    }[cloud]
  }

  function formatDateTime(dateTime: string): string {
    return `${dateTime.slice(8, 10)}:${dateTime.slice(10, 12)} ${dateTime.slice(6, 8)}/${dateTime.slice(4, 6)}/${dateTime.slice(0, 4)}`
  }

  function handleResponse(res: var) {
    if (res.status !== 200)
      return
    const {
      name: stationName,
      local_date_time_full: dateTime,
      air_temp: airTemp,
      apparent_t: apparentTemp,
      rel_hum: humidity,
      wind_spd_kmh: windSpeedKmh,
      wind_spd_kt: windSpeedKnots,
      wind_dir: windDir,
      weather: weather,
      cloud: cloud
    } = res.json().observations.data[0]
    const windSpeedIcon = root.windSpeedIcon(windSpeedKnots)
    const windDirIcon = root.windDirIcon(windDir)
    const isDay = root.isDay(dateTime)
    const weatherIcon = root.weatherIcon(isDay, weather)
    const cloudIcon = root.cloudIcon(isDay, cloud)
    const icons = [windSpeedIcon, windDirIcon, weatherIcon, cloudIcon].filter(x => x).join(" ")
    root.text = `󰔏 ${airTemp}°C (${apparentTemp}°C)  ${humidity}% ${icons}`
    root.tooltip = `Station Name:\t${stationName}
Obs. Date/Time:\t${root.formatDateTime(dateTime)}
Temperature:\t${airTemp}°C
Feels Like:\t${apparentTemp}°C
Humidity:\t${humidity}%
Wind:\t\t${windSpeedKmh}km/h (${windSpeedKnots}kts) ${windDir}
Weather:\t\t${weather}
Cloud Cover:\t${cloud}`
  }

  Timer {
    id: timer
    triggeredOnStart: true
    running: true
    repeat: true
    interval: 1800000
    onTriggered: Util.httpGet(root.url, root.handleResponse)
  }
}
