import 'package:disco_app/views/cert_page.dart';
import 'package:flutter/material.dart';

import 'package:disco_app/dependency_provider.dart';
import 'package:disco_app/views/server_page.dart';
import 'package:disco_app/views/client_page.dart';
import 'package:disco_app/views/key_page.dart';
import 'package:disco_app/views/db_page.dart';

main(List<String> args) {
  runApp(DependencyProvider(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _currentIndex = 0;
  var _appBarTitle = 'KeyGen';
  final _pages = [KeyPage(), ServerPage(), CertPage()];
  final _titles = ['KeyGen', 'Server', 'Certificate'];

  BottomNavigationBarItem _navBarItem(IconData icon, String title) {
    return BottomNavigationBarItem(
        icon: Icon(
          icon,
          size: 30,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.button,
        ));
  }

  void _onTabTapped(int index) {
    pageController.jumpToPage(index);
    setState(() {
      _appBarTitle = _titles[index];
    });
  }

  final pageController = PageController();
  void onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disco',
      routes: <String, WidgetBuilder>{
        '/db': (context) => DbPage(),
      },
      theme: ThemeData(
          primarySwatch: Colors.blue, canvasColor: Colors.transparent),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => DbPage()));
          },
          child: Icon(Icons.add),
        ),
        appBar: AppBar(
          title: Text(_appBarTitle),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          showUnselectedLabels: true,
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: [
            _navBarItem(Icons.vpn_key, 'Key'),
            _navBarItem(Icons.network_check, 'Server'),
            _navBarItem(Icons.account_box, 'Cert'),
          ],
        ),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          children: _pages,
          controller: pageController,
          onPageChanged: onPageChanged,
        ),
      ),
    );
  }
}
