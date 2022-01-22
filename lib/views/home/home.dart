import 'package:events/navigator.dart';
import 'package:events/views/home/for_you_widget.dart';
import 'package:events/views/home/featured_widget.dart';
import 'package:events/views/home/near_you/near_you_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../controllers/consumer/home_controller.dart';
import '../../globals.dart' as globals;
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    RefreshController _refreshController =
        RefreshController(initialRefresh: false);

    return Obx(() => (controller.currentPosition.value.longitude != null && controller.currentPosition.value.latitude != null && controller.loading.value)
        ? Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
                controller: _refreshController,
                onRefresh: () async {
                  // monitor network fetch
                  await Future.delayed(Duration(milliseconds: 1000));
                  controller.items.value = 4;
                  // if failed,use refreshFailed()
                  _refreshController.refreshCompleted();

                  Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                          pageBuilder: (a, b, c) => NavigatorPage(),
                          transitionDuration: Duration(seconds: 0)));
                },
                onLoading: () async {
                  // monitor network fetch
                  await Future.delayed(Duration(milliseconds: 1000));
                  // if failed,use loadFailed(),if no data return,use LoadNoData()
                  controller.items.value = controller.items.value + 3;
                  _refreshController.loadComplete();
                },
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    FeaturedWidget(),
                    NearYouWidget(),
                    ForYouWidget()],
                ),
              ),
            ),
          )
        : globals.spinner);
  }
}
