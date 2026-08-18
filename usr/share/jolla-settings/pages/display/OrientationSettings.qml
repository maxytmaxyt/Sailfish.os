import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.systemsettings 1.0
import Nemo.Configuration 1.0

Column {
    property alias orientationLockCombo: orientationLockCombo

    width: parent.width

    SectionHeader {
        //% "Orientation"
        text: qsTrId("settings_display-he-orientation")
    }

    ComboBox {
        id: orientationLockCombo

        // postpone change until menu is closed so that transition doesn't happen during orientation change
        property int pendingChange: -1
        onCurrentIndexChanged: {
            pendingChange = currentIndex
            changeTimer.restart()
        }

        //% "Orientation"
        label: qsTrId("settings_display-la-orientation")
        menu: ContextMenu {
            onClosed: orientationLockCombo.applyChange()

            Repeater {
                model: orientationLockModel
                MenuItem {
                    text: qsTrId(label)
                }
            }
        }
        //% "If you want to disable orientation switching temporarily, select the Automatic option and "
        //% "keep your finger on the screen while turning the device."
        description: qsTrId("settings_display-la-orientation_automatic")

        function applyChange() {
            changeTimer.stop()
            if (orientationLockCombo.pendingChange >= 0) {
                displaySettings.orientationLock = orientationLockModel.get(orientationLockCombo.pendingChange).value
                orientationLockCombo.pendingChange = -1
            }
        }

        Timer {
            id: changeTimer

            interval: 1000
            onTriggered: orientationLockCombo.applyChange()
        }
    }

    TextSwitch {
        // bigger screens having this implicitly on
        visible: Screen.sizeCategory <= Screen.Medium
        //% "Rotating homescreen"
        text: qsTrId("settings_display-la-rotating_homescreen")
        //% "Allows the homescreen to follow the current orientation"
        description: qsTrId("settings_display-la-rotating_homescreen_description")
        automaticCheck: false
        checked: homescreenOrientationConfig.value
        onClicked: homescreenOrientationConfig.value = !homescreenOrientationConfig.value
    }

    ConfigurationValue {
        id: homescreenOrientationConfig

        key: "/desktop/lipstick-jolla-home/allow_homescreen_rotation"
        defaultValue: false
    }
}
