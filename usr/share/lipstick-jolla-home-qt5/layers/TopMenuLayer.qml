import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Lipstick 1.0
import org.nemomobile.lipstick 0.1

// iPhone mapping: Swipe DOWN from top edge → Control Center
// (mirrors iOS Control Center swipe-down-from-top-right gesture)
EdgeLayer {
    id: topMenuLayer

    property bool housekeeping
    property bool closeFromEdge
    property Item topMenu
    readonly property rect exposedArea: topMenu ? Qt.rect(topMenu.exposedArea.x, topMenu.exposedArea.y,
                                                          topMenu.exposedArea.width, topMenu.exposedArea.height)
                                                : Qt.rect(0, 0, 0, 0)

    signal toggleActive()

    peekFilter {
        enabled: Lipstick.compositor.systemInitComplete
        onTopActiveChanged: closeFromEdge = peekFilter.topActive
        onLeftActiveChanged: closeFromEdge = peekFilter.leftActive
        onRightActiveChanged: closeFromEdge = peekFilter.rightActive
    }

    childrenOpaque: false
    objectName: "topMenuLayer"

    edge: PeekFilter.Top
    // iPhone-style: Control Center pulls down from top edge
    hintHeight: topMenu ? topMenu.itemSize * 1.5 : 0  // slightly smaller pull hint
    hintDuration: 250  // iPhone-style: fast response

    function show() {
        if (!active) {
            toggleActive()
        }
    }

    function hide() {
        if (active) {
            toggleActive()
        }
    }
}