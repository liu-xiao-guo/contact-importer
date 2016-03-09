import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Content 0.1
import QtContacts 5.0
import Ubuntu.Components.ListItems 0.1 as ListItem

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    id: root
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "contact-importer.liu-xiao-guo"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true

    // Removes the old toolbar and enables new features of the new header.
    useDeprecatedToolbar: false

    width: units.gu(60)
    height: units.gu(85)
    property var activeTransfer
    property list<ContentItem> importItems

    Page {
        title: i18n.tr("contact-importer")

        ContentPeer {
            id: sourceSingle
            contentType: ContentType.Contacts
            handler: ContentHandler.Source
            selectionType: ContentTransfer.Single
        }

        ContentPeer {
            id: sourceMulti
            contentType: ContentType.Contacts
            handler: ContentHandler.Source
            selectionType: ContentTransfer.Multiple
        }

        ContactModel {
            id: model
            autoUpdate: true
        }

        ContactModel {
            id: phoneContact
            autoUpdate: true

            manager: "galera"
        }

        ContactModel {
            id: contactModel
            autoUpdate: true

            manager: "memory"
        }

        ListView {
            id: contactView
            height: parent.height *.45

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }

            model: phoneContact

            delegate: ListItem.Subtitled {
                text: contact.name.firstName
                subText: contact.phoneNumber.number
            }
        }

        Label {
            id: importedText

            anchors {
                left: parent.left
                right: parent.right
                top: contactView.bottom
            }

            font.underline: true

            text: "Imported contact:"
        }

        ListView {
            id: importedView
            height: parent.height - contactView.height -
                    buttons.height - importedText.height

            anchors {
                left: parent.left
                right: parent.right
                top: importedText.bottom
                bottom: buttons.bottom
            }            

            delegate: ListItem.Subtitled {
                text: contact.name.firstName
                subText: contact.phoneNumber.number
            }
        }

        Row {
            id: buttons
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            anchors.bottomMargin: units.gu(1)
            height: childrenRect.height
            spacing: units.gu(1)

            Button {
                text: "Import a single contact"
                onClicked: {
                    //                    root.activeTransfer = ContentHub.importContent(ContentType.Contacts);
                    root.activeTransfer = sourceSingle.request();
                    root.activeTransfer.selectionType = ContentTransfer.Single;
                    root.activeTransfer.start();
                }
            }
            Button {
                text: "Import multiple contacts"
                onClicked: {
                    //                    root.activeTransfer = ContentHub.importContent(ContentType.Contacts);
                    root.activeTransfer = sourceMulti.request();
                    root.activeTransfer.selectionType = ContentTransfer.Multiple;
                    root.activeTransfer.start();
                }
            }
        }

        ContentTransferHint {
            id: importHint

            anchors.fill: parent
            activeTransfer: root.activeTransfer
        }

        Connections {
            target: root.activeTransfer ? root.activeTransfer : null
            onStateChanged: {
                if (root.activeTransfer.state === ContentTransfer.Charged) {
                    importItems = root.activeTransfer.items;

                    console.log("length: " + importItems.length);

                    for ( var i = 0; i < importItems.length; i ++ ) {
                        console.log("imported url: " + importItems[i].url);
                        console.log("imported text: " + importItems[i].text);
                    }

                    contactModel.importContacts(importItems[0].url, ["Sync"])

                    // Now dump the data
                    var contacts = contactModel.contacts;

                    console.log("length: " + contacts.length );
                    for ( var contact in contacts ) {
                        console.log("contact[ " + contact + "]: " + contacts[contact].name);
                    }

                    importedView.model = contactModel;

                }
            }
        }

        Component.onCompleted:  {
            var list = model.availableManagers;

            console.log("The " + list.length + " ContactModel managers are: ");
            for (var item in list ) {
                console.log("manager[ " + item + " ]: " + list[item] );
            }
        }
    }
}

