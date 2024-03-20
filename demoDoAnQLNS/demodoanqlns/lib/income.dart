  import 'package:excel/excel.dart';
  import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;
  import 'dart:convert';
  import 'dart:io';
  import 'package:intl/intl.dart';
  import 'package:path_provider/path_provider.dart';
  import 'dart:math';
  import 'detail_salary.dart';

  class Income extends StatefulWidget {
    final String idInc;
    const Income({Key? key, required this.idInc}) : super(key: key);

    @override
    _IncomeState createState() => _IncomeState();
  }

  class _IncomeState extends State<Income> {
    late Map<String, dynamic> salaryData;
    late List<Map<String, dynamic>> salaryDataList = [];
    bool isLoading = true;
    @override
    void initState() {
      super.initState();
      fetchSalaryData();
    }
    //chuyển hướng từ trang income sang detailSalary với dữ liệu lương chuyển qua
    void navigateToDetailSalaryPage(Map<String, dynamic> salaryData) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailSalaryPage(salaryData: salaryData),
        ),
      );
    }
    //lấy thông tin bảng lương từ csdl
    Future<void> fetchSalaryData() async {
      final url = Uri.parse('http://192.168.16.1:3000/api/salary/${widget.idInc}');
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          isLoading = false;
          setState(() {
            //nv001 có quyền xem tất cả bảng lương
            if (widget.idInc == 'nv001') {
              // Nếu là 'nv001', tức là admin, hiển thị danh sách bảng lương của tất cả nhân viên
              salaryDataList = List<Map<String, dynamic>>.from(jsonDecode(response.body));
            } else {
              // Ngược lại, chỉ hiển thị danh sách bảng lương của nhân viên đó
              salaryDataList.add(jsonDecode(response.body));
            }
          });
        } else {
          throw Exception('Failed to load salary data');
        }
      } catch (error) {
        print('Error fetching salary data: $error');
      }
    }
    //format hiển thị ngày
    String formatDateString(String dateString) {
      var parsedDate = DateTime.parse(dateString);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    }
    // định dạng số tiền tệ
    String formatCurrency(int number) {
      final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '');
      return formatter.format(number);
    }
    //xuất Excel
    Future<void> exportToExcel(List<Map<String, dynamic>> salaryDataList) async {
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      // thêm hàng tiêu đề
      sheet.appendRow([
        TextCellValue('Ngày xuất'),
        TextCellValue('Mã lương'),
        TextCellValue('Mã nhân viên'),
        TextCellValue('Lương Cơ Bản'),
        TextCellValue('Phụ Cấp'),
        TextCellValue('Khấu Trừ'),
        TextCellValue('Thực Nhận'),
        TextCellValue('Ngày TT'),
      ]);

      // thêm dữ liệu từ mỗi phần tử trong danh sách vào sheet
      for (final salaryData in salaryDataList) {
        sheet.appendRow([
          TextCellValue(salaryData['issueDate'].toString()),
          TextCellValue(salaryData['_id'].toString()),
          TextCellValue(salaryData['employeeID'].toString()),
          TextCellValue(salaryData['basicSalary'].toString()),
          TextCellValue(salaryData['allowances'].toString()),
          TextCellValue(salaryData['deductions'].toString()),
          TextCellValue(salaryData['netSalary'].toString()),
          TextCellValue(salaryData['paymentDate'].toString()),
        ]);
      }

      //tạo tên file ngẫu nhiên
      String generateRandomFileName(String prefix, String extension) {
        final random = Random();
        const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
        final randomString = List.generate(5, (index) => chars[random.nextInt(chars.length)]).join('');
        return '$prefix$randomString$extension';
      }
      final directory = Directory('D:/DataDoAn/excel'); // Thay đổi đường dẫn tới thư mục của bạn
      final filePath = directory.path + '/' + generateRandomFileName('bangluong', '.xlsx');
      final List<int> bytes = excel.encode()!;
      final excelFile = File(filePath);
      await excelFile.writeAsBytes(bytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File Excel đã được lưu tại: $filePath'),
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Thu nhập'),
          backgroundColor: Colors.blue,
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Danh sách bảng lương',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              Expanded(
                child: ListView.builder(
                  itemCount: salaryDataList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final salaryData = salaryDataList[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          'Mã nhân viên: ${salaryData['employeeID']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Lương Cơ Bản: ${formatCurrency(salaryData['basicSalary'])}'),
                            Text('Phụ Cấp: ${formatCurrency(salaryData['allowances'])}'),
                            Text('Khấu Trừ: ${formatCurrency(salaryData['deductions'])}'),
                            Text('Thực Nhận: ${formatCurrency(salaryData['netSalary'])}'),
                            Text('Ngày TT: ${formatDateString(salaryData['paymentDate'])}'),
                          ],
                        ),
                        onTap: () {
                          navigateToDetailSalaryPage(salaryData);
                        },
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  await exportToExcel(salaryDataList);
                },
                child: Text('Xuất ra Excel'),
              ),

            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.feedback_outlined),
        ),
      );
    }
  }
