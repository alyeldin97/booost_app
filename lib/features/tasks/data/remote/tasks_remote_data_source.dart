const String taskJoinedSelect = '''
*,
clients(id, name, color, logo_url),
task_assignees(profiles(id, full_name, avatar_url, role, created_at)),
task_platforms(platform),
task_labels(id, task_id, label),
task_checklist_items(id, task_id, title, is_completed, position),
task_attachments(id, task_id, file_name, file_url, file_type, uploaded_by, created_at),
task_comments(id, task_id, profile_id, content, created_at, profiles(full_name, avatar_url)),
content_items(id)
''';
