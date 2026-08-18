import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import Nemo.DBus 2.0
import org.nemomobile.contacts 1.0

Dialog {
    id: root

    acceptDestination: importFromServices
    acceptDestinationAction: PageStackAction.Push

    function importFromFile() {
        var obj = pageStack.animatorPush("../ContactFilePickerPage.qml")
        obj.pageCompleted.connect(function(page) {
            page.onFileSelected.connect(function(fileUrl) {
                openImportPage({ "importSourceUrl": fileUrl }, true)
            })
        })
    }

    function createAccount(providerName) {
        // ignoring account type for now
        settingsDbus.showAccounts()
    }

    function abandonImport() {
        // Pop down to the contact list
        pageStack.pop(pageStack.previousPage(root))
    }

    function openImportPage(properties, replace) {
        var obj
        if (replace) {
            obj = pageStack.animatorReplace("ContactImportPage.qml", properties)
        } else {
            obj = pageStack.animatorPush("ContactImportPage.qml", properties)
        }
        obj.pageCompleted.connect(function(page) {
            page.contactOpenRequested.connect(function(contactId) {
                if (contactId != undefined) {
                    pageStack.animatorReplace("Sailfish.Contacts.ContactCardPage",
                                              { "contact": peopleModel.personById(contactId) })
                } else {
                    // Pop down to the contact list
                    pageStack.pop(pageStack.previousPage(root))
                }
            })
        })
    }

    DBusInterface {
        id: settingsDbus

        service: "com.jolla.settings"
        path: "/com/jolla/settings/ui"
        iface: "com.jolla.settings.ui"

        function showAccounts() {
            settingsDbus.call("showAccounts", [])
        }
    }

    SilicaFlickable {
        width: parent.width
        height: parent.height
        contentWidth: width
        contentHeight: contentColumn.height + Theme.paddingMedium

        Column {
            id: contentColumn

            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader {
                id: header

                //: Import label to go to import options
                //% "Import"
                acceptText: qsTrId("contacts-he-import")
            }
            Column {
                width: parent.width

                Label {
                    x: Theme.horizontalPageMargin
                    width: parent.width - x - Theme.horizontalPageMargin
                    wrapMode: Text.Wrap
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeLarge

                    //: Functional title
                    //% "Import Contacts"
                    text: qsTrId("contacts-la-import_contacts")
                }
                Label {
                    x: Theme.horizontalPageMargin
                    width: parent.width - x - Theme.horizontalPageMargin
                    wrapMode: Text.Wrap
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeMedium

                    text: peopleModel.count == 0
                          ? //: No available contacts
                            //% "You have no contacts yet"
                            qsTrId("contacts-la-no_contacts_available")
                          : //: Available contacts
                            //% "%n contact(s) already available."
                            qsTrId("contacts-la-n_contacts_available", peopleModel.count)
                }
            }
            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - x - Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeMedium

                //: Prompt the user to choose an import option (text should match accept text label)
                //% "Choose 'Import' if you would like to import contacts using Accounts or other sources."
                text: qsTrId("contacts-la-import_prompt_account_or_other_sources")
            }
            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - x - Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeMedium

                //: Tells the user where to access import functionality
                //% "You can always import contacts from Settings / App settings / People."
                text: qsTrId("contacts-la-import_instructions")
            }
        }
    }

    PeopleModel {
        id: peopleModel
        filterType: PeopleModel.FilterAll
    }

    Component {
        id: importFromServices

        Page {
            SilicaFlickable {
                id: flickable

                width: parent.width
                height: parent.height
                contentWidth: width
                contentHeight: skipButton.y + skipButton.height + Theme.paddingMedium

                Column {
                    id: contentColumn

                    width: parent.width
                    spacing: Theme.paddingLarge

                    PageHeader {}
                    Label {
                        x: Theme.horizontalPageMargin
                        width: parent.width - x - Theme.horizontalPageMargin
                        wrapMode: Text.Wrap
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeLarge

                        //: Import from services heading
                        //% "Import contacts from services"
                        text: qsTrId("contacts-la-import_from_services")
                    }
                    Label {
                        x: Theme.horizontalPageMargin
                        width: parent.width - x - Theme.horizontalPageMargin
                        wrapMode: Text.Wrap
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeMedium

                        //: Prompt the user to create an account or help to import data
                        //% "Do you have accounts with contacts stored, e.g. a Google account? "
                        //% "If so, create an account to synchronize the contacts to the device. "
                        //% "If you don't have any suitable account, choose 'Import without services'."
                        text: qsTrId("contacts-la-import_select_account")
                    }
                    Column {
                        width: parent.width

                        WizardActionItem {
                            //% "Show accounts"
                            text: qsTrId("contacts-la-show_accounts")
                            iconSource: "image://theme/icon-m-setting"

                            onClicked: {
                                settingsDbus.showAccounts()
                            }
                        }

                        WizardActionItem {
                            //% "Import without services"
                            text: qsTrId("contacts-la-without_services")
                            iconSource: "image://theme/icon-m-device"

                            onClicked: {
                                pageStack.animatorPush('wizard/ImportFromDevice.qml', {
                                                           'importFromFile': importFromFile,
                                                           'createAccount': createAccount,
                                                           'abandonImport': abandonImport
                                                       })
                            }
                        }
                    }
                }

                Button {
                    id: skipButton

                    anchors.horizontalCenter: parent.horizontalCenter
                    //: Cancel import procedure
                    //% "Skip importing"
                    text: qsTrId("contacts-bt-skip_importing")
                    y: Math.max(flickable.height - (height + Theme.itemSizeMedium),
                                contentColumn.y + contentColumn.height + Theme.paddingLarge)

                    onClicked: abandonImport()
                }
            }
        }
    }
}
