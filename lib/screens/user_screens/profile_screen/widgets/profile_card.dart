import 'package:flutter/material.dart';
import 'package:Hira_Plus/constants/color_class.dart';

class ProfileCard extends StatelessWidget {
  final String userName;
  final String phone;
  const ProfileCard({required this.userName, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ColorClass.brandDarkGreen,
        boxShadow: [
          BoxShadow(
            color: ColorClass.brandDarkGreen.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: ColorClass.brandLightGreen,
            child: Text(
              userName.isNotEmpty ? userName.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase() : '',
              style: const TextStyle(fontSize: 28, color: ColorClass.brandDarkGreen, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  phone,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 