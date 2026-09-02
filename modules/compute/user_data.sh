#!/bin/bash
set -euo pipefail

dnf update -y
dnf install -y nginx mariadb105

mkdir -p /etc/nginx/ssl

cat > /etc/nginx/ssl/server.crt <<CERT
${tls_cert_pem}
CERT

cat > /etc/nginx/ssl/server.key <<KEY
${tls_key_pem}
KEY

chmod 600 /etc/nginx/ssl/server.key

cat > /usr/share/nginx/html/index.html <<'HTML'
<!DOCTYPE html>
<html>
<head><title>Three-Tier App</title></head>
<body>
  <h1>Three-Tier AWS Architecture</h1>
  <p>Application tier is running on Amazon Linux 2023 over HTTPS.</p>
</body>
</html>
HTML

cat > /etc/nginx/conf.d/app.conf <<'NGINX'
server {
  listen 443 ssl;
  server_name _;

  ssl_certificate     /etc/nginx/ssl/server.crt;
  ssl_certificate_key /etc/nginx/ssl/server.key;

  root /usr/share/nginx/html;
  index index.html;
}
NGINX

systemctl enable nginx
systemctl start nginx

# Verify database connectivity from the app tier (non-blocking for health checks)
mysql -h "${db_endpoint}" -u "${db_username}" -p"${db_password}" -e "SELECT 1;" "${db_name}" || true
