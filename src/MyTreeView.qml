import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Item {
    id:treeViewRct
    anchors.fill: parent;

    property alias treeCurIndex: treeView.currentIndex;

    TreeView {
        id:treeView
        width: parent.width
        height: parent.height

        headerVisible: false
        rootIndex: undefined
        style: treeViewStyle
        itemDelegate: treeItemDelegate
        sortIndicatorVisible: true
        model: fileSystemModel

        TableViewColumn {
            id:nodeNameColumn
            role:"fileName"
            width: treeViewRct.width*3
        }

        onClicked: {
            pathText.text = fileSystemModel.getFilePath(index);

            fileArray = fileSystemModel.getFileArray(index);

            suffixArray = fileSystemModel.getSuffixArray(index);

            gridView.currentIndex = -1;
        }

        onDoubleClicked: {
            if (treeView.isExpanded(index))
            {
                treeView.collapse(index)
            }
            else
            {
                treeView.expand(index)
            }
        }
    }
    Component {
        id:treeViewStyle
        TreeViewStyle {
            branchDelegate: Image {
                id:image
                source: styleData.isExpanded ? "collapse.png" : "expansion.png"
            }
            rowDelegate: Rectangle {
                height: 30
                color:styleData.selected ? "#f6b4ff" : "#46b4aa"
            }
        }
    }

    Component {
        id:treeItemDelegate
        Rectangle {
            height: 30
            width: parent.width
            color: styleData.selected ? "#f6b4ff" : "#46b4aa"

            Image {
                id:logo
                height: 20
                width: 15
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                source: styleData.hasChildren ? "folder.png" : "loadFile.png";
            }

            Text {
                width: 100
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: logo.right
                anchors.leftMargin: 5
                text:styleData.value
                color:styleData.selected ? "#4d68ff" : "#4d6878"
                font.pointSize: 12
            }
        }
    }
}



