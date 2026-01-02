import qs.component.common

HardwareStats {
  id: root
  name: "gpu"

  RepeatedCommand {
    command: ["nvidia-smi", "--query-gpu", ["utilization.gpu", "temperature.gpu", "power.draw", "memory.used", "memory.total"].join(","), "--format", ["csv", "noheader", "nounits"].join(",")]
    onFinished: output => {
      const [usagePct, tempC, powerW, memoryUsedMiB, memoryTotalMiB] = output.split(", ").map(Number)
      root.usagePercent = usagePct
      root.temperatureC = tempC
      root.powerWatts = powerW
      root.memoryUsedGiB = memoryUsedMiB / 1024
      root.memoryTotalGiB = memoryTotalMiB / 1024
    }
  }
}
