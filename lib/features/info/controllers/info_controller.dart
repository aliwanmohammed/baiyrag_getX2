import 'package:get/get.dart';
import '../domain/repositories/info_repository.dart';
import '../models/about_us_model.dart';
import '../models/contact_info_model.dart';
import '../models/faq_model.dart';
import '../models/privacy_policy_model.dart';

class InfoController extends GetxController {
  InfoController(this._repository);
  final InfoRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  List<AboutUsModel> aboutUs = [];
  List<ContactInfoModel> contactInfos = [];
  List<FaqModel> faqs = [];
  List<PrivacyPolicyModel> privacyPolicies = [];

  Future<void> loadAboutUs() async {
    isLoading = true;
    errorMessage = null;
    update();
    final r = await _repository.getAboutUs(status: true, perPage: 50);
    if (r.isSuccess) {
      aboutUs = r.data?.items ?? [];
    } else {
      errorMessage = r.message;
    }
    isLoading = false;
    update();
  }

  Future<void> loadContactInfos() async {
    isLoading = true;
    errorMessage = null;
    update();
    final r = await _repository.getContactInfos(status: true, perPage: 50);
    if (r.isSuccess) {
      contactInfos = r.data?.items ?? [];
    } else {
      errorMessage = r.message;
    }
    isLoading = false;
    update();
  }

  Future<void> loadFaqs() async {
    isLoading = true;
    errorMessage = null;
    update();
    final r = await _repository.getFaqs(status: true, perPage: 50);
    if (r.isSuccess) {
      faqs = r.data?.items ?? [];
    } else {
      errorMessage = r.message;
    }
    isLoading = false;
    update();
  }

  Future<void> loadPrivacyPolicies() async {
    isLoading = true;
    errorMessage = null;
    update();
    final r = await _repository.getPrivacyPolicies(status: true, perPage: 50);
    if (r.isSuccess) {
      privacyPolicies = r.data?.items ?? [];
      privacyPolicies.sort(
        (a, b) => a.sortOrder.compareTo(b.sortOrder),
      );
    } else {
      errorMessage = r.message;
    }
    isLoading = false;
    update();
  }
}
