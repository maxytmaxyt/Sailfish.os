import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Settings.Networking 1.0
import Connman 0.2

ListItem {
    id: root

    property bool connected: networkService.serviceState === NetworkService.OnlineState
                             || (ready && connectCompletionTimer.running)
    property bool ready: networkService.serviceState === NetworkService.ReadyState
    property int previousState: NetworkService.UnknownState
    property int currentState: networkService.serviceState

    function getDescription() {
        if (!networkService.supported) {
            //% "Secure, not supported type"
            return qsTrId("settings_network-la-not_supported_secure_network")
        } else if (connected) {
            //% "Connected"
            return qsTrId("settings_network-la-connected_state")
        } else if (currentState === NetworkService.ReadyState) {
            //% "Limited connectivity"
            return qsTrId("settings_network-la-limited_state")
        } else if (previousState === NetworkService.OnlineState && currentState === NetworkService.AssociationState) {
            // need previous state as well
            // as connman signals 'association' on disconnect as well
            //% "Disconnecting..."
            return qsTrId("settings_network-la-disconnecting_state")
        } else if (currentState === NetworkService.AssociationState
                   || currentState === NetworkService.ConfigurationState) {
            //% "Connecting..."
            return qsTrId("settings_network-la-connecting_state")
        } else {
            //: Open here refers to network without authentication
            //% "Open"
            QT_TRID_NOOP("settings_network-la-open_network")
            //% "Secure"
            QT_TRID_NOOP("settings_network-la-secure_network")

            var security = networkService.security

            if (networkService.name) {
                return security[0] === "none" ? qsTrId("settings_network-la-open_network")
                                              : qsTrId("settings_network-la-secure_network")
            }

            if (security.indexOf("none") >= 0) {
                return qsTrId("settings_network-la-open_network")
            } else if (security.indexOf("wep") >= 0) {
                //% "Secure (WEP)"
                return qsTrId("settings_network-la-secure_wep")
            } else if (security.indexOf("psk") >= 0) {
                //% "Secure (WPA)"
                return qsTrId("settings_network-la-secure_wpa")
            } else if (security.indexOf("psksae") >= 0) {
                //% "Secure (WPA2/WPA3)"
                return qsTrId("settings_network-la-secure_wpa-mixed")
            } else if (security.indexOf("sae") >= 0) {
                //% "Secure (WPA3)"
                return qsTrId("settings_network-la-secure_wpa3")
            } else {
                return qsTrId("settings_network-la-secure_network")
            }
        }
    }

    enabled: !managed
    contentHeight: textSwitch.height
    highlighted: textSwitch.down || menuOpen || connected || ready
    visible: networkService.type === "wifi"
    _backgroundColor: "transparent"
    openMenuOnPressAndHold: false
    menu: Component {
        ContextMenu {
            MenuItem {
                //% "Connect"
                text: qsTrId("settings_network-me-connect")
                visible: !networkService.connected && networkService.available && networkService.supported
                onClicked: networkService.requestConnect()
            }
            MenuItem {
                //% "Disconnect"
                text: qsTrId("settings_network-me-disconnect")
                visible: networkService.connected && !networkService.autoConnect
                onClicked: networkService.requestDisconnect()
            }
            MenuItem {
                //% "Forget"
                text: qsTrId("settings_network-me-forget")

                onClicked: {
                    var network = networkService
                    //% "Forgotten"
                    remorseAction(qsTrId("settings_network-la-forgotten"),
                                  function () { network.remove() })
                }
            }
            MenuItem {
                //% "Details"
                text: qsTrId("settings_network-me-details")
                onClicked: pageStack.animatorPush("NetworkDetailsPage.qml", {"network": networkService})
            }

            onActiveChanged: mainPage.suppressScan = active
        }
    }

    onCurrentStateChanged: {
        if (previousState === NetworkService.ConfigurationState && currentState === NetworkService.ReadyState)
            connectCompletionTimer.start()
        else
            connectCompletionTimer.stop()

        previousState = currentState
    }

    ListView.onRemove: animateRemoval()

    IconTextSwitch {
        id: textSwitch

        enabled: root.enabled
        icon.source: "image://theme/icon-m-wlan-" + WlanUtils.getStrengthString(networkService.strength)
        automaticCheck: false
        checked: networkService.autoConnect
        highlighted: root.highlighted
        text: networkService.name ? networkService.name
                                  : //% "Hidden network"
                                    qsTrId("settings_network-la-hidden_network")
        description: getDescription()
        onClicked: if (networkService.supported) {
            networkService.autoConnect = !networkService.autoConnect
        }
        onPressAndHold: root.openMenu()
    }

    Timer {
        id: connectCompletionTimer

        interval: 12000
        repeat: false
    }

    NetworkManager { id: networkManager }
}
