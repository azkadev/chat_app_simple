import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  return runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignPage(),
    ),
  );
}

class SignPage extends StatefulWidget {
  const SignPage({Key? key}) : super(key: key);

  @override
  SignState createState() => SignState();
}

class SignState extends State<SignPage> {
  final TextEditingController usernameTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    showPopUp(titleName, valueBody) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(titleName),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text(valueBody ?? "Error"),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Mengerti'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 25,
              ),
              const Center(
                child: Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextField(
                cursorColor: Colors.black,
                controller: usernameTextController,
                maxLength: 15,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(0.0),
                  hintText: 'username',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  ),
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                  ),
                  prefixIcon: const Icon(
                    Iconsax.user,
                    color: Colors.black,
                    size: 18,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade200,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  floatingLabelStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
              MaterialButton(
                onPressed: () async {
                  try {
                    var usernameValue = usernameTextController.text;
                    if (usernameValue.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ChatScreen(username: usernameValue);
                          },
                        ),
                      );
                    } else {
                      return showPopUp("Username", "Tolong isi username ya !");
                    }
                  } catch (e) {
                    return showPopUp("Failed", "application Error");
                  }
                },
                color: Colors.blue,
                height: 50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.only(
                  left: 25,
                  right: 25,
                ),
                child: const Center(
                  child: Text(
                    "Log in",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


ChatModel chatModelFromJson(String str) => ChatModel.fromJson(json.decode(str));

String chatModelToJson(ChatModel data) => json.encode(data.toJson());

class ChatModel {
  ChatModel({
    required this.id,
    required this.username,
    required this.sentAt,
    required this.message,
  });

  String id;
  String username;
  String sentAt;
  String message;

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        id: json["id"],
        username: json["username"],
        sentAt: json["sentAt"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "sentAt": sentAt,
        "message": message,
      };
}


class ChatScreen extends StatefulWidget {
  final String username;
  const ChatScreen({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatModel> _messages = [];

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  late Socket socket;

  @override
  void initState() {
    try {
      socket = io("http://127.0.0.1:3000/", {
        "transports": ["websocket"],
        "autoConnect": true,
      });

      socket.connect();

      socket.on('connect', (data) {
        debugPrint('connected');
        print(socket.connected);
      });

      socket.on('message', (data) {
        var message = ChatModel.fromJson(data);
        
        setStateIfMounted(() {
          _messages.add(message);
        });
      });

      socket.onDisconnect((_) => debugPrint('disconnect'));
      print("oke");
    } catch (e) {
      print(e);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: SafeArea(
          minimum: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                child: const Icon(
                  Iconsax.arrow_left,
                  color: Colors.black,
                  size: 25,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(
                width: 10.0,
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blueGrey[100],
                backgroundImage: const AssetImage("assets/images/avatar-6.png"),
              ),
              const SizedBox(
                width: 10.0,
              ),
              Text(
                widget.username,
                style: const TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                reverse: _messages.isEmpty ? false : true,
                itemCount: 1,
                shrinkWrap: false,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 10,
                      right: 10,
                      bottom: 3,
                    ),
                    child: Column(
                      mainAxisAlignment: _messages.isEmpty
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: _messages.map((msg) {
                            bool isMe = msg.id == socket.id;
                            String message = msg.message;
                            String date = msg.sentAt;
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: Column(
                                mainAxisAlignment: isMe
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5.0),
                                    constraints: BoxConstraints(
                                      maxWidth: size.width * .5,
                                      maxHeight: double.infinity,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? const Color(0xFFE3D8FF)
                                          : const Color(0xFFFFFFFF),
                                      borderRadius: isMe
                                          ? const BorderRadius.only(
                                              topRight: Radius.circular(11),
                                              topLeft: Radius.circular(11),
                                              bottomRight: Radius.circular(0),
                                              bottomLeft: Radius.circular(11),
                                            )
                                          : const BorderRadius.only(
                                              topRight: Radius.circular(11),
                                              topLeft: Radius.circular(11),
                                              bottomRight: Radius.circular(11),
                                              bottomLeft: Radius.circular(0),
                                            ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 7,
                                            ),
                                            child: Text(
                                              widget.username,
                                              textAlign: TextAlign.end,
                                              style: const TextStyle(
                                                  color: Color(0xFF594097),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          message,
                                          textAlign: TextAlign.start,
                                          softWrap: true,
                                          style: const TextStyle(
                                            color: Color(0xFF2E1963),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              top: 7,
                                            ),
                                            child: Text(
                                              date.split(" ")[1].toString(),
                                              textAlign: TextAlign.end,
                                              style: const TextStyle(
                                                color: Color(0xFF594097),
                                                fontSize: 9,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 2)],
              ),
              child: TextField(
                minLines: 1,
                maxLines: 5,
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: "Type a message",
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(2.5),
                    child: InkWell(
                      child: const Icon(
                        Iconsax.happyemoji,
                        color: Colors.pink,
                        size: 25,
                      ),
                      onTap: () {},
                    ),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: InkWell(
                      child: const Icon(
                        Iconsax.send_1,
                        color: Colors.blue,
                        size: 25,
                      ),
                      onTap: () async {
                        if (_messageController.text.trim().isNotEmpty) {
                          setState(() {
                            String message = _messageController.text.trim();
                            socket.emit(
                              "message",
                              ChatModel(
                                      id: socket.id.toString(),
                                      message: message,
                                      username: widget.username,
                                      sentAt: DateTime.now()
                                          .toLocal()
                                          .toString()
                                          .substring(0, 16))
                                  .toJson(),
                            );
                            _messageController.clear();
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent *
                                  -0.0100,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
