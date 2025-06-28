/// lib/shared/common/page_mode_enum.dart
///
/// an enum to indicate the page mode
///
/// - [view]: the page is in view mode
/// - [edit]: the page is in edit mode
///
/// useful to limited user's action on the page
enum PageMode {
  view,
  edit;

  String get getIng {
    switch (this) {
      case PageMode.view:
        return "viewing";
      case PageMode.edit:
        return "editing";
    }
  }
}
