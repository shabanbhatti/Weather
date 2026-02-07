import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_project/Pages/Home%20page/widgets/home_ui_widget.dart';
import 'package:weather_project/controllers/api_controller.dart';
import 'package:weather_project/utils/get_weather_img_method.dart';
import 'package:weather_project/utils/hours_for_background_img_method.dart';
import 'package:weather_project/utils/all_weathers_img_paths.dart';
import 'package:weather_project/widgets/get_api_errors_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  static const pageName = '/home';

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    print('Home BUILD CALLED');
    return Consumer(
      builder: (context, apiSerREF, child) {
        var myRef = apiSerREF.watch(apiSerProvider);
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            image:
                (myRef is LoadedSuccessfuly)
                    ? DecorationImage(
                      image: AssetImage(
                        getWeatherImage(
                          condition: myRef.weather.list![0].weather![0].main!,
                          isDay: isDay(myRef.time.formatted!),
                        ),
                      ),
                      fit: BoxFit.cover,

                      opacity: 0.9,
                    )
                    : DecorationImage(
                      image: AssetImage(clear_day),
                      fit: BoxFit.cover,
                    ),
          ),
          child: child,
        );
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,

        body: Center(
          child: Consumer(
            builder:
                (context, myRef, child) => switch (myRef.watch(
                  apiSerProvider,
                )) {
                  LoadingState() => const CupertinoActivityIndicator(
                    color: Colors.white,
                    radius: 13,
                  ),
                  LoadedSuccessfuly(weather: var weather, time: var time) =>
                    HomeUiWidget(weather: weather, time: time),
                  ErrorState(error: var error) => getErrorWidget(
                    error,
                    context,
                    onReload:
                        () =>
                            myRef.read(apiSerProvider.notifier).fetchWeather(),
                    on404ErrorTitle: '❌ City not found!',
                  ),
                  EmptyState() => const Text('No DATA'),
                },
          ),
        ),
      ),
    );
  }
}
