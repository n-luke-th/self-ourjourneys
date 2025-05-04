import 'package:flutter/material.dart';
import 'package:ourjourneys/components/main_view.dart';
import 'package:ourjourneys/components/paginated_albums_grid.dart';
import 'package:ourjourneys/shared/views/ui_consts.dart';

class AllFilesPage extends StatefulWidget {
  const AllFilesPage({super.key});

  @override
  State<AllFilesPage> createState() => _AllFilesPageState();
}

class _AllFilesPageState extends State<AllFilesPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  final List<_MediaTab> _tabs = [
    _MediaTab(
      title: 'All',
      contentType: null,
      icon: const Icon(
        Icons.storage_outlined,
      ),
    ),
    _MediaTab(
        title: 'Images',
        contentType: 'image/',
        icon: const Icon(
          Icons.image_outlined,
        )),
    _MediaTab(
      title: 'Videos',
      contentType: 'video/',
      icon: const Icon(
        Icons.video_library_outlined,
      ),
    ),
    _MediaTab(
      title: 'Documents',
      contentType: 'application/pdf',
      icon: const Icon(
        Icons.picture_as_pdf_outlined,
      ),
    )
  ];

  @override
  void initState() {
    _tabController = TabController(
        length: _tabs.length,
        vsync: this,
        animationDuration: UiConsts.animationDuration);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return mainView(
      context,
      appBarTitle: "All Uploaded Files",
      appbarBottom: TabBar(
        controller: _tabController,
        isScrollable: false,
        labelPadding: UiConsts.PaddingAll_standard,
        // indicatorPadding: UiConsts.PaddingHorizontal_small,
        tabAlignment: TabAlignment.fill,
        enableFeedback: true,
        labelColor: Theme.of(context).colorScheme.onSurface,
        tabs: _tabs
            .map((e) => Tab(
                  text: e.title,
                  icon: e.icon,
                  iconMargin: UiConsts.PaddingHorizontal_small,
                ))
            .toList(),
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
  final Widget? icon;

  const _MediaTab({required this.title, this.contentType, this.icon});
}
