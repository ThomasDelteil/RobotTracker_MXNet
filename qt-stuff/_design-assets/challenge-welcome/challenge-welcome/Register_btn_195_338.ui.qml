import QtQuick 2.8

Item {
    id: register_btn_195_338
    width: 454
    height: 112

    Image {
        id: register_btn_active_bg_195_351
        x: 0
        y: 0
        source: "assets/register_btn_active_bg_195_351.png"
    }

    Text {
        id: register_195_350
        x: 95
        y: 42
        color: "#222840"
        text: "Register"
        font.letterSpacing: 1
        anchors.verticalCenterOffset: 1
        font.capitalization: Font.AllUppercase
        font.weight: Font.Bold
        anchors.verticalCenter: register_btn_active_bg_195_351.verticalCenter
        anchors.horizontalCenter: register_btn_active_bg_195_351.horizontalCenter
        font.pixelSize: 42
        font.family: "Rexlia"
    }

    Image {
        id: register_btn_pressed_bg_195_353
        x: 0
        y: 0
        visible: false
        source: "assets/register_btn_pressed_bg_195_353.png"
    }

    Text {
        id: register_195_349
        x: 95
        y: 42
        color: "#41CD52"
        text: "Register"
        visible: false
        font.letterSpacing: 1
        anchors.verticalCenterOffset: 1
        font.capitalization: Font.AllUppercase
        font.weight: Font.Bold
        anchors.verticalCenter: register_btn_pressed_bg_195_353.verticalCenter
        anchors.horizontalCenter: register_btn_pressed_bg_195_353.horizontalCenter
        font.pixelSize: 42
        font.family: "Rexlia"
    }

    Image {
        id: register_btn_disabled_bg_195_346
        x: 0
        y: 0
        visible: false
        source: "assets/register_btn_disabled_bg_195_346.png"
    }

    Text {
        id: register_195_348
        x: 95
        y: 42
        color: "#848895"
        text: "Register"
        visible: false
        font.letterSpacing: 1
        anchors.verticalCenterOffset: 1
        font.capitalization: Font.AllUppercase
        font.weight: Font.Bold
        anchors.verticalCenter: register_btn_disabled_bg_195_346.verticalCenter
        anchors.horizontalCenter: register_btn_disabled_bg_195_346.horizontalCenter
        font.pixelSize: 42
        font.family: "Rexlia"
    }
}

/*##^## Designer {
    D{i:0;UUID:"3fd2b2238a2a39d12ab28858c3051672"}D{i:1;UUID:"2505c47d1d989e34a74d95862034e127"}
D{i:2;UUID:"3d43883a09cf18fb8425f209b2f18c33"}D{i:3;UUID:"1972a8baa9b009e03357fbc2279cd479"}
D{i:4;UUID:"f30ba880dd64f840537522feb7971637"}D{i:5;UUID:"5adbb7111ebb2b3eb967deea0f57b762"}
D{i:6;UUID:"fe3dcacde8e45500d93b270b455011eb"}
}
 ##^##*/

