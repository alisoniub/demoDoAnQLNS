import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AttendancePage extends StatefulWidget {
  final String idAtten;

  const AttendancePage({Key? key, required this.idAtten}) : super(key: key);

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late String _currentDate = '';
  late List<DateTime> _markedAttendance = []; // anh sách thời gian đã chấm công
  late DateTime _selectedDay = DateTime.now();
  int _attendanceCount = 0; // Số lần chấm công

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chấm công'),
        backgroundColor: Colors.blue, //đặt màu nền cho appBar là màu xanh blue
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TableCalendar(
            focusedDay: _selectedDay,
            firstDay: DateTime.utc(2000),
            lastDay: DateTime.utc(2030),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
              _fetchAttendanceCount(selectedDay);
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _markAttendance();
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  return Colors.green; // Màu xanh lá cho nút chấm công
                },
              ),
            ),
            child: Text('Chấm công'),
          ),
          SizedBox(height: 20),
          Text(
            'Số lần chấm công: $_attendanceCount',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _markedAttendance.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    'Đã chấm công lúc: ${DateFormat('HH:mm:ss').format(_markedAttendance[index]).toString().split(' ')[0]} ngày ${_markedAttendance[index].toString().split(' ')[0]}',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _fetchAttendanceCount(_selectedDay);
  }

  void _updateDateTime() {
    setState(() {
      _currentDate = DateTime.now().toString().split(' ')[0];
    });
  }

  Future<void> _fetchAttendanceCount(DateTime selectedDay) async {
    final response = await http.get(
      Uri.parse('http://192.168.16.1:3000/api/attendance/count/${widget.idAtten}?currentDate=${selectedDay.toString().split(' ')[0]}'),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        _markedAttendance = List.generate(data['count'], (index) => selectedDay);
        _attendanceCount = data['count']; //cập nhật số lần chấm công
      });
    } else {
      throw Exception('Failed to fetch attendance count');
    }
  }

  Future<void> _markAttendance() async {
    try {
      //gọi API để kiểm tra số lần chấm công trong ngày hiện tại của nhân viên
      final response = await http.get(
        Uri.parse('http://192.168.16.1:3000/api/attendance/count/${widget.idAtten}?currentDate=${_selectedDay.toString().split(' ')[0]}'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        int count = data['count'];

        // Kiểm tra nếu số lần chấm công vượt quá 4
        if (count >= 4) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã đạt số lần chấm công tối đa')),
          );
          return;
        }
      } else {
        throw Exception('Failed to fetch attendance count');
      }

      // Chỉ có thể chấm công vào ngày hiện tại, không cho phép chấm công sớm hơn.
      if (!isSameDay(_selectedDay, DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bạn chỉ có thể chấm công vào ngày hiện tại')),
        );
        return;
      }

      //thêm ngày chấm công vào CSDL
      final responseAdd = await http.post(
        Uri.parse('http://192.168.16.1:3000/api/attendance/add'),
        body: {
          'employeeID': widget.idAtten,
          'status': '1',
        },
      );
      if (responseAdd.statusCode == 201) {
        setState(() {
          _markedAttendance.add(DateTime.now());
          _attendanceCount++; // Tăng số lần chấm công
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chấm công thành công')),
        );
      } else {
        throw Exception('Đã xảy ra lỗi khi chấm công');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi: $error')),
      );
    }
  }

}