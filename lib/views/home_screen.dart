import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/interview_role.dart';
import '../viewmodels/interview_viewmodel.dart';
import 'interview_room_screen.dart';
import 'interview_history_screen.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final InterviewViewmodel _viewmodel = InterviewViewmodel();

  String _selectedDifficulty = 'Medium';
  final List<String> _difficulties = ['Basic', 'Medium', 'Advanced'];

  final List<InterviewRole> _roles = [
    InterviewRole(
      id: '1',
      title: 'Flutter Developer',
      description: 'State management, widgets, lifecycle, and clean architecture.',
      iconPath: '📱',
    ),
    InterviewRole(
      id: '2',
      title: 'Android Developer',
      description: 'Kotlin, MVVM, Jetpack Compose, and Android Studio workflows.',
      iconPath: '🤖',
    ),
    InterviewRole(
      id: '3',
      title: 'Java & Spring Boot',
      description: 'Backend services, REST APIs, database handling, and security.',
      iconPath: '☕',
    ),
    InterviewRole(
      id: '4',
      title: 'Python & AI Developer',
      description: 'Core python concepts, data structures, and basic AI logic.',
      iconPath: '🐍',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI Interview Coach',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const InterviewHistoryScreen(),
                    ),
                );
              },
              icon: const Icon(Icons.history_rounded, color: Color(0xFF6C63FF),size: 28),
              tooltip: 'Past Interviews',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select your Domain',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose the role you want to practice your mock interview for with Agora AI.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              'Selected Difficulty Level',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: _difficulties.map((level) {
                final isSelected = _selectedDifficulty == level;
                return Expanded(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDifficulty = level;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF6C63FF) : const Color(0xFF1E1E2C),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF6C63FF) : Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            level,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    )
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            
            Expanded(
                child: ListView.builder(
                  itemCount: _roles.length,
                    itemBuilder: (context, index) {
                    final role = _roles[index];
                    final isSelected = _viewmodel.selectedRole == role.title;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _viewmodel.selectRole(role.title);
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF6C63FF).withOpacity(0.2)
                              : const Color(0xFF1E1E2C),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF6C63FF)
                                : Colors.grey.withOpacity(0.2),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Text(
                              role.iconPath,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      role.title,
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      role.description,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[400],
                                      ),
                                    )
                                  ],
                                ),
                            ),
                            if(isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF6C63FF),
                              ),
                          ],
                        ),
                      ),
                    );
                    },
                ),
            ),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                  onPressed: _viewmodel.selectedRole == null
                    ? null
                    : () {
                       Navigator.push(
                           context,
                           MaterialPageRoute(
                               builder: (context) => InterviewRoomScreen(
                                 selectedRole: _viewmodel.selectedRole!,
                                 selectedDifficulty: _selectedDifficulty,
                               ),
                           )
                       );
                  },
                  child: Text(
                    'Start Mock Interview',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}