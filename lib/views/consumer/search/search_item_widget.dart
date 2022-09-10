import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:events/views/organizer/event_information/eventDetails.dart';
import 'package:events/globals.dart' as globals;
import 'package:get/get.dart';
import 'package:events/domains/event.dart';

class SearchItemWidget extends StatelessWidget {
  final Event event;

  SearchItemWidget({Key? key, required this.event}) : super(key: key);

  navigateToEventDetailsPage(BuildContext context, Event event) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EventDetails(
                  event: event,
                )));
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () => navigateToEventDetailsPage(context, event),
      child: Container(
          height: Get.height * 0.337,
          width: Get.width * 0.466,
          decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage((event.urls.length != 0)
                      ? event.urls[0]
                      : 'https://i.pinimg.com/originals/85/6f/31/856f31d9f475501c7552c97dbe727319.jpg'))),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              width: Get.width * 0.466,
              height: Get.height * 0.06,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: <Color>[Colors.black45, Colors.transparent])),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(
                    event.title,
                    style: TextStyle(
                        fontFamily: globals.montserrat,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          )),
    );
  }
}