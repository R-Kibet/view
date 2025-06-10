#!/bin/bash
set -e  # Exit on any error

echo "Starting dependency installation..."

# Update system packages
echo "Updating system packages..."
sudo yum update -y

# Install Apache HTTP Server
echo "Installing Apache HTTP Server..."
sudo yum install -y httpd

# Install Tomcat
echo "Installing Tomcat..."
sudo yum install -y tomcat tomcat-webapps tomcat-admin-webapps

# Create Apache virtual host configuration
echo "Creating Apache virtual host configuration..."
sudo tee /etc/httpd/conf.d/tomcat_manager.conf > /dev/null << 'EOF'
<VirtualHost *:80>
    ServerAdmin root@localhost
    ServerName app.nextwork.com
    DefaultType text/html
    ProxyRequests off
    ProxyPreserveHost On
    ProxyPass / http://localhost:8080/nextwork-web-project/
    ProxyPassReverse / http://localhost:8080/nextwork-web-project/
    
    # Enable proxy modules
    LoadModule proxy_module modules/mod_proxy.so
    LoadModule proxy_http_module modules/mod_proxy_http.so
</VirtualHost>
EOF

# Enable and start Apache
echo "Starting Apache HTTP Server..."
sudo systemctl enable httpd
sudo systemctl start httpd

# Enable and start Tomcat
echo "Starting Tomcat..."
sudo systemctl enable tomcat
sudo systemctl start tomcat

# Check if services are running
echo "Checking service status..."
if sudo systemctl is-active --quiet httpd; then
    echo "Apache is running successfully"
else
    echo "ERROR: Apache failed to start"
    exit 1
fi

if sudo systemctl is-active --quiet tomcat; then
    echo "Tomcat is running successfully"
else
    echo "ERROR: Tomcat failed to start"
    exit 1
fi

echo "Dependency installation completed successfully!"