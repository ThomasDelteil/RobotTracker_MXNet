import QtQuick 2.8

Item {
    id: main
    width: 1920
    height: 1080
    property alias low_left_195_216Alias: low_left_195_216

    Rectangle {
        id: background_wall
        color: "#cde2ee"
        anchors.fill: parent
    }

    Rectangle {
        id: floor
        color: "#b17f4a"
        anchors.topMargin: 1050
        anchors.fill: parent
    }

    Item {
        id: left_shelf
        y: 35
        width: 450
        anchors.left: parent.left
        anchors.leftMargin: 0
        Image {
            id: low_left_195_216
            x: 0
            y: 223
            source: "assets/low_left_195_216.png"
        }

        Image {
            id: top_left_195_214
            x: 0
            y: 0
            source: "assets/top_left_195_214.png"
        }
    }

    Item {
        id: right_shelf
        x: 1469
        y: 37
        width: 450
        anchors.right: parent.right
        anchors.rightMargin: 0
        Image {
            id: low_right_195_357
            x: 0
            y: 221
            source: "assets/low_right_195_357.png"
        }

        Image {
            id: top_right_195_220
            x: 0
            y: 0
            source: "assets/top_right_195_220.png"
        }
    }






    Image {
        id: info_background
        x: 526
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 0
        source: "assets/info_background_195_307.png"
    }

    Image {
        id: niryo_left
        y: 525
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 4
        source: "assets/niryo1_195_305.png"
    }

    Image {
        id: niryo_right
        x: 1428
        y: 590
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 78
        source: "assets/niryo2_195_303.png"
    }


    Register_btn_195_338 {
        id: register_btn
        x: 733
        anchors.top: terms_btn.bottom
        anchors.topMargin: 45
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Terms_btn_195_325 {
        id: terms_btn
        x: 733
        anchors.top: check_box.bottom
        anchors.topMargin: 26
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Check_box_195_327 {
        id: check_box
        x: 783
        anchors.horizontalCenterOffset: -147
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: text_box.bottom
        anchors.topMargin: 28
    }


    Text {
        id: i_agree_to_the_terms_195_316
        y: 664
        color: "#09102B"
        text: "I agree to the terms"
        anchors.verticalCenter: check_box.verticalCenter
        anchors.left: check_box.right
        anchors.leftMargin: 36
        font.pixelSize: 32
        font.family: "Titillium Web"
    }

    Rectangle {
        id: text_box
        x: 661
        y: 1206
        width: 700
        height: 70
        color: "#ffffff"
        anchors.top: parent.top
        anchors.topMargin: 551
        anchors.horizontalCenter: parent.horizontalCenter
        border.color: "#09102b"
        border.width: 2
    }

    Text {
        id: johnnydoe76_gmail_com_195_315
        x: 762
        color: "#43ADEE"
        text: "johnnydoe76@gmail.com"
        font.weight: Font.Bold
        anchors.top: text_box.bottom
        anchors.topMargin: -64
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 36
        font.family: "Titillium Web"
    }

    Text {
        id: register_with_your_email_to_play__195_313
        x: 733
        color: "#09102B"
        text: "Register with your username to play!"
        anchors.top: parent.top
        anchors.topMargin: 487
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 34
        font.family: "Titillium Web"
    }


    Text {
        id: username
        color: "#09102b"
        text: "UserNameHere3455"
        anchors.top: parent.top
        anchors.topMargin: 401
        font.weight: Font.Bold
        font.bold: false
        anchors.left: by.right
        anchors.leftMargin: 0
        font.pixelSize: 34
        font.family: "Titillium Web"
    }

    Text {
        id: by
        x: 788
        width: 44
        height: 52
        color: "#43ADEE"
        text: "by"
        anchors.horizontalCenterOffset: -153
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 401
        font.weight: Font.DemiBold
        font.pixelSize: 34
        font.family: "Titillium Web"
    }

    Text {
        id: book_number
        color: "#09102b"
        text: "25 books"
        anchors.top: parent.top
        anchors.topMargin: 351
        font.weight: Font.Bold
        font.bold: false
        anchors.left: highest_score.right
        anchors.leftMargin: 0
        font.pixelSize: 34
        font.family: "Titillium Web"
    }

    Text {
        id: highest_score
        width: 212
        height: 52
        color: "#43ADEE"
        text: "Highest score:"
        anchors.horizontalCenterOffset: -70
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 351
        font.weight: Font.DemiBold
        font.pixelSize: 34
        font.family: "Titillium Web"
    }

    Text {
        id: how_many_books_can_you_move_in_5_minutes__195_311
        x: 618
        color: "#09102B"
        text: "How many books can you move in 5 minutes?"
        font.weight: Font.Bold
        anchors.top: parent.top
        anchors.topMargin: 265
        anchors.horizontalCenter: parent.horizontalCenter
        font.letterSpacing: -0.4
        font.pixelSize: 36
        font.family: "Titillium Web"
    }

    Text {
        id: robot_arm_challenge_195_310
        x: 624
        color: "#43ADEE"
        text: "robot arm challenge"
        font.weight: Font.Bold
        anchors.top: parent.top
        anchors.topMargin: 175
        anchors.horizontalCenter: parent.horizontalCenter
        font.letterSpacing: 0.8
        font.pixelSize: 58
        font.family: "Rexlia"
    }

    Text {
        id: the_great_195_309
        x: 604
        color: "#43ADEE"
        text: "The Great"
        font.weight: Font.Bold
        anchors.horizontalCenterOffset: 0
        anchors.top: parent.top
        anchors.topMargin: 61
        font.letterSpacing: 1.8
        anchors.horizontalCenter: parent.horizontalCenter
        font.capitalization: Font.AllUppercase
        font.pixelSize: 100
        font.family: "Rexlia"
    }










}


















































/*##^## Designer {
    D{i:0;UUID:"bbde620954409fc12d68d7b87d7fa776"}D{i:1;anchors_height:1080;anchors_width:1920}
D{i:2;UUID:"a0866aa67504dd2e97bfaa2a5bba70ee";anchors_width:1920;anchors_y:0}D{i:4;UUID:"fa1a60b5104a4c40bae194700c5cb55b"}
D{i:5;UUID:"edfa3fe357682dbcd626d8fe8aac85a1"}D{i:3;UUID:"01927ea8547f6e1bee6287ac07273194";anchors_x:1469}
D{i:7;UUID:"22ccd09b50fed768e688cbc2568ffc5e"}D{i:8;UUID:"dd870504e4a0f5370bfdb2b10c2fedba"}
D{i:6;UUID:"8d87b00bc3cb583dc2a2d585d3c62ce2";anchors_x:0}D{i:12;UUID:"6914daf2e82f4a9e03ad2bcc1c209c59";anchors_x:879}
D{i:14;UUID:"e55977b2247ecc1ca73ce5ff47e1cb54";anchors_y:565}D{i:15;UUID:"9648356f9d73223dbbda81f37a314e20";anchors_y:499}
D{i:16;UUID:"d3f40248a8f016456c74f30f632aea28";anchors_x:788;anchors_y:364}D{i:17;UUID:"8aeda83ed0f07872495082d95cc732a8";anchors_x:788;anchors_y:364}
D{i:18;UUID:"6e6c43c56f799ddcdbe90458af7e7749";anchors_y:279}D{i:19;UUID:"36eef488e42faab92098028e2bb4cb54";anchors_y:"-27"}
D{i:24;anchors_x:4}
}
 ##^##*/
