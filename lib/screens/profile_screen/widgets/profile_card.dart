import 'package:flutter/material.dart';
import 'package:hira_plus/constants/color_class.dart';

class ProfileCard extends StatelessWidget {
  final String userName;
  final String phone;
  final String? department;
  final String? designation;
  const ProfileCard({
    super.key,
    required this.userName,
    required this.phone,
    this.department,
    this.designation,
  });

  @override
  Widget build(BuildContext context) {
    print('ProfileCard: userName=$userName, designation=$designation');
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
              userName.isNotEmpty
                  ? userName
                      .trim()
                      .split(' ')
                      .map((e) => e[0])
                      .take(2)
                      .join()
                      .toUpperCase()
                  : '',
              style: const TextStyle(
                  fontSize: 28,
                  color: ColorClass.brandDarkGreen,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                if (designation != null && designation!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    designation!,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
