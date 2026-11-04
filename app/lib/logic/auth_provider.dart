import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'ai_providers.dart';

class UserProfile {
  final String id;
  final String email;
  final String name;
  final String avatar;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.avatar = '',
  });

  factory UserProfile.fromRecord(RecordModel record) {
    final rawName = record.getStringValue('name');
    final email = record.getStringValue('email');
    return UserProfile(
      id: record.id,
      email: email,
      name: rawName.isNotEmpty ? rawName : (email.isNotEmpty ? email.split('@').first : 'Học viên'),
      avatar: record.getStringValue('avatar'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'avatar': avatar,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String? ?? '',
        email: json['email'] as String? ?? '',
        name: json['name'] as String? ?? '',
        avatar: json['avatar'] as String? ?? '',
      );
}

class AuthState {
  final bool isAuthenticated;
  final UserProfile? user;
  final String? token;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.token,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    UserProfile? user,
    String? token,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  @override
  AuthState build() {
    _restoreSession();
    return const AuthState(isLoading: true);
  }

  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final userStr = prefs.getString(_userKey);

      if (token != null && token.isNotEmpty && userStr != null) {
        final userJson = jsonDecode(userStr) as Map<String, dynamic>;
        final user = UserProfile.fromJson(userJson);
        final pbService = ref.read(pocketBaseServiceProvider);
        pbService.pb.authStore.save(token, null);

        state = AuthState(
          isAuthenticated: true,
          user: user,
          token: token,
          isLoading: false,
        );
        return;
      }
    } catch (_) {}

    state = const AuthState(isLoading: false);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final pbService = ref.read(pocketBaseServiceProvider);
      final authData = await pbService.pb.collection('users').authWithPassword(
            email.trim(),
            password.trim(),
          );

      final user = UserProfile.fromRecord(authData.record);
      final token = authData.token;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, jsonEncode(user.toJson()));

      state = AuthState(
        isAuthenticated: true,
        user: user,
        token: token,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Đăng nhập thất bại: Kiểm tra lại email hoặc mật khẩu.',
      );
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final pbService = ref.read(pocketBaseServiceProvider);
      await pbService.pb.collection('users').create(
        body: {
          'email': email.trim(),
          'password': password.trim(),
          'passwordConfirm': password.trim(),
          'name': name.trim(),
        },
      );

      // Auto login after successful registration
      return await login(email, password);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Đăng ký thất bại: Email có thể đã tồn tại hoặc mật khẩu quá ngắn (tối thiểu 8 ký tự).',
      );
      return false;
    }
  }

  Future<bool> loginWithApple() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final userIdentifier = credential.userIdentifier;
      if (userIdentifier == null || userIdentifier.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Đăng nhập Apple thất bại: Không lấy được thông tin tài khoản.',
        );
        return false;
      }

      final email = credential.email ?? '';
      final fullName = [
        credential.givenName ?? '',
        credential.familyName ?? '',
      ].where((s) => s.isNotEmpty).join(' ');

      final pbService = ref.read(pocketBaseServiceProvider);
      final response = await http.post(
        Uri.parse('${pbService.baseUrl}/api/auth/apple'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_identifier': userIdentifier,
          'email': email,
          'full_name': fullName,
          'identity_token': credential.identityToken ?? '',
        }),
      );

      if (response.statusCode != 200) {
        final errJson = jsonDecode(response.body) as Map<String, dynamic>?;
        final msg = errJson?['message'] as String? ?? 'Đăng nhập Apple không thành công.';
        state = state.copyWith(isLoading: false, errorMessage: msg);
        return false;
      }

      final resData = jsonDecode(response.body) as Map<String, dynamic>;
      final token = resData['token'] as String;
      final recordMap = resData['record'] as Map<String, dynamic>;
      final recordModel = RecordModel(recordMap);

      final user = UserProfile.fromRecord(recordModel);
      pbService.pb.authStore.save(token, recordModel);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, jsonEncode(user.toJson()));

      state = AuthState(
        isAuthenticated: true,
        user: user,
        token: token,
        isLoading: false,
      );
      return true;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        state = state.copyWith(isLoading: false);
        return false;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Lỗi xác thực Apple: ${e.message}',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Lỗi đăng nhập Apple: $e',
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final pbService = ref.read(pocketBaseServiceProvider);
      pbService.pb.authStore.clear();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (_) {}

    state = const AuthState(
      isAuthenticated: false,
      user: null,
      token: null,
      isLoading: false,
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
