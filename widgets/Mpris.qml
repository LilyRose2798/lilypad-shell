import QtQuick
import Quickshell.Services.Mpris
import qs.common

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
  property MprisPlayer player: [...Mpris.players.values].sort((p, q) => rankPlayer(q) - rankPlayer(p))[0]
  icon: ({
           [MprisPlaybackState.Playing]: "󰏥",
           [MprisPlaybackState.Paused]: "󰐌",
           [MprisPlaybackState.Stopped]: "󰙦"
         })[player.playbackState]
  LText {
    text: `${root.player.trackArtist} - ${root.player.trackTitle}`
    font.pointSize: Style.pillFontSize
    maximumLineCount: 1
    wrapMode: Text.NoWrap
  }
  tooltip: `${player.identity}${player.volumeSupported ? `\nVolume: ${(100 * player.volume).toFixed(0)}%` : ""}`
  onLeftClick: {
    if (player.canTogglePlaying)
      player.togglePlaying()
  }
  onMiddleClick: {
    if (player.canGoNext)
      player.next()
  }
  onRightClick: {
    if (player.canGoPrevious)
      player.previous()
  }
  onWheel: wheel => {
             if (player.canSeek)
             player.seek(wheel.angleDelta.y > 0 || wheel.angleDelta.x < 0 ? 1 : wheel.angleDelta.y < 0
                                                                            || wheel.angleDelta.x > 0 ? -1 : 0)
           }
}
