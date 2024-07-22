import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class ChatCtrl extends GetxController {
  final FirebaseApp _app;

  ChatCtrl(this._app);

  FirebaseAuth get _authApp => FirebaseAuth.instanceFor(app: _app);

  String get userRef => "users/${_authApp.currentUser!.uid}";

  int get chatsNotRead => chats.where((element) {
        return element.data()?['lastSenderRef'] !=
                "users/${_authApp.currentUser!.uid}" &&
            !element.data()?['receiverSeen'];
      }).length;

  final RxList<String> friends = <String>[].obs;
  final RxList<FdSnapshot> chats = <FdSnapshot>[].obs;

  Stream<FdSnapshot> getUserAccountStream(String accountRef) {
    return UserAccountService.getUserAccountDoc(accountRef).snapshots();
  }

  Stream<FdSnapshot> getReceiverStream(List<String> refs) {
    var findReceiverRef = refs.firstWhere(
      (element) => element != "users/${_authApp.currentUser!.uid}",
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
          accountRef: "users/${_authApp.currentUser!.uid}"),
    );
    chats.bindStream(
      ChatService.getChatList("users/${_authApp.currentUser!.uid}"),
    );

    ever(chats, (value) {
      var hasMessages = value.where((element) {
        return element.data()?['lastSenderRef'] !=
                "users/${_authApp.currentUser!.uid}" &&
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
      senderRef: "users/${_authApp.currentUser!.uid}",
      receiverRef: receiverRef,
    );

    Get.toNamed(AppRoutes.chat, arguments: ref);
  }

  void openChat(FdSnapshot chat) {
    if (chat.data()?['lastSenderRef'] != "users/${_authApp.currentUser!.uid}") {
      ChatService.receiverSeenMessage(conversationRef: chat.reference.path);
    }
    Get.toNamed(AppRoutes.chat, arguments: chat.reference.path);
  }

  bool isSender(FdSnapshot chat) {
    return chat.data()?['senderRef'] == "users/${_authApp.currentUser!.uid}";
  }

  void sendMessage({
    required String conversationRef,
    required String message,
  }) async {
    if (message.isEmpty) return;
    await ChatService.sendMessage(
      conversationRef: conversationRef,
      senderRef: "users/${_authApp.currentUser!.uid}",
      message: message,
    );
  }

  void updateLastSeen(DocumentSnapshot<Map<String, dynamic>> chatItem) {
    if (chatItem.data()?['lastSenderRef'] !=
        "users/${_authApp.currentUser!.uid}") {
      ChatService.viewConversation(conversationRef: chatItem.reference.path);
    }
  }

  void updateFirstAttempt(
      {required String conversationRef, required bool value}) {
    ChatService.updateFirstAttempt(
        conversationRef: conversationRef, value: value);
  }

  void deleteConversation({required String conversationRef}) {
    ChatService.deleteConversation(conversationRef: conversationRef);
  }
}
