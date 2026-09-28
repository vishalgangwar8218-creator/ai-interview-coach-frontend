import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_interview_coach/services/backend_service.dart';

class InterviewHistoryScreen extends StatefulWidget{
  const InterviewHistoryScreen({super.key});

  @override
  State<InterviewHistoryScreen> createState() => _InterviewHistoryScreenState();
}

class _InterviewHistoryScreenState extends State<InterviewHistoryScreen> {
  bool _isLoading = true;
  List<dynamic> _historyList = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    var history = await BackendService.fetchInterviewHistory();
    setState(() {
      _historyList = history;
      _isLoading = false;
    });
  }

  void _showFeedbackPopup(BuildContext context, dynamic historyItem) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E2C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(
                      historyItem['role'] ?? 'Interview Details',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${historyItem['overallScore']}/100',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Difficulty: ${historyItem['difficulty'] ?? 'Medium'}",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Detailed FeedBack:",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6C63FF),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      historyItem['feedback'] ?? 'No feedback available',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[300],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Close",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF6C63FF),
                      fontWeight: FontWeight.bold,
                    ),
                  )
              ),
            ],
          );
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12121A),
      appBar: AppBar(
        title: Text(
          'Interview History',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : _historyList.isEmpty
            ? Center(
               child: Text(
               'No past interview found.',
               style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
           ),
        )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _historyList.length,
              itemBuilder: (context, index) {
                final item = _historyList[index];
                return GestureDetector(
                  onTap: () => _showFeedbackPopup(context, item),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2C),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['role'] ?? 'Role',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF6C63FF),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Score: ${item['overallScore']}/100',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.greenAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['feedback'] ?? 'No feedback available.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
      ),
    );
  }
}