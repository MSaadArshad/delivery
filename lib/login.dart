import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class View extends StatefulWidget {
  const View({super.key});

  @override
  State<View> createState() => _ViewState();
}

class _ViewState extends State<View> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool _passwordVisible = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.height *
        0.01; // Provides height of the screen
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding: EdgeInsets.all(size * 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Login',
                      style: TextStyle(
                          fontSize: size * 4, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: size * 4),
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Email Address",
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      controller: email,
                    ),
                    SizedBox(height: size * 4),
                    TextField(
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        labelText: "Password",
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      controller: password,
                    ),
                    Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                            onPressed: () {},
                            child: Text('Forgot password?',
                                style: TextStyle(
                                    fontSize: size * 2,
                                    fontWeight: FontWeight.bold)))),
                    SizedBox(height: size * 2),
                    ButtonTheme(
                        minWidth: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.06,
                        shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color: Color(0xFF052339),
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(10)),
                        child: MaterialButton(
                          elevation: 8.0,
                          onPressed: () {
                            _checkCredentials(email.text, password.text);
                          },
                          color: const Color(0xFF052339),
                          child: Text(
                            'Login',
                            style: TextStyle(
                                fontSize: size * 2, color: Colors.white),
                          ),
                        )),
                    SizedBox(height: size * 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('New here? ',
                            style: TextStyle(
                                fontSize: size * 2,
                                fontWeight: FontWeight.bold)),
                        InkWell(
                          child: Text('Create an account',
                              style: TextStyle(
                                  fontSize: size * 2,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold)),
                          onTap: () {},
                        ),
                      ],
                    ),
                    SizedBox(height: size * 3),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_back),
                      label: Text('Back to user type screen',
                          style: TextStyle(fontSize: size * 1.75)),
                    ),
                    const Spacer(),
                    const Text(
                      'Version: 3.9.3',
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  _loadCredentials() async {
    // This method checks if the user is already logged in
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('email') && prefs.containsKey('password')) {
      await _checkCredentials(prefs.getString('email'), prefs.getString('password'));
    }
  }

  _checkCredentials(email, password) async {
    // This method sends a request to verify the email and password

    if (email == "") {
      showDialog(
          context: context,
          builder: (context) => const AlertDialog(
                title: Text("Missing Information"),
                content: Text("Please enter the email address"),
              ));
      return;
    }

    if (password == "") {
      showDialog(
          context: context,
          builder: (context) => const AlertDialog(
                title: Text("Missing Information"),
                content: Text("Please enter the password"),
              ));
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });
      var url = Uri.parse('https://dev2.deliveryapp.com/api/user/authenticate'); // Api request
      final response = await http.post(
        url,
        body: {
          'email': email,
          'password': password,
          'device_name': 'mobile',
          'device_token': '1234565sssasdsfdgd6789',
          'device_os': 'ios',
          'device_details': '[]'
        },
      );

      if (response.statusCode == 200) {
        isLoading = false;
        _saveCredentials(email, password); // saves credentials on first log in
      } else {
        setState(() {
          isLoading = false;
        });
        // ignore: use_build_context_synchronously
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: const Text("Incorrect credentials"),
                content: const Text(
                    "The provided email or password is incorrect, please check the credentials and try again."),
                actions: <Widget>[
                  ElevatedButton(
                      child: const Text(
                        'Ok!',
                      ),
                      onPressed: () {
                        setState(() {
                          Navigator.pop(context);
                        });
                      }),
                ],
              );
            });
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        isLoading = false;
      });
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text(
                  "Failed to login at this time, please try again later!"),
              actions: <Widget>[
                ElevatedButton(
                    child: const Text(
                      'Ok!',
                    ),
                    onPressed: () {
                      setState(() {
                        Navigator.pop(context);
                      });
                    }),
              ],
            );
          });
      return;
    }
  }

  _saveCredentials(String email, String password) async {
    // This method saves credentials on first log in and takes the user to the order creation page
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
    prefs.setString('password', password);
    // ignore: use_build_context_synchronously
    Navigator.pushNamedAndRemoveUntil(context, 'order', (route) => false);
  }

}
