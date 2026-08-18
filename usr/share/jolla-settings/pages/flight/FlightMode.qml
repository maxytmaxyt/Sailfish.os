import QtQuick 2.0
import Sailfish.Silica 1.0
import Connman 0.2
import Sailfish.Settings.Networking 1.0
import Nemo.KeepAlive 1.2

Item {
    property Item remorse
    property bool active: networkManager.offlineMode

    function setActive(_active) {
        if (active === _active) {
            return
        }

        // Hold keepalive session over offlineMode property change ipc
        keepAlive.enabled = true
        networkManager.offlineMode = _active
    }

    KeepAlive {
        id: keepAlive
    }

    NetworkManager {
        id: networkManager

        onOfflineModeChanged: {
            active = offlineMode
            // Operation succeeded - stop keepalive
            keepAlive.enabled = false
        }
    }
}
