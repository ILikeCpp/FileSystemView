import QtQuick 2.9
import QtQuick.Window 2.0
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2

Window {
    id:root
    width: 640
    height: 480
    visible: true
    title:qsTr("文件操作")

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
                fileMgrForm = com.createObject(root);

                com.destroy();
            }
        }

        if (null != fileMgrForm)
        {
            fileMgrForm.show();
        }
    }

    Item {
        id: item
        anchors.fill: parent;

        //显示当前路径
        Rectangle {
            id: pathRect
            width: parent.width;
            height: label.height + 10;
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
                anchors.right: parent.right;
                anchors.rightMargin: 10;
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
                anchors.centerIn: parent;
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

            delegate: Item {
                id: fileItem
                width: gridView.cellWidth
                height: gridView.cellHeight

                MouseArea {
                    anchors.fill: parent;
                    onClicked: {
                        gridView.currentIndex = index;
                        gridView.currentFile = modelData.filePath;
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

            spacing: parent.width/15

            Button {
                id: okBtn
                width: parent.width/5
                text: qsTr("确定")

                onClicked: {
                    if (gridView.currentIndex != -1)
                    {
                        fileSystemModel.openFile(gridView.currentFile);
                    }
                }
            }

            Button {
                id: cancelBtn
                width: parent.width/5
                text: qsTr("取消")
                onClicked: {
                    gridView.currentIndex = -1;
                }
            }

            Button {
                id: newBtn
                width: parent.width/5
                text: qsTr("新建")
                onClicked: {
                    if (pathText.text == "")
                    {
                        return;
                    }

                    var obj = fileSystemModel.addNewFile(pathText.text);
                    var temp = fileArray;
                    temp.push(obj);
                    fileArray = temp;
                    gridView.currentIndex = fileArray.length-1;
                    gridView.currentFile = obj.filePath;
                }
            }

            Button {
                id: fileMgrBtn
                width: parent.width/5
                text: qsTr("文件管理")
                onClicked: {
                    moveToFileMgr();
                }
            }
        }
    }
}
