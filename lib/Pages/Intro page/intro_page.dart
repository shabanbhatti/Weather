import 'package:flutter/material.dart';
import 'package:weather_project/utils/all_weathers_img_paths.dart';
import 'package:weather_project/Pages/Home%20page/home_page.dart';
import 'package:weather_project/utils/constant_images.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});
  static const pageName = '/';

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> with TickerProviderStateMixin {
  late AnimationController controller;
  late AnimationController rotateAndScaleController;
  late Animation<double> opacity;

  late Animation<double> scale;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });

    rotateAndScaleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: rotateAndScaleController,
        curve: Curves.easeInOutBack,
      ),
    );

    opacity = Tween<double>(begin: 0.3, end: 1.0).animate(controller);

    Future.delayed(const Duration(milliseconds: 50), () {
      rotateAndScaleController.forward();
    });

    controller.forward();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(Home.pageName);
      }
    });
  }

  @override
  void dispose() {
    controller.stop();
    controller.dispose();
    rotateAndScaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Intro page BUILD CALLED');
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(clear_day), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: scale,
                      child: Image.asset(
                        weatherIcon,
                        height: 180,
                        fit: BoxFit.fitHeight,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: FadeTransition(
                        opacity: opacity,
                        child: const Text(
                          'Weather',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
