import QtQuick 2.10
import QtQuick.Window 2.10
import QtQuick.Controls 2.3
import FPS 1.0
import "./ui" as UI

Window {
    visible: true
    width: 1024
    height: 600
    title: qsTr("Hello World")

    Component {
        id: home
        Home {
        }
    }

    UI.ZSnackbar {
        id: snackbar
        z:9999
    }

    Rectangle {
        id: headerRect
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 50
        color: "#404040"

        UI.ZButton {
            id: button
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.left: parent.left
            anchors.leftMargin: 8
            width: 80
            height: 35
            text: qsTr("Back")

            onClicked: function(){
                stackView.pop()
            }
        }

        FPSLabel {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 100
            height: 50
        }

        UI.ZText{
            text: UI.ZFontIcon.fa_signal
            font.pixelSize: 20
            font.family: UI.ZFontIcon.fontFontAwesome.name
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 8
            width: 20
            color: "white"
        }
    }

    StackView {
        id: stackView
        anchors.top: headerRect.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        initialItem: home
    }


}
