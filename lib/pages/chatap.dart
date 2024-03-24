import 'package:chatap/pages/home.dart';
import 'package:chatap/pages/service/database.dart';
import 'package:chatap/pages/service/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';

class ChatAp extends StatefulWidget {
  String name, profileurl, username;
  ChatAp(
      {required this.name, required this.profileurl, required this.username});

  @override
  State<ChatAp> createState() => _ChatApState();
}

class _ChatApState extends State<ChatAp> {
  TextEditingController messageController = TextEditingController();
  String? myUserName, myProfilePic, myName, myEmail, messageId, chatRoomId;
  Stream? streamMessage;

  getthesharedpref() async {
    myUserName = await SharedPreferencesHelper().getUserName();
    myName = await SharedPreferencesHelper().getUserDisplayname();
    myEmail = await SharedPreferencesHelper().getUserEmail();
    myProfilePic = await SharedPreferencesHelper().getUserPic();

    /// To get the i of chatroom for the chat an his message
    chatRoomId = getChatRoomIdbyUsername(widget.username, myUserName!);
    setState(() {});
  }

  /// Funcition that load every messegem sent useres in the conversation
  ontheload() async {
    await getthesharedpref();
    await getAndSetMessage();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  getChatRoomIdbyUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return '$b _$a';
    } else {
      return '$a _$b';
    }
  }

  getAndSetMessage() async {
    streamMessage = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    setState(() {});
  }

//// Function that bring all message from firebase, to list as well as must be in the ui screen
  Widget chatMessageTile(String message, bool sendByMe) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
            child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(24),
                bottomRight: sendByMe
                    ? const Radius.circular(0)
                    : const Radius.circular(24),
                topRight: const Radius.circular(24),
                bottomLeft: sendByMe
                    ? const Radius.circular(24)
                    : const Radius.circular(0),
              ),
              color: sendByMe
                  ? const Color.fromARGB(255, 243, 235, 230)
                  : const Color.fromARGB(255, 255, 218, 182)),
          child: Text(
            message,
            style: const TextStyle(
                color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ))
      ],
    );
  }

  ///Function that show every message sent to users
  Widget chatMessage() {
    return StreamBuilder(
      stream: streamMessage,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          return Center(child: Text('No messages available'));
        } else {
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 90.0, top: 130.0),
            itemCount: snapshot.data.docs.length,
            reverse: true,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.docs[index];
              return chatMessageTile(ds['message'], myUserName == ds['sendBy']);
            },
          );
        }
      },
    );
  }

  /// Function that is used to send a message

  addMessage(bool sendClicked) {
    if (messageController.text != '') {
      String message = messageController.text;
      messageController.text = '';
      DateTime now = DateTime.now();

      String formattedDate = DateFormat('h:mma').format(now);
      Map<String, dynamic> messageInfoMap = {
        'message': message,
        'sendBy': myUserName,
        'ts': formattedDate,
        'time': FieldValue.serverTimestamp(),
        'imgUrl': myProfilePic
      };
      messageId ??= randomAlphaNumeric(10);
      DatabaseMethods()
          .addMessage(chatRoomId!, messageId!, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          'lastMessage': message,
          'lastMessageSendTs': formattedDate,
          'time': FieldValue.serverTimestamp(),
          'lastMessageSendBy': myUserName,
        };
        DatabaseMethods()
            .updateLastMessageSend(chatRoomId!, lastMessageInfoMap);
        if (sendClicked) {
          messageId = null;
        }
      });
    }
  }

  ///The widet of original componente, that was not added
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffCA7236),
        body: Container(
          margin: const EdgeInsets.only(
            top: 50.0,
          ),
          child: Stack(children: [
            Container(
                margin: const EdgeInsets.only(top: 50.0),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 1.12,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: chatMessage()),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomePage(
                                  myName: myName!,
                                  myEmail: myEmail!,
                                  myProfilePic: myProfilePic!,
                                  myUserName: myUserName!,
                                )));
                  },
                  child: const Icon(
                    Icons.arrow_back_ios_new_outlined,
                    color: Color(0xffE0B993),
                  ),
                ),
                const SizedBox(
                  width: 115,
                ),
                Text(
                  widget.name,
                  style: const TextStyle(
                      color: Color(0xffE0B993),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
            Container(
              margin:
                  const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
              alignment: Alignment.bottomCenter,
              child: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type a message here',
                        hintStyle: const TextStyle(
                          color: Colors.black38,
                          fontSize: 14,
                        ),
                        suffixIcon: GestureDetector(
                            onTap: () {
                              addMessage(true);
                            },
                            child: const Icon(Icons.send_rounded))),
                  ),
                ),

                //// Bottom messager sender
              ),
            ),
          ]),
        ));
  }
}
