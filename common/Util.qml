pragma Singleton
import Quickshell

Singleton {
  function pad(val: var, length: int): string {
    return String(val).padStart(length, " ")
  }

  function zeroPad(val: var, length: int): string {
    return String(val).padStart(length, "0")
  }
}
