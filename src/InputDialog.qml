import QtQuick 2.9
import QtQuick.Dialogs 1.2

Dialog {
    id: inputDialog
    visible: false
    width: 200;
    height: 100;

    standardButtons: StandardButton.Save | StandardButton.Cancel

    property alias inputText: textInput.text

    Rectangle {
        id: rect;
        width: parent.width-10;
        height: textInput.height + 10;
        anchors.centerIn: parent;
        border.width: 1;
        border.color: "black"
        clip: true;

        TextInput {
            id: textInput
            cursorVisible: false
            anchors.left: parent.left;
            anchors.leftMargin: 5
            anchors.right: parent.right;
            anchors.rightMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            selectByMouse: true;
        }
    }
}
