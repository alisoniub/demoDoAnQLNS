import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Lab05_DatHang'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<TextEditingController> _controllers = <TextEditingController>[];
  List<MatHang> _listMatHang = <MatHang>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.yellow,
              child: Center(
                child: Text(
                  "ĐẶT HÀNG",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                child: FutureBuilder(
                  future: fetchEmployeeData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Failed to load data'));
                    } else {
                      var employees = snapshot.data;
                      return ListView.builder(
                        itemCount: employees?.length,
                        itemBuilder: (BuildContext context, int index) {
                          _controllers.add(new TextEditingController());
                          _listMatHang.add(new MatHang(
                              "${employees?[index]['lastName']} ${employees?[index]['firstName']}",
                              Random().nextInt(10000),
                              0));
                          _controllers[index].text = _listMatHang[index].soLuong.toString();
                          return Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black)),
                            child: Row(
                              children: [
                                Container(
                                  width: 250,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            _listMatHang[index].tenMonHang,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "Đơn giá: " +
                                                _listMatHang[index]
                                                    .donGia
                                                    .toString(),
                                            style: TextStyle(
                                                color: Colors
                                                    .orangeAccent.shade400),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        width: 50,
                                        child: TextField(
                                            controller: _controllers[index],
                                            onChanged: (value) {
                                              _listMatHang[index].soLuong = int.parse(value);
                                            }),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text("Warning"),
              content: Text("Xác nhận đơn hàng?"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, 'Hủy'),
                    child: Text('Hủy')),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DonHangPage(
                                listMatHang: _listMatHang,
                              )));
                    },
                    child: Text("OK"))
              ],
            ),
          );
        },
        child: Icon(
          Icons.navigation,
        ),
      ),
    );
  }

  Future<List<dynamic>> fetchEmployeeData() async {
    final response = await http.get(Uri.parse('http://192.168.16.1:3000/api/employee')); // Thay đổi đường dẫn endpoint tương ứng
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load employee data');
    }
  }
}

class DonHangPage extends StatelessWidget {
  DonHangPage({Key? key, required this.listMatHang}) : super(key: key);
  final List<MatHang> listMatHang;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lab05_DatHang"),
      ),
      body: ListView.builder(
        itemCount: listMatHang.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            decoration: BoxDecoration(border: Border.all()),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(listMatHang[index].toString()),
            ),
          );
        },
      ),
    );
  }
}

class MatHang {
  String tenMonHang;
  int donGia;
  int soLuong;

  MatHang(this.tenMonHang, this.donGia, this.soLuong);

  String toString() {
    return "Tên hàng: " +
        tenMonHang +
        "\n" +
        "Đơn giá: " +
        donGia.toString() +
        "\n" +
        "Số lượng: " +
        soLuong.toString() +
        "\n" +
        "Thành tiền";
  }
}
