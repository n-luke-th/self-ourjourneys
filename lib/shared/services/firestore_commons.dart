enum FirestoreCollections {
  /// test('test')
  ///
  /// this collection meant to be the location to any content to test Firestore service
  test('test'),

  /// memories('memories')
  ///
  /// this collection meant to be the location to store data for the 'memories' feature
  memories('memories'),

  /// albums('albums')
  ///
  /// this collection meant to be the location to store data for the 'albums' feature
  albums('albums'),

  /// anniversaries('anniversaries')
  ///
  /// this collection meant to be the location to store data for the 'anniversaries' feature
  anniversaries('anniversaries'),

  /// mediaData('mediaData')
  ///
  /// this collection meant to be the location to store information about the media that user uploaded to the application
  mediaData('mediaData'),

  /// feedback = '_userFeedback'
  ///
  /// this collection meant to be the location where user to store document that related to their feedback to the application maintainers
  feedback("_userFeedback");

  final String value;

  const FirestoreCollections(this.value);
}

class QueryFilter {
  final String field;
  final dynamic value;
  final QueryCondition condition;

  QueryFilter(this.field, this.value, this.condition);
}

enum QueryCondition {
  isEqualTo,
  isNotEqualTo,
  isLessThan,
  isLessThanOrEqualTo,
  isGreaterThan,
  isGreaterThanOrEqualTo,
  arrayContains,
  arrayContainsAny,
  whereIn,
  whereNotIn,
  isNull,
}
