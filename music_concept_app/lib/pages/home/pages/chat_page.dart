import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:music_concept_app/lib.dart';

class ChatPage extends StatefulWidget {
  final String conversationRef;
  const ChatPage({
    super.key,
    required this.conversationRef,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    Future.delayed(500.milliseconds, () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          StreamBuilder(
              stream: Get.find<ChatCtrl>()
                  .getConversationStream(widget.conversationRef),
              builder: (context, conversation) {
                var hasData = conversation.hasData;
                if (hasData) {
                  return _buildReceiverDetails(conversation);
                }
                return const Padding(
                  padding: EdgeInsets.only(top: kToolbarHeight + 16.0),
                  child: UserAccountSkeleton(),
                );
              }),
          const SizedBox(
            height: 20.0,
          ),
          const Divider(),
          const SizedBox(
            height: 20.0,
          ),
          Expanded(
            child: _buildChatList(),
          ),
          _buildFirstAttempt()
        ],
      ),
    );
  }

  StreamBuilder<FdSnapshot> _buildFirstAttempt() {
    var textCtrl = TextEditingController();
    return StreamBuilder(
        stream:
            Get.find<ChatCtrl>().getConversationStream(widget.conversationRef),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }

          String? creatorRef = snapshot.data?.data()?['creatorRef'];

          var firstAttemptData = snapshot.data?.data()?['firstAttempt'] ?? true;
          var userRef = Get.find<ChatCtrl>().userRef;
          var firstAttempt = firstAttemptData && userRef != creatorRef;
          return Column(
            children: [
              ...(firstAttempt
                  ? [
                      const SizedBox(
                        height: 20.0,
                      ),
                      Container(
                          decoration: BoxDecoration(
                            color: Get.theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      "¿Desea interactuar con esta persona?",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        HomeAppBarAction(
                                          icon: Icons.check,
                                          onTap: () {
                                            Get.find<ChatCtrl>()
                                                .updateFirstAttempt(
                                              conversationRef:
                                                  widget.conversationRef,
                                            );
                                          },
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        HomeAppBarAction(
                                          icon: Icons.close,
                                          onTap: () {
                                            Get.back();
                                            Get.find<ChatCtrl>()
                                                .deleteConversation(
                                              conversationRef:
                                                  widget.conversationRef,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ]))),
                      const SizedBox(
                        height: 20.0,
                      ),
                    ]
                  : [
                      const Divider(),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: textCtrl,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                    vertical: 0.0,
                                  ),
                                  filled: true,
                                  fillColor: Get.theme.colorScheme.onBackground,
                                  hintText: "Escribe un mensaje",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: BorderSide.none),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            HomeAppBarAction(
                              selected: true,
                              light: true,
                              onTap: () {
                                Get.find<ChatCtrl>().sendMessage(
                                  conversationRef: widget.conversationRef,
                                  message: textCtrl.text,
                                );
                                textCtrl.text = "";
                              },
                              icon: Icons.send,
                            ),
                          ],
                        ),
                      ),
                    ])
            ],
          );
        });
  }

  StreamBuilder<List<FdSnapshot>> _buildChatList() {
    return StreamBuilder(
        stream: Get.find<ChatCtrl>().getChatStream(widget.conversationRef),
        builder: (context, snapshot) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
          if (!snapshot.hasData) {
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(10.0),
              itemBuilder: (context, index) {
                return Row(
                  mainAxisAlignment: index % 2 == 0
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Skeleton(
                        height: 50.0,
                        width: 300.0,
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }
          return ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(10.0),
            itemBuilder: (context, index) {
              var chatItem = snapshot.data![index];
              return ChatItem(chatItem: chatItem);
            },
            itemCount: snapshot.data?.length ?? 0,
          );
        });
  }

  StreamBuilder<FdSnapshot> _buildReceiverDetails(
      AsyncSnapshot<FdSnapshot> conversation) {
    return StreamBuilder(
        stream: Get.find<ChatCtrl>().getReceiverStream(
          conversation.data?.data()?['participants']?.cast<String>(),
        ),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return const SizedBox.shrink();
          }
          return GestureDetector(
            onTap: () {
              if (snapshot.hasData) {
                Get.find<FanPageCtrl>().goToGuestProfile(snapshot.data!);
              }
            },
            child: Container(
              padding:
                  const EdgeInsets.only(left: 16.0, top: kToolbarHeight + 16.0),
              child: Row(
                children: [
                  HomeAppBarAction(
                    icon: Icons.arrow_back,
                    onTap: () {
                      Get.back();
                    },
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  ProfileImage(
                    avatarSize: 50.0,
                    image: snapshot.data?.data()?['image'],
                    name: snapshot.data?.data()?['name'],
                    active: snapshot.data?.data()?['active'] ?? false,
                    hasVisit: snapshot.data?.data()?['currentVisit'] != null,
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.data?.data()?['name'] ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          snapshot.data?.data()?['active'] ?? false
                              ? "Activo ahora"
                              : "Inactivo",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  HomeAppBarAction(
                    icon: Icons.delete,
                    onTap: () {
                      Get.back();
                      Get.find<ChatCtrl>().deleteConversation(
                        conversationRef: widget.conversationRef,
                      );
                    },
                  ),
                  const SizedBox(
                    width: 16.0,
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class ChatItem extends StatelessWidget {
  const ChatItem({
    super.key,
    required this.chatItem,
  });

  final DocumentSnapshot<Map<String, dynamic>> chatItem;

  @override
  Widget build(BuildContext context) {
    var iAmSender = Get.find<ChatCtrl>().isSender(chatItem);
    var receiverSeen = chatItem.data()?['receiverSeen'] ?? false;
    var receiverSeenTimestamp =
        chatItem.data()?['receiverSeenTimestamp'] as Timestamp?;
    var lastSeenTime = receiverSeenTimestamp?.toDate() ?? DateTime.now();
    var lastSeenTimeString = DateFormat('HH:mm a').format(lastSeenTime);
    if (!receiverSeen && !iAmSender) {
      Get.find<ChatCtrl>().updateLastSeen(chatItem);
    }
    var backgroundColor = iAmSender
        ? Get.theme.colorScheme.primary
        : Get.theme.colorScheme.onBackground;
    var textColor = Get.theme.colorScheme.onPrimary;
    return Column(
      children: [
        Row(
          mainAxisAlignment:
              iAmSender ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 15.0,
              ),
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              constraints: const BoxConstraints(maxWidth: 300.0),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chatItem.data()?['message'] ?? "**********",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    DateFormat('HH:mm a').format(
                      (chatItem.data()?['timestamp'] as Timestamp?)?.toDate() ??
                          DateTime.now(),
                    ),
                    style: TextStyle(
                      fontSize: 10.0,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          width: double.infinity,
          child: Text(
            receiverSeen ? "Visto $lastSeenTimeString" : "Enviado",
            style: TextStyle(
              fontSize: 10.0,
              color: Colors.grey[500],
            ),
            textAlign: iAmSender ? TextAlign.end : TextAlign.start,
          ),
        )
      ],
    );
  }
}
