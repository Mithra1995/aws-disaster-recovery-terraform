#!/bin/bash
# Wait for network …
until ping -c1 8.8.8.8 &>/dev/null; do :; done

# ── OS + packages ─────────────────────────────────────────
yum update  -y
yum install -y httpd awscli   # add awscli

systemctl start  httpd
systemctl enable httpd

chmod 777 -R /var/www/html      # (loose perms only for test boxes)

# ── Pull the image from S3 ────────────────────────────────
BUCKET="dr-demo-use1-east-37cfd18a"
OBJECT="terraform_image.png"

aws s3 cp "s3://${BUCKET}/${OBJECT}" /var/www/html/

# make sure Apache can read it
chmod 644 /var/www/html/${OBJECT}

# ── Build the landing page ───────────────────────────────
cat >/var/www/html/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Static Webpage</title>
  <style>
    body  {                       /* centers everything */
      background:#f4f8ff;
      font-family:Arial,Helvetica,sans-serif;
      margin:0; padding:2rem;
      display:flex;
      flex-direction:column;
      align-items:center;         /* horizontal centering */
    }
    img   { max-width:90%; height:auto; border:4px solid #b30000; }
    h1    { margin-top:0; text-align:center; }
  </style>
</head>
<body>
  <h1>Welcome to static Webpage</h1>
  <img src="terraform_image.png" alt="Terraform Image">
</body>
</html>
EOF

