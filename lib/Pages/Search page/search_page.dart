import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_project/Pages/Search%20page/controllers/is_controller_empty.dart';
import 'package:weather_project/Pages/Search%20page/controllers/search_filter_list_controller.dart';
import 'package:weather_project/Pages/Search%20page/widgets/background_img_container.dart';
import 'package:weather_project/Pages/Search%20page/widgets/search_sliver_appbar_widget.dart';
import 'package:weather_project/Pages/Search%20page/widgets/searched_data_widget.dart';
import 'package:weather_project/controllers/db_controller.dart';
import 'package:weather_project/utils/dialog%20boxes/delete_all_dialog.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  static const pageName = '/search_page';

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> scale;
  late Animation<Offset> slide;
  TextEditingController? controller;
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

    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller!.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('SEARCH PAGE BUILD CALLED');
    return BackgroundImgContainer(
      child: Scaffold(
        backgroundColor: Colors.black.withAlpha(100),

        body: Center(
          child: CustomScrollView(
            slivers: [
              SliverAppBarSearch(controller: controller!),

              SliverPadding(
                padding: const EdgeInsets.only(top: 10, right: 10),
                sliver: SliverToBoxAdapter(
                  child: ScaleTransition(
                    scale: scale,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Consumer(
                          builder: (context, s, child) {
                            var myREF = s.watch(dbProvider);
                            if (myREF is DbLoadedSuccessfulyState) {
                              return Consumer(
                                builder:
                                    (context, y, child) =>
                                        (y.watch(isControllerEmptyProvider) ==
                                                true)
                                            ? OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              onPressed: () {
                                                showDeleteAllDialog(context, () {
                                                  y
                                                      .read(dbProvider.notifier)
                                                      .deleteAlll()
                                                      .then((value) {
                                                        y
                                                            .read(
                                                              filterListProvider
                                                                  .notifier,
                                                            )
                                                            .updateList();
                                                        Navigator.pop(context);
                                                      });
                                                });
                                              },
                                              child: const Text(
                                                'Clear all',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                            : const SizedBox(),
                              );
                            } else {
                              return const SizedBox();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SearchedDataWidget(scale: scale),
            ],
          ),
        ),
      ),
    );
  }
}
