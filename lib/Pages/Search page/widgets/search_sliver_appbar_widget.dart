import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_project/Pages/Home%20page/home_page.dart';
import 'package:weather_project/Pages/Search%20page/controllers/is_controller_empty.dart';
import 'package:weather_project/Pages/Search%20page/controllers/is_searched_controller.dart';
import 'package:weather_project/Pages/Search%20page/controllers/search_filter_list_controller.dart';
import 'package:weather_project/controllers/api_controller.dart';
import 'package:weather_project/controllers/db_controller.dart';
import 'package:weather_project/models/search_history_model.dart';

class SliverAppBarSearch extends StatefulWidget {
  const SliverAppBarSearch({super.key, required this.controller});
  final TextEditingController controller;

  @override
  State<SliverAppBarSearch> createState() => _SliverAppBarSearchState();
}

class _SliverAppBarSearchState extends State<SliverAppBarSearch>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> scale;
  late Animation<Offset> slide;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOutBack),
    );

    slide = Tween<Offset>(
      begin: const Offset(0.2, 0.5),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOutBack),
    );

    Future.delayed(const Duration(milliseconds: 50), () {
      animationController.forward();
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(CupertinoIcons.back, color: Colors.white),
      ),
      snap: true,
      floating: true,
      pinned: true,
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Consumer(
                builder: (context, searchx, child) {
                  return (searchx.watch(isSearchedProvider) == false)
                      ? const SizedBox()
                      : const CupertinoActivityIndicator(
                        color: Colors.white,
                        radius: 13,
                      );
                },
              ),
            ),
          ],
        ),
      ],
      shape: const RoundedRectangleBorder(),
      title: const Text(
        'History',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      expandedHeight: 120,

      flexibleSpace: FlexibleSpaceBar(
        background: SlideTransition(
          position: slide,
          child: ScaleTransition(
            scale: scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: SizedBox(
                      height: 40,
                      child: Consumer(
                        builder: (context, x, child) {
                          return TextField(
                            cursorColor: Colors.white,
                            controller: widget.controller,
                            style: TextStyle(color: Colors.white),
                            onChanged: (value) {
                              x
                                  .read(filterListProvider.notifier)
                                  .onChanged(value);
                              x
                                  .read(isControllerEmptyProvider.notifier)
                                  .onChangedControllerEmptyOrNot(value);
                            },
                            onSubmitted: (value) async {
                              var data =
                                  await x.read(dbProvider.notifier).fetch() ??
                                  [];

                              bool alreadyExists = data.any(
                                (element) =>
                                    element.searchHistory
                                        ?.toLowerCase()
                                        .trim() ==
                                    value.toLowerCase().trim(),
                              );

                              if (!alreadyExists) {
                                x
                                    .read(dbProvider.notifier)
                                    .insert(
                                      SearchHistoryModel(
                                        searchHistory: widget.controller.text,
                                      ),
                                    );
                              }

                              if (value.isNotEmpty) {
                                x
                                    .read(apiSerProvider.notifier)
                                    .fetchWeather(city: widget.controller.text)
                                    .then((value) {
                                      x.read(dbProvider.notifier).fetch();
                                      x
                                          .read(filterListProvider.notifier)
                                          .updateList();
                                      Navigator.of(
                                        context,
                                      ).pushNamedAndRemoveUntil(
                                        Home.pageName,
                                        (route) => false,
                                      );
                                    });
                                x.read(isSearchedProvider.notifier).foo();
                              }
                            },
                            decoration: InputDecoration(
                              fillColor: Colors.white.withAlpha(50),
                              filled: true,
                              contentPadding: EdgeInsets.all(10),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Search city',
                                style: TextStyle(color: Colors.white),
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
