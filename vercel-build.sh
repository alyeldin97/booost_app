#!/usr/bin/env bash
set -euo pipefail

git clone https://github.com/flutter/flutter.git -b 3.35.3 --depth 1 _flutter
export PATH="$PATH:$(pwd)/_flutter/bin"

flutter config --enable-web
flutter pub get

cat > env.json <<EOF
{"SUPABASE_URL":"${SUPABASE_URL}","SUPABASE_ANON_KEY":"${SUPABASE_ANON_KEY}"}
EOF

flutter build web --release --dart-define-from-file=env.json
