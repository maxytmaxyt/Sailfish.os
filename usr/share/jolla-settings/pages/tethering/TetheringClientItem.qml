import QtQuick 2.6
import Sailfish.Silica 1.0

Item {
    property alias address: addressLabel.text
    property alias mac: macLabel.text

    width: parent.width
    height: visible ? (column.height + Theme.paddingMedium * 2) : 0
    opacity: visible ? 1 : 0

    Column {
        id: column

        x: Theme.horizontalPageMargin
        width: parent.width - x*2
        y: Theme.paddingMedium

        Label {
            id: addressLabel

            width: parent.width
            color: Theme.highlightColor
            wrapMode: Text.Wrap
        }
        Label {
            id: macLabel

            width: parent.width
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.secondaryHighlightColor
            wrapMode: Text.Wrap
        }
    }
}
