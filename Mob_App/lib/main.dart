import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SignUpPage(),
    );
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the text fields
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Gender and Date Picker values
  String? gender;
  DateTime? selectedDate;

  // Terms and Conditions checkbox
  bool isChecked = false;

  final List<Map<String, String>> validCredentials = [
    {'email': 'user1@example.com', 'password': 'password123'},
    {'email': 'user2@example.com', 'password': 'password456'},
    {'email': 'user3@example.com', 'password': 'password789'}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: fullNameController,
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 3) {
                    return 'Full Name is required and must be at least 3 characters';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      !value.contains('@') ||
                      !value.contains('.')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'Password is required and must be at least 6 characters';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: gender,
                decoration: InputDecoration(labelText: 'Gender'),
                items: ['Male', 'Female', 'Other']
                    .map((gender) => DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    gender = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a gender';
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text("Date of Birth"),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && picked != selectedDate) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
              ),
              if (selectedDate != null)
                Text("${selectedDate!.toLocal()}".split(' ')[0]),
              CheckboxListTile(
                title: Text("Accept Terms & Conditions"),
                value: isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && isChecked) {
                    String email = emailController.text;
                    String password = passwordController.text;
                    if (validCredentials.any((cred) =>
                        cred['email'] == email &&
                        cred['password'] == password)) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WelcomePage(
                            fullName: fullNameController.text,
                            email: email,
                            gender: gender!,
                            dob: selectedDate!,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Invalid email or password')));
                    }
                  }
                },
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  final String fullName;
  final String email;
  final String gender;
  final DateTime dob;

  WelcomePage({
    required this.fullName,
    required this.email,
    required this.gender,
    required this.dob,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Welcome, $fullName!', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            Text('Email: $email'),
            Text('Gender: $gender'),
            Text('Date of Birth: ${dob.toLocal()}'.split(' ')[0]),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to AboutUsPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AboutUsPage(),
                  ),
                );
              },
              child: Text('Go to About Us'),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About Us')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('App Name: FlutterApp', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            Text('Team Members:'),
            ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    AssetImage('assets/images/farhana.jpg'), // Add image here
                radius: 30,
              ),
              title: Text('Farhana Alam'),
              subtitle: Text('Roll: 48, Email: falam3399@gmail.com'),
              trailing: Icon(Icons.mail),
              onTap: () async {
                final url = 'mailto: falam3399@gmail.com';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    AssetImage('assets/images/shakin.jpg'), // Add image here
                radius: 30,
              ),
              title: Text('Shakin Alam Kabbo'),
              subtitle: Text('Roll: 11, Email: kabboshakin088@gmail.com'),
              trailing: Icon(Icons.mail),
              onTap: () async {
                final url = 'mailto: kabboshakin088@gmail.com';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    AssetImage('assets/images/masum.jpg'), // Add image here
                radius: 30,
              ),
              title: Text('N. M Rashidujjaman Masum'),
              subtitle: Text('Roll: 57, Email: nmrmasumbdkk531@gmail.com'),
              trailing: Icon(Icons.mail),
              onTap: () async {
                final url = 'mailto: nmrmasumbdkk531@gmail.com';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    AssetImage('assets/images/jubair.jpg'), // Add image here
                radius: 30,
              ),
              title: Text('Jubair Ahammad Akter'),
              subtitle: Text('Roll: 59, Email: akteradib007@gmail.com'),
              trailing: Icon(Icons.mail),
              onTap: () async {
                final url = 'mailto: akteradib007@gmail.com';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
