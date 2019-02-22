import QtQuick 2.8

Item {
    id: agree_btn_195_407
    width: 455
    height: 113

    Item {
        id: agree_btn_active_195_398
        x: 0
        y: 0
        Image {
            id: agree_btn_active_bg_195_396
            x: 0
            y: 0
            source: "assets/agree_btn_active_bg_195_396.png"
        }

        Text {
            id: i_agree_195_397
            x: 124
            y: 42
            color: "#222840"
            text: "I agree"
            font.pixelSize: 42
            font.family: "Rexlia"
        }
    }

    Item {
        id: agree_btn_pressed_195_402
        x: 0
        y: 0
        width: 454
        height: 112
        Image {
            id: agree_btn_pressed_bg_195_400
            x: 0
            y: 0
            anchors.horizontalCenterOffset: 0
            anchors.horizontalCenter: parent.horizontalCenter
            source: "assets/agree_btn_pressed_bg_195_400.png"
        }

        Text {
            id: i_agree_195_401
            height: 60
            color: "#41CD52"
            text: "I agree"
            anchors.verticalCenterOffset: 3
            font.capitalization: Font.AllUppercase
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            lineHeight: 3.1
            font.pixelSize: 42
            font.family: "Rexlia"
        }
    }
}




/*##^## Designer {
    D{i:0;UUID:"3fd2b2238a2a39d12ab28858c3051672"}D{i:2;UUID:"2505c47d1d989e34a74d95862034e127"}
D{i:3;UUID:"3d43883a09cf18fb8425f209b2f18c33"}D{i:1;UUID:"3ef9d52fc1c40aef50f57f273d93ed64"}
D{i:5;UUID:"1972a8baa9b009e03357fbc2279cd479"}D{i:6;UUID:"f30ba880dd64f840537522feb7971637"}
D{i:4;UUID:"94c9d64c77e984cb3a5a0f6d01d229e8"}
}
 ##^##*/
