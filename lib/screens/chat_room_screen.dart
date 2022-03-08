import 'dart:math';

import 'package:chap_app/main.dart';
import 'package:chap_app/model/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../model/chatroom_model.dart';
import '../model/user_model.dart';

class ChatRoomScreen extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatRoomModel;
  final UserModel userModel;
  final User firebaseUser;


  const ChatRoomScreen({Key? key,required this.chatRoomModel,
    required this.userModel,required this.firebaseUser,required this.targetUser}) : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {

  TextEditingController messageController = TextEditingController();

  // Create and Send the message
  void sendMessage () async {
    String mesg = messageController.text.trim();
    messageController.clear();
    if(mesg != ""){
      // Send Message
      MessageModel newmessage = MessageModel(
        messageid: uuid.v1(),
        sender:  widget.userModel.uid,
        createdon: DateTime.now(),
        text: mesg,
        seen: false,
      );
      FirebaseFirestore.instance.collection('chatrooms').doc(widget.chatRoomModel.chatroomid)
          .collection('messages').doc(newmessage.messageid).set(newmessage.toMap());
      print('**********************Message Send********************');
      // widget.chatRoomModel.lastMessage = mesg;
      // FirebaseFirestore.instance.collection('chatrooms')
      //     .doc(widget.chatRoomModel.chatroomid).set(widget.chatRoomModel.toMap());
      print('*******************');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
             backgroundImage:(widget.targetUser.profilepic == "")? null : NetworkImage(widget.targetUser.profilepic.toString()),
            ),

            SizedBox(width: 10,),

            Text(widget.targetUser.fullname.toString()),

          ],
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: StreamBuilder(

                      stream: FirebaseFirestore.instance.collection('chatrooms').doc(widget.chatRoomModel.chatroomid)
                          .collection('messages').orderBy('createdon', descending: true).snapshots(),
                      builder: (context,snapshot){

                        if(snapshot.connectionState == ConnectionState.active){
                          if(snapshot.hasData){
                            QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                            return ListView.builder(
                              reverse: true ,
                                itemCount: dataSnapshot.docs.length,
                                itemBuilder: (context, index) {
                              MessageModel currentMessage =
                              MessageModel.fromMap(dataSnapshot.docs[index].data() as Map<String , dynamic>);
                              return Row(
                                mainAxisAlignment: (currentMessage.sender == widget.userModel.uid)?
                                MainAxisAlignment.end : MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                    margin: EdgeInsets.symmetric(vertical: 2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: (currentMessage.sender == widget.userModel.uid)? Colors.grey : Theme.of(context).colorScheme.secondary
                                    ),
                                      child: Text(currentMessage.text.toString())),
                                ],
                              );
                            });

                          }else if(snapshot.hasError){
                            return Center(
                              child: Text('Error '),
                            );
                          }else{
                            return Center(
                              child: Text('Say Hi To Your Friend'),
                            );
                          }
                        }else{
                          return Center(
                            child: Text('Check Your InterNet Connection'),
                          );
                        }
                      },
                    ),
                  ),
                )),
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 5
              ),
              child: Row(
                children: [

                   Flexible(
                     child: TextField(
                       controller: messageController,
                       maxLines: null,
                         decoration: const InputDecoration(
                        hintText: "Enter message",
                        border: InputBorder.none

                      )
                    ),
                  ),
                  IconButton(
                    onPressed: (){
                      sendMessage();
                    },
                    icon: Icon(Icons.send,color: Theme.of(context).colorScheme.secondary,),
                  )
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}
