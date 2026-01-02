import qs.common
import qs.component.common

HardwareStats {
  id: root
  name: "cpu"
  property var prevUsageStats: null

  function getUsage(prev: var, cur: var): double {
    const total = (cur.idle + cur.nonIdle) - (prev.idle + prev.nonIdle)
    return (total - (cur.idle - prev.idle)) / total
  }

  RepeatedCommand {
    command: ["cat", "/proc/stat"]
    onFinished: output => {
      const [all, ...cores] = output.split("\n").filter(line => line.startsWith("cpu")).map(line => line.split(/\s+/)).map(([name, ...values]) => {
        const number = name === "cpu" ? 0 : (parseInt(name.slice(3)) + 1)
        const [user, nice, system, idle_, ioWait, irq, softIrq, steal, guest, guestNice] = values.map(Number)
        const idle = idle_ + ioWait
        const nonIdle = user + nice + system + irq + softIrq + steal
        return {
          number,
          idle,
          nonIdle
        }
      }).sort((a, b) => a.number - b.number)
      if (root.prevUsageStats !== null) {
        root.usagePercent = 100 * root.getUsage(root.prevUsageStats.all, all)
        root.usageTooltip = cores.map((core, i) => `${Util.zeroPad(core.number, 2)}: ${Util.zeroPad((100 * root.getUsage(root.prevUsageStats.cores[i], core)).toFixed(0), 2)}%`).join("\n")
      }
      root.prevUsageStats = {
        all,
        cores
      }
    }
  }

  RepeatedCommand {
    command: ["cat", "/proc/meminfo"]
    onFinished: output => {
      const memInfo = {}
      for (const line of output.split("\n").filter(x => x)) {
        const [key, value] = line.split(/:\s+/)
        memInfo[key] = Number(value.split(" ")[0])
      }
      root.memoryTotalGiB = memInfo["MemTotal"] / 1048576
      root.memoryUsedGiB = root.memoryTotalGiB - memInfo["MemAvailable"] / 1048576
      root.memoryTooltip = output
    }
  }

  RepeatedCommand {
    command: ["sensors", "-j"]
    onFinished: output => {
      const zenpower = JSON.parse(output)["zenpower-pci-00c3"]
      root.temperatureC = Number(zenpower["Tdie"]["temp1_input"])
      root.powerWatts = Number(zenpower["SVI2_P_Core"]["power1_input"] + zenpower["SVI2_P_SoC"]["power2_input"])
      const tooltip = JSON.stringify(zenpower, null, 4)
      root.temperatureTooltip = tooltip
      root.powerTooltip = tooltip
    }
  }
}
