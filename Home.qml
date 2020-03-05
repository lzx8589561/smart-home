import QtQuick 2.10
import QtQuick.Controls 2.3
import "./ui" as UI

Item {
    Component {
        id: menu
        MenuPage {
        }
    }

    Component {
        id: lovelace
        Lovelace {
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: function(){
            year.text = Qt.formatDateTime(new Date(), "yyyy-MM-dd dddd")
            time.text = Qt.formatDateTime(new Date(), "hh:mm:ss")
        }
    }

    Text {
        id: time
        anchors.top:parent.top
        anchors.topMargin: 100
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatDateTime(new Date(), "hh:mm:ss")
        font.pixelSize: 100
    }

    Text {
        id: year
        anchors.top:time.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatDateTime(new Date(), "yyyy-MM-dd dddd")
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 60
        verticalAlignment: Text.AlignVCenter
    }

    UI.ZButton {
        id: menuButtom
        anchors.left: parent.left
        anchors.leftMargin: 50
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        text: qsTr("Menu")
        onClicked: function(){
            stackView.push(menu)
            snackbar.open("In menu, Ha Ha Ha !!!")
        }
    }

    UI.ZButton {
        id: quitButton
        anchors.right: parent.right
        anchors.rightMargin: 50
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        text: qsTr("Quit")
        onClicked: function(){
            Qt.quit()
        }
    }

    UI.ZButton {
        id: button
        anchors.left: parent.left
        anchors.leftMargin: 50
        anchors.bottom: menuButtom.top
        anchors.bottomMargin: 50
        text: qsTr("Home")
        onClicked: {
            stackView.push(lovelace)
        }
    }

}
