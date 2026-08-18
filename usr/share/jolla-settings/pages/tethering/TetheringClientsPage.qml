import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Settings.Networking 1.0
import Connman 0.2

Page {
    id: page

    property string technology

    PageHeader {
        id: pageHeader
        //% "Hotspot clients"
        title: qsTrId("settings_network-ph-hotspot-clients")
    }

    SilicaListView {
        id: clientList

        anchors {
            top: pageHeader.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        model: networkManager.tetheringClients

        delegate: TetheringClientItem {
            address: modelData.address
            mac: modelData.mac
            visible: modelData.technology === technology
        }

        ViewPlaceholder {
            text: wifiTethering.active
                ? //: "View placeholder for no tethering clients connected"
                  //% "No clients currently connected"
                  qsTrId("settings_network-ph-hotspot-no-clients")
                : //: "View placeholder for disabled hotspot"
                  //% "Hotspot is currently disabled"
                  qsTrId("settings_network-ph-hotspot-disabled")
            enabled: networkManager.wifiClientCount === 0
        }

        VerticalScrollDecorator {}
    }

    MobileDataWifiTethering {
        id: wifiTethering
    }

    NetworkManager {
        id: networkManager

        property int wifiClientCount: {
            var nextCount = 0
            for (var i = 0; i < tetheringClients.length; i++) {
                if (tetheringClients[i].technology === "wifi") {
                    nextCount += 1
                }
            }
            return nextCount
        }
    }
}