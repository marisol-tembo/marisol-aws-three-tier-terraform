from datetime import datetime, timezone

import pymysql
from flask import Flask, Response

app = Flask(__name__)

DB_CONFIG = {
    "host": "${db_endpoint}",
    "user": "${db_username}",
    "password": "${db_password}",
    "database": "${db_name}",
    "connect_timeout": 5,
    "cursorclass": pymysql.cursors.DictCursor,
}


def check_database():
    try:
        connection = pymysql.connect(**DB_CONFIG)
        with connection.cursor() as cursor:
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS connection_tests (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    tested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
                """
            )
            cursor.execute("INSERT INTO connection_tests () VALUES ()")
            cursor.execute("SELECT COUNT(*) AS total FROM connection_tests")
            count_row = cursor.fetchone()
            cursor.execute("SELECT VERSION() AS version")
            version_row = cursor.fetchone()
            connection.commit()
        connection.close()
        return {
            "connected": True,
            "version": version_row["version"],
            "test_count": count_row["total"],
            "error": None,
        }
    except Exception as exc:
        return {
            "connected": False,
            "version": None,
            "test_count": None,
            "error": str(exc),
        }


@app.route("/health")
def health():
    return Response("ok", mimetype="text/plain", status=200)


@app.route("/")
def index():
    db = check_database()
    status_class = "ok" if db["connected"] else "fail"
    status_text = "Connected" if db["connected"] else "Not connected"

    if db["connected"]:
        details = f"""
        <p><strong>MySQL version:</strong> {db["version"]}</p>
        <p><strong>Successful connection tests:</strong> {db["test_count"]}</p>
        <p class="hint">Each page load inserts a row into <code>connection_tests</code> to prove app → RDS writes work.</p>
        """
    else:
        details = f"""
        <p><strong>Error:</strong> {db["error"]}</p>
        <p class="hint">If RDS was still starting, refresh this page in a minute.</p>
        """

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Three-Tier DB Test</title>
  <style>
    body {{
      font-family: system-ui, sans-serif;
      background: #0f172a;
      color: #e2e8f0;
      margin: 0;
      min-height: 100vh;
      display: grid;
      place-items: center;
    }}
    main {{
      width: min(720px, 92vw);
      background: #1e293b;
      border-radius: 12px;
      padding: 2rem;
      box-shadow: 0 12px 30px rgba(0, 0, 0, 0.35);
    }}
    h1 {{ margin-top: 0; color: #38bdf8; }}
    .badge {{
      display: inline-block;
      padding: 0.35rem 0.75rem;
      border-radius: 999px;
      font-weight: 700;
      margin-bottom: 1rem;
    }}
    .ok {{ background: #14532d; color: #bbf7d0; }}
    .fail {{ background: #7f1d1d; color: #fecaca; }}
    code {{ background: #334155; padding: 0.1rem 0.35rem; border-radius: 4px; }}
    .hint {{ color: #94a3b8; }}
    ul {{ line-height: 1.8; }}
  </style>
</head>
<body>
  <main>
    <h1>Marisol's Three-Tier Architecture DB Connection Test</h1>
    <p>Traffic path: <strong>Internet → ALB → EC2 (private) → RDS MySQL (private)</strong></p>
    <div class="badge {status_class}">Database: {status_text}</div>
    {details}
    <h2>What this page proves</h2>
    <ul>
      <li>ALB can reach the application tier in private subnets</li>
      <li>App tier can reach RDS on port 3306 through security groups</li>
      <li>RDS is not publicly accessible — only the app tier can connect</li>
    </ul>
    <p class="hint">Checked at {datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")} UTC</p>
  </main>
</body>
</html>"""
    return Response(html, mimetype="text/html")


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=8080)
