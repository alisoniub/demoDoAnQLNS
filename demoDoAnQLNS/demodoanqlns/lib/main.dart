import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'home.dart';
import 'personneldirectory.dart';
import 'info.dart';

void main() {

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  get firstName => null;
  get lastName => null;
  get employeeID => null;
  //get email => null;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Do An Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Do An'),
      routes: {
        '/app': (context) => MyHomePage(title: 'Quan Ly Nhan Su'),
        //'/home': (context) => Home(firstName: firstName,lastName: lastName, employeeID: employeeID, employeeImage: avt,),
        //'/direc': (context) => Directory(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/background_login1.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'WELCOME',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  'H R M',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF808000),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage()
                      ),
                    );
                  },
                  child: Text(
                    'Sign in',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _idController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;
  bool rememberPassword = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background_login1.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Đăng nhập',
                  style: TextStyle(
                    fontSize: 35.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6600FF),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30.0),
                Text(
                  'Nhập id',
                  style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _idController,
                  decoration: InputDecoration(hintText: 'Nhập id'),
                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20.0),
                Text(
                  'Nhập mật khẩu',
                  style: TextStyle(fontSize: 13.0),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Nhập mật khẩu',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                  ),
                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                  obscureText: _isObscure,
                ),
                SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    _xulyLogin(context);
                  },
                  child: Text('Đăng nhập'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF6600FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: rememberPassword,
                      onChanged: (value) {
                        setState(() {
                          rememberPassword = value!;
                        });
                      },
                    ),
                    Text(
                      'Nhớ mật khẩu',
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Quên Mật Khẩu ?',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Colors.amberAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> loginCheck(String id, String password) async {
    final url = Uri.parse('http://192.168.16.1:3000/api/login');
    final response = await http.post(
      url,
      body: jsonEncode({
        '_idController': id,
        '_passwordController': password,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    var responseBody = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Đăng nhập không thành công: ${jsonDecode(response.body)['message']}');
    }
  }

  void _xulyLogin(BuildContext context) async {
    String id = _idController.text;
    String password = _passwordController.text;
    try {
      final response = await loginCheck(id, password);
      print('Đăng nhập thành công: ${response['message']}');
      // Chuyển hướng sang trang Home và truyền thông tin nhân viên
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Home(
            firstName: response['firstName'] ?? '',
            lastName: response['lastName'] ?? '',
            employeeID: response['employeeID'] ?? '',
            employeeImage: response['employeeImage'] ?? '',
        ),
      ));
      //Navigator.pushReplacementNamed(context, '/home');
    } catch (error) {
      print('Đăng nhập không thành công: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Đăng nhập không thành công'),
            content: Text('Tên người dùng hoặc mật khẩu không chính xác. Vui lòng thử lại.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Đóng'),
              ),
            ],
          );
        },
      );
    }
  }
}

