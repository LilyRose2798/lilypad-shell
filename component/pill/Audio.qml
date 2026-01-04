import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Pill {
  id: root
  property PwNode source: Pipewire.defaultAudioSource
  property PwNode sink: Pipewire.defaultAudioSink
  property int step: 1
  icon: !sink?.ready ? "󰖁" : sink.audio.muted ? "󰝟" : sink.audio.volume < 0.005 ? "󰕿" : sink.audio.volume < 0.495 ? "󰖀" : "󰕾"
  text: !sink?.ready ? "" : (100 * sink.audio.volume).toFixed(0)
  suffix: "%"
  tooltip: [!source?.ready ? "" : `${source.audio.muted ? "󰍭" : "󰍬"} ${(100 * source.audio.volume).toFixed(0)}%`, !sink?.ready ? "" : `${root.icon} ${(100 * sink.audio.volume).toFixed(0)}%`].filter(x => x !== "").join("\n")
  onLeftClick: Quickshell.execDetached(["pwvucontrol"])
  onMiddleClick: {
    if (sink?.ready)
      sink.audio.muted = !sink.audio.muted
  }
  onWheelUp: {
    if (sink?.ready)
      sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume + step / 100))
  }
  onWheelRight: {
    if (sink?.ready)
      sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume + step / 100))
  }
  onWheelDown: {
    if (sink?.ready)
      sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume - step / 100))
  }
  onWheelLeft: {
    if (sink?.ready)
      sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume - step / 100))
  }
  PwObjectTracker {
    objects: [root.source, root.sink]
  }
}
