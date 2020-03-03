import QtQuick 2.10
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import "./ui" as UI

Item {

    property var lovelaceCards: value

    UI.ZTopMenu {
        id: topMenu
        anchors.top:parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 45
        zclickedCall: function(index){
            console.log("点击索引",main.lovelaceArray[index]["title"])
            gridView.darw()
        }
        Component.onCompleted: {
            zmodel = main.lovelaceArray.map(item => ({"name": item.title}))
        }
    }

    GridView {
        id: gridView
        anchors {
            left: parent.left
            top: topMenu.bottom
            right: parent.right
            bottom: parent.bottom
        }
        cellWidth: width / 2
        cellHeight: 240
        clip: true
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AlwaysOn
        }

        model: ListModel {}

        add: Transition {
            NumberAnimation { properties: "y"; from: 100; duration: 200;easing.type: Easing.OutQuad }
        }

        Component.onCompleted: {
            darw()
        }

        function darw(){
            let cards = []
            const item = main.lovelaceArray[topMenu.currentIndex]
            item.cards.forEach(card => {
                switch(card.type){
                    case "entities":
                        cards.push(card)
                    break
                }
            })

            lovelaceCards = cards
            model.clear()
            lovelaceCards.forEach(item => model.append(item))
        }

        function findEntity(id){
            return main.states.find(item=>(item.entity_id === id))
        }

        delegate: Item {
            width: gridView.cellWidth
            height: gridView.cellHeight
            Rectangle {
                id: rectBox
                anchors.fill: parent
                anchors.leftMargin: index % 2 == 0 ? 20 : 10
                anchors.rightMargin: index % 2 == 1 ? 20 : 10
                anchors.topMargin: 20
//                color: "red"
//                radius: 5
                clip: true

                Rectangle {
                    id: titleRectangle
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                    height: title ? 40 : 0
                    color: "#03a9f496"
                    UI.ZText {
                        text: title ? title : ""
                        anchors.centerIn: titleRectangle
                        font.pixelSize: 20

                    }
                }



                ListView {
                    id: listView
                    anchors {
                        top: titleRectangle.bottom
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                    clip: true
                    ScrollBar.vertical: ScrollBar {
                        id: control
                        size: 0.3
                        position: 0.2
                        active: true
                        orientation: Qt.Vertical

                        contentItem: Rectangle {
                            implicitWidth: 3
                            implicitHeight: 100
                            radius: width / 2
                            color: control.pressed ? "#bbbbbb" : "#d4d4d4"
                        }
                    }




                    model: entities

                    delegate: Rectangle {
                        id: rowEntityRect
                        height: 50
                        width: listView.width
//                        color: "red"
                        property string entityState: gridView.findEntity(entity).state

                        UI.ZText {
                            id: iconText
                            width: entity.startsWith("switch") ||
                                   entity.startsWith("scene") ||
                                   entity.startsWith("sensor") ? 24 : 0
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text:
                                entity.startsWith("switch") ? UI.ZFontIcon.fa_flash :
                                entity.startsWith("scene") ? UI.ZFontIcon.fa_puzzle_piece :
                                entity.startsWith("sensor") ? UI.ZFontIcon.fa_thermometer :
                                UI.ZFontIcon.fa_puzzle_piece
                            font.family: UI.ZFontIcon.fontFontAwesome.name
//                            color: "white"
                            font.pixelSize: 20
                            clip: true
                        }

                        UI.ZText {
                            anchors.left: iconText.right
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: gridView.findEntity(entity).attributes.friendly_name
                            font.pixelSize: 20
                        }
                        UI.ZText {
                            visible: (entity.startsWith("switch") && rowEntityRect.entityState === "unavailable") || entity.startsWith("sensor")
                            anchors.right: parent.right
                            anchors.rightMargin: 15
                            anchors.verticalCenter: parent.verticalCenter
                            text: rowEntityRect.entityState === "unavailable" ? "不可用" : rowEntityRect.entityState
                            font.pixelSize: 16
                        }
                        UI.ZCheckBox {
                            visible: (entity.startsWith("switch") && rowEntityRect.entityState !== "unavailable")
                            id: checkBox
                            width: 50
                            height: 50
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: ""
                            checked: rowEntityRect.entityState === "on"
                            property int reqi: 0

                            onClicked: {
                                reqi = main.reqIndex
                                const reqBody = "{\"type\":\"call_service\",\"domain\":\"switch\",\"service\":\""+ (checked ? "turn_on" : "turn_off") +"\",\"service_data\":{\"entity_id\":\""+entity+"\"},\"id\":"+main.reqIndex+"}"
                                main.reqIndex = main.reqIndex + 1
                                socket.sendTextMessage(reqBody)
                            }

                            Connections{
                                target: main
                                onStateSignal:{
                                    if(entityId === entity){
                                        rowEntityRect.entityState = gridView.findEntity(entity).state
                                        checkBox.checked = rowEntityRect.entityState === "on"
                                    }
                                }
                                onResultSignal:{
                                    if(result.id === checkBox.reqi){
                                        if(result.success){
                                            snackbar.open("操作成功")
                                        } else{
                                            snackbar.open("操作失败，请检查连接")
                                        }
                                    }
                                }
                            }
                        }

                        UI.ZButton {
                            id: activateButton
                            visible: entity.startsWith("scene")
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: "激活"
                            property int reqi: 0

                            onClicked: {
                                reqi = main.reqIndex
                                const reqBody = "{\"type\":\"call_service\",\"domain\":\"scene\",\"service\":\"turn_on\",\"service_data\":{\"entity_id\":\""+entity+"\"},\"id\":"+main.reqIndex+"}"
                                main.reqIndex = main.reqIndex + 1
                                socket.sendTextMessage(reqBody)
                            }

                            Connections{
                                target: main
                                onResultSignal:{
                                    if(result.id === activateButton.reqi){
                                        if(result.success){
                                            snackbar.open("激活成功")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            DropShadow {
                anchors.fill: rectBox
                horizontalOffset: 2
                verticalOffset: 2
                radius: 10.0
                samples: 16
                color: "#80000000"
                source: rectBox
            }
        }

    }

}
