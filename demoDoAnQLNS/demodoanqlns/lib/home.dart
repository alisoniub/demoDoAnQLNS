import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'income.dart';
import 'info.dart';
import 'jobs.dart';
import 'main.dart';
import 'personneldirectory.dart';
import 'attendance.dart';
import 'account.dart';

class Home extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String employeeID;
  final String employeeImage;

  const Home({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.employeeID,
    required this.employeeImage,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? _avatarUrl;
  late Timer _timer;
  late String _currentDateTime = '';

  @override
  void initState() {
    super.initState();
    _fetchEmployeeAvatar();
    _updateDateTime();
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      _updateDateTime();
    });
  }
  //hiển thị avt từ csdl
  Future<void> _fetchEmployeeAvatar() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.16.1:3000/api/employee/${widget.employeeID}'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _avatarUrl = 'assets/${data?['avt']?['imageName'] ?? 'avtnv009.jpg'}';
        });
      } else {
        throw Exception('Failed to load employee data');
      }
    } catch (e) {
      print('Error fetching employee avatar: $e');
    }
  }
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateDateTime() {
    setState(() {
      _currentDateTime = DateFormat('EEEE, dd/MM/yyyy - HH:mm').format(DateTime.now());
    });
  }

  void _openInforPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Infor(idInfo: widget.employeeID),
      ),
    );
  }

  void _openDirectoryPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Directory(idDirec: widget.employeeID),
      ),
    );
  }

  void _openJobsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Jobs(idJobs: widget.employeeID),
      ),
    );
  }

  void _openIncomePage() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Income(idInc: widget.employeeID),
      ),
    );
  }

  void _openAttendancePage() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendancePage(idAtten: widget.employeeID),
      ),
    );
  }

  void _openAccountPage() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountPage(employeeID: widget.employeeID),
      ),
    );
  }

  void _performSearch() {
    //Thực hiện các hành động tìm kiếm ở đây
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Đặt màu nền cho appBar là màu xanh blue
        elevation: 0, // Loại bỏ đổ bóng của appBar
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Xin chào, ${widget.firstName}',
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  _currentDateTime,
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/background_main.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                padding: EdgeInsets.zero,
                child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logo_app.jpg',
                        width: double.infinity,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${widget.firstName} ${widget.lastName}',
                        style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Hồ sơ'),
                onTap: _openInforPage,
              ),
              ListTile(
                leading: Icon(Icons.notifications),
                title: Text('Thông báo'),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.assignment),
                title: Text('Đăng kí'),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Cài đặt'),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.feedback),
                title: Text('Góp ý'),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text('Thông tin'),
                onTap: () {},
              ),
              ListTile(
                tileColor: Colors.red[100], // Màu đỏ nhạt cho nền
                leading: Icon(
                  Icons.logout,
                  color: Colors.red, // Màu đỏ cho biểu tượng
                ),
                title: Text(
                  'Đăng xuất',
                  style: TextStyle(
                    color: Colors.red, // Màu đỏ cho chữ
                    fontWeight: FontWeight.bold, // Chữ đậm
                  ),
                ),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
                  );
                },
              ),

            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/background_main.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    padding: EdgeInsets.all(10),
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 0,
                    children: [
                      buildImageButton('assets/ic_info.jpg', 'Hồ sơ', _openInforPage),
                      buildImageButton('assets/ic_danhba.jpg', 'Danh bạ', _openDirectoryPage),
                      buildImageButton('assets/ic_luong.jpg', 'Thu nhập ', _openIncomePage),
                      buildImageButton('assets/ic_dkngaynghi.jpg', 'Đăng ký', () {}),
                      buildImageButton('assets/ic_kpi.jpg', 'Công việc', _openJobsPage),
                      buildImageButton('assets/ic_khaosat.jpg', 'Chấm công', _openAttendancePage),
                      buildImageButton('assets/ic_them.png', '...', () {}),
                      buildImageButton('assets/ic_setting.jpg', 'Cài đặt',  _openAccountPage),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _performSearch(); // Gọi hàm thực hiện chức năng tìm kiếm
        },
        // backgroundColor: Colors.blue,
        child: Icon(Icons.search),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SizedBox(
        height: 30, //
      ),
    );
  }

  Widget buildImageButton(String imagePath, String text, void Function() onPressed) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Column(
        children: [
          ClipOval(
            child: Container(
              width: 80,
              height: 80,
              color: Colors.white,
              child: InkWell(
                onTap: onPressed,
                splashColor: Colors.transparent,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
