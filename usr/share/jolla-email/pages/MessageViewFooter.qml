/*
 * Copyright (c) 2020 Open Mobile Platform LLC.
 *
 * License: Proprietary
 */

import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as SilicaPrivate
import Sailfish.Calendar 1.0
import Sailfish.WebView.Controls 1.0
import Sailfish.WebView.Popups 1.0
import Nemo.Email 0.1
import org.nemomobile.calendar 1.0
import "utils.js" as Utils

SilicaControl {
    id: footer

    property bool open
    property alias textSelectionController: textSelectionToolbar.controller
    property bool showReplyAll
    property alias portrait: textSelectionToolbar.portrait

    signal reply
    signal replyAll
    signal forward
    signal deleteEmail

    property int _biggestCorner: Math.max(Screen.topLeftCorner.radius,
                                          Screen.topRightCorner.radius,
                                          Screen.bottomLeftCorner.radius,
                                          Screen.bottomRightCorner.radius)
    property int _bottomPadding: portrait ? _biggestCorner * 0.5 : 0

    height: _bottomPadding + (portrait ? Theme.itemSizeMedium : Theme.itemSizeSmall)

    palette.colorScheme: Theme.DarkOnLight

    Rectangle {
        anchors.fill: parent
        color: "#f3f0f0"
    }

    TextSelectionToolbar {
        id: textSelectionToolbar

        width: footer.width
        height: footer.height - footer._bottomPadding
        leftPadding: Theme.paddingMedium
        rightPadding: Theme.paddingMedium

        selectAllEnabled: true

        buttons: {
            if (controller && controller.selectionVisible) {
                return defaultButtons
            } else {
                var buttons = [
                    {
                        "icon": "image://theme/icon-m-message-reply",
                        //% "Reply"
                        "label": qsTrId("jolla-email-la-reply"),
                        "action": footer.reply
                    }
                ]

                if (footer.showReplyAll) {
                    buttons.push(
                        {
                            "icon": "image://theme/icon-m-message-reply-all",
                            //% "Reply All"
                            "label": qsTrId("jolla-email-la-reply_all"),
                            "action": footer.replyAll
                        })
                }
                buttons.push(
                    {
                        "icon": "image://theme/icon-m-delete",
                        //% "Delete"
                        "label": qsTrId("jolla-email-la-delete"),
                        "action": footer.deleteEmail
                    }, {
                        "icon": "image://theme/icon-m-message-forward",
                        //% "Forward"
                        "label": qsTrId("jolla-email-la-forward"),
                        "action": footer.forward
                    })
                return buttons
            }
        }

        onCall: Qt.openUrlExternally("tel:" + controller.text)
        onShare: webShareAction.shareText(controller.text)
    }

    WebShareAction {
        id: webShareAction
    }
}
