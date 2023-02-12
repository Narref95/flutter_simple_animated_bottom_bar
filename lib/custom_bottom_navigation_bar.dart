import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

List<Widget> screens = [
  Container(color: Colors.orange, child: const Center(child: Text('Screen 1'))),
  Container(color: Colors.green, child: const Center(child: Text('Screen 2'))),
  Container(color: Colors.yellow, child: const Center(child: Text('Screen 3'))),
  Container(color: Colors.blue, child: const Center(child: Text('Screen 4'))),
];

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  CustomBottomNavigationBarState createState() =>
      CustomBottomNavigationBarState();
}

class CustomBottomNavigationBarState extends State<CustomBottomNavigationBar>
    with TickerProviderStateMixin {
  late List<AnimationController> iconControllers = [];
  late List<Animation<double>> iconAnimations = [];

  int currentIndex = 0;

  int beginningIconDuration = 1000;
  int reverseIconDuration = 200;

  double expandedIconSize = 50;
  double normalIconSize = 30;

  Curve forwardingCurve = Curves.elasticOut;
  Curve reversingCurve = Curves.easeIn;

  List<String> listOfIcons = [
    'assets/svg/phone.svg', 'assets/svg/android.svg', 'assets/svg/beer.svg', 'assets/svg/calculator.svg'
  ];

  int pageIndex = 0;
  late PageController pageController;

  void onPageChanged(int page) {
    debugPrint('Page changed to $page');
    setState(() {
      currentIndex = page;
      onTabTapped(page, false);
    });
  }

  void onTabTapped(int index, bool animatePage) {
    if (animatePage) {
      pageController.animateToPage(index,
          duration: const Duration(milliseconds: 1250),
          curve: Curves.fastLinearToSlowEaseIn);
    }
    for (var i = 0; i < iconControllers.length; i++) {
      if (i == index) {
        iconControllers[i].forward();
      } else {
        iconControllers[i].reverse();
      }
    }
    HapticFeedback.lightImpact();
  }

  @override
  void initState() {
    pageController = PageController(initialPage: pageIndex);

    for (var i = 0; i < listOfIcons.length;i++) {
      iconControllers.add(
          AnimationController(
              vsync: this,
              duration: Duration(milliseconds: beginningIconDuration),
              reverseDuration: Duration(milliseconds: reverseIconDuration))
      );
      iconAnimations.add(Tween<double>(begin: normalIconSize, end: expandedIconSize).animate(
        CurvedAnimation(
            parent: iconControllers[i],
            curve: forwardingCurve,
            reverseCurve: reversingCurve),
      )..addListener(() {
        setState(() {});
      }));
    }

    iconControllers[0].forward();

    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    for (var element in iconControllers) {
      element.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        PageView(
          onPageChanged: onPageChanged,
          pageSnapping: true,
          controller: pageController,
          children: screens,
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Container(
                height: 60,
                decoration: const BoxDecoration(
                    color: Colors.black54
                ),
              ),
              Container(
                height: 60,
                width: screenWidth * .25,
                margin: EdgeInsets.only(left: pageController.hasClients ? pageController.position!.pixels / 4 : 0),
                decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                ),
              ),
              Container(
                height: 75,
                color: Colors.transparent,
                alignment: Alignment.topCenter,
                child: ListView.builder(
                  itemCount: 4,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => InkWell(
                    onTap: () {
                      currentIndex = index;
                      onTabTapped(index, true);
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: AnimatedPadding(
                      padding: EdgeInsets.only(
                          top: index == currentIndex ? 0 : 30),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.fastLinearToSlowEaseIn,
                      child: Container(
                        width: screenWidth * .25,
                        alignment: Alignment.topCenter,
                        child: SvgPicture.asset(
                          listOfIcons[index],
                          width: iconAnimations[index].value,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}