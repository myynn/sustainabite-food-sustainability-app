import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:project_part2/main.dart';
import 'package:project_part2/screens/login_screen.dart';
import 'package:project_part2/services/firebase_service.dart';

// this is a helper function to validate the email format using regex, checks if email has one or more characters that are word characters, hypens, or dots, has @ symbol, one or more domain parts, like gmail., yahoo., ends with a domain 2 to 4 characters long
bool isValidEmail(String email) {
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email);
}

//this is the sign up screen
class SignupScreen extends StatelessWidget {
  static String routeName = '/signup';

//accessing firebase using get it
  final FirebaseService fbService = GetIt.instance<FirebaseService>();

  final _formKey = GlobalKey<FormState>(); //global key for form validation
  String? email; //these are the variables to store from input values
  String? password;
  String? confirmPassword;

//handles user registration
  void register(BuildContext context) async {
    bool isValid = _formKey.currentState!.validate(); //validates form fields
    if (isValid) {
      _formKey.currentState!.save(); //saves field values

      //password and confirm password must match before proceeding
      if (password != confirmPassword) {
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match.')),
        );
        return;
      }

      try {
        //call register function in firebase service for registering new users using password and email
        await fbService.register(email, password);

        //show success registration message and redirect to login screen
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User registered successfully!')),
        );

        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      } on FirebaseAuthException catch (e) {
        //firebase specific error handling
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Registration failed')),
        );
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
        leading: BackButton(color: Colors.black),
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
          Image.asset('images/SustainaBite.png', height: 240), //the app logo image
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
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    // this is the email input field
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFDDE7DA),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2))],
                      ),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 25),
                        ),
                        keyboardType: TextInputType.emailAddress, //this is the keyboard type for email
                        autofillHints: [AutofillHints.email], //this helps with auto suggestions
                        validator: (value) {
                          if (value == null || value.isEmpty) { //input field cannot be empty
                            return "Please provide an email address.";
                          }  else if (value.startsWith('.') || value.endsWith('.')) { //cannot end or start with a dot
                            return "Email cannot start or end with a dot.";
                          }  else if (!isValidEmail(value)) { //uses isvalidemail from the function above to validate input field like check if input has @ symbol
                            return "Please enter a valid email address.";
                          } 
                          return null;
                        },
                        onSaved: (value) => email = value!.trim(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // this is the password input field
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFDDE7DA),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2))],
                      ),
                      child: TextFormField(
                        obscureText: true, //to hide the password characters when user types in
                        decoration: const InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 25),
                        ),
                        keyboardType: TextInputType.visiblePassword, //this is the keyboard type for password
                        autofillHints: [AutofillHints.newPassword],
                        validator: (value) {
                          if (value == null || value.isEmpty) { //input field cannot be empty
                            return 'Please provide a password.';
                          } else if (value.length < 6) {
                            return 'Password must be at least 6 characters.'; //input field must have at least 6 characters
                          } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
                            return 'Include at least one uppercase letter.'; //input field must have at least one uppercase
                          } else if (!RegExp(r'[a-z]').hasMatch(value)) {
                            return 'Include at least one lowercase letter.'; //input field must have at least one lowercase
                          } else if (!RegExp(r'\d').hasMatch(value)) {
                            return 'Include at least one number.'; //input field must have at least one number
                          } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                            return 'Password must contain at least one special character.'; //input field must contain at least one special character
                          }  
                          return null;
                        },
                        onSaved: (value) => password = value!.trim(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // this is the confirm password input field
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFDDE7DA),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2))],
                      ),
                      child: TextFormField(
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Confirm Password',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 25),
                        ),
                        keyboardType: TextInputType.visiblePassword, //this uses the password keyboard type
                        autofillHints: [AutofillHints.password],
                        validator: (value) {
                          if (value == null || value.isEmpty) { //checks if the input field is not empty
                            return 'Please confirm your password.';
                          } else if (value.length < 6) { //input must have at least 6 characters
                            return 'Password must be at least 6 characters.';
                          }
                          return null;
                        },
                        onSaved: (value) => confirmPassword = value!.trim(),
                      ),
                    ),

                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight, //redirects user to login screen 
                      child: TextButton( //the button for users that already have an existing account and redirects them to login screen
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            LoginScreen.routeName,
                          );
                        },
                        child: const Text.rich(
                          TextSpan(
                            text: 'Already a member? ',
                            style: TextStyle(color: Colors.black, fontSize: 15),
                            children: [
                              TextSpan(
                                text: 'Login',
                                style: TextStyle(
                                  color: Colors.grey,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton( //sign up button
                      onPressed: () => register(context), //this calls the register function
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFBF70),
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
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),
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

