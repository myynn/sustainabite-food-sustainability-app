import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:project_part2/screens/settings_screen.dart';
import 'package:project_part2/screens/start_screen.dart';
import 'package:project_part2/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_part2/services/theme_service.dart';

//this is the appdrawer
class AppDrawer extends StatelessWidget {
  final FirebaseService fbService =
      GetIt.instance<
        FirebaseService
      >(); //fbservice fives access to firebase authentication methods via injected service class
  final ThemeService themeService = GetIt.I<ThemeService>();

  void logout(BuildContext context) async {
    try {
      await fbService
          .logout(); //logs the user using logout from firebaseservice

      //after the user logs out redirects user to the start screen and removes previous routes
      Navigator.of(context).pushReplacementNamed(StartScreen.routeName);

      //this dismisses the keyboard if it is open and shows a logout confirmation message
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User logged out successfully!')),
      );
    } on FirebaseAuthException catch (e) {
      //this shows any error messages
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.code)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      //creates the side drawer ui using drawer and column
      child: Column(
        children: [
          AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title:
                fbService.getCurrentUser() ==
                        null //if user is not signed in, show hello friend
                    ? const Text("Hello Friend!")
                    : FittedBox(
                      child: Text(
                        "Hello ${fbService.getCurrentUser()!.email!}!", //if user is logged in show hellp and then the email they are signed in with
                      ),
                    ),
            automaticallyImplyLeading: false,
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.of(context).pushNamed(
                SettingsScreen.routeName,
              ); //this navigates the user to the settings screen when tapped
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Log out"),
            onTap:
                () => logout(
                  context,
                ), //this logs the user out via the logout function from firebase services
          ),
        ],
      ),
    );
  }
}
