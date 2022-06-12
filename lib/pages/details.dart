import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show jsonDecode;

String? inputKey;

class Details extends StatefulWidget {
  Details({Key? key, required this.title, required this.inputKey})
      : super(key: key);

  final String title;
  final String inputKey;

  @override
  _DetailsState createState() => _DetailsState(this.inputKey);
}

class ApiFetch {
  Future getData(inputKey) async {
    final url = "https://www.alphavantage.co/query?function=INCOME_STATEMENT&symbol=$inputKey&apikey=I5IJ9LLEO55YGFKS";
    final req = await http.get(Uri.parse(url));
    if (req.statusCode == 200) {
      final body = req.body;
      final res = jsonDecode(body);
      return res;
    } else {
      return jsonDecode(req.body);
    }
  }
}

class _DetailsState extends State<Details> {
  String inputKey;
  _DetailsState(this.inputKey);

  @override
  void initState() {
    setState(() {
      inputKey = inputKey;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body:  FutureBuilder(
        future: ApiFetch().getData(this.inputKey),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data.length == 0) {
              return Center(child: Text('Oops, there is no data ...'));
            } else {
                 return  ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data.length.clamp(0,1),
                        itemBuilder: (context, index) {
                          final data = snapshot.data;
                          return DataTable(
                            columns: [
                              DataColumn(
                                  label: Text('',
                                      style: TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text(
                                      data['annualReports'][0]['fiscalDateEnding']
                                          .substring(0, 4),
                                      style: TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text(
                                      data['annualReports'][1]['fiscalDateEnding']
                                          .substring(0, 4),
                                      style: TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.bold))),
                            ],
                            rows: [
                              DataRow(cells: [
                                DataCell(Text('Total Revenue')),
                                DataCell(Text(data['annualReports'][0]['totalRevenue'])),
                                DataCell(Text(data['annualReports'][1]['totalRevenue'])),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('Operating Expenses')),
                                DataCell(
                                    Text(data['annualReports'][0]['operatingIncome'])),
                                DataCell(
                                    Text(data['annualReports'][1]['operatingIncome'])),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('Gross Profit')),
                                DataCell(Text(data['annualReports'][0]['grossProfit'])),
                                DataCell(Text(data['annualReports'][1]['grossProfit'])),
                              ]),
                            ],
                          );
                        },
                      );
            }
          }
          else if (snapshot.connectionState == ConnectionState.none) {
            return Text('Error'); // error
          } else {
            return CircularProgressIndicator(); // loading
          }
        },
      ),
    );
  }
}
