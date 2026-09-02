locals {
  app_py = templatefile("${path.module}/app/app.py", {
    db_endpoint = var.db_endpoint
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
  })

  requirements_txt = file("${path.module}/app/requirements.txt")

  user_data = templatefile("${path.module}/templates/user_data.sh", {
    app_py           = local.app_py
    requirements_txt = local.requirements_txt
    db_endpoint      = var.db_endpoint
    db_name          = var.db_name
    db_username      = var.db_username
    db_password      = var.db_password
    tls_cert_pem     = var.tls_cert_pem
    tls_key_pem      = var.tls_key_pem
  })
}
