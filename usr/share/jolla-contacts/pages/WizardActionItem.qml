import QtQuick 2.6
import Sailfish.Silica 1.0

BackgroundItem {
    property alias iconSource: icon.source
    property alias text: label.text

    width: parent.width
    height: Math.max(icon.height, label.height) + 2*Theme.paddingMedium

    Icon {
        id: icon

        x: Theme.horizontalPageMargin
        anchors.verticalCenter: parent.verticalCenter
    }

    Label {
        id: label

        x: icon.x + icon.width + Theme.paddingLarge
        width: parent.width - x - Theme.horizontalPageMargin
        anchors.verticalCenter: parent.verticalCenter
        color: highlighted ? Theme.highlightColor : Theme.primaryColor
        wrapMode: Text.Wrap
    }
}
