const String contentItemJoinedSelect = '''
*,
clients(id, name, color, logo_url),
copywriter:profiles!content_items_copywriter_id_fkey(id, full_name, avatar_url, role, created_at),
designer:profiles!content_items_designer_id_fkey(id, full_name, avatar_url, role, created_at),
account_manager:profiles!content_items_account_manager_id_fkey(id, full_name, avatar_url, role, created_at)
''';
