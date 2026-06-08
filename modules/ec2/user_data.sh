#!/bin/bash
# Apache + PHP installation for Amazon Linux 2023

yum update -y

yum install -y httpd php php-mysqlnd

systemctl start httpd
systemctl enable httpd

mkdir -p /var/www/html

cat > /var/www/html/index.php << 'PHPEOF'
<?php
$db_host = '${db_host}';
$db_name = '${db_name}';
$db_user = '${db_user}';
$s3_bucket = '${s3_bucket}';
?>
<!DOCTYPE html>
<html>
<head>
    <title>Web App - Terraform Deployment</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
        .card { border: 1px solid #ddd; border-radius: 8px; padding: 20px; margin: 10px 0; }
        h1 { color: #333; }
        .info { background: #f5f5f5; padding: 10px; border-radius: 4px; }
        .label { font-weight: bold; color: #555; }
    </style>
</head>
<body>
    <h1>Web App Deployed via Terraform</h1>
    <div class="card">
        <h2>Server Info</h2>
        <div class="info"><span class="label">PHP Version:</span> <?php echo phpversion(); ?></div>
        <div class="info"><span class="label">Server:</span> <?php echo $_SERVER['SERVER_SOFTWARE']; ?></div>
    </div>
    <div class="card">
        <h2>Database Config</h2>
        <div class="info"><span class="label">DB Host:</span> <?php echo $db_host; ?></div>
        <div class="info"><span class="label">DB Name:</span> <?php echo $db_name; ?></div>
        <div class="info"><span class="label">DB User:</span> <?php echo $db_user; ?></div>
    </div>
    <div class="card">
        <h2>S3 Static Assets</h2>
        <div class="info"><span class="label">S3 Bucket:</span> <?php echo $s3_bucket; ?></div>
    </div>
</body>
</html>
PHPEOF

cat > /var/www/html/db_test.php << 'DBEOF'
<?php
$db_host = '${db_host}';
$db_name = '${db_name}';
$db_user = '${db_user}';
$db_password = '${db_password}';

echo "<h2>Database Connection Test</h2>";
echo "<p>Host: $db_host</p>";
echo "<p>Database: $db_name</p>";

try {
    $conn = new mysqli($db_host, $db_user, $db_password, $db_name);
    if ($conn->connect_error) {
        echo "<p style='color:red;'>Connection failed: " . $conn->connect_error . "</p>";
    } else {
        echo "<p style='color:green;'>Connected successfully to RDS MySQL!</p>";
        $conn->close();
    }
} catch (Exception $e) {
    echo "<p style='color:orange;'>Note: " . $e->getMessage() . " (expected if DB not reachable from here)</p>";
}
?>
DBEOF

chown apache:apache /var/www/html/*.php
chmod 644 /var/www/html/*.php
chmod -R 755 /var/www
