#!/bin/bash
set -euo pipefail

exec > >(tee /var/log/user-data.log) 2>&1
echo "Starting webapp bootstrap at $(date -u)"

dnf install -y nginx python3 python3-pip

mkdir -p /etc/nginx/ssl /opt/three-tier-app

cat > /etc/nginx/ssl/server.crt <<CERT
${tls_cert_pem}
CERT

cat > /etc/nginx/ssl/server.key <<KEY
${tls_key_pem}
KEY

chmod 600 /etc/nginx/ssl/server.key

cat > /opt/three-tier-app/app.py <<'APP'
${app_py}
APP

cat > /opt/three-tier-app/requirements.txt <<'REQ'
${requirements_txt}
REQ

chown -R nginx:nginx /opt/three-tier-app

python3 -m pip install --upgrade pip --break-system-packages
python3 -m pip install -r /opt/three-tier-app/requirements.txt --break-system-packages

cat > /etc/systemd/system/three-tier-app.service <<'SERVICE'
[Unit]
Description=Three-tier Flask application
After=network-online.target nginx.service
Wants=network-online.target

[Service]
User=nginx
Group=nginx
WorkingDirectory=/opt/three-tier-app
Environment=PYTHONUNBUFFERED=1
ExecStart=/usr/bin/python3 -m gunicorn --bind 127.0.0.1:8080 --workers 2 app:app
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICE

cat > /etc/nginx/conf.d/app.conf <<'NGINX'
server {
  listen 443 ssl;
  server_name _;

  ssl_certificate     /etc/nginx/ssl/server.crt;
  ssl_certificate_key /etc/nginx/ssl/server.key;

  location / {
    proxy_pass http://127.0.0.1:8080;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }
}
NGINX

systemctl daemon-reload
systemctl enable nginx three-tier-app
systemctl restart three-tier-app
systemctl restart nginx

echo "Webapp bootstrap complete at $(date -u)"
