import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AccountPage extends StatefulWidget {
  final String employeeID;
  //truyền id nhân viên
  const AccountPage({Key? key, required this.employeeID}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String _id = '';
  String password = '';
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    fetchAccountDetails();
    _showPassword = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tài khoản'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin tài khoản:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'ID: $_id',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Password: ',
                  style: TextStyle(fontSize: 16),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                  child: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 5),
                // Password text will be shown only if _showPassword is true
                if (_showPassword)
                  Text(
                    password,
                    style: TextStyle(fontSize: 16),
                  )
                else
                  Text(
                    '******',
                    style: TextStyle(fontSize: 16),
                  ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _showChangePasswordDialog();
              },
              child: Text('Sửa mật khẩu'),
            ),
          ],
        ),
      ),
    );
  }

  //nhận thông tin account từ collection Accounts
  Future<void> fetchAccountDetails() async {
    final String apiUrl = 'http://192.168.16.1:3000/api/get_account_details';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'employeeID': widget.employeeID,
        }),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _id = responseData['id'];
          password = responseData['password'];
        });
      } else {
        print('Đã xảy ra lỗi: ${response.statusCode}');
      }
    } catch (error) {
      print('Đã xảy ra lỗi: $error');
    }
  }

  //thay đối mật khẩu
  Future<void> changePassword(String newPassword) async {
    final String apiUrl = 'http://192.168.16.1:3000/api/accounts/updatePassword/${widget.employeeID}';
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          print('Thay đổi mật khẩu thành công');
          setState(() {
            password = newPassword;
          });
        } else {
          print('Đã xảy ra lỗi: ${responseData['message']}');
        }
      } else {
        print('Đã xảy ra lỗi: ${response.statusCode}');
      }
    } catch (error) {
      print('Đã xảy ra lỗi: $error');
    }
  }
  //hiển thị mật khẩu/ẩn mật khẩu
  Future<void> _showChangePasswordDialog() async {
    String newPassword = '';
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Thay đổi mật khẩu'),
          content: TextFormField(
            decoration: InputDecoration(hintText: 'Nhập mật khẩu mới'),
            onChanged: (value) {
              newPassword = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                changePassword(newPassword);
                Navigator.of(context).pop();
              },
              child: Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }
}
