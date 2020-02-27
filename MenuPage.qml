import QtQuick 2.10
import QtQuick.Controls 2.3
import "./ui" as UI

Item {
    Text {
        id: text1
        x: 163
        y: 44
        text: qsTr("This is pretty menu!!!")
        font.pixelSize: 32
    }

    Rectangle {
        id: rectangle
        x: 121
        y: 138
        width: 77
        height: 64
        color: "#ef2929"
    }

    Rectangle {
        id: rectangle1
        x: 282
        y: 138
        width: 77
        height: 64
        color: "#ef2929"
    }

    Rectangle {
        id: rectangle2
        x: 447
        y: 138
        width: 77
        height: 64
        color: "#ef2929"
    }

    Rectangle {
        id: rectangle3
        x: 121
        y: 250
        width: 77
        height: 64
        color: "#f57900"
    }

    Rectangle {
        id: rectangle4
        x: 282
        y: 250
        width: 77
        height: 64
        color: "#f57900"
    }

    Rectangle {
        id: rectangle5
        x: 447
        y: 250
        width: 77
        height: 64
        color: "#f57900"
    }

}
