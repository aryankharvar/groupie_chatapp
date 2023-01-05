import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:groupie_chatapp/utils/constants.dart';
import 'package:groupie_chatapp/utils/widgets/common_widgets.dart';

import '../../services/auth_service.dart';
import '../home_page.dart';

class RegisterPage extends StatefulWidget {
   RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController= TextEditingController();

  TextEditingController passwordController= TextEditingController();

  TextEditingController nameController= TextEditingController();

   final _formKey=GlobalKey<FormState>();

   AuthService authService=AuthService();

   bool isLoading=false;

  @override
  Widget build(BuildContext context) {

    _register(){
      setState((){
        isLoading=true;
      });
      authService.registerUserWithEmailAndPassword(nameController.text,emailController.text,passwordController.text).then((value){
        if(value==true){
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => HomePage()),
                  (route) => false);
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

      body: isLoading? const Center(child: CircularProgressIndicator()):SingleChildScrollView(
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
                Text("Create your account now to chat and explore",style: TextStyle(
                  fontSize: 15,
                ),),
                Image.asset(Constants.getAssetImagePath(imageName: "onlineworld_register.gif"),height:MediaQuery.of(context).size.height*0.35,width: double.infinity,),
                //SizedBox(height: 10,),
                TextFormField(
                    controller:nameController,
                    validator: (value){
                      return RegExp(
                          r"^[a-zA-Z]+")
                          .hasMatch(value!) && value.length>2?null:"Please enter a valid name";
                    },
                    keyboardType: TextInputType.text,
                    decoration: commonTextInputDecoration.copyWith(
                      labelText: "Full Name",
                      prefixIcon: Icon(Icons.person,color: Constants.primaryColour,),
                    )
                ),
                SizedBox(height: 10,),
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
                      return value!.length>6?null:"Password must contain at least seven characters.";
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
                          _register();
                        }

                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child:Text("Register",style: TextStyle(
                        fontSize: 16,
                      ),)
                  ),
                ),
                SizedBox(height: 10,),
                Text.rich(TextSpan(
                  text: "Already have an account? ",
                  style: const TextStyle(
                      color: Colors.black, fontSize: 14),
                  children: <TextSpan>[
                    TextSpan(
                        text: "Login Now",
                        style: const TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pop(context);
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
