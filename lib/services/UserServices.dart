import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SupervisorService {
  static const String BASE_URL = 'http://10.0.2.2:8082';
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$BASE_URL/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      print(response);
      // final responseData = response.data as Map<String, dynamic>;
      if (response.data['statusCode']==200) {
        final userData = response.data;
        await _secureStorage.write(key: 'token', value: userData['token']);
        await _secureStorage.write(key: 'role', value: userData['role']);

        print(userData['token']);
        return userData;
      }else{
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      print(e);
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Login failed');
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      throw Exception(e ?? 'An unexpected error occurred');
    }
  }

  static Future<List<dynamic>> getJobs(String token) async {
    try {
      final response = await Dio().get(
        '$BASE_URL/job-registry/get-jobs', // Replace with your actual jobs endpoint
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      print(response);
      return response.data['details']; // Adjust based on your response structure
    } on DioError catch (e) {
      throw Exception('Failed to fetch jobs: ${e.message}');
    }
  }

  static Future<Response> getAllEntriesOfJob(int jobId, String token) async {
    try {
      final response = await Dio().get(
        '$BASE_URL/job-entry/get-all-entries-of-job/$jobId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      // print(response);
      // print(response.data);
      return response;
    } on DioError catch (e) {
      throw Exception('Failed to fetch jobs: ${e.message}');
    }
  }

  static Future<List<dynamic>> getAllInventory(String token) async {
    try {
      final response = await Dio().get(
        '$BASE_URL/inventory/getAll', // Replace with your actual jobs endpoint
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      // print(response);
      return response.data['inventoryItemList'];
    } on DioError catch (e) {
      throw Exception('Failed to fetch jobs: ${e.message}');
    }
  }

  static Future<List<dynamic>> getAllTechnician(String token) async {
    try {
      final response = await Dio().get(
        '$BASE_URL/job-entry/get-technicians', // Replace with your actual jobs endpoint
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      // print(response);
      return response.data['ourUsersList'];
    } on DioError catch (e) {
      throw Exception('Failed to fetch jobs: ${e.message}');
    }
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'token');
  }
}