import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_concept_app/lib.dart';

class HomeCtrl extends GetxController {
  final FirebaseApp app;

  HomeCtrl(this.app);

  final PageController pageCtrl = PageController(initialPage: 1);

  final RxInt _currentPage = RxInt(1);
  final RxBool _showBottomBar = RxBool(true);

  int get currentPage => _currentPage.value;
  bool get showBottomBar => _showBottomBar.value;

  @override
  void onInit() {
    super.onInit();
    Get.put(PostCtrl(app));
    Get.put(EventCtrl(app));
    Get.put(FanPageCtrl(app));
    Get.put(SearchCtrl());
    Get.put(ProfileCtrl(app));
    Get.put(ChatCtrl(app));
  }

  @override
  void onClose() {
    super.onClose();
    pageCtrl.dispose();
    Get.delete<ChatCtrl>();
    Get.delete<ProfileCtrl>();
    Get.delete<SearchCtrl>();
    Get.delete<FanPageCtrl>();
    Get.delete<EventCtrl>();
    Get.delete<PostCtrl>();
  }

  @override
  void onReady() {
    super.onReady();

    ever(_currentPage, _onPageChange);
  }

  void _onPageChange(int page) {
    pageCtrl.animateToPage(
      page,
      duration: 500.milliseconds,
      curve: Curves.easeInOut,
    );
    _showBottomBar.value = page > 0;
  }

  void setBottomBarVisibility(bool value) {
    _showBottomBar.value = value;
  }

  void goToProfile() {
    _currentPage.value = 2;
    Get.find<FanPageCtrl>().showReed();
  }

  void goToReed() {
    _currentPage.value = 1;
    Get.find<FanPageCtrl>().showReed();
  }

  void goToSearch() {
    _currentPage.value = 0;
    Get.find<FanPageCtrl>().showReed();
  }
}

class SearchCtrl extends GetxController {
  final RxString _searchText = RxString('');
  final Rx<String?> _selectedCategory = Rx(null);
  final RxBool _isMapSearching = RxBool(false);

  RxList<DocumentSnapshot<Map<String, dynamic>>> searchResult =
      RxList<DocumentSnapshot<Map<String, dynamic>>>();
  final RxList<String> categories = RxList<String>();

  String? get currentCategory => _selectedCategory.value;

  String get searchText => _searchText.value;
  bool get isMapSearching => _isMapSearching.value;

  void setSearchText(String value) => _searchText.value = value;
  void setSelectedCategory(String? value) => _selectedCategory.value = value;
  void setMapSearching(bool value) => _isMapSearching.value = value;

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>? _future;

  @override
  void onReady() {
    super.onReady();
    ever(_searchText, _onSearch);
    ever(_selectedCategory, _onSearchCategory);

    categories.bindStream(AppConfigService.bussinessCategories);
  }

  void _onSearch(String value) async {
    _future?.ignore();
    _future = UserAccountService.searchAccounts(
      value,
      category: _selectedCategory.value,
    );
    var result = await _future!;
    searchResult.value = result;
  }

  void _onSearchCategory(String? value) async {
    _future?.ignore();

    if (value == 'Amigos Compartiendo') {
      _future = UserAccountService.searchAccountsVisiting(
        searchText,
      );
      var result = await _future!;
      searchResult.value = result;
      return;
    }

    _future = UserAccountService.searchAccounts(
      searchText,
      category: value,
    );

    var result = await _future!;
    searchResult.value = result;
  }

  void clearResults() {
    _searchText.value = "";
    searchResult.value = [];
  }
}

class FanPageCtrl extends GetxController {
  final FirebaseApp _app;

  FanPageCtrl(this._app);

  FirebaseAuth get _authApp => FirebaseAuth.instanceFor(app: _app);

  final PageController pageCtrl = PageController();
  final RxInt _currentPage = RxInt(0);

  bool get isNotifications => _currentPage.value == 1;
  bool get isChat => _currentPage.value == 2;

  final Rx<DocumentReference<Map<String, dynamic>>?> _currentAccount =
      Rx<DocumentReference<Map<String, dynamic>>?>(null);

  DocumentReference<Map<String, dynamic>>? get currentAccount =>
      _currentAccount.value;

  @override
  void onReady() {
    super.onReady();
    _authApp.userChanges().listen((user) {
      _currentAccount.value =
          user != null ? UserAccountService.getUserAccountRef(user.uid) : null;
    });
    _currentPage.listen(_onPageChange);
  }

  void showReed() {
    if (_currentPage.value != 0) {
      _currentPage.value = 0;
    } else {
      Get.back();
    }
  }

  void toggleNotifications() {
    _currentPage.value = _currentPage.value == 1 ? 0 : 1;
  }

  void toggleChat() {
    _currentPage.value = _currentPage.value == 2 ? 0 : 2;
  }

  void _onPageChange(int page) {
    Get.find<HomeCtrl>().setBottomBarVisibility(page == 0);
    pageCtrl.animateToPage(
      page,
      duration: 500.milliseconds,
      curve: Curves.easeInOut,
    );
  }

  void goToGuestProfile(DocumentSnapshot<Map<String, dynamic>> guest) {
    if (guest.reference.path != currentAccount?.path) {
      Get.toNamed(AppRoutes.guestProfile, arguments: guest);
    } else {
      Get.find<HomeCtrl>().goToProfile();
    }
  }
}
