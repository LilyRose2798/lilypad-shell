pragma Singleton
import Quickshell

Singleton {
  readonly property bool isDebug: Quickshell.env("LILYPAD_DEBUG") === "1"
  readonly property string shellName: "lilypad"
}
