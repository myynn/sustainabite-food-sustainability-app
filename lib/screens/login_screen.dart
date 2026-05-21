import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_part2/main.dart';
import 'package:project_part2/screens/signup_screen.dart';
import 'package:project_part2/screens/reset_password_screen.dart';
import 'package:project_part2/services/firebase_service.dart';

//this is the login screen
class LoginScreen extends StatelessWidget {
  static String routeName = '/login';

  final FirebaseService fbService = GetIt.instance<FirebaseService>(); //this gets the firebase service via getit
  final _formKey = GlobalKey<FormState>(); //this is the form key for validation

  String? email; //these are the variables to store from input values
  String? password;

//this is login function with firebase authentication
  void login(BuildContext context) async {
    bool isValid = _formKey.currentState!.validate(); //validates the form
    if (isValid) {
      _formKey.currentState!.save(); //saves the values from the form

      try {
        await fbService.login(email, password); //this calls the firebase login from firebase service to authenticate users with password and email

        FocusScope.of(context).unfocus(); //this hides keyboard
        ScaffoldMessenger.of(context).hideCurrentSnackBar(); //this clears old snackbars
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User logged in successfully!')),
        );
        Navigator.of(context).pushReplacementNamed(MainScreen.routeName); //redirects users after successful authentication
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed'))); //this shows the firebase error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'SustainaBite',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Image.asset('images/SustainaBite.png', height: 240), //this is the app logo image
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFA1CEAF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Form(
                key: _formKey, //this attaches the form key
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Welcome back!',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // this is the email input field
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDE7DA),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress, //this is the keyboard type for email
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 25,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) { //makes sure input field is not empty
                            return "Please provide an email address.";
                          } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) { //helps to validate email, like must have @ symbol, checks if email has one or more characters that are word characters, hypens, or dots
                            return "Please enter a valid email address.";
                          } else if (value.startsWith('.') || value.endsWith('.')) { //makes sure input must not start or end with .
                            return 'Email cannot start or end with a dot.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          email = value!.trim(); //to save trimmed email
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    //this is the password input field
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDE7DA),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.visiblePassword, //this is the keyboard type for password
                        obscureText: true, //to hide the text when user types in the input field
                        decoration: const InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 25,
                          ),
                        ),
                        validator: (value) { //i only used basic form validation to check password presence and length only as i assume the password was already validated during sign up
                          if (value == null || value.isEmpty) { //ensure that input field is not empty
                            return 'Please provide a password.';
                          } else if (value.length < 6) { //ensures that input has at least 6 characters
                            return 'Password must be at least 6 characters.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          password = value!.trim(); //this saves trimmed password
                        },
                      ),
                    ),
                    const SizedBox(height: 6),

                    // this is the forgot password button
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton( //forgot password button redirects user to the rest password screen
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            ResetPasswordScreen.routeName,
                          );
                        },
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: Colors.grey,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    //this is the login button
                    ElevatedButton(
                      onPressed: () => login(context), //this calls the login function
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFBF70),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 130,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextButton( //this is the sign up button for users that dont have an existing account, redirects them to the sign up screen
                      onPressed: () {
                        Navigator.pushReplacementNamed( //redirects users to the sign up screen
                          context,
                          SignupScreen.routeName,
                        );
                      },
                      child: const Text("No account? Sign up here!"),
                    ),

                    const SizedBox(height: 15),

                    OutlinedButton.icon( //this is for users to sign in with google authentication method
                      onPressed: () async {
                        try {
                          await fbService.signInWithGoogle(); //calls the google sign in function from firebase service to sign in users using google sign in

                          FocusScope.of(context).unfocus(); //this hides the keyboard
                          ScaffoldMessenger.of(context).hideCurrentSnackBar(); //clears any previous messages
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Signed in with Google!')),
                          );

                          Navigator.pushReplacementNamed(context, MainScreen.routeName); //redirects users to the main screen after successful authentication
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Google sign-in failed: $e')), //gives any error messages
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFDDE7DA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 120,
                        ),
                      ),
                      icon: Image.asset('images/google.png', height: 24), //the google image for the button
                      label: const Text(
                        "Continue with Google", //the continue with google text on the button
                        style: TextStyle(fontSize: 10, color: Colors.black),
                      ),
                    ),

                  const SizedBox(height: 5),
                  OutlinedButton.icon( //this is the github sign in authentication method
                    onPressed: () async {
                      try {
                        await fbService.signInWithGitHub(); //this calls the github sign in function via firebase oauth provider

                        FocusScope.of(context).unfocus(); //this hides any active keyboards
                        ScaffoldMessenger.of(context).hideCurrentSnackBar(); //this clears any previous messages
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Signed in with GitHub!')),
                        );

                        Navigator.pushReplacementNamed(context, MainScreen.routeName); //redirects users to the main screen after successful authentication
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('GitHub sign-in failed: $e')), //gives any error messages
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFDDE7DA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 120),
                    ),
                    icon: ClipRRect(
                      borderRadius: BorderRadius.circular(100), //this allows the image to be circular in shape
                      child: Image.asset(
                        'images/github.png', //the github image on the continue with github button
                        height: 24,
                        width: 24,
                        fit: BoxFit.cover,
                      ),
                    ),
                    label: const Text(
                      "Continue with GitHub", //the continue with github text on the button
                      style: TextStyle(fontSize: 10, color: Colors.black),
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
