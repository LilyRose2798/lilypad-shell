pragma Singleton
import Quickshell

Singleton {
  function pad(val: var, length: int): string {
    return String(val).padStart(length, " ")
  }

  function zeroPad(val: var, length: int): string {
    return String(val).padStart(length, "0")
  }

  function flattenString(val: string): string {
    return val.trim().replace("\r\n", " ").replace("\n", " ")
  }
}
