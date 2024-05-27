import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:music_concept_app/lib.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Chats",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    var friend = Get.find<ChatCtrl>().friends[index];
                    return FriendItem(friend: friend);
                  },
                  itemCount: Get.find<ChatCtrl>().friends.length,
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              const Divider(),
              Expanded(
                child: Obx(
                  () => ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      var conversation = Get.find<ChatCtrl>().chats[index];
                      return ConversationItem(conversation: conversation);
                    },
                    itemCount: Get.find<ChatCtrl>().chats.length,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class FriendItem extends StatelessWidget {
  const FriendItem({
    super.key,
    required this.friend,
  });

  final String friend;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Get.find<ChatCtrl>().getUserAccountStream(friend),
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: GestureDetector(
            onTap: () {
              Get.find<ChatCtrl>().openNewChat(
                receiverRef: friend,
              );
            },
            child: ProfileImage(
              avatarSize: 60.0,
              image: snapshot.data?.data()?['image'],
              name: snapshot.data?.data()?['name'],
              active: snapshot.data?.data()?['active'] ?? false,
              hasVisit: snapshot.data?.data()?['currentVisit'] != null,
              isClickable: false,
            ),
          ),
        );
      },
    );
  }
}

class ConversationItem extends StatelessWidget {
  const ConversationItem({
    super.key,
    required this.conversation,
  });

  final FdSnapshot conversation;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Get.find<ChatCtrl>().getReceiverStream(
        conversation.data()?['participants'].cast<String>(),
      ),
      builder: (context, snapshot) {
        var receiverSeen = conversation.data()?['receiverSeen'] ?? false;
        return ListTile(
          onTap: () {
            Get.find<ChatCtrl>().openChat(
              conversation,
            );
          },
          leading: ProfileImage(
            image: snapshot.data?.data()?['image'],
            name: snapshot.data?.data()?['name'],
            active: snapshot.data?.data()?['active'] ?? false,
            hasVisit: snapshot.data?.data()?['currentVisit'] != null,
            isClickable: false,
          ),
          title: Text(
            snapshot.data?.data()?['name'] ?? "**************",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            conversation.data()?['lastMessage'] ?? "**************",
            style: TextStyle(
              fontWeight: receiverSeen ? FontWeight.normal : FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            DateFormat("hh:mm a").format(
              (conversation.data()?['timestamp'] as Timestamp?)?.toDate() ??
                  DateTime.now(),
            ),
            style: TextStyle(
              color: Colors.grey[500],
              fontWeight: receiverSeen ? FontWeight.normal : FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
