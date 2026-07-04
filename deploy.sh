#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Get current working directory path
PUBLIC_DIR="$(pwd)/public"

NGINX_CONF_NAME="templates.ngopikode.space.conf"
NGINX_AVAILABLE="/etc/nginx/sites-available/$NGINX_CONF_NAME"
NGINX_ENABLED="/etc/nginx/sites-enabled/$NGINX_CONF_NAME"

echo "=== Starting Deployment for templates.ngopikode.space ==="
echo "Target Nginx root path: $PUBLIC_DIR"

# 1. Update and Copy Nginx Config
read -p "Configure and copy Nginx server block to sites-available? (y/n): " confirm_conf
if [[ "$confirm_conf" =~ ^[Yy]$ ]]; then
    echo "Generating temporary Nginx configuration with current path..."
    # Replace root directive with the local public folder path
    sed "s|root .*;|root $PUBLIC_DIR;|g" "$NGINX_CONF_NAME" > temp_nginx.conf
    
    echo "Copying configuration to $NGINX_AVAILABLE..."
    sudo cp temp_nginx.conf "$NGINX_AVAILABLE"
    rm temp_nginx.conf
    echo "✔ Nginx configuration successfully copied."
else
    echo "Skipped Nginx configuration copy."
fi

# 2. Create Nginx Symlink
read -p "Enable site by creating symlink in sites-enabled? (y/n): " confirm_symlink
if [[ "$confirm_symlink" =~ ^[Yy]$ ]]; then
    echo "Creating symlink..."
    sudo ln -sf "$NGINX_AVAILABLE" "$NGINX_ENABLED"
    echo "✔ Symlink created at $NGINX_ENABLED"
else
    echo "Skipped symlink creation."
fi

# 3. Test and reload Nginx
echo "Testing Nginx configuration syntax..."
sudo nginx -t

read -p "Reload Nginx to apply changes? (y/n): " confirm_reload
if [[ "$confirm_reload" =~ ^[Yy]$ ]]; then
    echo "Reloading Nginx service..."
    sudo systemctl reload nginx
    echo "✔ Nginx successfully reloaded!"
else
    echo "Skipped Nginx reload. Please reload manually: sudo systemctl reload nginx"
fi

echo "=== Deployment script completed. ==="
