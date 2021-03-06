import QtQuick 2.10
import QtQuick.Window 2.10
import QtQuick.Controls 2.3
import QtWebSockets 1.1
import FPS 1.0
import "./ui" as UI

Window {
    id: main
    visible: true
    width: 1024
    height: 600
    title: qsTr("Hello World")

    signal stateSignal(string entityId)
    signal resultSignal(var result)

    Component {
        id: home
        Home {
        }
    }

    UI.ZLoading {
        id: loading
        z:9998
        ztitleText: qsTr("loading...")
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

        UI.ZText {
            id: backButton
            visible: stackView.depth > 1
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            text: UI.ZFontIcon.fa_angle_left
            font.family: UI.ZFontIcon.fontFontAwesome.name
            color: "white"
            font.pixelSize: 35
        }

        UI.ZText {
            id: backLabel
            visible: stackView.depth > 1
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: backButton.right
            anchors.leftMargin: 10
            text: stackView.depth > 1 ? stackView.get(stackView.index - 1).title : ""
            color: "white"
            font.pixelSize: 20
        }

        MouseArea {
            anchors {
                top: parent.top
                left: backButton.left
                right: backLabel.right
                bottom: parent.bottom
            }

            onPressed: {
                backButton.color = "#cecece"
                backLabel.color = "#cecece"
            }

            onReleased: {
                backButton.color = "white"
                backLabel.color = "white"
            }

            onClicked: {
                stackView.pop()
            }
        }

        UI.ZText {
            id: titleLabel
            anchors.centerIn: parent
            text: stackView.currentItem.title
            color: "white"
            font.pixelSize: 20
        }

//        FPSLabel {
//            anchors.horizontalCenter: parent.horizontalCenter
//            width: 100
//            height: 50
//        }

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

    property string wsUrl: "ws://192.168.8.111:8123/api/websocket"
    property var authReq: {
        "id": 1,
        "body": "{\"type\": \"auth\",\"access_token\": \"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI1ZWJmNGU1ZTZiMzE0ODE1YmRmY2Q0M2RjNjgxNWYyNyIsImlhdCI6MTU4Mjk1ODQ1OCwiZXhwIjoxODk4MzE4NDU4fQ.DFPiKTes1cahvRc3mWz_noIqseNAf7WuVg3ivv-y8Ak\"}"
    }
    property var subscribeReq: {
        "id": 2,
        "body": "{\"id\": 2,\"type\": \"subscribe_events\",\"event_type\": \"state_changed\"}"
    }
    property var getStatesReq: {
        "id": 3,
        "body": "{\"id\":3,\"type\":\"get_states\"}"
    }
    property var lovelaceReq: {
        "id": 15,
        "body": "{\"id\":15,\"type\":\"lovelace/config\",\"force\":false}"
    }
    property var subscribeLovelaceReq: {
        "id": 20,
        "body": "{\"id\": 20,\"type\": \"subscribe_events\",\"event_type\": \"lovelace_updated\"}"
    }
    property var states: null
    property var lovelaceArray: null
    property int reqIndex: 30

    property int reLovelaceReqIndex: 0

    WebSocket {
        id: socket
        url: wsUrl
        onTextMessageReceived: {
            var receiveObj = JSON.parse(message)

            switch(receiveObj.type){
                case "auth_ok":
                    socket.sendTextMessage(subscribeReq.body)
                    socket.sendTextMessage(getStatesReq.body)
                    socket.sendTextMessage(lovelaceReq.body)
                    socket.sendTextMessage(subscribeLovelaceReq.body)
                    break
                case "event":
                    switch(receiveObj.id){
                        case subscribeReq.id:
                            const i = states.findIndex(function(item){
                                return item.entity_id === receiveObj.event.data.entity_id
                            })
                            states[i] = receiveObj.event.data.new_state
                            stateSignal(receiveObj.event.data.entity_id)
                            break
                        case subscribeLovelaceReq.id:
                            reqIndex ++
                            reLovelaceReqIndex = reqIndex
                            socket.sendTextMessage("{\"id\":"+reLovelaceReqIndex+",\"type\":\"lovelace/config\",\"force\":false}")
                            break
                    }
                    break
                case "result":
                    switch(receiveObj.id){
                        case subscribeReq.id:
                            if(receiveObj.success){
                                console.log("订阅成功")
                            }else{
                                console.log("订阅失败")
                            }
                            break
                        case subscribeLovelaceReq.id:
                            if(receiveObj.success){
                                console.log("订阅布局成功")
                            }else{
                                console.log("订阅布局失败")
                            }
                            break
                        case getStatesReq.id:
                            if(receiveObj.success){
                                console.log("获取状态成功")
                                states = receiveObj.result
                                console.log(JSON.stringify(states))
                            }else{
                                console.log("获取状态失败")
                            }
                            break
                        case lovelaceReq.id:
                            if(receiveObj.success){
                                console.log("获取布局成功")
                                lovelaceArray = receiveObj.result.views
                                console.log(JSON.stringify(lovelaceArray))
                            }else{
                                console.log("获取布局失败")
                            }
                            break
                        case reLovelaceReqIndex:
                            if(receiveObj.success){
                                console.log("重获取布局成功")
                                lovelaceArray = receiveObj.result.views
                                console.log(JSON.stringify(lovelaceArray))
                            }else{
                                console.log("重获取布局失败")
                            }
                            break
                        default:
                            resultSignal(receiveObj)
                    }
                    break
            }
        }

        onStatusChanged:{
            if (socket.status == WebSocket.Error) {
                console.log("Error: " + socket.errorString)
            } else if (socket.status == WebSocket.Open) {
                socketCheckTimer.running = false
                console.log("Socket connection success")
                loading.zclose()
                socket.sendTextMessage(authReq.body)
            } else if (socket.status == WebSocket.Closed) {
                socketCheckTimer.running = true
                console.log("Socket closed")
            }
        }
        active: true
        Component.onCompleted: {
            loading.zopen()
        }
    }

    Timer {
        id: socketCheckTimer
        interval: 2000; running: true; repeat: true
        onTriggered: {
            if(socket.status != WebSocket.Open && socket.status != WebSocket.Connecting){
                console.log("reconnect")
                socket.active = false
                socket.active = true
            }
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
