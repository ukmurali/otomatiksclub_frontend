import 'package:otomatiksclub/constants.dart';
import 'package:otomatiksclub/utils/utils.dart';

class UserAuthData {
  final String? userId;
  final String? authToken;
  final String? username;
  final String? role;

  UserAuthData({this.userId, this.authToken, this.username, this.role});
}

Future<UserAuthData> getUserIdAndAuthToken() async {
  Map<String, dynamic>? userData = await getValue(AppConstants.userKey);
  if (userData == null) {
    return UserAuthData(userId: null, authToken: null);
  }

  Map<String, dynamic> userMap = userData['user'];
  String? userId = userMap['id'];
  String? username = userMap['username'];
  Map<String, dynamic> roleData = userData['role'];
  String? authToken = userData['token'];
 
  return UserAuthData(
      userId: userId, authToken: authToken, username: username, role: roleData['roleCode']);
}
