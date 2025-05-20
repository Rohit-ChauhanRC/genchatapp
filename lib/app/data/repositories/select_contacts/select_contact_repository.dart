import '../../models/new_models/response_model/contact_response_model.dart';

abstract class IContactRepository {
  Future<List<UserList>> fetchAppUsersFromContacts(List<String> phoneNumbers);
}
