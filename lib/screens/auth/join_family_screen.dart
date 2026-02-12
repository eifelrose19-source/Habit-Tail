

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JoinFamilyScreen extends StatelessWidget {
  const JoinFamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD0BFFF), // softIris
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter your family code below to join your family",
              style: GoogleFonts.quicksand(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3F2E5A), // midnightPlum
              ),
            ),
            const SizedBox(height: 8),
            const Text("Enter the unique Family ID provided by your parent."),
            const SizedBox(height: 32),
            TextField(
              decoration: InputDecoration(
                labelText: "Family ID (e.g., FAM-123)",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Logic to search DB for Family ID
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF98E4FF), // electricSky
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Find My Family"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

