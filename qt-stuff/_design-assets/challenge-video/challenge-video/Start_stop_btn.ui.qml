import QtQuick 2.8

Item {
    id: start_stop_btn
    width: 455
    height: 113

    Item {
        id: stop_btn_pressed
        x: 0
        y: 0
        Image {
            id: stop_btn_pressed_bg_243_433
            x: 0
            y: 0
            source: "assets/stop_btn_pressed_bg_243_433.png"
        }

        Text {
            id: stop_243_434
            x: 155
            y: 41
            color: "#B5B7BF"
            text: "Stop"
            font.pixelSize: 42
            font.family: "Rexlia"
        }
    }

    Item {
        id: stop_btn_active
        x: 0
        y: 0
        Image {
            id: stop_btn_active_bg_243_430
            x: 0
            y: 0
            source: "assets/stop_btn_active_bg_243_430.png"
        }

        Text {
            id: stop_243_428
            x: 155
            y: 41
            color: "#222840"
            text: "Stop"
            font.pixelSize: 42
            font.family: "Rexlia"
        }
    }

    Item {
        id: start_btn_pressed
        x: 0
        y: 0
        Image {
            id: start_btn_pressed_bg_243_424
            x: 0
            y: 0
            source: "assets/start_btn_pressed_bg_243_424.png"
        }

        Text {
            id: start_243_418
            x: 140
            y: 41
            color: "#B5B7BF"
            text: "Start"
            font.pixelSize: 42
            font.family: "Rexlia"
        }
    }

    Item {
        id: start_btn_active
        x: 0
        y: 0
        Image {
            id: start_btn_active_bg_243_410
            x: 0
            y: 0
            source: "assets/start_btn_active_bg_243_410.png"
        }

        Text {
            id: start_243_407
            x: 140
            y: 41
            color: "#222840"
            text: "Start"
            font.pixelSize: 42
            font.family: "Rexlia"
        }
    }
}

/*##^## Designer {
    D{i:0;UUID:"a7dc4ff4ae5ea8ac0a56f8b73bf36b92"}D{i:2;UUID:"d2938aac302d5a0a3cffce8f5a4b4632"}
D{i:3;UUID:"fe3dcacde8e45500d93b270b455011eb"}D{i:1;UUID:"c44b9ebe816ec9742943e313cc7007ca"}
D{i:5;UUID:"e519704a248a240e30dc4c92332b63da"}D{i:6;UUID:"fe3dcacde8e45500d93b270b455011eb"}
D{i:4;UUID:"7c06116c8162a8d0c04d4660f77bbffe"}D{i:8;UUID:"5b255dafb450f32987bba16d0c4191d5"}
D{i:9;UUID:"fe3dcacde8e45500d93b270b455011eb"}D{i:7;UUID:"6bc64f4d28f59182f0eb13a2a7b667a1"}
D{i:11;UUID:"70b0bf897ec446063be561b49cac7c71"}D{i:12;UUID:"fe3dcacde8e45500d93b270b455011eb"}
D{i:10;UUID:"263bd7d7df7b65aeebeda75f141a8100"}
}
 ##^##*/

