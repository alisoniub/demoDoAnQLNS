import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'edit_employee.dart';
import 'add_employee.dart';

class Directory extends StatefulWidget {
  final String idDirec;

  Directory({Key? key, required this.idDirec}) : super(key: key);

  @override
  _DirectoryState createState() => _DirectoryState();
}

class _DirectoryState extends State<Directory> {
  late Future<List<dynamic>> _futureEmployeeList;

  @override
  void initState() {
    super.initState();
    _futureEmployeeList = fetchEmployeeData();
    authenticateAndAuthorize();
    _fetchEmployeeAvatar();
  }

  bool canEdit = false;
  String? _avatarUrl;
  List<String> _avatarUrls = [];
  //xác thực quyền admin
  Future<void> authenticateAndAuthorize() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.16.1:3000/api/authenticate/${widget.idDirec}'),
      );
      if (response.statusCode == 200) {
        setState(() {
          canEdit = true;
        });
      } else {
        print('Xác thực thất bại');
      }
    } catch (error) {
      print('Lỗi xác thực và phân quyền: $error');
    }
  }
  //lấy hình ảnh từ csd;
  Future<void> _fetchEmployeeAvatar() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.16.1:3000/api/avt'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          List<String> imageNames = [];
          for (var employee in data) {
            String imageName = employee['imageName'];
            imageNames.add(imageName);
          }
          setState(() {
            _avatarUrls = imageNames.map((imageName) => 'assets/$imageName').toList();
          });
        } else {
          setState(() {
            _avatarUrls = ['assets/avtnv009.jpg'];
          });
        }
      } else {
        throw Exception('Failed to load employee data');
      }
    } catch (e) {
      print('Error fetching employee avatar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh bạ nhân sự'),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: FutureBuilder(
              future: _futureEmployeeList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Đã xảy ra lỗi'));
                } else {
                  var employeeList = snapshot.data;
                  return ListView.builder(
                    itemCount: employeeList?.length,
                    itemBuilder: (context, index) {
                      var employee = employeeList?[index];
                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              //dữ liệu avt là null thì lấy avt mặc định
                              backgroundImage: _avatarUrl != null
                                  ? AssetImage(_avatarUrl!)
                                  : AssetImage('assets/avtnv009.jpg'),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${employee['_id']} ${employee['lastName']} ${employee['firstName']}',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    String phoneNumber = employee['phoneNumber'].toString();
                                    _launchCall(phoneNumber);
                                  },
                                  icon: Icon(Icons.call, color: Colors.lightGreen),
                                ),
                                //nếu không phải là admin không hiển thị nút button Icons.edit
                                if (canEdit)
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditEmployeePage(
                                            employeeData: employee,
                                            employeeId: employee['_id'],
                                            onEmployeeUpdated: () {
                                              setState(() {
                                                _futureEmployeeList = fetchEmployeeData();
                                              });
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.edit),
                                  ),
                              ],
                            ),
                            subtitle: Text(
                              '${employee['phoneNumber']}, ${employee['idDepartment']}',
                            ),
                            onLongPress: () {
                              //nếu không phải là admin không có hành động xóa 1 nhân viên nào
                              if (canEdit) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Xác nhận xóa'),
                                      content: Text(
                                        'Bạn có chắc muốn xóa nhân viên này?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Hủy'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await deleteEmployee(employee['_id']);
                                            Navigator.pop(context);
                                            setState(() {
                                              _futureEmployeeList = fetchEmployeeData();
                                            });
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('Thông báo'),
                                                  content: Text('Đã xóa nhân viên ${employee['_id']}'),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text('OK'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Text('Xóa'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                          ),
                          Divider(),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      //chỉ hiển thị nút thêm nhân viên khi là quyền Admin
      floatingActionButton: canEdit
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEmployeePage(
                onEmployeeAdded: () {
                  setState(() {
                    _futureEmployeeList = fetchEmployeeData();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Thêm thành công nhân viên'),
                    ),
                  );
                },
              ),
            ),
          );
        },
        backgroundColor: Colors.blueGrey,
        child: Icon(Icons.add),
      )
          : null,
    );
  }
  //hiển thị danh sách nhân viên
  Future<List<dynamic>> fetchEmployeeData() async {
    final response = await http.get(Uri.parse('http://192.168.16.1:3000/api/employees/list'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load employee data');
    }
  }

  //xóa nhân viên
  Future<void> deleteEmployee(String employeeId) async {
    final response = await http.delete(Uri.parse('http://192.168.16.1:3000/api/employee/delete/$employeeId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete employee');
    }
  }

  //hàm thực hiện cuộc gọi
  void _launchCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      //mở cuộc gọi thông qua ứng dụng khác
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thiết bị không hỗ trợ cuộc gọi trực tiếp từ ứng dụng này'),
            content: Text('Bạn có muốn mở ứng dụng thay thê để thực hiện cuộc gọi không?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Không'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await launch('https://wa.me/$phoneNumber');
                },
                child: Text('Có'),
              ),
            ],
          );
        },
      );
    }
  }
}
