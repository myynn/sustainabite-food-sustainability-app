import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_part2/screens/change_password_screen.dart';
import 'package:project_part2/screens/start_screen.dart';
import 'package:project_part2/services/firebase_service.dart';
import 'package:project_part2/services/theme_service.dart';

//this is the settings screen that is accessed from the appdrawer
class SettingsScreen extends StatelessWidget {
  static String routeName = '/settings';
  final FirebaseService fbService = GetIt.instance<FirebaseService>(); //get firebase service via getit
  final ThemeService themeService = GetIt.instance<ThemeService>(); //this gets the theme service via get it

  void confirmDeleteAccount(BuildContext context) { //shows confirmation pop up to ensure user wants to confirm they want to delete their account
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete account"),
        content: const Text("Are you sure you want to permanently delete your account?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), //cancel button to allow user to close the pop up
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop(); //closes the pop up message before deleting
              try {
                await fbService.deleteAccount(); // this code calls delete function from firebase service to delete a users account
                Navigator.of(context).pushReplacementNamed(StartScreen.routeName); //redirects user to start screen after deleting their account
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Account deleted successfully.")),
                );
              } on FirebaseAuthException catch (e) {
                final message = e.code == 'requires-recent-login' //handles error and makes user login to their account again before deleting their account
                    ? 'Please log in again to delete your account.'
                    : e.message ?? 'Deletion failed.';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser; //gets the current firebase user

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary, //the theme appbar colour
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Center(
              child: Image.asset(
                'images/SustainaBitelogov2.png', //the app logo image
                height: 150,
              ),
            ),
            const SizedBox(height: 24),

            //this is to display the users email in the settings page if it is available
            if (user != null && user.email != null)
              Text(
                'Logged in as: ${user.email}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),

            const SizedBox(height: 24),
            const Divider(),

            // this is the theme picker section for personalisation
            ListTile(
              leading: const Icon(Icons.palette), //the palette icon for theme selection
              title: const Text('Themes'), //the section title
              subtitle: const Text('Tap a colour to apply'), //to tell users to tap a colour to apply
              trailing: const SizedBox.shrink(), //this is to keep the alignment clear
            ),
            Padding( //this is a row of selectable theme colour options
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, //to evenly space out the colour dots
                children: [ //each theme dot is a selectable circle that calls the theme service set theme, so when tapped it boradcsts the selected colour to the app to update the theme
                  _ThemeDot(color: const Color(0xFF4E6E58), onTap: () => themeService.setTheme(const Color(0xFF4E6E58), '#4E6E58')),
                  _ThemeDot(color: Colors.green,      onTap: () => themeService.setTheme(Colors.green,      'green')),
                  _ThemeDot(color: const Color(0xFF0CC0DF), onTap: () => themeService.setTheme(const Color(0xFF0CC0DF), '#0CC0DF')),
                  _ThemeDot(color: const Color(0xFF81CBB1), onTap: () => themeService.setTheme(const Color(0xFF81CBB1), '#81CBB1')),
                  _ThemeDot(color: const Color(0xFFFFBF70), onTap: () => themeService.setTheme(const Color(0xFFFFBF70), '#FFBF70')),
                ],
              ),
            ),

            const Divider(),

            // this is the change password option for account management
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change password'),
              onTap: () {
                Navigator.pushNamed(context, ChangePasswordScreen.routeName); //redirects the user to the change password screen after pressing the option
              },
            ),
            const Divider(),

            //this is the delete account option for account management
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete account'),
              onTap: () => confirmDeleteAccount(context), //to show users the pop up to ask whether they want to confirm they want to delete their account from above
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

//this is the function to change the app theme when tapped
class _ThemeDot extends StatelessWidget {
  final Color color; //the colour displayed in the dot
  final VoidCallback onTap; //the function to run when the dot is tapped
  const _ThemeDot({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, //this triggers the theme colour change logic
      child: CircleAvatar(backgroundColor: color, radius: 15),
    );
  }
}