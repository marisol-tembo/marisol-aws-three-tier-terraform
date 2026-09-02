#!/bin/bash
set -euo pipefail

dnf update -y
dnf install -y nginx mariadb105

cat > /usr/share/nginx/html/index.html <<'HTML'
<!DOCTYPE html>
<html>
<head><title>Three-Tier App</title></head>
<body>
  <h1>Three-Tier AWS Architecture</h1>
  <p>Application tier is running on Amazon Linux 2023.</p>
</body>
</html>
HTML

systemctl enable nginx
systemctl start nginx

# Verify database connectivity from the app tier (non-blocking for health checks)
mysql -h "${db_endpoint}" -u "${db_username}" -p"${db_password}" -e "SELECT 1;" "${db_name}" || true
