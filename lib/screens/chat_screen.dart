import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
FirebaseUser loggedInUser;
class ChatScreen extends StatefulWidget {
  static const String id="Chatscreen";
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final mssgcontroller=TextEditingController();
  String textValue;
  final firestore=Firestore.instance;
  final _auth=FirebaseAuth.instance;

 @override
  void initState() {
    getUser();
  }
  void getUser()async{
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    }catch(e){
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
               _auth.signOut();
               Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('messages').snapshots(),
              builder: (context,snapshot){
                List<MessageBubble> mssgs=[];
                if(!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                  );
                }
                  var messages=snapshot.data.documents.reversed;
                 for(var mssg in messages){
                   var mssgText=mssg.data['text'];
                   var mssgSender=mssg.data['sender'];
                   var current=loggedInUser.email;
                   var totalmssg=MessageBubble(sender: mssgSender,text: mssgText,isMe: mssgSender==current);
                   mssgs.add(totalmssg);
                }
                return Expanded(
                  child: ListView(
                    reverse: true,
                    children:mssgs,
                  ),
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: mssgcontroller,
                      onChanged: (value) {
                        textValue=value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),

                  FlatButton(
                    onPressed: () {
                      mssgcontroller.clear();
                      firestore.collection('messages').add({
                        'sender':loggedInUser.email,
                        'text':textValue,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class MessageBubble extends StatelessWidget {
  bool isMe;
  String text;
  String sender;
  MessageBubble({this.text,this.sender,this.isMe});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isMe?CrossAxisAlignment.end:CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(sender,
          style: TextStyle(
            color: Colors.black,
          ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20,vertical:20),
          child: Material(
            borderRadius: isMe?BorderRadius.only(topLeft:Radius.circular(30),
                bottomLeft: Radius.circular(30),bottomRight: Radius.circular(30)):BorderRadius.only(
                topRight:Radius.circular(30),
                bottomLeft: Radius.circular(30),bottomRight: Radius.circular(30)),
            elevation: 5,
            color: isMe?Colors.lightBlueAccent:Colors.white70,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(text,
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

