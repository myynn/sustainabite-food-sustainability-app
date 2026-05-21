import 'package:flutter/material.dart';
import 'package:project_part2/screens/login_screen.dart';
import 'package:project_part2/screens/signup_screen.dart';


//this is the start screen after user logs out or they choose whether they want to login or sign up as new user
class StartScreen extends StatelessWidget {
  static String routeName = '/start';

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column( //this is used to stack the main content and the button section veritcally
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                
                  const Text(
                    'SustainaBite', //title of the app
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

             
                  Image.asset('images/SustainaBite.png', height: 300), //the app logo image

                  const SizedBox(height: 20),

   
                  const Text(
                    'Fresh food, greener planet.', //the slogan of the app
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

     
          ClipRRect( //this helps to make the top corners of the green container rounded
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
            child: Container( //this container holds the login and signup buttons
              height: screenHeight * 0.40,
              width: double.infinity,
              color: const Color(0xFFA1CEAF),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton( //this navigates the user to the login screen when pressed
                      onPressed: () {
                        Navigator.pushNamed(context, LoginScreen.routeName);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFBF70),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton( //this takes the user to the sign up screen when pressed
                      onPressed: () {
                        Navigator.pushNamed(context, SignupScreen.routeName);
                      },
                      style: OutlinedButton.styleFrom( //the button only has an outline to follow the wireframe
                        side: const BorderSide(
                          color: Color(0xFFFFBF70),
                          width: 2,
                        ),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
