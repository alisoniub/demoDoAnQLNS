import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class Infor extends StatefulWidget {
  final String idInfo;

  Infor({Key? key, required this.idInfo}) : super(key: key);

  @override
  _InforState createState() => _InforState();
}

class _InforState extends State<Infor> with SingleTickerProviderStateMixin {
  late Future<Map<String, dynamic>> _employeeData;
  late AnimationController _controller;
  late Animation<double>? _animation;
  bool _isFrontVisible = true;

  @override
  void initState() {
    super.initState();
    _employeeData = fetchEmployeeData();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  //lấy thông tin của 1 nhân viên
  Future<Map<String, dynamic>> fetchEmployeeData() async {
    final response = await http.get(Uri.parse('http://192.168.16.1:3000/api/employee/${widget.idInfo}'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Không thể tải dữ liệu nhân viên');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin cá nhân'),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: _employeeData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi'));
          } else {
            Map<String, dynamic>? employeeData = snapshot.data as Map<String, dynamic>?;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Thông tin cá nhân',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_isFrontVisible && _animation != null) {
                          _controller.forward();
                        } else if (_animation != null) {
                          _controller.reverse();
                        }
                        _isFrontVisible = !_isFrontVisible;
                      });
                    },
                    child: Transform(
                      transform: Matrix4.identity()..rotateY(_animation?.value ?? 0 * 3.141592),
                      alignment: Alignment.center,
                      child: Container(
                        width: 171,
                        height: 171,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(85),
                          border: Border.all(width: 2, color: Colors.black),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(85),
                          child: Image.asset(
                            'assets/${employeeData?['avt']?['imageName'] ?? 'avtnv009.jpg'}',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  buildInfoRow('Tên:', '${employeeData?['lastName']} ${employeeData?['firstName']}'),
                  buildInfoRow('MSNV:', '${employeeData?['_id']}'),
                  buildInfoRow('Ngày sinh:', '${employeeData?['dateOfBirth']}'),
                  buildInfoRow('SĐT:', '${employeeData?['phoneNumber']}'),
                  buildInfoRow('Chức vụ:', '${employeeData?['position']}'),
                  buildInfoRow('Email:', '${employeeData?['email']}'),
                ],
              ),
            );
          }
        },
      ),
    );
  }
  //format cho các InfoRow
  Widget buildInfoRow(String label, String value) {
    if (label == 'SĐT:' || label == 'Email:') {
      return Row(
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            onPressed: () {
              _showEditDialog(label, value);
            },
            icon: Icon(Icons.edit),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
          SizedBox(height: 40),
          if (label == 'Ngày sinh:')
            Text(
              formatDateString(value),
              style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          if (label != 'Ngày sinh:')
            Expanded(
              child: Text(
                value,
                style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      );
    }
  }
  //định dạng ngày hiển thị
  String formatDateString(String dateString) {
    var parsedDate = DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').parse(dateString);
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  }
  //dialog chỉnh sửa SDT và Email
  Future<void> _showEditDialog(String label, String currentValue) async {
    String updatedValue = currentValue;
    String hintText = '';
    if (label == 'SĐT:') {
      hintText = 'Nhập số điện thoại mới';
    } else if (label == 'Email:') {
      hintText = 'Nhập email mới';
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Chỉnh sửa $label'),
              content: TextField(
                decoration: InputDecoration(
                  hintText: hintText,
                ),
                controller: TextEditingController(text: currentValue),
                onChanged: (value) {
                  updatedValue = value;
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Xác nhận'),
                  onPressed: () async {
                    if ((label == 'SĐT:' && !isPhoneNumberValid(updatedValue)) ||
                        (label == 'Email:' && !isEmailValid(updatedValue))) {
                      showInvalidInputDialog(context, label);
                      return;
                    }
                    try {
                      if (label == 'SĐT:') {
                        await updatePhoneNumber(widget.idInfo, updatedValue);
                      } else if (label == 'Email:') {
                        await updateEmail(widget.idInfo, updatedValue);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Bạn đã cập nhật $label $updatedValue'),
                        ),
                      );
                      await fetchAndSetEmployeeData();
                    } catch (e) {
                      print('Lỗi cập nhật $label: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã xảy ra lỗi khi cập nhật $label'),
                        ),
                      );
                    }
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Hủy'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
  //cập nhật sdt
  Future<void> updatePhoneNumber(String id, String newPhoneNumber) async {
    if (!isPhoneNumberValid(newPhoneNumber)) {
      throw Exception('Số điện thoại không hợp lệ');
    }
    final String normalizedPhoneNumber = normalizePhoneNumber(newPhoneNumber);

    final String apiUrl = 'http://192.168.16.1:3000/api/updatePhoneNumber/$id';
    final response = await http.put(Uri.parse(apiUrl), body: {'phoneNumber': normalizedPhoneNumber});

    if (response.statusCode == 200) {
      print('Cập nhật số điện thoại thành công');
    } else {
      throw Exception('Cập nhật số điện thoại thất bại');
    }
  }
  //cập nhật email
  Future<void> updateEmail(String id, String newEmail) async {
    final String apiUrl = 'http://192.168.16.1:3000/api/updateEmail/$id';
    final response = await http.put(Uri.parse(apiUrl), body: {'email': newEmail});

    if (response.statusCode == 200) {
      print('Cập nhật email thành công');
    } else {
      throw Exception('Cập nhật email thất bại');
    }
  }
  //kiểm tra xem email có chứa dấu @ không
  bool isEmailValid(String email) {
    return email.contains('@');
  }
  //kiểm tra độ dài SDT phải là 10 số, và không chứ kí tự
  bool isPhoneNumberValid(String phoneNumber) {
    return phoneNumber.length == 10 && int.tryParse(phoneNumber) != null;
  }
  String normalizePhoneNumber(String phoneNumber) {
    return phoneNumber;
  }
  //hiển thị Dialog thông báo nhập sai cú pháp
  void showInvalidInputDialog(BuildContext context, String label) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(label == 'Email:' ? 'Email không hợp lệ' : 'Số điện thoại không hợp lệ'),
          content: Text(label == 'Email:' ? 'Vui lòng nhập một địa chỉ email hợp lệ.' : 'Vui lòng nhập lại số điện thoại có 10 chữ số và không chứa ký tự khác số.'),
          actions: <Widget>[
            TextButton(
              child: Text('Đóng'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchAndSetEmployeeData() async {
    final updatedEmployeeData = await fetchEmployeeData();
    fetchEmployeeData().then((data) {
      setState(() {
        _employeeData = Future<Map<String, dynamic>>.value(data);
      });
    }).catchError((error) {
      print('Error fetching employee data: $error');
    });
  }
}
