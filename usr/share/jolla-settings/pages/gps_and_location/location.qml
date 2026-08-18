/****************************************************************************
**
** Copyright (c) 2013-2019 Jolla Ltd.
** Copyright (c) 2019 Open Mobile Platform LLC.
** License: Proprietary
**
****************************************************************************/
import QtQuick 2.6
import Sailfish.Silica 1.0
import com.jolla.settings.system 1.0
import com.jolla.settings 1.0
import org.nemomobile.ofono 1.0
import Sailfish.Policy 1.0

Page {
    id: root

    property string beacondDbDisclaimer: {
        //: Text between %1 and %2 is link to service main page, between %3 and %4 to privacy policy
        //% "By using %1beaconDb%2 services you agree to their %3privacy policy%4."
        return qsTrId("settings_location-la-beacondb_disclaimer")
            .arg("<a href=\"https://beacondb.net/\">").arg("</a>")
            .arg("<a href=\"https://beacondb.net/privacy/\">").arg("</a>")
    }

    property int effectiveMode: locationSettings.pendingAgreements.length > 0 && !transitionTimer.running
                                ? LocationConfiguration.CustomMode
                                : locationSettings.locationMode

    function checkFlightMode() {
        // Until we have explicit UI to exit flight mode here, best just to do that when turning on gps or main location.
        if (locationSettings.gpsEnabled) {
            locationSettings.gpsFlightMode = false
        }
    }

    function setMode(mode) {
        if (locationSettings.locationMode == LocationConfiguration.CustomMode) {
            locationSettings.saveCustomSettings()
        }

        transitionTimer.start()
        locationSettings.locationMode = mode

        if (locationSettings.pendingAgreements.length > 0) {
            pageStack.animatorPush(usageTermsComponent, {
                                       providers: locationSettings.pendingAgreements
                                   })
        }
    }

    LocationConfiguration { id: locationSettings }

    Timer {
        // this timer exists to ensure that after pressing a switch,
        // that switch is lit up even while the user may need to
        // accept an agreement prior to being able to enable it.
        id: transitionTimer

        interval: 600 // long enough for page transition duration
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height

        Column {
            id: content

            width: parent.width
            enabled: AccessPolicy.locationSettingsEnabled
            bottomPadding: Theme.paddingLarge

            PageHeader {
                //% "Location"
                title: qsTrId("settings_location-he-location")
            }

            DisabledByMdmBanner {
                active: !content.enabled
            }

            TextSwitch {
                automaticCheck: false
                checked: locationSettings.locationEnabled
                enabled: AccessPolicy.locationSettingsEnabled

                //% "Location"
                text: qsTrId("settings_location-la-location")
                //% "Allow applications to pinpoint your location. This feature consumes some battery power."
                description: qsTrId("settings_location-la-location_switch_description")

                onClicked: {
                    var newState = !checked
                    locationSettings.locationEnabled = newState
                    root.checkFlightMode()
                }
            }

            Column {
                width: parent.width
                visible: locationSettings.locationProviders.length > 0

                SectionHeader {
                    //: Title of the accuracy settings section
                    //% "Accuracy"
                    text: qsTrId("settings_location-la-simple_settings_section")
                }

                TextSwitch {
                    automaticCheck: false
                    checked: effectiveMode == LocationConfiguration.HighAccuracyMode
                    enabled: locationSettings.locationEnabled && AccessPolicy.locationSettingsEnabled

                    //% "High-accuracy positioning"
                    text: qsTrId("settings_location-la-high_accuracy_positioning")

                    //: Description of the high accuracy positioning mode
                    //% "Use online services to assist device GPS to calculate highly accurate positioning information. "
                    //% "Data costs may apply."
                    description: qsTrId("settings_location-la-high_accuracy_positioning_description")

                    onClicked: {
                        setMode(LocationConfiguration.HighAccuracyMode)
                        root.checkFlightMode()
                    }
                }
                TextSwitch {
                    automaticCheck: false
                    checked: effectiveMode == LocationConfiguration.BatterySavingMode
                    enabled: locationSettings.locationEnabled && AccessPolicy.locationSettingsEnabled

                    //% "Battery-saving mode"
                    text: qsTrId("settings_location-la-battery_saving_positioning")

                    //: Description of the battery-saving positioning mode
                    //% "Use online services instead of the GPS to calculate positioning information. "
                    //% "Data costs may apply, but this mode uses less battery power."
                    description: qsTrId("settings_location-la-battery_saving_positioning_description")

                    onClicked: {
                        setMode(LocationConfiguration.BatterySavingMode)
                    }
                }
                TextSwitch {
                    automaticCheck: false
                    checked: effectiveMode == LocationConfiguration.DeviceOnlyMode
                    enabled: locationSettings.locationEnabled && AccessPolicy.locationSettingsEnabled

                    //% "Device-only mode"
                    text: qsTrId("settings_location-la-device_positioning")

                    //: Description of the device-only positioning mode
                    //% "Use the device GPS to calculate positioning information. This mode doesn't use any data."
                    description: qsTrId("settings_location-la-device_positioning_description")

                    onClicked: {
                        setMode(LocationConfiguration.DeviceOnlyMode)
                        root.checkFlightMode()
                    }
                }

                TextSwitch {
                    automaticCheck: false
                    checked: effectiveMode == LocationConfiguration.CustomMode
                    enabled: locationSettings.locationEnabled && AccessPolicy.locationSettingsEnabled

                    //% "Custom settings"
                    text: qsTrId("settings_location-la-custom_positioning")

                    //: Description of the custom positioning settings mode
                    //% "Turn on or off specific positioning methods for maximum control over data usage and privacy."
                    description: qsTrId("settings_location-la-custom_positioning_description")

                    onClicked: {
                        if (locationSettings.locationMode != LocationConfiguration.CustomMode) {
                            locationSettings.locationMode = LocationConfiguration.CustomMode
                            locationSettings.restoreCustomSettings()
                            root.checkFlightMode()
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: Theme.paddingLarge
                }

                Button {
                    enabled: locationSettings.locationEnabled
                             && AccessPolicy.locationSettingsEnabled
                             && effectiveMode == LocationConfiguration.CustomMode
                    anchors.horizontalCenter: parent.horizontalCenter
                    //% "Select custom settings"
                    text: qsTrId("settings_location-bt-select_custom_positioning_settings")
                    onClicked: {
                        if (locationSettings.locationMode != LocationConfiguration.CustomMode) {
                            locationSettings.locationMode = LocationConfiguration.CustomMode
                            locationSettings.restoreCustomSettings()
                        }

                        var obj = pageStack.animatorPush(advancedSettingsPageComponent)
                        obj.pageCompleted.connect(function(page) {
                            page.onStatusChanged.connect(function() {
                                if (page.status == PageStatus.Deactivating) locationSettings.saveCustomSettings() }
                            )})
                    }
                }
            }
        }
    }

    // at the moment this only handles mls/beaconDB but having some leftover functionality for
    // combining more agreements to be accepted
    Component {
        id: usageTermsComponent

        Dialog {
            id: usageTermsDialog

            readonly property string providerName: providers.length > 0 ? providers[0] : ""
            property var providers: []

            acceptDestination: providers.length > 1 ? usageTermsComponent : undefined
            acceptDestinationProperties: providers.length > 1
                                         ? { providers: usageTermsDialog.providers.slice(1) }  : {}
            acceptDestinationAction: providers.length > 1 ? PageStackAction.Replace : PageStackAction.Push

            onAccepted: {
                if (providerName == "mls") {
                    locationSettings.mlsEnabled = true
                    locationSettings.mlsOnlineState = LocationConfiguration.OnlineAGpsEnabled
                } else {
                    console.warn("Accepting unknown provider", providerName)
                }
            }

            SilicaFlickable {
                anchors.fill: parent
                contentHeight: content.height

                Column {
                    id: content

                    width: parent.width

                    DialogHeader {
                        dialog: usageTermsDialog
                    }

                    Label {
                        visible: providerName != "mls" // current mls/beaconDB is more informational
                        x: Theme.horizontalPageMargin
                        width: parent.width - 2*x
                        color: Theme.secondaryHighlightColor
                        font.pixelSize: Theme.fontSizeLarge
                        wrapMode: Text.Wrap
                        //% "Accept terms and enable assisted positioning"
                        text: qsTrId("settings_location-he-location_terms")
                    }

                    Item {
                        width: 1
                        height: Theme.paddingLarge
                    }

                    Text {
                        x: Theme.horizontalPageMargin
                        width: parent.width - 2*x
                        color: Theme.highlightColor
                        linkColor: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeMedium
                        textFormat: Text.StyledText
                        wrapMode: Text.Wrap
                        text: {
                            if (providerName == "mls") {
                                return root.beacondDbDisclaimer
                            }

                            console.warn("Unknown provider for agreement text", usageTermsDialog.providerName)

                            //% "No text available!"
                            return qsTrId("settings_location-unknown_agreement")
                        }
                        onLinkActivated: Qt.openUrlExternally(link)
                    }
                }

                VerticalScrollDecorator {}
            }
        }
    }

    Component {
        id: advancedSettingsPageComponent

        Page {
            SilicaFlickable {
                anchors.fill: parent
                contentHeight: content.height

                Column {
                    id: content

                    width: parent.width
                    bottomPadding: Theme.paddingLarge

                    PageHeader {
                        //: Title of the "advanced" settings section
                        //% "Advanced settings"
                        title: qsTrId("settings_location-la-advanced_settings_section")
                    }
                    Column {
                        visible: locationSettings.gpsAvailable
                        width: parent.width

                        SectionHeader {
                            //% "GPS"
                            text: qsTrId("settings_location-la-gps_section_header")
                        }
                        IconTextSwitch {
                            automaticCheck: false
                            checked: locationSettings.gpsEnabled
                            enabled: locationSettings.locationEnabled

                            icon.source: "image://theme/icon-m-gps"

                            //% "GPS positioning"
                            text: qsTrId("settings_location-la-gps_positioning")

                            //: Description of GPS positioning
                            //% "Enable GPS-positioning to pinpoint the device location to a high level of accuracy. "
                            //% "Extra battery usage will be incurred."
                            description: qsTrId("settings_location-gps_positioning_description")

                            onClicked: {
                                var newState = !checked
                                locationSettings.gpsEnabled = newState
                                root.checkFlightMode()
                            }
                        }
                    }

                    Column {
                        visible: locationSettings.hybrisAvailable
                        width: parent.width

                        SectionHeader {
                            //% "AGPS"
                            text: qsTrId("settings_location-la-agps_section")
                        }

                        TextSwitch {
                            automaticCheck: false
                            checked: locationSettings.hybrisEnabled
                            enabled: locationSettings.gpsEnabled

                            //% "Enable GPS assistance"
                            text: qsTrId("settings_location-la-agps")

                            onClicked: {
                                locationSettings.hybrisEnabled = !locationSettings.hybrisEnabled
                            }
                        }

                        TextSwitch {
                            automaticCheck: false
                            checked: locationSettings.hybrisOnlineState == LocationConfiguration.OnlineAGpsEnabled
                            enabled: locationSettings.gpsEnabled && locationSettings.hybrisEnabled

                            //% "Enable extra online based assistance for location"
                            text: qsTrId("settings_location-la-agps_online_positioning")

                            onClicked: locationSettings.hybrisOnlineState
                                       = locationSettings.hybrisOnlineState == LocationConfiguration.OnlineAGpsEnabled
                                         ? LocationConfiguration.OnlineAGpsDisabled
                                         : LocationConfiguration.OnlineAGpsEnabled
                        }
                    }

                    Column {
                        visible: locationSettings.mlsAvailable
                        width: parent.width

                        SectionHeader {
                            //% "beaconDB"
                            text: qsTrId("settings_location-la-beacondb_section_header")
                        }

                        TextSwitch {
                            automaticCheck: false
                            checked: locationSettings.mlsEnabled
                                     && locationSettings.mlsOnlineState === LocationConfiguration.OnlineAGpsEnabled

                            //% "Online position lookup based on nearby cell towers and WLAN networks"
                            text: qsTrId("settings_location-la-beacondb_online_positioning")

                            description: modemManager.availableModems.length > 0
                                         ? //: Description of the online (cell-tower plus wlan) Mozilla Location Services
                                           //: position lock for devices with mobile data capability
                                           //% "Calculate medium-accuracy, cell-tower plus wireless-network-based "
                                           //% "positioning information via online request. Data costs may apply."
                                           qsTrId("settings_location-la-mls_online_positioning_description")
                                         : //: Description of the online (cell-tower plus wlan) Mozilla Location Services
                                           //: position lock for devices without mobile data capability
                                           //% "Calculate low-accuracy, wireless-network-based positioning "
                                           //% "information via online request."
                                           qsTrId("settings_location-la-mls_online_positioning_description_non_mobile_data")

                            onClicked: {
                                if (locationSettings.mlsEnabled
                                        && locationSettings.mlsOnlineState === LocationConfiguration.OnlineAGpsEnabled) {
                                    locationSettings.mlsOnlineState = LocationConfiguration.OnlineAGpsDisabled
                                } else if (locationSettings.mlsOnlineState === LocationConfiguration.OnlineAGpsAgreementNotAccepted) {
                                    pageStack.animatorPush(usageTermsComponent, { providers: ["mls"] })
                                } else {
                                    locationSettings.mlsEnabled = true
                                    locationSettings.mlsOnlineState = LocationConfiguration.OnlineAGpsEnabled
                                }
                            }
                        }

                        Item {
                            width: 1
                            height: Theme.paddingLarge
                        }

                        Text {
                            x: Theme.horizontalPageMargin
                            width: parent.width - 2*x
                            font.pixelSize: Theme.fontSizeSmall
                            wrapMode: Text.Wrap
                            textFormat: Text.StyledText
                            text: root.beacondDbDisclaimer
                            color: Theme.highlightColor
                            linkColor: Theme.primaryColor

                            onLinkActivated: Qt.openUrlExternally(link)
                        }

                        OfonoModemManager {
                            id: modemManager
                        }
                    }
                }
            }
        }
    }
}
