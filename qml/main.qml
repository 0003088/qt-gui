import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Window 2.0
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1

ApplicationWindow {
    id: mainWindow

    visible: true
    width: Screen.desktopAvailableWidth
    height: Screen.desktopAvailableHeight

    title: "Elektra Editor"

    onClosing: {
        if(!undoManager.isClean()){
            close.accepted = false
            exitDialog.open()
        }
        else
            Qt.quit()
    }

    property int deltaKeyAreaHeight: Math.round(keyArea.height - searchResultsArea.height*0.5 - defaultSpacing)
    property int deltaKeyAreaWidth: Math.round(mainRow.width*0.7 - defaultSpacing)
    property int deltaMetaAreaHeight: Math.round(metaArea.height - searchResultsArea.height*0.5)
    property var keyAreaSelectedItem: null
    //TreeViewModel
    property var metaAreaModel: (keyAreaSelectedItem === null ? null : keyAreaSelectedItem.metaValue)

    property int pasteCounter: 0

    //Spacing & Margins recommended by KDE HIG
    property int defaultSpacing: 4
    property int defaultMargins: 8

    //Get access to system colors
    SystemPalette {
        id: activePalette
        colorGroup: SystemPalette.Active
    }
    SystemPalette {
        id: inactivePalette
        colorGroup: SystemPalette.Inactive
    }
    SystemPalette {
        id: disabledPalette
        colorGroup: SystemPalette.Disabled
    }

    NewKeyWindow {
        id: newKeyWindow
    }

    EditKeyWindow {
        id: editKeyWindow
    }


    //    NewKeyWindow {
    //        id: newArrayWindow
    //        title: qsTr("Create new Array Entry")
    //        valueLayout.visible: false
    //        nameLabel.text: qsTr("Array Name: ")
    //        addButton.text: qsTr("New Array Entry")
    //    }

    UnmountBackendWindow {
        id: unmountBackendWindow
    }

    WizardLoader {
        id: wizardLoader
    }

    FileDialog {
        id: exportDialog
        title: qsTr("Export to file")
        selectExisting: false
    }

    ExitDialog {
        id: exitDialog
    }

    Action {
        id:newKeyAction
        text: qsTr("Key...")
        iconSource: "icons/new.png"
        tooltip: qsTr("New Key")
        onTriggered: newKeyWindow.show()
    }

    Action {
        id:newArrayAction
        text: qsTr("Array Entry...")
        onTriggered: newArrayWindow.show()
        enabled: false
    }

    Action {
        id:deleteAction
        text: qsTr("Delete")
        iconSource: "icons/delete.png"
        tooltip: "Delete"
        shortcut: StandardKey.Delete
    }

    Action {
        id: importAction
        text: qsTr("Import Configuration... ")
        iconSource: "icons/import.png"
        tooltip: qsTr("Import Configuration")
        onTriggered: importDialog.open()
        enabled: false
    }

    Action {
        id: exportAction
        text: qsTr("Export Configuration... ")
        iconSource: "icons/export.png"
        tooltip: qsTr("Export Configuration")
        onTriggered: exportDialog.open()
        enabled: false
    }

    Action {
        id: undoAction
        text: qsTr("Undo")
        iconSource: "icons/undo.png"
        tooltip: qsTr("Undo")
        shortcut: StandardKey.Undo
        enabled: undoManager.canUndo
        onTriggered: {

            if(undoManager.undoText === "deleteKey"){
                undoManager.undo()
                keyAreaView.__incrementCurrentIndex()
                keyAreaView.selection.clear()
                keyAreaView.selection.select(keyAreaView.currentRow)
                keyAreaSelectedItem = keyAreaView.model.get(keyAreaView.currentRow)
            }
            else if(undoManager.undoText === "cut"){
                pasteCounter--
                undoManager.undo()
            }
            else{
                undoManager.undo()
            }
        }
    }

    Action {
        id: redoAction
        text: qsTr("Redo")
        iconSource: "icons/redo.png"
        tooltip: qsTr("Redo")
        shortcut: StandardKey.Redo
        enabled: undoManager.canRedo
        onTriggered: {

            if(undoManager.redoText === "deleteKey"){

                keyAreaView.__decrementCurrentIndex()
                keyAreaView.selection.clear()
                keyAreaView.selection.select(keyAreaView.currentRow)
                keyAreaSelectedItem = keyAreaView.model.get(keyAreaView.currentRow)

                if(keyAreaView.rowCount !== 0)
                    keyAreaSelectedItem = keyAreaView.model.get(keyAreaView.currentRow)
                else
                    keyAreaSelectedItem = null
            }
            else if(undoManager.redoText === "deleteBranch"){

                if(metaAreaModel !== null)
                    metaAreaModel = null
            }
            else if(undoManager.redoText === "cut"){
                pasteCounter--
            }

            undoManager.redo()
        }

    }

    Action {
        id: synchronizeAction
        text: qsTr("Synchronize")
        iconSource: "icons/synchronize.png"
        tooltip: qsTr("Synchronize")
        shortcut: StandardKey.Refresh
        onTriggered: {
            externTreeModel.synchronize()
            undoManager.setClean()
        }
    }

    Action {
        id: createBackendAction
        text: qsTr("Create Backend...")
        tooltip: qsTr("Create Backend")
        onTriggered: wizardLoader.show()
        enabled: false
    }

    Action {
        id: unmountBackendAction
        text: qsTr("Unmount Backend...")
        tooltip: qsTr("Unmount Backend")
        onTriggered: unmountBackendWindow.show()
        enabled: false
    }

    Action {
        id: editAction
        text: qsTr("Edit...")
        tooltip: qsTr("Edit")
    }

    Action {
        id: cutAction
        text: qsTr("Cut")
        tooltip: qsTr("Cut")
        shortcut: StandardKey.Cut
    }

    Action {
        id: copyAction
        text: qsTr("Copy")
        tooltip: qsTr("Copy")
        shortcut: StandardKey.Copy
    }

    Action {
        id: pasteAction
        text: qsTr("Paste")
        tooltip: qsTr("Paste")
        shortcut: StandardKey.Paste
    }

    menuBar: MainMenuBar {
        id:mainMenuBar
    }

    toolBar: ToolBar {
        id:mainToolbar

        RowLayout {
            id:tbLayout

            anchors.fill: parent
            anchors.rightMargin: defaultSpacing

            ToolButton {
                id:tbNew
                action: newKeyAction
            }
            ToolButton {
                id:tbDelete
                action: deleteAction
            }
            ToolButton {
                id:tbImport
                action: importAction
            }
            ToolButton {
                id:tbExport
                action: exportAction
            }
            ToolButton {
                id:tbUndo
                action: undoAction
            }
            ToolButton {
                id:tbRedo
                action: redoAction
            }
            ToolButton {
                id:tbSynchronize
                action: synchronizeAction
            }
            Item {
                width: Math.round(mainWindow.width*0.3 - 7*tbRedo.width - 7*defaultSpacing - defaultMargins)
                height: 28
            }

            Image {
                id: searchLogo
                source: "icons/edit-find.png"
            }
            SearchField {
                id: searchField
                Layout.fillWidth: true
                focus: true
                onAccepted: {searchResultsListView.model = treeView.model.find(text); searchResultsListView.currentIndex = -1}
            }
        }
    }

    ListModel {
        id: mountedBackendsModel
        ListElement {
            backendName: "Test"
        }
        ListElement {
            backendName: "Backend1"
        }
        ListElement {
            backendName: "Backend2"
        }
    }

    Row {
        id: mainRow
        anchors.fill: parent
        anchors.margins: defaultMargins
        spacing: defaultSpacing

        BasicRectangle {
            id:treeViewRectangle

            width: Math.round(parent.width*0.3)
            height: parent.height

            TreeView {
                id: treeView
            }
        }
        Column {
            id: keyMetaColumn

            spacing: defaultSpacing

            BasicRectangle {
                id: keyArea

                width: deltaKeyAreaWidth
                height: Math.round(mainRow.height*0.7 - defaultSpacing)

                Component {
                    id: tableViewColumnDelegate

                    Item {
                        anchors.fill: parent
                        anchors.margins: defaultSpacing

                        Text{
                            anchors.verticalCenter: parent.verticalCenter
                            text: styleData.value
                            color: (keyAreaView.copyPasteIndex === styleData.row && treeView.currentNode.path === keyAreaView.currentNodePath) ? disabledPalette.text : activePalette.text
                        }
                    }
                }

                TableView {
                    id: keyAreaView

                    property int copyPasteIndex
                    property string currentNodePath

                    anchors.fill: parent
                    anchors.margins: 2
                    frameVisible: false
                    alternatingRowColors: false
                    backgroundVisible: false

                    model:{
                        if(treeView.currentNode !== null)
                            if(treeView.currentNode.childCount > 0 && treeView.currentNode.childrenHaveNoChildren)
                                //TreeViewModel
                                treeView.currentNode.children
                    }
                    TableViewColumn {
                        role: "name"
                        title: qsTr("Name")
                        width: Math.round(keyArea.width*0.5)
                        delegate: tableViewColumnDelegate
                    }
                    TableViewColumn {
                        role: "value"
                        title: qsTr("Value")
                        width: Math.round(keyArea.width*0.5)
                        delegate: tableViewColumnDelegate
                    }

                    rowDelegate: Component {

                        Rectangle {
                            width: keyAreaView.width
                            color: styleData.selected ? activePalette.highlight : "transparent"

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.RightButton

                                onClicked: {
                                    keyAreaSelectedItem = model.get(styleData.row)

                                    if(mouse.button === Qt.RightButton)
                                        keyContextMenu.popup()
                                    else{
                                        keyAreaView.selection.clear()
                                        keyAreaView.selection.select(styleData.row)
                                        keyAreaView.currentRow = styleData.row
                                    }
                                }

                                onDoubleClicked: {
                                    keyAreaSelectedItem = model.get(styleData.row)
                                    editKeyWindow.show()
                                    editKeyWindow.populateMetaArea()
                                }
                            }
                        }
                    }
                }
            }
            BasicRectangle {
                id: metaArea

                width: deltaKeyAreaWidth
                height: Math.round(mainRow.height*0.3)

                ScrollView {
                    id: metaAreaScrollView

                    anchors.fill: parent
                    anchors.margins: defaultMargins

                    ListView {
                        id: metaAreaListView

                        model: metaAreaModel

                        delegate: Text {
                            color: activePalette.text
                            text: keyAreaSelectedItem === null ? "" : (name + ": " + value)
                        }
                    }
                }
            }
            BasicRectangle {
                id: searchResultsArea

                width: deltaKeyAreaWidth
                height: Math.round(mainRow.height*0.2)
                visible: false

                Button {
                    id: searchResultsCloseButton

                    iconSource: "icons/dialog-close.png"
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: Math.round(defaultMargins*0.25)
                    tooltip: qsTr("Close")
                    onClicked: keyMetaColumn.state = ""

                    style: ButtonStyle {
                        background: Rectangle {
                            color: searchResultsArea.color
                        }
                    }
                }

                ScrollView {
                    id: searchResultsScrollView

                    anchors.fill: parent
                    anchors.margins: defaultMargins
                    anchors.rightMargin: searchResultsCloseButton.width

                    ListView {
                        id: searchResultsListView

                        focus: false

                        highlight: Rectangle {
                            id: highlightBar
                            color: activePalette.highlight
                        }

                        delegate: Text {
                            color: activePalette.text
                            text: path

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {searchResultsListView.currentIndex = index}
                            }
                        }
                    }
                }
            }
            states:
                State {
                name: "SHOW_SEARCH_RESULTS"

                PropertyChanges {
                    target: keyArea
                    height: deltaKeyAreaHeight
                }
                PropertyChanges {
                    target: metaArea
                    height: deltaMetaAreaHeight
                }
                PropertyChanges {
                    target: searchResultsArea
                    visible: true
                }
            }
        }
    }
    statusBar: StatusBar {
        id:mainStatusBar

        RowLayout {
            id: statusBarRow

            Label {
                id: path
                anchors.fill: parent
                anchors.leftMargin: defaultMargins
                text: treeView.currentNode === null ? "" : treeView.currentNode.path + "/" + (keyAreaSelectedItem === null ? "" : keyAreaSelectedItem.name)
            }
        }
    }
}
