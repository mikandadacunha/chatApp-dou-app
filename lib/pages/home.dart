import 'package:chatap/pages/chatap.dart';
import 'package:chatap/pages/service/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final String myName, myProfilePic, myUserName, myEmail;
  const HomePage(
      {super.key,
      required this.myName,
      required this.myProfilePic,
      required this.myUserName,
      required this.myEmail});

  @override
  State<HomePage> createState() => _HomePageState();
}
/// Trying to correct an error with my cod, this the user preferencesshared
/// 

class _HomePageState extends State<HomePage> {
  bool search = false;

  /// ç
  /// the id of each user for the chatroom message
  late Stream<QuerySnapshot> chatRoomStream =
      DatabaseMethods().getChatRooms(widget.myUserName);
/// Our chatlist of all message sent by me
  Widget chatRoomList() {
    return StreamBuilder<QuerySnapshot>(
        stream: chatRoomStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('there is an erro') ;
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
              itemCount: snapshot.data!.size,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data!.docs[index];
                return ChatRoomListTile(
                    chatRoomId: ds.id,
                    lastMessage: ds['lastMessage'],
                    myUserName: widget.myUserName,
                    time: ds['lastMessageSendTs']);
              });
        });
  }

  ///The function that call chatroom for each user for his chatroom or the old message sent
  getChatRoomIdbyUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return '$b _$a';
    } else {
      return '$a _$b';
    }
  }

  var queryResultSet = [];
  var tempSearchStore = [];
//// initial seach to list every iqual name to the first letter
  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }
    setState(() {
      search = true;
    });
    var capitalizedValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);
    if (queryResultSet.isEmpty && value.length == 1) {
      DatabaseMethods().search(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.docs.length; ++i) {
          queryResultSet.add(docs.docs[i].data());
        }
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element['username'].startsWith(capitalizedValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffCA7236),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, top: 43.0, right: 20.0, bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// here we compare every moment when the search icon is click to expand the textfield
                  search
                      ? Expanded(
                          child: TextField(
                          /// Function that transform every first character of each name to upper case
                          onChanged: (value) {
                            /// function that we created to help us to find user or message
                            initiateSearch(value.toUpperCase());
                          },
                          decoration: const InputDecoration(
                              fillColor: Color(0xffAF5F25),
                              border: InputBorder.none,
                              hintText: 'search name',
                              hintStyle: TextStyle(
                                  color: Color(0xffE0B993),
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w500)),
                          style: const TextStyle(
                              color: Color(0xffE0B993),
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500),
                        ))
                      : const Text(
                          'duo-app',
                          style: TextStyle(
                              color: Color(0xffE0B993),
                              fontWeight: FontWeight.bold,
                              fontSize: 26.0),
                        ),
                  GestureDetector(
                    onTap: () {
                      search = true;
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: const Color(0xffAF5F25),
                          borderRadius: BorderRadius.circular(50)),
                      child: search
                          ? GestureDetector(
                              onTap: () {
                                search = false;
                                setState(() {});
                              },
                              child: const Icon(
                                Icons.close,
                                color: Color(0xffE0B993),
                              ),
                            )
                          : const Icon(
                              Icons.search_outlined,
                              color: Color(0xffE0B993),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            /// The main container of home page, here is where we find the list of message
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              margin: const EdgeInsets.only(top: 10),
              height: search
                  ? MediaQuery.of(context).size.height / 1.17
                  : MediaQuery.of(context).size.height / 1.14,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: Column(
                children: [
                  //// User list message, where we find every listed user and his message when we search it
                  search
                      ? ListView(
                          padding:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
                          primary: false,
                          shrinkWrap: true,
                          children: tempSearchStore.map((element) {
                            return buildResultCard(element);
                          }).toList())
                      : chatRoomList(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

/// Result of our searcho in the database 
  Widget buildResultCard(data) {
    return GestureDetector(
      onTap: () async {
        search = false;
        setState(() {});
        var chatRoomId =
            getChatRoomIdbyUsername(widget.myUserName, data['username']);
        Map<String, dynamic> chatRoomInfoMap = {
          'username': [widget.myUserName, data['username']],
        };
        await DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
        // ignore: use_build_context_synchronously
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatAp(
                    name: data['Name'],
                    profileurl: data['Phote'] ?? const CircleAvatar(child: Icon(Icons.person_2_outlined),),
                    username: data['username'])));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.network(
                    data['Phote'] ?? 'github.com/mikandadacunha.pg',
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  )),
              const SizedBox(
                width: 10.0,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['Name'],
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    data['username'],
                    style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500),
                  )
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }
}

/// Where we build the listview of list of messages and users

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUserName, time;
   ChatRoomListTile(
      {required this.chatRoomId,
      required this.lastMessage,
      required this.myUserName,
      required this.time});

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = '', name = '', username = '', id = '';

  getthisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll('_', '').replaceAll(widget.myUserName, '');
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getUserInfo(username.toUpperCase());
    if (querySnapshot.docs.isEmpty) {
      return 'No users found';
    }
    name = '${querySnapshot.docs[0]['Name']}';
    profilePicUrl = '${querySnapshot.docs[0]['Phote']}';
    id = '${querySnapshot.docs[0]['id']}';
    setState(() {});
  }

  @override
  void initState() {
    getthisUserInfo();
    super.initState();
  }
/// my message body listview
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Row(
        children: [
          profilePicUrl == ''
              ? CircleAvatar(
                  child: Center(
                    child: Text(
                      username[0],
                      style: const TextStyle(fontSize: 25),
                    ),
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.network(
                    profilePicUrl,
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                  ),
                ),
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              ////Messege body or description section, we find here all setting about de body messege
              Container(
                width: MediaQuery.of(context).size.width/3,
                child: Text(
                  widget.lastMessage,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12.0,
                      color: Colors.black45),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            widget.time,
            style: const TextStyle(
                color: Colors.black45, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
