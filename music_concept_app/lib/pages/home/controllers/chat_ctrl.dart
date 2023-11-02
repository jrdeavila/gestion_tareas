import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class ChatCtrl extends GetxController {
  int get chatsNotRead => chats.where((element) {
        return element.data()?['lastSenderRef'] !=
                "users/${FirebaseAuth.instance.currentUser!.uid}" &&
            !element.data()?['receiverSeen'];
      }).length;

  final RxList<String> friends = <String>[].obs;
  final RxList<FdSnapshot> chats = <FdSnapshot>[].obs;

  Stream<FdSnapshot> getUserAccountStream(String accountRef) {
    return UserAccountService.getUserAccountDoc(accountRef).snapshots();
  }

  Stream<FdSnapshot> getReceiverStream(List<String> refs) {
    var findReceiverRef = refs.firstWhere(
      (element) => element != "users/${FirebaseAuth.instance.currentUser!.uid}",
    );
    return UserAccountService.getUserAccountDoc(findReceiverRef).snapshots();
  }

  Stream<List<FdSnapshot>> getChatStream(String chatRef) {
    return ChatService.getChats(
      conversationRef: chatRef,
    );
  }

  Stream<FdSnapshot> getConversationStream(String conversationRef) {
    return ChatService.getConversation(conversationRef);
  }

  @override
  void onReady() {
    super.onReady();
    friends.bindStream(
      FollowingFollowersServices.getFriends(
          accountRef: "users/${FirebaseAuth.instance.currentUser!.uid}"),
    );
    chats.bindStream(
      ChatService.getChatList(
          "users/${FirebaseAuth.instance.currentUser!.uid}"),
    );

    ever(chats, (value) {
      var hasMessages = value.where((element) {
        return element.data()?['lastSenderRef'] !=
                "users/${FirebaseAuth.instance.currentUser!.uid}" &&
            !element.data()?['receiverSeen'];
      }).isNotEmpty;
      if (hasMessages) {
        AudioPlayer().play(AssetSource("notification/notification.mp3"));
      }
    });
  }

  void openNewChat({
    required String receiverRef,
  }) async {
    var ref = await ChatService.createConversation(
      senderRef: "users/${FirebaseAuth.instance.currentUser!.uid}",
      receiverRef: receiverRef,
    );

    Get.toNamed(AppRoutes.chat, arguments: ref);
  }

  void openChat(FdSnapshot chat) {
    if (chat.data()?['lastSenderRef'] !=
        "users/${FirebaseAuth.instance.currentUser!.uid}") {
      ChatService.receiverSeenMessage(conversationRef: chat.reference.path);
    }
    Get.toNamed(AppRoutes.chat, arguments: chat.reference.path);
  }

  bool isSender(FdSnapshot chat) {
    return chat.data()?['senderRef'] ==
        "users/${FirebaseAuth.instance.currentUser!.uid}";
  }

  void sendMessage({
    required String conversationRef,
    required String message,
  }) async {
    if (message.isEmpty) return;
    await ChatService.sendMessage(
      conversationRef: conversationRef,
      senderRef: "users/${FirebaseAuth.instance.currentUser!.uid}",
      message: message,
    );
  }
}
