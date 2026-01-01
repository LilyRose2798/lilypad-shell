import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Pill {
  id: root
  property PwNode source: Pipewire.defaultAudioSource
  property PwNode sink: Pipewire.defaultAudioSink
  icon: !sink?.ready ? "" : sink.audio.muted ? "󰖁" : sink.audio.volume < 0.005 ? "󰝟" : sink.audio.volume < 0.295 ? "󰕿" : sink.audio.volume < 0.595 ? "󰖀" : "󰕾"
  text: !sink?.ready || isNaN(sink.audio.volume) ? "" : (100 * sink.audio.volume).toFixed(0)
  onLeftClick: Quickshell.execDetached(["pwvucontrol"])
  onMiddleClick: {
    if (sink?.ready)
      sink.audio.muted = !sink.audio.muted
  }
  onWheel: wheel => {
    if (sink?.ready)
      sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume + 0.0002 * (wheel.angleDelta.y - wheel.angleDelta.x)))
  }
  PwObjectTracker {
    objects: [root.source, root.sink]
  }
}
