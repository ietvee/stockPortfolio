import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show jsonDecode;
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stock_portfolio/pages/details.dart';
import 'package:stock_portfolio/pages/favorite.dart';

List<List<dynamic>> data = [];
List<List<dynamic>> dataSlice = [];
List<bool> boolList = List<bool>.filled(data.length, false);
String? keyword;

// fetch all companies
class ApiFetch {
  final url = "https://www.alphavantage.co/query?function=LISTING_STATUS&state=active&apikey=E220DH8RAYLY4R91";
  Future getData() async {
    String fileName = "cacheData.json";
    var dir = await getTemporaryDirectory();
    File file = File(dir.path + "/" + fileName);

    if(file.existsSync()) {
      print("Reading from device cache");

      // read from cache
      final datas = file.readAsStringSync();
      List<List<dynamic>> csvTable = CsvToListConverter().convert(datas);
      data = csvTable;
      dataSlice = data.sublist(1,10);
      return dataSlice;
    } else {
      print("Fetching from network");

      // read from network
      final req = await http.get(Uri.parse(url));
      if (req.statusCode == 200) {
        final body = req.body;
        // save to json cache
        file.writeAsStringSync(body, flush: true, mode: FileMode.write);
        List<List<dynamic>> csvTable = CsvToListConverter().convert(body);
        data = csvTable;
        dataSlice = data.sublist(1,10);
        return dataSlice;
      } else {
        return jsonDecode(req.body);
      }
    }
  }
}

// fetch search best matches
class ApiFetchSearch {
  final url = 'https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=$keyword&apikey=E220DH8RAYLY4R91';
  Future getData() async {
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

class Portfolio extends StatefulWidget {
  Portfolio({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _PortfolioState createState() => _PortfolioState();
}

class _PortfolioState extends State<Portfolio> {
  late Future _apiFetch;
  ScrollController _scrollController = ScrollController();
  int _currentMax = 10;

  @override
  void initState() {
    super.initState();
    // _restorePersistedPreference();
    _apiFetch = ApiFetch().getData();
    _scrollController.addListener(() {
    if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
      _getMoreData();
    }
    });
  }

  // pagination
  _getMoreData(){
    for(int i = _currentMax; i < _currentMax + 10; i++){
      dataSlice.add(data[_currentMax + i]);
    }
    _currentMax = _currentMax + 10;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:  Colors.grey,
        shadowColor: Colors.white,
        elevation: 0,
        title: Center(child: Text(widget.title, style: TextStyle(color: Colors.black),) ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.bookmark),
              onPressed: () => pushToFavoriteWordsRoute(context, data),
            ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15),
            child: TextField(
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                ),
                suffixIcon: InkWell(
                  child: Icon(Icons.search),
                ),
                contentPadding: EdgeInsets.all(15.0),
                hintText: 'Search a company',
              ),
              onChanged: (string) {
                setState(() {
                  keyword = string;
                });
              },
            ),
          ),
    keyword == null
    ?  Expanded(
            child:
              FutureBuilder(
              future: _apiFetch,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data.length == 0) {
                    return Center(child: Text('Oops, there is no data ...'));
                  } else {
                    return
                      ListView.builder(
                        scrollDirection: Axis.vertical,
                        controller: _scrollController,
                        itemExtent: 100,
                        itemCount: snapshot.data.length + 1,
                        itemBuilder: (context, index) {
                          if (index == snapshot.data.length) {
                            return Center(
                              child: Column(
                                children: [
                                  const CircularProgressIndicator(),
                                ],
                              ),
                            );
                          }
                          final data = snapshot.data;
                          return
                            ListTile(
                              title: data[index][1] == '' ? Text("ERROR while loading the name ...",style: TextStyle(color: Colors.red)) : Text(data[index][1].toString()),
                              trailing:  IconButton(
                                  icon: Icon(
                                    boolList[index] ? Icons.favorite : Icons.favorite_border,
                                    color: boolList[index] ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () {
                                    boolList[index] = !boolList[index];
                                    setState(() => {});
                                  }
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Details(
                                      title: data[index][1].toString(),
                                      inputKey: data[index][0].toString(),
                                    ),
                                  ),
                                );
                              },
                            );
                        },
                      );
                  }
                }
                else if (snapshot.connectionState == ConnectionState.none) {
                  return Text('Error');
                } else {
                  return Column(
                    children: [
                      Center(child: CircularProgressIndicator()),
                    ],
                  ); // loading
                }
              },
            )
          ) :
           Expanded(
                child: FutureBuilder(
                  future: ApiFetchSearch().getData(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.data.length == 0) {
                        return Center(child: Text('Oops, there is no data ...'));
                      } else {
                        return  ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data['bestMatches'].length,
                          itemBuilder: (context, index) {
                            final data = snapshot.data['bestMatches'];
                            return snapshot.data.length == null ? SizedBox()  :
                            ListTile(
                              title: Text(data[index]['1. symbol'].toString()),
                              trailing: Icon(Icons.keyboard_arrow_right_sharp),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Details(
                                        title:
                                        data[index]['2. name'].toString(),
                                        inputKey:
                                        data[index]['1. symbol'].toString(),
                                      ),
                                    ));
                              },
                            );
                          },
                        );
                      }
                    }
                    else if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        children: [
                          Center(child: CircularProgressIndicator()),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          Center(child: CircularProgressIndicator()),
                        ],
                      ); // loading
                    }
                  },
                ),
            ),
        ],
      ),
    );
  }

  Future pushToFavoriteWordsRoute(BuildContext context,  index) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => FavoriteWordsRoute(
          favoriteItems: data,
        ),
      ),
    );
  }

}
