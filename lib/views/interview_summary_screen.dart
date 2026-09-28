import 'package:flutter/material.dart';
import '../models/interview_summary.dart';
import 'home_screen.dart';

class InterviewSummaryScreen extends StatelessWidget {
  final InterviewSummary summary;
  const InterviewSummaryScreen({Key? key, required this.summary}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1016),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Interview Performance Report', style: TextStyle(color: Colors.white, fontSize: 18)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1F29),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.5)),
                ),
                child: Text(
                  'Role: ${summary.role}',
                  style: const TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF161722),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  const Text('Overall Performance Score', style: TextStyle(color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 10),
                  Text(
                    summary.feedback,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('🌟 Key Strengths', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...summary.strengths.map((strength) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(strength, style: const TextStyle(color: Colors.white70))),
                ],
              ),
            )),
            const SizedBox(height: 20),

            const Text('📈 Areas of Improvement', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...summary.improvements.map((improvement) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orangeAccent, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(improvement, style: const TextStyle(color: Colors.white70))),
                ],
              ),
            )),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (route) => false,
                    );
                  },
                  child: const Text('Back to Home', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}