import 'package:stem_club/constants.dart';
import 'package:stem_club/utils/utils.dart';

class UserAuthData {
  final String? userId;
  final String? authToken;
  final String? username;

  UserAuthData({this.userId, this.authToken, this.username});
}

Future<UserAuthData> getUserIdAndAuthToken() async {
  Map<String, dynamic>? userData = await getValue(AppConstants.userKey);
  if (userData == null) {
    return UserAuthData(userId: null, authToken: null);
  }

  Map<String, dynamic> userMap = userData['user'];
  String? userId = userMap['id'];
  String? username = userMap['username'];
  String? authToken = userData['token'];

  return UserAuthData(userId: userId, authToken: authToken, username: username);
}
