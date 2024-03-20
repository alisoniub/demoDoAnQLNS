import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailSalaryPage extends StatefulWidget {
  final Map<String, dynamic> salaryData;
  //truyền thông tin id nhân viên
  const DetailSalaryPage({Key? key, required this.salaryData}) : super(key: key);

  @override
  _DetailSalaryPageState createState() => _DetailSalaryPageState();
}

class _DetailSalaryPageState extends State<DetailSalaryPage> {
  //format hiển thị ngày
  String formatDateString(String dateString) {
    var parsedDate = DateTime.parse(dateString);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thu nhập'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Thu nhập',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Ngày xuất:',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  formatDateString(widget.salaryData['paymentDate'] ?? '--'),
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Mã lương:',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  widget.salaryData['_id'] ?? '--',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Mã nhân viên:',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  widget.salaryData['employeeID'] ?? '--',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Table(
              border: TableBorder.all(),
              children: [
                TableRow(
                  children: [
                    TableCell(child: Text('Lương Cơ Bản')),
                    TableCell(child: Text('Phụ Cấp')),
                    TableCell(child: Text('Khấu Trừ')),
                    TableCell(child: Text('Thực Nhận')),
                    TableCell(child: Text('Ngày TT')),
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(child: Text(widget.salaryData['basicSalary'].toString() ?? '0')),
                    TableCell(child: Text(widget.salaryData['allowances'].toString() ?? '0')),
                    TableCell(child: Text(widget.salaryData['deductions'].toString() ?? '0')),
                    TableCell(child: Text(widget.salaryData['netSalary'].toString() ?? '0')),
                    TableCell(child: Text(formatDateString(widget.salaryData['paymentDate'] ?? '0'))),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
