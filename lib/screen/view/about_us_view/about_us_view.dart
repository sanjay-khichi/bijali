import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About Us"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "About Bijali",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              "Bijali is an social media app designed for averyone to connect, share, and explore the content in a safe and respectful environment.",
            ),
            SizedBox(height: 16.0),
            Text(
              "Our Mission",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "At Bijali, our mission is to provide a platform where individuals can express themselves, discover like-minded individuals, and engage in every discussions and content creation.",
            ),
            SizedBox(height: 16.0),
            Text(
              "Features",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "1. User Profiles: Create a unique profile and customize it to reflect your personality.",
            ),
            Text(
              "2. Content Sharing: Share content, including photos, videos, and text posts.",
            ),
            Text(
              "3. Privacy Controls: Maintain control over your privacy with customizable privacy settings.",
            ),
            Text(
              "4. Community Engagement: Connect with like-minded individuals, join groups, and participate in discussions.",
            ),
            SizedBox(height: 16.0),
            Text(
              "Contact Us",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "If you have any questions, suggestions, or concerns, please reach out to our support team at support@bijaliapp.com. We value your feedback and are dedicated to continually improving the Bijali app.",
            ),
          ],
        ),
      ),
    );
  }
}
