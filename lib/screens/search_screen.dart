import 'package:chap_app/model/chatroom_model.dart';
import 'package:chap_app/model/user_model.dart';
import 'package:chap_app/screens/chat_room_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class SearchScreen extends StatefulWidget {
  final User firebaseUser;
  final UserModel userModel;

  const SearchScreen({Key? key, required this.firebaseUser,required this.userModel}) : super(key: key);
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  TextEditingController searchController = TextEditingController();

  // Creating New ChatRoom
  Future<ChatRoomModel?> getchatroomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('chatrooms')
        .where("participants.${widget.userModel.uid}", isEqualTo: true,)
        .where("participants.${targetUser.uid}", isEqualTo: true).get();

    // check is there any ChatRoom exist with target User
    if (snapshot.docs.length > 0) {
      // Fetch the existing ChatRoom
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatRoom = ChatRoomModel.fromMap(
          docData as Map<String, dynamic>);
      chatRoom = existingChatRoom;
    } else {
      // Create new ChatRoom
      ChatRoomModel newChatRoom = ChatRoomModel(
          chatroomid: uuid.v1(),
          lastMessage: "",
          participants: {
            widget.userModel.uid.toString(): true,
            targetUser.uid.toString(): true
          }
      );
      await FirebaseFirestore.instance.collection('chatrooms')
          .doc(newChatRoom.chatroomid).set(newChatRoom.toMap());
      chatRoom = newChatRoom;
    }
    return chatRoom;

    print('Null Check');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Search"),
        ),
        body: SafeArea(
            child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Column(children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(labelText: "Email Address"),
            ),
            const SizedBox(
              height: 20,
            ),
            CupertinoButton(
              onPressed: () {
                setState(() {
                  setState(() {

                  });
                });
              },
              color: Theme.of(context).colorScheme.secondary,
              child: Text("Search"),
            ),
            const SizedBox(
              height: 20,
            ),

            StreamBuilder(

              stream: FirebaseFirestore.instance.collection("users").where("email",
                isEqualTo: searchController.text.trim()).snapshots(),

              builder: (context,snapshot){
                // check the connectivity of Firebase
                if(snapshot.connectionState == ConnectionState.active){

                  if(snapshot.hasData){
                    // QuerySnapShot is used to Store One or more Document Object
                    QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                    if(dataSnapshot.docs.length > 0){
                      //this will only select the user at index 0
                      Map<String , dynamic> userMap = dataSnapshot.docs[0]
                          .data() as Map<String , dynamic>;

                      // NOw Convert the Map to Object
                      UserModel searchedUser = UserModel.fromMap(userMap);
                      // Display the detail of User in ListTile
                      return ListTile(
                        onTap: () async {
                          // Create new ChatRoom
                          ChatRoomModel? chatroomModel = await getchatroomModel(searchedUser);
                          if(chatroomModel != null){
                            Navigator.of(context).pop();
                            // Navigate to ChatRoomScreen
                            Navigator.push(context, MaterialPageRoute(builder: (context){
                              return ChatRoomScreen(chatRoomModel: chatroomModel ,userModel: widget.userModel,
                                targetUser: searchedUser,firebaseUser: widget.firebaseUser,);
                            }));
                          }



                        },
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          backgroundImage: NetworkImage(searchedUser.profilepic!),
                        ),
                        title: Text(searchedUser.fullname.toString()),
                        subtitle: Text(searchedUser.email.toString()),
                        trailing: Icon(Icons.keyboard_arrow_right),
                      );
                    }else{
                      return Text('No Result Found');
                    }
                  }else{
                     return Text('Database Is Empty');
                  }
                }else{
                  return CircularProgressIndicator();
                }
               // return CircularProgressIndicator();
              },
            ),

          ]),
        )
        )
    );
  }
}
