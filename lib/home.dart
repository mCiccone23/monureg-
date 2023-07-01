import 'package:monureg/page/AddPhoto.dart';
import 'package:flutter/material.dart';
import 'page/NearMonu.dart';
import 'page/NearEvent.dart';
import 'page/Report.dart';
import 'page/PhotoBook.dart';
import 'page/Setting.dart';

class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int currentTab = 0;
  void apriDartFile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPhoto()),
    );
  }

  final List<Widget> screens = [
    NearMonu(),
    NearEvent(),
    PhotoBook(),
    Setting(),
  ];

  final Map<Widget, int> screens_value = {
  NearMonu() : 0,
  NearEvent() : 1,
  PhotoBook() : 2,
  Setting() : 4,
  };

  final PageController bucket = PageController();
  Widget currentScreen = NearMonu();
  Widget lastScreen = NearMonu();

  @override
  void dispose() {
    bucket.dispose();
    super.dispose();
  }

  void onPageChanged(int index) {
    setState(() {
      currentTab = index;
      currentScreen = screens[index];
    });
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(currentScreen.toString()),
        centerTitle: false,
      ),
      body: PageView(
        controller: bucket,
        children: screens,
        onPageChanged: onPageChanged,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {apriDartFile(context);},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked ,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 10,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget> [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaterialButton(
                    key: ValueKey('NearMonu'),
                    minWidth: 40,
                    onPressed: () {
                      setState( () {
                        lastScreen = currentScreen;
                        currentScreen = NearMonu();
                        currentTab = 0;
                        bucket.jumpToPage(0);
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map,
                          color: currentTab == 0 ? Colors.blue : Colors.grey,
                        ),
                        Text(
                          'Monument',
                          style: TextStyle(color: currentTab == 0 ? Colors.blue : Colors.grey
                          ) ,
                        )
                      ],
                    ),
                  ),
                  MaterialButton(
                    key: ValueKey('NearEvent'),
                    minWidth: 40,
                    onPressed: () {
                      setState( () {
                        lastScreen = currentScreen;
                        currentScreen = NearEvent();
                        currentTab = 1;
                        bucket.jumpToPage(1);
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_available,
                          color: currentTab == 1 ? Colors.blue : Colors.grey,
                        ),
                        Text(
                          'Event',
                          style: TextStyle(color: currentTab == 1 ? Colors.blue : Colors.grey
                          ) ,
                        )
                      ],
                    ),
                  ),


                ],

              ),
              //Right Tab Bar Icons
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaterialButton(
                    key: ValueKey('PhotoBook'),
                    minWidth: 40,
                    onPressed: () {
                      setState( () {
                        lastScreen = currentScreen;
                        currentScreen = PhotoBook();
                        currentTab = 2;
                        bucket.jumpToPage(2);
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_box,
                          color: currentTab == 2 ? Colors.blue : Colors.grey,
                        ),
                        Text(
                          'PhotoBook',
                          style: TextStyle(color: currentTab == 2 ? Colors.blue : Colors.grey
                          ) ,
                        )
                      ],
                    ),
                  ),
                  MaterialButton(
                    key: ValueKey('Setting'),
                    minWidth: 40,
                    onPressed: () {
                      setState( () {
                        lastScreen = currentScreen;
                        currentScreen = Setting();
                        currentTab = 4;
                        bucket.jumpToPage(4);
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.report,
                          color: currentTab == 4 ? Colors.blue : Colors.grey,
                        ),
                        Text(
                          'Setting',
                          style: TextStyle(color: currentTab == 4 ? Colors.blue : Colors.grey
                          ) ,
                        )
                      ],
                    ),
                  ),


                ],

              ),
            ],
          ),
        ),
      ),
    );
  }
}