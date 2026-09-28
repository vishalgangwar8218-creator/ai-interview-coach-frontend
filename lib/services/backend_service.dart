import 'dart:convert';
import 'package:ai_interview_coach/models/interview_summary.dart';
import 'package:ai_interview_coach/views/interview_summary_screen.dart';
import 'package:http/http.dart' as http;

class BackendService {
  static const String baseUrl = "http://10.174.115.22:8080/api";

  //Sign UP
  static Future<bool> signUp(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Signup Error: $e");
      return false;
    }
  }

  // Sign In
  static Future<bool> signIn(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/signin"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      return response.statusCode == 200;
    } catch(e) {
      print("Signin Error: $e");
      return false;
    }
  }

  static Future<String> fetchNextQuestion(String role,String difficulty, String candidateAnswer) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/interview/next-question"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "role": role,
          "difficulty": difficulty,
          "candidateAnswer": candidateAnswer,
        }),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['question'] ?? "Can you explain your experience?";
      } else {
        return "Technical error occurred on server.";
      }
    } catch (e) {
      print("Catch Error: $e");
      return "Unable to connect to AI server";
    }
  }

  static Future<InterviewSummary?> fetchInterviewSummary(String role, String transcript) async{
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/interview/summary"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "role": role,
          "candidateAnswer": transcript,
        })
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return InterviewSummary.fromJson(data);
      }
    } catch (e) {
      print("Error fetching summary: $e");
    }

    return null;
  }

  static Future<List<dynamic>> fetchInterviewHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/interview/history'),
        headers: {"Content-Type": "application/json"},
      );

      print("History API Status Code: ${response.statusCode}");
      print("History API Response: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      print("History Fetch Error: $e");
      return [];
    }
  }
}