import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

//this is the change password screen that is accessed from the settings screen from the appdrawer
class ChangePasswordScreen extends StatelessWidget {
  static String routeName = '/change-password';

//accessing the firebase service using getit for dependency injection
  final FirebaseService fbService = GetIt.instance<FirebaseService>();
  final formKey = GlobalKey<FormState>(); //form key used to validate and save form state
  String? currentPassword; //these are the variables to store from input values
  String? newPassword;

  //this is the function to handle password change
  void changePassword(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      try {
        final user = FirebaseAuth.instance.currentUser;
        final email = user?.email;

        //this reauthenticates a user before allowing them to change their password
        final credential = EmailAuthProvider.credential(
          email: email!,
          password: currentPassword!,
        );

        await user!.reauthenticateWithCredential(credential); //this is required for sensitive operations
        await user.updatePassword(newPassword!); //this is to change the password

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully.')), //shows the success message
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Failed to change password.')), //shows error message if reauthentication or update password fails
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar( //this is the appbar with logo styling
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'SustainaBite',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Image.asset('images/SustainaBite.png', height: 240), //this is the app logo image
          const SizedBox(height: 12),
          Expanded( //this is the form container
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFA1CEAF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    const Text('Change password', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    //this is the input field for users to type in their current password
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDE7DA),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2))],
                      ),
                      child: TextFormField(
                        obscureText: true, //this hides the password input when user types in
                        keyboardType: TextInputType.visiblePassword, //this is the keyboard type for password
                        decoration: const InputDecoration(
                          hintText: 'Current password',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 25),
                        ),
                        validator: (value) { //i only used basic form validation to check password presence and length only as i assume the password was already validated during sign up
                          if (value == null || value.isEmpty) { //makes sure input field is not empty
                            return 'Please enter your current password.';
                          } else if (value.length < 6) { //makes sure input has at least 6 characters
                            return 'Password must be at least 6 characters.';
                          }
                          return null;
                        },
                        onSaved: (value) => currentPassword = value,
                      ),
                    ),

                    const SizedBox(height: 20),

                    //input field for users to input their new password
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDE7DA),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2))],
                      ),
                      child: TextFormField(
                        obscureText: true, //this hides password input
                        keyboardType: TextInputType.visiblePassword, //this s the keyboard type for password
                        decoration: const InputDecoration(
                          hintText: 'New password',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 25),
                        ),
                            validator: (value) {
                              if (value == null || value.isEmpty) { //input field must not be empty
                                return 'Please enter a new password.';
                              } else if (value.length < 6) { //password input must have at least 6 characters
                                return 'Password must be at least 6 characters.';
                              } else if (!RegExp(r'[A-Z]').hasMatch(value)) { //password input must have at least one uppercase
                                return 'Password must contain at least one uppercase letter.';
                              } else if (!RegExp(r'[a-z]').hasMatch(value)) { //password input must have at least one lowercase
                                return 'Password must contain at least one lowercase letter.';
                              } else if (!RegExp(r'[0-9]').hasMatch(value)) { //this unput must contain at least one number
                                return 'Password must contain at least one number.';
                              } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) { //this input must have at least one special character
                                return 'Password must contain at least one special character.';
                              }
                              return null;
                            },
                        onSaved: (value) => newPassword = value, //saves the users input from the form field into the newpassword variable
                      ),
                    ),

                    const SizedBox(height: 24),
                    ElevatedButton( //this is the update password button
                      onPressed: () => changePassword(context), //saves the input from the form field
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFBF70),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 100),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Update password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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