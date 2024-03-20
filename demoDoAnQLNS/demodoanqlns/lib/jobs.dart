import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Jobs extends StatefulWidget {
  final String idJobs;
  Jobs({required this.idJobs});

  @override
  _JobsState createState() => _JobsState();
}

class _JobsState extends State<Jobs> {
  late Future<List<Map<String, dynamic>>> _futureJobList;

  @override
  void initState() {
    super.initState();
    _futureJobList = fetchJobData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách công việc'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureJobList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Đã xảy ra lỗi'));
                } else {
                  List<Map<String, dynamic>> jobList = snapshot.data!;

                  int employeeJobCount = countEmployeeJobs(jobList, widget.idJobs);
                  if (employeeJobCount > 0) {
                    // Lấy tên công việc
                    String jobNames = getJobNames(jobList, widget.idJobs);

                    WidgetsBinding.instance!.addPostFrameCallback((_) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Thông báo'),
                          content: Text('Bạn có $employeeJobCount công việc: $jobNames'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Đóng'),
                            ),
                          ],
                        ),
                      );
                    });
                  }
                  return ListView.builder(
                    itemCount: jobList.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> job = jobList[index];
                      String formattedStartDate = formatDateString(job['startDate']);
                      String formattedEndDate = formatDateString(job['endDate']);
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text((index + 1).toString()),
                        ),
                        title: Text(
                          '${job['jobName']}',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mã công việc: ${job['_id']}'),
                            Text('Ngày giao: $formattedStartDate'),
                            Text('Ngày kết thúc: $formattedEndDate'),
                            Text('Nhân viên: ${job['employeeID']}'),
                            Text('Ghi chú: ${job['note']}'),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  //hiển thị danh sách công việc
  Future<List<Map<String, dynamic>>> fetchJobData() async {
    final response = await http.get(Uri.parse('http://192.168.16.1:3000/api/jobslist'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<Map<String, dynamic>> jobList = data.map((item) => item as Map<String, dynamic>).toList();
      return jobList;
    } else {
      throw Exception('Failed to load job data');
    }
  }
  //đếm số công việc mà nhân viên có id đó được giao
  int countEmployeeJobs(List<Map<String, dynamic>> jobList, String employeeID) {
    int count = 0;
    for (var job in jobList) {
      if (job['employeeID'] == employeeID) {
        count++;
      }
    }
    return count;
  }
  //tên công việc mà nhân viên đang truy cập được giao
  String getJobNames(List<Map<String, dynamic>> jobList, String employeeID) {
    List<String> names = [];
    for (var job in jobList) {
      if (job['employeeID'] == employeeID) {
        names.add(job['jobName']);
      }
    }
    return names.join(', ');
  }
  //định dạng ngày hiển thị
  String formatDateString(String dateString) {
    var parsedDate = DateFormat('yyyy-MM-ddTHH:mm:ss.sssZ').parse(dateString);
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  }
}
