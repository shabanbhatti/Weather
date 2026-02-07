import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_project/Pages/Home%20page/home_page.dart';
import 'package:weather_project/Pages/Search%20page/controllers/is_searched_controller.dart';
import 'package:weather_project/Pages/Search%20page/controllers/search_filter_list_controller.dart';
import 'package:weather_project/controllers/api_controller.dart';
import 'package:weather_project/controllers/db_controller.dart';

class SearchedDataWidget extends ConsumerWidget {
  const SearchedDataWidget({super.key, required this.scale});
  final Animation<double> scale;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var myRef = ref.watch(dbProvider);
    var filterList = ref.watch(filterListProvider);
    if (myRef is DbLoadingState) {
      return const SliverFillRemaining(
        child: Center(
          child: CupertinoActivityIndicator(color: Colors.white, radius: 13),
        ),
      );
    } else if (myRef is DbLoadedSuccessfulyState) {
      return SliverList.builder(
        itemCount: filterList.length,

        itemBuilder:
            (context, index) => ListTile(
              onTap: () {
                ref
                    .read(apiSerProvider.notifier)
                    .fetchWeather(city: filterList[index].searchHistory)
                    .then((value) {
                      ref.read(filterListProvider.notifier).updateList();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        Home.pageName,
                        (route) => false,
                      );
                    });
                ref.read(isSearchedProvider.notifier).foo();
              },
              leading: const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.search, color: Colors.white),
              ),
              title: Text(
                filterList[index].searchHistory.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              trailing: IconButton(
                onPressed: () {
                  ref.read(dbProvider.notifier).delete(filterList[index]).then((
                    value,
                  ) {
                    ref.read(filterListProvider.notifier).updateList();
                  });
                },
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
      );
    } else if (myRef is DbErrorState) {
      return SliverFillRemaining(child: Center(child: Text(myRef.error)));
    } else if (myRef is DbEmptyState) {
      return const SliverFillRemaining(
        child: Center(
          child: Text(
            'No search history',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      return const SliverToBoxAdapter();
    }
  }
}
