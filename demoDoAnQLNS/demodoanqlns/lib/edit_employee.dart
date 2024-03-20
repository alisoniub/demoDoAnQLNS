import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditEmployeePage extends StatefulWidget {
  final String employeeId;
  final Map<String, dynamic> employeeData;
  final Function() onEmployeeUpdated;

  const EditEmployeePage({
    Key? key,
    required this.employeeData,
    required this.employeeId,
    required this.onEmployeeUpdated,
  }) : super(key: key);

  @override
  _EditEmployeePageState createState() => _EditEmployeePageState();
}

class _EditEmployeePageState extends State<EditEmployeePage> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneNumberController;
  late TextEditingController idDepartmentController;
  File? _image;
  late TextEditingController _idController;

  bool _isImageSelected = false;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.employeeData['_id']);
    firstNameController = TextEditingController(text: widget.employeeData['firstname']);
    lastNameController = TextEditingController(text: widget.employeeData['lastName']);
    phoneNumberController = TextEditingController(text: widget.employeeData['phoneNumber']);
    idDepartmentController = TextEditingController(text: widget.employeeData['idDepartment']);
    fetchEmployeeData();
  }

  @override
  void dispose() {
    // Dispose controllers
    _idController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    idDepartmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh sửa nhân viên'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _idController,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Mã nhân viên',
                labelStyle: TextStyle(fontSize: 16.0),
              ),
            ),
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(labelText: 'Tên'),
            ),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: 'Họ'),
            ),
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(labelText: 'Số điện thoại'),
            ),
            TextField(
              controller: idDepartmentController,
              decoration: InputDecoration(labelText: 'Phòng ban'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _chooseImage,
              child: Text('Chọn ảnh'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateEmployee,
              child: Text('Lưu'),
            ),
            SizedBox(height: 15),
            if (_image != null) ...[
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 2.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  //giới hạn số điện thoại nhập vào 10 số
  bool _validatePhoneNumber(String phoneNumber) {
    return RegExp(r'^\d{10}$').hasMatch(phoneNumber);
  }

  //đưa thông tin nhân viên vào TextField
  Future<void> fetchEmployeeData() async {
    final response = await http.get(Uri.parse('http://192.168.16.1:3000/api/employee/update/${widget.employeeId}'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        firstNameController.text = data['firstname'];
        lastNameController.text = data['lastName'];
        phoneNumberController.text = data['phoneNumber'];
        idDepartmentController.text = data['idDepartment'];
      });
    } else {
      throw Exception('Failed to load employee data');
    }
  }

  //thực hiện thay đổi thông tin nhân viên nhập vào từ TextField
  Future<void> _updateEmployee() async {
    if (_validatePhoneNumber(phoneNumberController.text)) {
      try {
        final response = await http.put(
          Uri.parse('http://192.168.16.1:3000/api/employee/update/${widget.employeeId}'),
          body: {
            'firstName': firstNameController.text,
            'lastName': lastNameController.text,
            'phoneNumber': phoneNumberController.text,
            'idDepartment': idDepartmentController.text,
          },
        );
        if (response.statusCode == 200) {
          widget.onEmployeeUpdated();
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Thành công'),
                content: Text('Đã chỉnh sửa nhân viên ${firstNameController.text} ${lastNameController.text} thành công.\nMã nhân viên: ${widget.employeeId}'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          throw Exception('Failed to update employee');
        }
      } catch (error) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Lỗi'),
              content: Text('Đã xảy ra lỗi khi cập nhật nhân viên: $error'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Lỗi'),
            content: Text('Số điện thoại phải là chuỗi 10 chữ số và không chứa kí tự khác số.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
  //chọn hình ảnh và hiển thị hình ảnh
  Future<void> _chooseImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _image = imageFile;
        _isImageSelected = true;
      });
    }
  }
}
