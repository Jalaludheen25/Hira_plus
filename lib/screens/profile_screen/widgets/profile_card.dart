import 'package:flutter/material.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'dart:developer' as developer;

class ProfileCard extends StatelessWidget {
  final String userName;
  final String phone;
  final String? department;
  final String? designation;
  final bool isDeptHead;
  
  const ProfileCard({
    super.key,
    required this.userName,
    required this.phone,
    this.department,
    this.designation,
    this.isDeptHead = false,
  });

  @override
  Widget build(BuildContext context) {
    // Add debug logging to verify the props being passed
    developer.log('ProfileCard: userName=$userName, phone=$phone, designation=$designation', 
        name: 'ProfileCard');
    
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
                      .map((e) => e.isNotEmpty ? e[0] : '')
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
                if (isDeptHead) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, color: ColorClass.greenBase, size: 18),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: ColorClass.greenBase.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Dept Head',
                          style: TextStyle(
                            color: ColorClass.greenBase,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    phone,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
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