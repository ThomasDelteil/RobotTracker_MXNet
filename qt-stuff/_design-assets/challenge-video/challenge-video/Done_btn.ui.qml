import QtQuick 2.8

Item {
    id: done_btn
    width: 455
    height: 113

    Item {
        id: done_btn_inactive
        x: 0
        y: 0
        Image {
            id: done_btn_inactive_bg_243_455
            x: 0
            y: 0
            source: "assets/done_btn_inactive_bg_243_455.png"
        }

        Text {
            id: done_243_453
            x: 154
            y: 41
            color: "#848895"
            text: "Done"
            font.pixelSize: 42
            font.family: "Rexlia"
        }
    }

    Item {
        id: done_btn_pressed
        x: 0
        y: 0
        Image {
            id: done_btn_pressed_bg_243_450
            x: 0
            y: 0
            source: "assets/done_btn_pressed_bg_243_450.png"
        }

        Text {
            id: done_243_448
            x: 154
            y: 41
            color: "#B5B7BF"
            text: "Done"
            font.pixelSize: 42
            font.family: "Rexlia"
        }
    }

    Item {
        id: done_btn_active
        x: 0
        y: 0
        Image {
            id: done_btn_active_bg_243_440
            x: 0
            y: 0
            source: "assets/done_btn_active_bg_243_440.png"
        }

        Text {
            id: done_243_438
            x: 154
            y: 41
            color: "#222840"
            text: "Done"
            font.pixelSize: 42
            font.family: "Rexlia"
        }
    }
}

/*##^## Designer {
    D{i:0;UUID:"bf1af86fc4e4a71c331cf5c4c68cedc3"}D{i:2;UUID:"c01f1be6b7657da7e84ed2e3abc3e8eb"}
D{i:3;UUID:"fe3dcacde8e45500d93b270b455011eb"}D{i:1;UUID:"3d68b8a85ce580954e7a6f992fdd9489"}
D{i:5;UUID:"8e123d4b102cfb4d3ad72efe64ad7ede"}D{i:6;UUID:"fe3dcacde8e45500d93b270b455011eb"}
D{i:4;UUID:"69796fba530cfea95fd0ee76fdbf532b"}D{i:8;UUID:"41693af43cbe2598d387d68473531ec4"}
D{i:9;UUID:"fe3dcacde8e45500d93b270b455011eb"}D{i:7;UUID:"428ff52b64a8f13bd5997f82732fd35b"}
}
 ##^##*/

