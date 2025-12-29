pragma Singleton
import QtQuick
import Quickshell
import qs.common
import qs.widgets

Singleton {
  id: root

  property var activeTooltip: null
  property var pendingTooltip: null // Track tooltip being created

  property Component tooltipComponent: Component {
    PopupWindow {
      id: root

      property string text: ""
      property string direction: "auto" // "auto", "left", "right", "top", "bottom"
      property int margin: 10
      property int padding: 15
      property int maxWidth: 320
      property real animationScale: 0.85

      // Internal properties
      property var targetItem: null
      property real anchorX: 0
      property real anchorY: 0
      property bool isPositioned: false
      property int screenWidth: 1920
      property int screenHeight: 1080
      property int screenX: 0
      property int screenY: 0

      visible: false
      color: Style.transparent

      anchor.item: targetItem
      anchor.rect.x: anchorX
      anchor.rect.y: anchorY

      // Timer for showing tooltip after delay
      Timer {
        id: showTimer
        interval: Style.tooltipDelay
        repeat: false
        onTriggered: {
          root.positionAndShow()
        }
      }

      // Function to show tooltip
      function show(target, tipText) {
        if (!target || !tipText || tipText === "")
          return

        // Stop any running timers and animations
        showTimer.stop();

        // If we're already showing for a different target, hide immediately
        if (visible && targetItem !== target) {
          hideImmediately()
        }

        // Convert \n to <br> for RichText format
        const processedText = tipText.replace(/\n/g, '<br>');

        // Set properties
        text = processedText
        targetItem = target;

        // Find the correct screen dimensions based on target's global position
        // Respect all screens positionning
        const targetGlobal = target.mapToGlobal(target.width / 2, target.height / 2)
        let foundScreen = false
        for (let i = 0; i < Quickshell.screens.length; i++) {
          const s = Quickshell.screens[i]
          if (targetGlobal.x >= s.x && targetGlobal.x < s.x + s.width && targetGlobal.y >= s.y && targetGlobal.y < s.y
              + s.height) {
            screenWidth = s.width
            screenHeight = s.height
            screenX = s.x
            screenY = s.y
            foundScreen = true
            break
          }
        }
        if (!foundScreen) {
          Logger.warn("Tooltip", "No screen found for target position!")
        }

        // Initialize animation state (hidden)
        tooltipContainer.opacity = 0.0
        tooltipContainer.scale = root.animationScale;

        // Start show timer (will position and then make visible)
        showTimer.start()
      }

      // Function to position and display the tooltip
      function positionAndShow() {
        if (!targetItem || !targetItem.parent) {
          return
        }

        // Calculate tooltip dimensions
        const tipWidth = Math.min(tooltipText.implicitWidth + (padding * 2), maxWidth)
        root.implicitWidth = tipWidth

        const tipHeight = tooltipText.implicitHeight + (padding * 2)
        root.implicitHeight = tipHeight;

        // Get target's global position and convert to screen-relative
        var targetGlobalAbs = targetItem.mapToGlobal(0, 0)
        var targetGlobal = {
          "x": targetGlobalAbs.x - screenX,
          "y": targetGlobalAbs.y - screenY
        }
        const targetWidth = targetItem.width
        const targetHeight = targetItem.height

        var newAnchorX = 0
        var newAnchorY = 0

        if (direction === "auto") {
          // Calculate available space in each direction (screen-relative)
          const spaceLeft = targetGlobal.x
          const spaceRight = screenWidth - (targetGlobal.x + targetWidth)
          const spaceTop = targetGlobal.y
          const spaceBottom = screenHeight - (targetGlobal.y + targetHeight);

          // Try positions in order of available space
          const positions = [
                  {
                    "dir": "bottom",
                    "space": spaceBottom,
                    "x": (targetWidth - tipWidth) / 2,
                    "y": targetHeight + margin,
                    "fits": spaceBottom >= tipHeight + margin
                  },
                  {
                    "dir": "top",
                    "space": spaceTop,
                    "x": (targetWidth - tipWidth) / 2,
                    "y": -tipHeight - margin,
                    "fits": spaceTop >= tipHeight + margin
                  },
                  {
                    "dir": "right",
                    "space": spaceRight,
                    "x": targetWidth + margin,
                    "y": (targetHeight - tipHeight) / 2,
                    "fits": spaceRight >= tipWidth + margin
                  },
                  {
                    "dir": "left",
                    "space": spaceLeft,
                    "x": -tipWidth - margin,
                    "y": (targetHeight - tipHeight) / 2,
                    "fits": spaceLeft >= tipWidth + margin
                  }
                ];

          // Find first position that fits
          var selectedPosition = null
          for (var i = 0; i < positions.length; i++) {
            if (positions[i].fits) {
              selectedPosition = positions[i]
              break
            }
          }

          // If none fit perfectly
          if (!selectedPosition) {
            // Sort by available space and use position with most space
            positions.sort(function (a, b) {
              return b.space - a.space
            })
            selectedPosition = positions[0]
          }

          newAnchorX = selectedPosition.x
          newAnchorY = selectedPosition.y
        } else {
          // Manual direction positioning
          switch (direction) {
          case "left":
            newAnchorX = -tipWidth - margin
            newAnchorY = (targetHeight - tipHeight) / 2
            break
          case "right":
            newAnchorX = targetWidth + margin
            newAnchorY = (targetHeight - tipHeight) / 2
            break
          case "top":
            newAnchorX = (targetWidth - tipWidth) / 2
            newAnchorY = -tipHeight - margin
            break
          case "bottom":
            newAnchorX = (targetWidth - tipWidth) / 2
            newAnchorY = targetHeight + margin
            break
          }
        }

        // Adjust horizontal position to keep tooltip on screen
        // For top/bottom tooltips, always adjust horizontally (they don't overlap horizontally)
        // For left/right tooltips, check for overlap before adjusting
        const globalX = targetGlobal.x + newAnchorX
        const isHorizontalTooltip = (direction === "top" || direction === "bottom")

        if (globalX < 0) {
          // Clipping at left - only adjust if tooltip won't overlap target
          const adjustedX = -targetGlobal.x + margin
          if (isHorizontalTooltip) {
            // Top/bottom tooltips: always allow horizontal adjustment
            newAnchorX = adjustedX
          } else {
            // Left/right tooltips: check for vertical overlap
            const wouldOverlap = adjustedX < targetWidth && adjustedX + tipWidth > 0
            if (!wouldOverlap) {
              newAnchorX = adjustedX
            }
          }
        } else if (globalX + tipWidth > screenWidth) {
          // Clipping at right - only adjust if tooltip won't overlap target
          const adjustedX = screenWidth - targetGlobal.x - tipWidth - margin
          if (isHorizontalTooltip) {
            // Top/bottom tooltips: always allow horizontal adjustment
            newAnchorX = adjustedX
          } else {
            // Left/right tooltips: check for vertical overlap
            const wouldOverlap = adjustedX < targetWidth && adjustedX + tipWidth > 0
            if (!wouldOverlap) {
              newAnchorX = adjustedX
            }
          }
        }

        // Adjust vertical position to keep tooltip on screen
        // For left/right tooltips, always adjust vertically (they don't overlap vertically)
        // For top/bottom tooltips, check for overlap before adjusting
        const globalY = targetGlobal.y + newAnchorY
        const isVerticalTooltip = (direction === "left" || direction === "right")

        if (globalY < 0) {
          // Clipping at top - only adjust if tooltip won't overlap target
          const adjustedY = -targetGlobal.y + margin
          if (isVerticalTooltip) {
            // Left/right tooltips: always allow vertical adjustment
            newAnchorY = adjustedY
          } else {
            // Top/bottom tooltips: check for horizontal overlap
            const wouldOverlap = adjustedY < targetHeight && adjustedY + tipHeight > 0
            if (!wouldOverlap) {
              newAnchorY = adjustedY
            }
          }
        } else if (globalY + tipHeight > screenHeight) {
          // Clipping at bottom - only adjust if tooltip won't overlap target
          const adjustedY = screenHeight - targetGlobal.y - tipHeight - margin
          if (isVerticalTooltip) {
            // Left/right tooltips: always allow vertical adjustment
            newAnchorY = adjustedY
          } else {
            // Top/bottom tooltips: check for horizontal overlap
            const wouldOverlap = adjustedY < targetHeight && adjustedY + tipHeight > 0
            if (!wouldOverlap) {
              newAnchorY = adjustedY
            }
          }
        }

        // Apply position first (before making visible)
        anchorX = newAnchorX
        anchorY = newAnchorY
        isPositioned = true;

        // Now make visible and start animation
        root.visible = true
      }

      // Function to hide tooltip
      function hide() {
        // Stop show timer if it's running
        showTimer.stop()
      }

      function completeHide() {
        visible = false
        text = ""
        isPositioned = false
        tooltipContainer.opacity = 1.0
        tooltipContainer.scale = 1.0
      }

      // Quick hide without delay or animation
      function hideImmediately() {
        showTimer.stop()
        completeHide()
      }

      // Update text function
      function updateText(newText) {
        if (visible && targetItem) {
          // Convert \n to <br> for RichText format
          const processedText = newText.replace(/\n/g, '<br>')
          text = processedText;

          // Recalculate dimensions
          const tipWidth = Math.min(tooltipText.implicitWidth + (padding * 2), maxWidth)
          root.implicitWidth = tipWidth

          const tipHeight = tooltipText.implicitHeight + (padding * 2)
          root.implicitHeight = tipHeight;

          // Reposition based on current direction (screen-relative)
          var targetGlobalAbs = targetItem.mapToGlobal(0, 0)
          var targetGlobal = {
            "x": targetGlobalAbs.x - screenX,
            "y": targetGlobalAbs.y - screenY
          }
          const targetWidth = targetItem.width
          const targetHeight = targetItem.height

          // Recalculate base anchor position (center on target for top/bottom, etc.)
          var newAnchorX = anchorX
          var newAnchorY = anchorY

          // Determine which direction the tooltip is currently positioned
          // and recalculate the centering for that direction
          var isHorizontalTooltip = false
          var isVerticalTooltip = false
          if (anchorY > targetHeight / 2) {
            // Tooltip is below target
            newAnchorX = (targetWidth - tipWidth) / 2
            isHorizontalTooltip = true
          } else if (anchorY < -tipHeight / 2) {
            // Tooltip is above target
            newAnchorX = (targetWidth - tipWidth) / 2
            isHorizontalTooltip = true
          } else if (anchorX > targetWidth / 2) {
            // Tooltip is to the right
            newAnchorY = (targetHeight - tipHeight) / 2
            isVerticalTooltip = true
          } else if (anchorX < -tipWidth / 2) {
            // Tooltip is to the left
            newAnchorY = (targetHeight - tipHeight) / 2
            isVerticalTooltip = true
          }

          // Adjust horizontal position to keep tooltip on screen if needed
          // For top/bottom tooltips, always adjust horizontally (they don't overlap horizontally)
          // For left/right tooltips, check for overlap before adjusting
          const globalX = targetGlobal.x + newAnchorX
          if (globalX < 0) {
            const adjustedX = -targetGlobal.x + margin
            if (isHorizontalTooltip) {
              newAnchorX = adjustedX
            } else {
              const wouldOverlap = adjustedX < targetWidth && adjustedX + tipWidth > 0
              if (!wouldOverlap) {
                newAnchorX = adjustedX
              }
            }
          } else if (globalX + tipWidth > screenWidth) {
            const adjustedX = screenWidth - targetGlobal.x - tipWidth - margin
            if (isHorizontalTooltip) {
              newAnchorX = adjustedX
            } else {
              const wouldOverlap = adjustedX < targetWidth && adjustedX + tipWidth > 0
              if (!wouldOverlap) {
                newAnchorX = adjustedX
              }
            }
          }

          // Adjust vertical position to keep tooltip on screen if needed
          // For left/right tooltips, always adjust vertically (they don't overlap vertically)
          // For top/bottom tooltips, check for overlap before adjusting
          const globalY = targetGlobal.y + newAnchorY
          if (globalY < 0) {
            const adjustedY = -targetGlobal.y + margin
            if (isVerticalTooltip) {
              newAnchorY = adjustedY
            } else {
              const wouldOverlap = adjustedY < targetHeight && adjustedY + tipHeight > 0
              if (!wouldOverlap) {
                newAnchorY = adjustedY
              }
            }
          } else if (globalY + tipHeight > screenHeight) {
            const adjustedY = screenHeight - targetGlobal.y - tipHeight - margin
            if (isVerticalTooltip) {
              newAnchorY = adjustedY
            } else {
              const wouldOverlap = adjustedY < targetHeight && adjustedY + tipHeight > 0
              if (!wouldOverlap) {
                newAnchorY = adjustedY
              }
            }
          }

          // Apply the new anchor positions
          anchorX = newAnchorX
          anchorY = newAnchorY;

          // Force anchor update
          Qt.callLater(() => {
                         if (root.anchor && root.visible) {
                           root.anchor.updateAnchor()
                         }
                       })
        }
      }

      // Reset function to clean up state
      function reset() {
        // Stop all timers and animations
        showTimer.stop();

        // Clear all state
        visible = false
        text = ""
        isPositioned = false
      }

      // Tooltip content container for animations
      Pill {
        id: tooltipContainer

        PillText {
          id: tooltipText
          value: root.text
        }
      }

      Component.onCompleted: {
        reset()
      }

      Component.onDestruction: {
        reset()
      }
    }
  }

  function show(target, text) {
    // Don't create if no text
    if (!target || !text) {
      Logger.info("Tooltip", "No target or text")
      return
    }

    // If we have a pending tooltip for a different target, cancel it
    if (pendingTooltip && pendingTooltip.targetItem !== target) {
      pendingTooltip.hideImmediately()
      pendingTooltip.destroy()
      pendingTooltip = null
    }

    // If we have an active tooltip for a different target, hide it
    if (activeTooltip && activeTooltip.targetItem !== target) {
      activeTooltip.hideImmediately();
      // Don't destroy immediately - let it clean itself up
      activeTooltip = null
    }

    // If we already have a tooltip for this target, just update it
    if (activeTooltip && activeTooltip.targetItem === target) {
      activeTooltip.updateText(text)
      return activeTooltip
    }

    // Create new tooltip instance
    const newTooltip = tooltipComponent.createObject(null)

    if (newTooltip) {
      // Track as pending until it's visible
      pendingTooltip = newTooltip;

      // Connect cleanup when tooltip hides
      newTooltip.visibleChanged.connect(() => {
                                          if (!newTooltip.visible) {
                                            // Clean up after a delay to avoid interfering with new tooltips
                                            Qt.callLater(() => {
                                                           if (newTooltip && !newTooltip.visible) {
                                                             if (activeTooltip === newTooltip) {
                                                               activeTooltip = null
                                                             }
                                                             if (pendingTooltip === newTooltip) {
                                                               pendingTooltip = null
                                                             }
                                                             newTooltip.destroy()
                                                           }
                                                         })
                                          } else {
                                            // Tooltip is now visible, move from pending to active
                                            if (pendingTooltip === newTooltip) {
                                              activeTooltip = newTooltip
                                              pendingTooltip = null
                                            }
                                          }
                                        });

      // Show the tooltip
      newTooltip.show(target, text)

      return newTooltip
    } else {
      Logger.error("Tooltip", "Failed to create tooltip instance")
    }

    return null
  }

  function hide() {
    if (pendingTooltip) {
      pendingTooltip.hide()
    }
    if (activeTooltip) {
      activeTooltip.hide()
    }
  }

  function hideImmediately() {
    if (pendingTooltip) {
      pendingTooltip.hideImmediately()
      pendingTooltip.destroy()
      pendingTooltip = null
    }
    if (activeTooltip) {
      activeTooltip.hideImmediately()
      activeTooltip.destroy()
      activeTooltip = null
    }
  }

  function updateText(newText) {
    if (activeTooltip) {
      activeTooltip.updateText(newText)
    }
  }
}
