import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_project/Pages/Home%20page/controllers/time_controller.dart';
import 'package:weather_project/Pages/Home%20page/widgets/home_sliver_appbar_widget.dart';
import 'package:weather_project/models/timezone_model.dart';
import 'package:weather_project/models/weather_API_model.dart';
import 'package:weather_project/utils/date_time_format_method.dart';
import 'package:weather_project/widgets/circular_percent_ind_widget.dart';

class HomeUiWidget extends ConsumerStatefulWidget {
  const HomeUiWidget({super.key, required this.weather, required this.time});
  final WeatherModel weather;
  final TimezoneModel time;

  @override
  ConsumerState<HomeUiWidget> createState() => _HomeUiWidgetState();
}

class _HomeUiWidgetState extends ConsumerState<HomeUiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> slide;
  late Animation<double> scale;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOutBack));
    scale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOutBack));
    Future.delayed(const Duration(milliseconds: 500), () {
      controller.forward();
    });
    Future.microtask(() {
      ref.read(timeProvider.notifier).runSec(widget.time);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('HOME UI BUILD CALLED');
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        MySliverAppBar(
          weather: widget.weather,
          dateFormat: dateFormat(widget.weather.list![0].dtTxt.toString()),
        ),

        humadityAndCloud(widget.weather, position: slide, scale: scale),

        visibilityAndWindSpeed(widget.weather, position: slide, scale: scale),

        rainChance(widget.weather, position: slide, scale: scale),

        todayDataOfWeather(),

        SliverPadding(
          padding: EdgeInsets.all(10),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: Text(
                '📍${widget.time.countryName.toString()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget todayDataOfWeather() {
    return SliverPadding(
      padding: EdgeInsets.all(10),
      sliver: SliverToBoxAdapter(
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(50),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'Today weather condition',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const Expanded(flex: 1, child: Divider(thickness: 2)),

              Expanded(
                flex: 10,
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,

                  shrinkWrap: true,
                  itemCount: min(8, widget.weather.list!.length),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    var weatherList = widget.weather.list![index];
                    return Padding(
                      padding: EdgeInsets.all(5),
                      child: Card(
                        color: Colors.grey.withAlpha(200),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Text(
                                timeFormat(
                                  widget.weather.list![index].dtTxt.toString(),
                                ),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 10,
                              child: Image.network(
                                'https://openweathermap.org/img/wn/${widget.weather.list![index].weather![0].icon}@2x.png',
                              ),
                            ),

                            Expanded(
                              flex: 7,
                              child: Text(
                                '${(weatherList.main!.temp! - 273.15).toStringAsFixed(0)}°C',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget humadityAndCloud(
  WeatherModel weather, {
  required Animation<Offset> position,
  required Animation<double> scale,
}) {
  return SliverPadding(
    padding: EdgeInsets.all(10),
    sliver: SliverToBoxAdapter(
      child: SlideTransition(
        position: position,
        child: ScaleTransition(
          scale: scale,
          child: Row(
            children: [
              Expanded(
                child: CircularPercentIndWidget(
                  percent: weather.list![0].main!.humidity!.toDouble() / 100,
                  color1: const Color.fromARGB(255, 255, 97, 86),
                  color2: const Color.fromARGB(255, 94, 2, 2),
                  percentText: '${weather.list![0].main!.humidity}%',
                  title: 'Humidity',
                ),
              ),
              Expanded(
                child: CircularPercentIndWidget(
                  percent: weather.list![0].clouds!.all! / 100,
                  percentText: '${weather.list![0].clouds!.all}%',
                  color1: const Color.fromARGB(255, 93, 202, 97),
                  color2: const Color.fromARGB(255, 2, 70, 4),
                  title: 'Clouds',
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget visibilityAndWindSpeed(
  WeatherModel weather, {
  required Animation<Offset> position,
  required Animation<double> scale,
}) {
  return SliverPadding(
    padding: EdgeInsets.all(10),
    sliver: SliverToBoxAdapter(
      child: SlideTransition(
        position: position,
        child: ScaleTransition(
          scale: scale,
          child: Row(
            children: [
              Expanded(
                child: CircularPercentIndWidget(
                  percent: weather.list![0].visibility!.toDouble() / 10000,

                  percentText:
                      '${(weather.list![0].visibility! / 10000 * 100).toStringAsFixed(0)}%',
                  title: 'Visibility',
                  color1: const Color.fromARGB(255, 177, 55, 198),
                  color2: const Color.fromARGB(255, 56, 2, 66),
                ),
              ),
              Expanded(
                child: CircularPercentIndWidget(
                  percent: weather.list![0].wind!.speed! / 100,
                  color1: Colors.cyan,
                  color2: const Color.fromARGB(255, 1, 57, 65),
                  percentText:
                      '${(weather.list![0].wind!.speed! / 100 * 100).toStringAsFixed(0)}%',
                  title: 'Wind speed',
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget rainChance(
  WeatherModel weather, {
  required Animation<Offset> position,
  required Animation<double> scale,
}) {
  return SliverPadding(
    padding: EdgeInsets.all(10),
    sliver: SliverToBoxAdapter(
      child: SlideTransition(
        position: position,
        child: ScaleTransition(
          scale: scale,
          child: Row(
            children: [
              Expanded(
                child: CircularPercentIndWidget(
                  percent: weather.list![0].pop!,
                  // color1: const Color.fromARGB(255, 3, 107, 118),
                  // color2: Colors.deepPurple,
                  color1: Colors.yellowAccent,
                  color2: const Color.fromARGB(255, 75, 67, 1),
                  percentText:
                      '${(weather.list![0].pop! * 100).toStringAsFixed(0)}%',
                  title: 'Rain Chance',
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
