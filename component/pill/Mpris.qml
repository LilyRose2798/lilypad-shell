pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.common
import qs.component.common

Pill {
  id: root
  spacing: 8
  property int maxLength: 40

  function rankPlayer(player: MprisPlayer): int {
    const id = player.identity
    const base = player.isPlaying ? -1 : -100
    if (id.includes("mpd"))
      return base + 10
    if (id.includes("feishin"))
      return base + 8
    if (id.includes("spotify"))
      return base + 7
    if (id.includes("firefox"))
      return base + 6
    if (id.includes("chrome"))
      return base + 5
    return base
  }

  property MprisPlayer activePlayer: Mpris.players.values.sort((p, q) => rankPlayer(q) - rankPlayer(p))[0] ?? null

  Variants {
    model: Mpris.players.values
    delegate: Scope {
      required property MprisPlayer modelData
      property int playbackState: modelData.playbackState
      property int uniqueId: modelData.uniqueId
      onPlaybackStateChanged: root.activePlayer = modelData
      onUniqueIdChanged: root.activePlayer = modelData
    }
  }

  icon: activePlayer === null ? "󰎆" : ({
      [MprisPlaybackState.Playing]: "󰏥",
      [MprisPlaybackState.Paused]: "󰐌",
      [MprisPlaybackState.Stopped]: "󰙦"
    })[activePlayer.playbackState]

  LText {
    visible: text !== ""
    text: root.activePlayer === null ? "" : Util.truncate([root.activePlayer.trackArtist, root.activePlayer.trackTitle].filter(x => x).join(" - "), root.maxLength)
    font.pointSize: Style.pillFontSize
  }

  tooltip: activePlayer === null ? "" : `${activePlayer.identity}${activePlayer.volumeSupported ? `
Volume: ${(100 * activePlayer.volume).toFixed(0)}%` : ""}`
  onLeftClick: {
    if (activePlayer?.canTogglePlaying)
      activePlayer?.togglePlaying()
  }
  onMiddleClick: {
    if (activePlayer?.canGoNext)
      activePlayer?.next()
  }
  onRightClick: {
    if (activePlayer?.canGoPrevious)
      activePlayer?.previous()
  }
  onWheel: wheel => {
    if (activePlayer?.canSeek)
      activePlayer?.seek(wheel.angleDelta.y > 0 || wheel.angleDelta.x < 0 ? 1 : wheel.angleDelta.y < 0 || wheel.angleDelta.x > 0 ? -1 : 0)
  }
}
