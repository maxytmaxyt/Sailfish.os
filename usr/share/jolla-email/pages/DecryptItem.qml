/*
 * Copyright (c) 2023-2024 Jolla Ltd.
 *
 * License: Proprietary
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Email 0.1

BackgroundItem {
    property EmailMessage email
    readonly property int encryptionStatus: email ? email.encryptionStatus : EmailMessage.NoDigitalEncryption

    height: Theme.itemSizeExtraSmall
    visible: encryptionStatus != EmailMessage.NoDigitalEncryption
    highlighted: email && email.canDecrypt && down
    onClicked: if (email && email.canDecrypt) email.decrypt()

    Icon {
        id: icon

        x: Theme.horizontalPageMargin
        anchors.verticalCenter: parent.verticalCenter
        source: "image://theme/icon-m-device-lock"
    }

    Label {
        anchors {
            left: icon.right
            right: parent.right
            leftMargin: Theme.paddingMedium
            rightMargin: Theme.horizontalPageMargin
        }
        height: parent.height

        text: {
            switch (encryptionStatus) {
            case EmailMessage.Encrypted:
                return email.canDecrypt ? //% "Decrypt content"
                                          qsTrId("jolla-email-la-decrypt_content")
                                        : //% "Encrypted content"
                                          qsTrId("jolla-email-la-encrypted_content")
            case EmailMessage.EncryptedDataDownloading:
                //% "Downloading encrypted content"
                return qsTrId("jolla-email-la-downloading_encrypted_content")
            case EmailMessage.EncryptedDataMissing:
                //% "Cannot download encrypted content"
                return qsTrId("jolla-email-la-cannot_download_encrypted_content")
            case EmailMessage.Decrypting:
                //% "Decrypting content"
                return qsTrId("jolla-email-la-decrypting_content")
            case EmailMessage.DecryptionFailure:
                //% "Decryption failed"
                return qsTrId("jolla-email-la-decryption_failed")
            }
            return ""
        }
        font.pixelSize: Theme.fontSizeSmall
        verticalAlignment: Text.AlignVCenter
        truncationMode: TruncationMode.Fade
    }
}
