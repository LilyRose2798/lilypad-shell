import QtQuick
import Quickshell.Services.Mpris
import qs.common
import qs.component.common

Pill {
  id: root
  spacing: 8

  function rankPlayer(player: MprisPlayer): int {
    const id = player.identity
    if (id.includes("mpd"))
      return 10
    if (id.includes("feishin"))
      return 8
    if (id.includes("spotify"))
      return 7
    if (id.includes("firefox"))
      return 6
    if (id.includes("chrome"))
      return 5
    return -1
  }

  property list<MprisPlayer> players: Mpris.players.values.filter(p => p !== null).sort((p, q) => rankPlayer(q) - rankPlayer(p))
  property MprisPlayer player: players[0] ?? null
  icon: player === null ? "󰎆" : ({
      [MprisPlaybackState.Playing]: "󰏥",
      [MprisPlaybackState.Paused]: "󰐌",
      [MprisPlaybackState.Stopped]: "󰙦"
    })[player.playbackState]

  LText {
    text: root.player === null ? "" : [root.player.trackArtist, root.player.trackTitle].filter(x => x).join(" - ")
    font.pointSize: Style.pillFontSize
  }

  tooltip: player === null ? "" : `${player.identity}${player.volumeSupported ? `
Volume: ${(100 * player.volume).toFixed(0)}%` : ""}`
  onLeftClick: {
    if (player?.canTogglePlaying)
      player?.togglePlaying()
  }
  onMiddleClick: {
    if (player?.canGoNext)
      player?.next()
  }
  onRightClick: {
    if (player?.canGoPrevious)
      player?.previous()
  }
  onWheel: wheel => {
    if (player?.canSeek)
      player?.seek(wheel.angleDelta.y > 0 || wheel.angleDelta.x < 0 ? 1 : wheel.angleDelta.y < 0 || wheel.angleDelta.x > 0 ? -1 : 0)
  }
}
