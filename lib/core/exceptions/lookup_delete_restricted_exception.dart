/// Thrown when deleting a dynamic lookup row (board column, task type,
/// platform, content-creation column) is blocked by the DB foreign key
/// because other rows still reference it.
class LookupDeleteRestrictedException implements Exception {
  const LookupDeleteRestrictedException();
}
