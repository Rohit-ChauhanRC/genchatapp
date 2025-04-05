import 'package:genchatapp/app/data/models/new_models/response_model/contact_response_model.dart';
import 'package:genchatapp/app/data/repositories/select_contacts/select_contact_repository.dart';
import 'package:genchatapp/app/network/api_endpoints.dart';

import '../../../network/api_client.dart';

class ContactRepositoryImpl implements IContactRepository {
  final ApiClient apiClient;

  ContactRepositoryImpl({required this.apiClient});

  @override
  Future<List<UserList>> fetchAppUsersFromContacts(List<String> phoneNumbers) async {

    final response = await apiClient.post(
      ApiEndpoints.fetchUser,
       {
        'phoneNumberArray': phoneNumbers,
      },
    );

    if (response.statusCode == 200 && response.data['status']) {
      List users = response.data['data'];
      return users.map((e) => UserList.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch registered contacts');
    }
  }
}
