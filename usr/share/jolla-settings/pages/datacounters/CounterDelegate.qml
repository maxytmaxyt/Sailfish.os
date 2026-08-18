import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
    id: root

    property alias title: titleLabel.text
    property var lastResetTime

    property double sent
    property double received

    width: parent.width

    Label {
        id: titleLabel

        color: Theme.highlightColor
        visible: text.length > 0
    }

    Label {
        //% "Sent: %1"
        text: qsTrId("settings_network-la-sent").arg(Format.formatFileSize(sent))
        color: Theme.secondaryHighlightColor
    }

    Label {
        //% "Received: %1"
        text: qsTrId("settings_network-la-received").arg(Format.formatFileSize(received))
        color: Theme.secondaryHighlightColor
    }

    Label {
        text: {
            if (lastResetTime !== undefined) {
                // ensure a UTC timestamp gets formatted in local time
                var localTime = new Date
                localTime.setTime(new Date(lastResetTime).getTime())
                //% "Time last cleared: %1"
                return qsTrId("settings_network-la-time_last_cleared").arg(Format.formatDate(localTime,
                                                                                             Formatter.Timepoint))
            }
            return ""
        }
        color: Theme.secondaryHighlightColor
        wrapMode: Text.Wrap
        width: parent.width
        visible: text.length > 0
    }
}
