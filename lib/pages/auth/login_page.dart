import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:groupie_chatapp/pages/auth/register_page.dart';
import 'package:groupie_chatapp/pages/home_page.dart';
import 'package:groupie_chatapp/services/auth_service.dart';
import 'package:groupie_chatapp/services/database_service.dart';
import 'package:groupie_chatapp/utils/constants.dart';
import 'package:groupie_chatapp/utils/widgets/common_widgets.dart';

import '../../utils/widgets/customLoader.dart';

class LoginPage extends StatefulWidget {
   LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController=TextEditingController();

  TextEditingController passwordController=TextEditingController();

  final _formKey=GlobalKey<FormState>();

  bool isLoading=false;

  AuthService authService=AuthService();

  @override
  Widget build(BuildContext context) {

    _login(){
      setState((){
        isLoading=true;
      });
      authService.loginWithEmailAndPassword(emailController.text,passwordController.text).then((value){
        if(value==true){
          nextScreenReplace(context, HomePage());
        }
        else{
          setState((){
            isLoading=false;
          });
          showSnackbar(context, Colors.red, value);
        }
      });
    }

    return Scaffold(
      body: isLoading?
       customLoader():SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 20,right: 20,top: MediaQuery.of(context).size.height*0.08,bottom: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Groupie",style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold
                ),),
                SizedBox(height: 10,),
                Text("Login now to see what they are talking!",style: TextStyle(
                    fontSize: 15,
                ),),
                Image.asset(Constants.getAssetImagePath(imageName: "onlineworld.gif"),height:MediaQuery.of(context).size.height*0.4,width: double.infinity,),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value){
                    return RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value!)
                        ? null
                        : "Please enter a valid email";
                  },
                  decoration: commonTextInputDecoration.copyWith(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email,color: Constants.primaryColour,),
                  )
                ),
                SizedBox(height: 10,),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                    validator: (value){
                    return value!.length>6?null:"Please enter a valid password";
                    },
                    decoration: commonTextInputDecoration.copyWith(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock,color: Constants.primaryColour,),
                    )
                ),
                SizedBox(height: 20,),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: (){
                        if(_formKey.currentState!.validate()){
                          _login();
                        }

                      },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                      child:Text("Sign In",style: TextStyle(
                        fontSize: 16,
                      ),)
                  ),
                ),
                SizedBox(height: 10,),
                Text.rich(TextSpan(
                  text: "Don't have an account? ",
                  style: const TextStyle(
                      color: Colors.black, fontSize: 14),
                  children: <TextSpan>[
                    TextSpan(
                        text: "Register here",
                        style: const TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            nextScreen(context, RegisterPage());
                          }),
                  ],
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
