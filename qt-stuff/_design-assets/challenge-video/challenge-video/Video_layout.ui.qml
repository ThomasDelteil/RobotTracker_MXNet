import QtQuick 2.8

Item {
    id: video_layout
    width: 1920
    height: 1080

    Image {
        id: video_mockup_243_269
        x: 0
        y: 0
        source: "assets/video_mockup_243_269.png"
    }

    Item {
        id: control_bar
        x: 0
        y: 838
        Image {
            id: control_barAsset
            x: 0
            y: 0
            source: "assets/control_bar.png"
        }
    }

    Done_btn {
        id: done_btn
        x: 1244
        y: 918
    }

    Start_stop_btn {
        id: start_stop_btn
        x: 223
        y: 918
    }
}






/*##^## Designer {
    D{i:0;UUID:"bbde620954409fc12d68d7b87d7fa776"}D{i:2;UUID:"c6cf5d963929f38e29dbc89021e26d19"}
D{i:4;UUID:"64ae0cde15361c2a7f515285900cd74f_asset"}D{i:3;UUID:"64ae0cde15361c2a7f515285900cd74f"}
}
 ##^##*/
