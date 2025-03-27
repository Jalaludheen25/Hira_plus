import 'package:canteen_app/routes/app_routes.dart';
import 'package:canteen_app/utils/navigation_helper.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildProfilePicture(),
              const SizedBox(height: 16),
              _buildProfileDetails(),
              const SizedBox(height: 32),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return const CircleAvatar(
      radius: 50,
      // Using default icon as placeholder for the profile picture
      child: Icon(Icons.person, size: 50),
    );
  }

  Widget _buildProfileDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        Text(
          'John Doe',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Phone: +1 234567890',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          'Department: Engineering',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: () {
        navigateTo(context: context, route: Routes.login);
      },
      child: const Text('Logout'),
    );
  }
}
