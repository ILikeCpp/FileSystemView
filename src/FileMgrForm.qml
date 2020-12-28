import QtQuick 2.9
import QtQuick.Window 2.0
import QtQuick.Controls 2.2

Window {
    id:root
    width: 640
    height: 480
    visible: true
    title:qsTr("文件管理")

    property var fileArray:[]

    property var fileMgrForm:null;

    property var suffixArray:["*.*"]

    function moveToFileMgr()
    {
        if (null == fileMgrForm)
        {
            var com = Qt.createComponent("qrc:/FileMgrForm.qml")
            if (com.status === Component.Ready)
            {
                fileMgrForm = Qt.createQmlObject(root);
            }
            com.destroy();
        }

        if (null != fileMgrForm)
        {
            fileMgrForm.show();
        }
    }

    InputDialog {
        id: inputDialog

        onAccepted: {
            if (fileSystemModel.renameFile(gridView.currentFile, inputText))
            {
                fileArray.splice(gridView.currentIndex,1);
                var temp = fileArray;
                var obj = new Object;
                obj.filePath = gridView.currentFile;
                obj.fileName = inputText;
                obj.icon = gridView.currentFileIcon;
                temp.push(obj);
                fileArray = temp;

                gridView.currentIndex = -1;
            }
        }
    }

    Item {
        id: item
        anchors.fill: parent;

        //显示当前路径
        Rectangle {
            id: pathRect
            width: parent.width;
            height: Math.max(label.height + 10,suffixBox.height+10);
            border.width: 1;
            border.color: "lightblue"

            Text {
                id: label
                text: qsTr("当前文件夹路径：")
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left;
                anchors.leftMargin: 10;
            }

            Text {
                id: pathText
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: label.right;
                anchors.leftMargin: 10
                anchors.right: suffixBox.left;
                anchors.rightMargin: 10;
            }

            MyComboBox {
                id: suffixBox
                model: suffixArray;
                anchors.right: parent.right;
                anchors.rightMargin: 10;
                anchors.verticalCenter: parent.verticalCenter

                onActivated: {
                    console.debug(suffixBox.currentText)
                    fileArray = fileSystemModel.getFileArrayBySuffix(treeView.treeCurIndex,suffixBox.currentText)

                    gridView.currentIndex = -1;
                }
            }
        }

        //树形
        Rectangle {
            id: treeRect
            width: parent.width/2
            anchors.top: pathRect.bottom;
            anchors.topMargin: 10;
            height: parent.height-pathRect.height-bottomItem.height-30;
            border.width: 1;
            border.color: "lightblue"

            MyTreeView {
                id: treeView
            }
        }

        //文件列表
        GridView {
            id: gridView
            anchors.left: treeRect.right
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.top: treeRect.top
            anchors.topMargin: 10
            anchors.bottom: treeRect.bottom
            anchors.bottomMargin: 10

            boundsBehavior: Flickable.StopAtBounds

            cellWidth: gridView.width/4
            cellHeight: gridView.width/4

            clip: true
            model: fileArray

            highlight: Rectangle { color: "lightsteelblue"; radius: 5 }
            focus: true

            property string currentFile: ""
            property string currentFileName: ""
            property string currentFileIcon: ""

            delegate: Item {
                id: fileItem
                width: gridView.cellWidth
                height: gridView.cellHeight

                MouseArea {
                    anchors.fill: parent;
                    onClicked: {
                        gridView.currentIndex = index;
                        gridView.currentFile = modelData.filePath;
                        gridView.currentFileName = modelData.fileName;
                        gridView.currentFileIcon = modelData.icon;
                    }
                }

                Image {
                    id: fileImg
                    source: modelData.icon
                    sourceSize: Qt.size(fileItem.width*0.9,fileItem.height*0.9)
                    anchors.top: parent.top;
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    id: fileName
                    text: modelData.fileName
                    width: fileItem.width-10
                    anchors.top: fileImg.bottom;
                    anchors.topMargin: 5;
                    anchors.bottom: parent.bottom;
                    anchors.bottomMargin: 5
                    wrapMode: Text.WrapAnywhere;
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }


        //底部按钮
        Row {
            id: bottomItem
            width: parent.width-20
            anchors.bottom: parent.bottom;
            anchors.bottomMargin: 10;
            anchors.horizontalCenter: parent.horizontalCenter

            spacing: parent.width/24

            Button {
                id: cutBtn
                width: parent.width/6
                text: qsTr("剪切")

                onClicked: {
                    if (gridView.currentIndex != -1)
                    {
                        pasteBtn.cutFilePath = gridView.currentFile;
                    }
                }
            }

            Button {
                id: copyBtn
                width: parent.width/6
                text: qsTr("复制")

                onClicked: {
                    if (gridView.currentIndex != -1)
                    {
                        pasteBtn.copyFilePath = gridView.currentFile;
                    }
                }
            }

            Button {
                id: pasteBtn
                width: parent.width/6
                text: qsTr("粘贴")

                property string cutFilePath: ""
                property string copyFilePath: ""

                onClicked: {
                    if (pathText.text !== "" && (cutFilePath !== ""))
                    {
                        fileSystemModel.cutFile(pathText.text, cutFilePath)

                        fileArray = [];
                        fileArray = fileSystemModel.getFileArray(treeView.treeCurIndex);

                        gridView.currentIndex = -1;
                    }

                    if (pathText.text !== "" && (copyFilePath !== ""))
                    {
                        fileSystemModel.copyFile(pathText.text, copyFilePath);

                        fileArray = [];
                        fileArray = fileSystemModel.getFileArray(treeView.treeCurIndex);

                        gridView.currentIndex = -1;
                    }
                }
            }

            Button {
                id: renameBtn
                width: parent.width/6
                text: qsTr("重命名")
                onClicked: {
                    if (gridView.currentIndex != -1)
                    {
                        inputDialog.title = "重命名";
                        inputDialog.inputText = gridView.currentFileName;
                        inputDialog.open();
                    }
                }
            }

            Button {
                id: delBtn
                width: parent.width/6
                text: qsTr("删除")
                onClicked: {
                    if (gridView.currentIndex != -1)
                    {
                        if (fileSystemModel.removeFile(gridView.currentFile))
                        {
                            fileArray.splice(gridView.currentIndex,1);
                            var temp = fileArray;
                            fileArray = temp;

                            gridView.currentIndex = -1;
                        }
                    }
                }
            }
        }
    }
}
