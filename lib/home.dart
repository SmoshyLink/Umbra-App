import 'package:awesome_loader/awesome_loader.dart';
import 'package:events/navigator.dart';
import 'package:events/nearyouItem.dart';
import 'package:events/searchResultItem.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:getwidget/getwidget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'globals.dart' as globals;
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:events/libOrg/eventDetails.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _current = 0;

  List<Container> containers = [
    Container(
      color: Colors.blue,
    ),
    Container(
      color: Colors.green,
    ),
    Container(
      color: Colors.red,
    ),
    Container(
      color: Colors.white,
    )
  ];

  double imageSize = 0;

  final geo = Geoflutterfire();

  Position _currentPosition = null;

  _getCurrentLocation() {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      print(e);
    });
  }

  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  navigateToEventDetailsPage(QueryDocumentSnapshot data) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EventDetails(
                  data: data,
                )));
  }

  List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  String dateConverter(Timestamp eventDate, String time) {
    DateTime converted = eventDate.toDate();
    return months[converted.month] +
        " " +
        converted.day.toString() +
        ", " +
        converted.year.toString() +
        "  |  " +
        time;
  }

  List<SearchResultItem> foryouItems = [];
  FirebaseFirestore fb = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot>> getForyouEvents() async {
    List<QueryDocumentSnapshot> events = [];

    await fb.collection("events").get().then((value) {
      value.docs.forEach((event) {
        events.add(event);
      });
    });

    return events;
  }

  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  Future<Null> _onRefresh() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(pageBuilder: (a, b, c) => NavigatorPage(), transitionDuration: Duration(seconds: 0))
    );
  }

  void _onLoading() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    //setState(() {});
    print("ima gay");
    _refreshController.loadComplete();
  }



  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double featureCarouselHeight = height * 0.5;
    double foryouCarouselHeight = height * 0.4;
    double nearyouCarouselHeight = height * 0.3;
    double infoHeight = height * 0.25;

    return _currentPosition != null
        ? Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Container(
                child: SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: true,
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  child: ListView(
                    children: [
                      // Featured carousel
                      FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("events")
                            .where('featured', isEqualTo: true)
                            .limit(5)
                            .get(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: AwesomeLoader(
                                loaderType: AwesomeLoader.AwesomeLoader2,
                                color: Colors.white,
                              ),
                            );
                          }

                          List<Container> featuredEvents = [];

                          snapshot.data.docs.forEach((var doc){
                            featuredEvents.add(Container(
                              key: Key(doc['title'] + doc.id),
                              margin: EdgeInsets.all(5.0),
                              child: GestureDetector(
                                onTap: () {
                                  navigateToEventDetailsPage(doc);
                                },
                                child: ClipRRect(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                                  child: Stack(children: [
                                    Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white10,
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                  !doc["urls"].isEmpty
                                                      ? doc["urls"][0]
                                                      : 'https://i.pinimg.com/originals/85/6f/31/856f31d9f475501c7552c97dbe727319.jpg',
                                                ),
                                                fit: BoxFit.cover)),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Container(
                                            padding: EdgeInsets.all(20),
                                            width: width,
                                            height:
                                            featureCarouselHeight * 0.33,
                                            decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                    begin:
                                                    Alignment.topCenter,
                                                    end: Alignment
                                                        .bottomCenter,
                                                    colors: <Color>[
                                                      Colors.black87,
                                                      Colors.transparent
                                                    ])),
                                            child: RichText(
                                              textAlign: TextAlign.start,
                                              text: TextSpan(children: <
                                                  TextSpan>[
                                                TextSpan(
                                                  text: doc["title"],
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily:
                                                      globals.montserrat,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontSize: 30),
                                                ),
                                                TextSpan(
                                                    text: '\n' +
                                                        dateConverter(
                                                            doc["date"],
                                                            doc["time"]),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontFamily: globals
                                                            .montserrat,
                                                        fontWeight: globals.fontWeight,
                                                        fontSize: 15)),
                                                TextSpan(
                                                    text: '\n' +
                                                        doc["locationName"]
                                                            .split(",")[0],
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontFamily: globals
                                                            .montserrat,
                                                        fontWeight: globals.fontWeight,
                                                        fontSize: 15))
                                              ]),
                                            ),
                                          ),
                                        )),
                                  ]),
                                ),
                              ),
                            ));
                          });

                          return Container(
                            height: foryouCarouselHeight,
                            child: CarouselSlider(
                              items: featuredEvents,

                              options: CarouselOptions(
                                autoPlay: true,
                                initialPage: 0,
                                enableInfiniteScroll: true,
                                viewportFraction: 1,
                                height: foryouCarouselHeight,
                                enlargeCenterPage: true,
                                pauseAutoPlayOnTouch: true,

                              ),
                            ),
                          );
                        },
                      ),
                      // Near you text
                      Container(
                        margin: EdgeInsets.only(top: 5, left: 10, bottom: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Near You",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontFamily: globals.montserrat,
                                //fontWeight: globals.fontWeight,
                                fontSize: 25,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      // Near You carousel
                      StreamBuilder(
                          stream: geo
                              .collection(
                              collectionRef: FirebaseFirestore.instance
                                  .collection('events'))
                              .within(
                              center: geo.point(
                                  latitude: _currentPosition.latitude,
                                  longitude: _currentPosition.longitude),
                              radius: 10,
                              field: "location"),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.data == null) {
                              return Text(
                                "No events near you",
                                style: TextStyle(color: Colors.white),
                              );
                            } else {
                              List<NearyouItem> ads = [];
                              var j;
                              if (snapshot.data.length > 5) {
                                j = 5;
                              } else {
                                j = snapshot.data.length;
                              }
                              for (var i = 0; i < j; i++) {
                                ads.add(NearyouItem(data: snapshot.data[i]));
                              }
                              return Container(
                                child: GFCarousel(
                                  height: nearyouCarouselHeight,
                                  enableInfiniteScroll: true,
                                  viewportFraction: 0.8,
                                  activeIndicator: Colors.white,
                                  items: ads.map(
                                        (con) {
                                      return Container(child: con);
                                    },
                                  ).toList(),
                                  onPageChanged: (index) {},
                                ),
                              );
                            }
                          }),
                      // For you text
                      Container(
                        margin: EdgeInsets.only(top: 10, left: 10, bottom: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "For You",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontFamily: globals.montserrat,
                                //fontWeight: globals.fontWeight,
                                fontSize: 25,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      // For You carousel
                      FutureBuilder(
                        future: getForyouEvents(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: AwesomeLoader(
                                loaderType: AwesomeLoader.AwesomeLoader2,
                                color: Colors.white,
                              ),
                            );
                          }

                          if (snapshot.data != null &&
                              snapshot.data.length != 0) {
                            snapshot.data.forEach((event) {
                              foryouItems.add(SearchResultItem(
                                data: event,
                                key: Key(event['title'] + event.id),
                              ));
                            });

                            print(foryouItems.length);

                            return Container(
                              height: height,
                              child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: foryouItems.length,
                                itemBuilder: (context, index) {
                                  return foryouItems[index];
                                },
                              ),
                            );
                          } else
                            return Container();
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        : globals.spinner;
  }
}
