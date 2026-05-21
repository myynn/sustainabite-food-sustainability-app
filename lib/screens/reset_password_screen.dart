import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:project_part2/services/firebase_service.dart';

//this is the reset password screen
class ResetPasswordScreen extends StatelessWidget {
  static String routeName = '/reset';

//gets the firebase service instance via getit
  final FirebaseService fbService = GetIt.instance<FirebaseService>();
  final form = GlobalKey<FormState>(); //key used to track the forms state
  String? email; //this is the variable to store from input values
 
 //function to handle password reset
  void reset(BuildContext context) async {
    bool isValid = form.currentState!.validate(); //validate form input
    if (isValid) {
      form.currentState!.save(); //save form field values

      try {
        await fbService.forgotPassword(email); //calls forgot password function from firebase service to reset a users password

        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please check your email to reset your password.')),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message ?? e.code)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar( //this is the appbar with styling
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
          Image.asset('images/SustainaBite.png', height: 240), // this is the app logo image
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFA1CEAF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Form( //this is a form to capture and validate the email
                key: form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Reset Password',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // email input field
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
                        autofillHints: [AutofillHints.email], //this helps with autofill
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 25),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) { //ensures that input field is not empty
                            return "Please provide an email address.";
                          } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) { //helps to validate email, like must have @ symbol, checks if email has one or more characters that are word characters, hypens, or dots
                            return "Please enter a valid email address.";
                          } else if (value.startsWith('.') || value.endsWith('.')) { //input cannot start and end with .
                            return 'Email cannot start or end with a dot.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          email = value!.trim(); //to save trimmed email
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // this is the reset password button
                    ElevatedButton(
                      onPressed: () => reset(context), //this calls the reset function
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFBF70),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 100),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Reset Password",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}