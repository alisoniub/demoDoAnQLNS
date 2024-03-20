import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddEmployeePage extends StatefulWidget {
  final Function() onEmployeeAdded;

  const AddEmployeePage({Key? key, required this.onEmployeeAdded})
      : super(key: key);

  @override
  _AddEmployeePageState createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  File? _image;
  bool _imageSelected = false;

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController idDepartmentController = TextEditingController();
  TextEditingController _idController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm nhân viên'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 15),
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: 'Mã nhân viên'),
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
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _chooseImage,
              child: Text('Chọn ảnh'),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () async {
                String _id = _idController.text;
                String firstName = firstNameController.text;
                String lastName = lastNameController.text;
                String phoneNumber = phoneNumberController.text;
                String idDepartment = idDepartmentController.text;
                try {
                  print('ID: $_id');
                  await addEmployee(_id, firstName, lastName, phoneNumber, idDepartment);
                  if (widget.onEmployeeAdded != null) {
                    widget.onEmployeeAdded();
                  }
                  Navigator.pop(context);
                } catch (error) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Lỗi'),
                        content: Text('Đã xảy ra lỗi khi thêm nhân viên.'),
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
              },
              child: Text('Thêm nhân viên'),
            ),
            SizedBox(height: 15),
            if (_image != null) ...[
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black, // Màu viền
                    width: 2.0, // Độ dày viền
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  //chọn hình ảnh từ máy khách
  Future<void> _chooseImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _image = imageFile;
        _imageSelected = true;
      });
    }
  }

  //thêm nhân viên
  Future<void> addEmployee(String _id, String firstName, String lastName, String phoneNumber, String idDepartment) async {
    // try {
    //   if (image == null) {
    //     throw Exception('No image selected');
    //   }

      var uri = Uri.parse('http://192.168.16.1:3000/api/employee/add');
      var request = http.MultipartRequest('POST', uri);
      request.fields['_id'] = _id;
      request.fields['firstName'] = firstName;
      request.fields['lastName'] = lastName;
      request.fields['phoneNumber'] = phoneNumber;
      request.fields['idDepartment'] = idDepartment;

      // List<int> imageBytes = await image.readAsBytes();
      // String base64Image = base64Encode(imageBytes);
      // request.fields['avt'] = jsonEncode({
      //   'imageName': image.path.split('/').last,
      //   'imageBinary': base64Image,
      // });

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception('Failed to add employee');
      }
    // } catch (error) {
    //   throw Exception('Failed to add employee: $error');
    // }
  }
}
