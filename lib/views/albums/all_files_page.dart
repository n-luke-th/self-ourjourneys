import 'package:flutter/material.dart';
import 'package:ourjourneys/components/main_view.dart';
import 'package:ourjourneys/components/paginated_albums_grid.dart';

class AllFilesPage extends StatefulWidget {
  const AllFilesPage({super.key});

  @override
  State<AllFilesPage> createState() => _AllFilesPageState();
}

class _AllFilesPageState extends State<AllFilesPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  final List<_MediaTab> _tabs = [
    _MediaTab(title: 'All', contentType: null),
    _MediaTab(title: 'Images', contentType: 'image/'),
    _MediaTab(title: 'Videos', contentType: 'video/'),
    _MediaTab(title: 'Docs', contentType: 'application/pdf'),
  ];

  @override
  void initState() {
    _tabController = TabController(length: _tabs.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return mainView(
      context,
      appBarTitle: "All Uploaded Files",
      appbarBottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabs: _tabs.map((e) => Tab(text: e.title)).toList(),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs
            .map((tab) =>
                PaginatedAlbumsGrid(filterContentTypePrefix: tab.contentType))
            .toList(),
      ),
    );
  }
}

class _MediaTab {
  final String title;
  final String? contentType;

  const _MediaTab({required this.title, this.contentType});
}
