import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Terms and Conditions"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Terms and Conditions for  Bijali ",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              "1. Eligibility",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "You must be at least 18 years old to use Bijali. By using the app, you confirm that you meet the minimum age requirement.",
            ),
            SizedBox(height: 16.0),
            Text(
              "2. Content and Community Guidelines",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Bijali is an 18+ social media app that allows users to share adult-oriented content. You are solely responsible for the content you post, and you agree not to share any illegal, offensive, violent, or explicit content that violates applicable laws or community standards.",
            ),
            Text(
              "You must respect the privacy of other users and not share personal information about others without their consent.",
            ),
            Text(
              "Bijali reserves the right to remove any content that violates these guidelines or is deemed inappropriate, at our sole discretion.",
            ),
            SizedBox(height: 16.0),
            Text(
              "3. User Conduct",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "You agree to use Bijali solely for lawful purposes and in a manner consistent with these Terms.",
            ),
            Text(
              "You will not engage in any activity that disrupts or interferes with the app's functioning or the experience of other users.",
            ),
            Text(
              "You will not attempt to gain unauthorized access to any part of Bijali or its users' accounts.",
            ),
            SizedBox(height: 16.0),
            Text(
              "4. Intellectual Property",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Bijali respects intellectual property rights. You may only share content that you own or have the necessary rights and permissions to use.",
            ),
            Text(
              "You grant Bijali a non-exclusive, transferable, sub-licensable, royalty-free, worldwide license to use, reproduce, modify, adapt, publish, translate, distribute, perform, and display your content for the purposes of operating and improving the app.",
            ),
            SizedBox(height: 16.0),
            Text(
              "5. Account Security",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "You are responsible for maintaining the security and confidentiality of your Bijali account credentials.",
            ),
            Text(
              "You will promptly notify Bijali of any unauthorized use of your account or any other security breach.",
            ),
            SizedBox(height: 16.0),
            Text(
              "6. Limitation of Liability",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Bijali and its affiliates shall not be liable for any direct, indirect, incidental, consequential, or punitive damages arising out of your use or inability to use the app.",
            ),
            Text(
              "Bijali does not endorse or guarantee the accuracy, completeness, or reliability of any user-generated content.",
            ),
            SizedBox(height: 16.0),
            Text(
              "7. Termination",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Bijali reserves the right to suspend, terminate, or disable your account at any time, without prior notice, if you violate these Terms.",
            ),
            Text(
              "You may also terminate your account by contacting Bijali's support team.",
            ),
            SizedBox(height: 16.0),
            Text(
              "8. Modification of Terms",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Bijali may modify or update these Terms from time to time. We will notify users of any significant changes via the app or other appropriate means.",
            ),
            Text(
              "Your continued use of Bijali after the modifications will constitute your acceptance of the updated Terms.",
            ),
            SizedBox(height: 16.0),
            Text(
              "9. Governing Law",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "These Terms shall be governed by and construed in accordance with the laws of [Jurisdiction].",
            ),
            Text(
              "Any disputes arising from these Terms shall be subject to the exclusive jurisdiction of the courts in [Jurisdiction].",
            ),
            SizedBox(height: 16.0),
            Text(
              "By using Bijali, you agree to abide by these Terms and Conditions. If you have any questions or concerns, please contact our support team. Thank you for using Bijali!",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
