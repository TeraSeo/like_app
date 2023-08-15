import 'package:email_otp/email_otp.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/pages/otp.dart';
import 'package:like_app/pages/register_page.dart';
import 'package:like_app/services/auth_service.dart';
import 'package:like_app/widgets/widgets.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();

  String email = "";
  String password = "";
  bool _isLoading = false;
  AuthServie authServie = AuthServie(); 
  final RoundedLoadingButtonController googleController = 
    RoundedLoadingButtonController();
  final RoundedLoadingButtonController facebookController = 
    RoundedLoadingButtonController();

  TextEditingController _emailController = TextEditingController();
  EmailOTP myauth = EmailOTP();

  // Future<void> _googleSignIn() async {
  //   final googleSignIn = GoogleSignIn();
  //   final googleAccount = await googleSignIn.signIn();
  //   if (googleAccount != null) {
  //     final googleAuth = await googleAccount.authentication;
  //     if (googleAuth.accessToken != null && googleAuth.idToken != null) {
  //       try {
  //         await FirebaseAuth.instance.signInWithCredential(GoogleAuthProvider.credential(
  //           idToken: googleAuth.idToken,
  //           accessToken: googleAuth.accessToken
  //         ));
  //       } on FirebaseException catch(error) {
  //       } catch (error) {
  //       } finally {}
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    double verticalPadding = MediaQuery.of(context).size.height * 0.04;
    double borderCircular = MediaQuery.of(context).size.height * 0.035;
    double padding = MediaQuery.of(context).size.height * 0.027;
    double sizedBox = MediaQuery.of(context).size.height * 0.03;
    double signInBtnWidth = MediaQuery.of(context).size.width * 0.9;
    double signInBtnHeight = MediaQuery.of(context).size.height * 0.04;
    double signInIcon = MediaQuery.of(context).size.height * 0.023;
    double sizedBoxWidth = MediaQuery.of(context).size.height * 0.016;
    double fontSize = MediaQuery.of(context).size.height * 0.018;

    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).primaryColor,
      // ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: _isLoading? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) :  SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height,
              maxWidth: MediaQuery.of(context).size.width,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red,
                  Colors.lightBlue, 
                ],
                begin: Alignment.topLeft,
                end: Alignment.centerRight,
              )
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: verticalPadding, horizontal: verticalPadding / 3 * 2
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Login", 
                          style: TextStyle(
                          color: Colors.white,
                          fontSize: verticalPadding / 4 * 5,
                          fontWeight: FontWeight.w800
                        ),),
                        SizedBox(
                          height: verticalPadding / 4,
                        ),
                        Text(
                          "Enter to a beautiful world", 
                          style: TextStyle(
                          color: Colors.white,
                          fontSize: verticalPadding / 1.7,
                          fontWeight: FontWeight.w300
                        ),)
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(borderCircular),
                        topRight: Radius.circular(borderCircular)
                      )
                    ),
                    child: Form(
                      key: formKey,
                      child: Padding(
                        padding:  EdgeInsets.all(padding),  
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            TextFormField(
                              decoration: textInputDecoration.copyWith(
                                labelText: "Email",
                                prefixIcon : Icon(
                                  Icons.email,
                                  color: Theme.of(context).primaryColor,
                                )
                              ),
                              onChanged: (val) {
                                setState(() {
                                  email = val;
                                });
                              },
                              validator: (val) {
                                return RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=>^_'{|}~]+@[a-zA-Z]+")
                                    .hasMatch(val!) ? null : "Please enter a valid email";
                              },
                            ),
                            SizedBox(height: sizedBox),
                            TextFormField(
                              obscureText: true,
                              decoration: textInputDecoration.copyWith(
                                labelText: "Password",
                                prefixIcon : Icon(
                                  Icons.lock,
                                  color: Theme.of(context).primaryColor,
                                )
                              ),
                              validator: (val) {
                                if (val!.length < 6) {
                                  return "Password must be at least 6 characters";
                                } else {
                                  return null;
                                }
                              },
                              onChanged: (val){
                                setState(() {
                                  password = val;
                                });
                              },
                            ),
                            SizedBox(
                              height: sizedBox * 2.2,
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: signInBtnHeight,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Theme.of(context).primaryColor,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(borderCircular)
                                  )
                                ),
                                child: Text(
                                  "Sign In",
                                  style: TextStyle(color: Colors.white, fontSize: borderCircular / 2),
                                ),
                                onPressed: () {
                                  login();
                                },
                              )
                            ),
                            SizedBox(height: borderCircular / 2 * 1.5),
                            Text.rich(
                              TextSpan(
                                text: "Don't have an account? ",
                                style: TextStyle(color: Colors.black, fontSize: borderCircular / 8 * 3),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: "Register here",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      decoration: TextDecoration.underline  
                                    ),
                                    recognizer: TapGestureRecognizer()..onTap = () {
                                      nextScreen(context, const RegisterPage());
                                    }
                                  ),
                                ]
                              )
                            ),
                            SizedBox(
                              height: sizedBox * 1.2,
                            ),
                            // Row(children: <Widget>[
                            //   Expanded(
                            //     child: new Container(
                            //         margin: const EdgeInsets.only(left: 10.0, right: 20.0),
                            //         child: Divider(
                            //           color: Colors.black,
                            //           height: 36,
                            //         )),
                            //   ),
                            //   Text("OR"),
                            //   Expanded(
                            //     child: new Container(
                            //         margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                            //         child: Divider(
                            //           color: Colors.black,
                            //           height: 36,
                            //         )),
                            //   ),
                            // ]),
                            // SizedBox(
                            //   height: sizedBox * 1.2,
                            // ),
                            // RoundedLoadingButton(
                            //   controller: googleController,
                            //   onPressed: () {
                            //     // _googleSignIn();
                            //   }, 
                            //   successColor: Colors.red,
                            //   width: signInBtnWidth,
                            //   height: signInBtnHeight,
                            //   elevation: 0,
                            //   // borderRadius: 25,
                            //   color: Colors.red,
                            //   child: Wrap(
                            //     children: [
                            //       Icon(
                            //         FontAwesomeIcons.google,
                            //         size: signInIcon,
                            //         color: Colors.white,
                            //       ),
                            //       SizedBox(
                            //         width: sizedBoxWidth,
                            //       ),
                            //       Text("Sign in with Google",
                            //         style: TextStyle(
                            //           color: Colors.white,
                            //           fontSize: fontSize,
                            //           fontWeight: FontWeight.w500
                            //         ),
                            //       )
                            //     ],
                            //   )),
                            // SizedBox(
                            //   height: sizedBox * 0.7,
                            // ),
                            // RoundedLoadingButton(
                            //   controller: facebookController,
                            //   onPressed: () {}, 
                            //   successColor: Colors.blue,
                            //   width: signInBtnWidth,
                            //   height: signInBtnHeight,
                            //   elevation: 0,
                            //   // borderRadius: 25,
                            //   color: Colors.blue,
                            //   child: Wrap(
                            //     children: [
                            //       Icon(
                            //         FontAwesomeIcons.facebook,
                            //         size: signInIcon,
                            //         color: Colors.white,
                            //       ),
                            //       SizedBox(
                            //         width: sizedBoxWidth,
                            //       ),
                            //       Text("Sign in with Facebook",
                            //         style: TextStyle(
                            //           color: Colors.white,
                            //           fontSize: fontSize,
                            //           fontWeight: FontWeight.w500
                            //         ),
                            //       )
                            //     ],
                            //   )),

                            // Container(
                            //   height: signInBtnHeight,
                            //   width: signInBtnWidth,
                            //   decoration: BoxDecoration(
                            //     image: DecorationImage(
                            //         image:
                            //             AssetImage('assets/googleSignIn.png'),
                            //         fit: BoxFit.cover),
                            //   ),
                            // ),
                            SizedBox(
                              height: sizedBox * 6.5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ),
      ),
    );
  }

  login() async  {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authServie.loginWithUserNameandPassword(email, password)
      .then((value) async {
        if (value == true) {
          await HelperFunctions.saveUserEmailSF(email);
          nextScreen(context, const OtpScreen());

        } else {
          setState(() {
            showSnackbar(context, Colors.red, value);
            _isLoading = false; 
          });
        }
      });
    }
  }

  // signInWithGoogle() async {
  //   try {
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  //     if (googleAuth?.accessToken != null && googleAuth?.idToken != null) {
  //       final credential = GoogleAuthProvider.credential(
  //         accessToken: googleAuth?.accessToken,
  //        idToken: googleAuth?.idToken
  //       );

  //      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

  //     }


  //   } on FirebaseAuthException catch (e) {
  //     showSnackbar(context, Colors.black, e.message);
  //   }
    
  // }
}