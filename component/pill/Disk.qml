import qs.component.common

Pill {
  id: root
  required property string path
  required property string name
  icon: "󰋊"
  prefix: `${name} `
  monoTooltip: true

  RepeatedCommand {
    interval: 60000
    command: ["df", root.path]
    onFinished: output => {
      const [filesystem, total, used, available, pct, path] = output.split("\n")[1].split(/\s+/)
      const usedTxt = (used / 1073741824).toFixed(2)
      const availableTxt = (available / 1073741824).toFixed(2)
      const totalTxt = (total / 1073741824).toFixed(2)
      root.text = `${usedTxt}/${totalTxt}TiB (${pct})`
      root.tooltip = `Filesystem: ${filesystem}
Mount path: ${path}
Used:       ${usedTxt}TiB
Available:  ${availableTxt}TiB
Total:      ${totalTxt}TiB`
    }
  }
}
