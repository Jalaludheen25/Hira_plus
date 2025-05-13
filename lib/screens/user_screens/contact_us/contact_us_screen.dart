import 'package:flutter/material.dart';
import 'package:hira_plus/constants/icons_class.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorClass.brandDarkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Contact Us',
            style: TextStyleClass.poppinsSemiBold(
                fontSize: 20, color: ColorClass.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 26),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                IconClass.d4dxLogo,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 32),
            _buildContactRow(
              icon: LucideIcons.mail,
              label: 'Email',
              value: 'mail@d4dx.co',
              onTap: () async {
                final Uri emailLaunchUri =
                    Uri(scheme: 'mailto', path: 'mail@d4dx.co');
                if (await canLaunchUrl(emailLaunchUri)) {
                  await launchUrl(emailLaunchUri);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No email app found.')),
                  );
                }
              },
            ),
            SizedBox(height: 20),
            _buildContactRow(
              icon: LucideIcons.phone,
              label: 'Phone',
              value: '+91 99466 66139',
              valueColor: Colors.blue,
              onTap: () async {
                final Uri phoneUri = Uri(scheme: 'tel', path: '+919946666139');
                if (await canLaunchUrl(phoneUri)) {
                  await launchUrl(phoneUri);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No phone app found.')),
                  );
                }
              },
            ),
            SizedBox(height: 20),
            _buildContactRow(
              icon: LucideIcons.globe,
              label: 'Website',
              value: 'd4dx.co/contact',
              valueColor: Colors.blue,
              onTap: () async {
                final Uri url = Uri.parse('https://d4dx.co/contact');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No browser found.')),
                  );
                }
              },
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  'Address',
                  style: TextStyleClass.poppinsMedium(
                      fontSize: 14, color: ColorClass.textSub500),
                ),
              ),
            ),
            _buildAddressRow(),
            const Spacer(),
            Text(
              'We are here to help you! Reach out to us for any queries or support.',
              style: TextStyleClass.poppinsRegular(
                  fontSize: 14, color: ColorClass.textSub500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    Color? valueColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorClass.brandLightGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: ColorClass.brandDarkGreen, size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyleClass.poppinsMedium(
                        fontSize: 14, color: ColorClass.textSub500)),
                Text(
                  value,
                  style: TextStyleClass.poppinsBold(
                    fontSize: 16,
                    color: valueColor ?? ColorClass.textMain900,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios,
              color: ColorClass.brandDarkGreen, size: 18),
        ],
      ),
    );
  }

  Widget _buildAddressRow() {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: ColorClass.brandLightGreen.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.mapPin, color: ColorClass.brandDarkGreen, size: 28),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Attarwala Appartment First Floor, 5/3520G, (44/1342), Mavoor Road, Thiruthiyad, Calicut, Kerala, Pin 673004,',
              style: TextStyleClass.poppinsMedium(
                  fontSize: 15, color: ColorClass.textMain900),
            ),
          ),
        ],
      ),
    );
  }
}
