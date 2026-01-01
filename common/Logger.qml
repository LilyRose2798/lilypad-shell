pragma Singleton
import Quickshell
import qs.common

Singleton {
  function _formatMessage(...args) {
    const message = args.length > 1 ? `\x1b[35m${Util.pad(args[0], 14)}\x1b[0m ${args.slice(1).join(" ")}` : args.join(" ")
    return `\x1b[36m[${Time.nowDateTimeString()}]\x1b[0m ${message}`
  }

  function debug(...args) {
    if (Settings?.isDebug)
      console.debug(_formatMessage(...args))
  }

  function info(...args) {
    console.info(_formatMessage(...args))
  }

  function warn(...args) {
    console.warn(_formatMessage(...args))
  }

  function error(...args) {
    console.error(_formatMessage(...args))
  }
}
