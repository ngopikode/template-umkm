#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Target paths
TARGET_DIR="/var/www/template-umkm"
NGINX_CONF_NAME="template-umkm.conf"
NGINX_AVAILABLE="/etc/nginx/sites-available/$NGINX_CONF_NAME"
NGINX_ENABLED="/etc/nginx/sites-enabled/$NGINX_CONF_NAME"

echo "=== Starting Deployment for template-umkm.ngopikode.space ==="

# 1. Sync static files
read -p "Deploy static web assets to $TARGET_DIR? (y/n): " confirm_assets
if [[ "$confirm_assets" =~ ^[Yy]$ ]]; then
    echo "Creating target directory..."
    sudo mkdir -p "$TARGET_DIR"
    
    echo "Copying files to $TARGET_DIR..."
    # Copy portal pages
    sudo cp index.html portal-style.css 404.html "$TARGET_DIR/"
    
    # Copy templates folder structure recursively
    sudo cp -r templates "$TARGET_DIR/"
    
    # Ensure correct permissions
    sudo chown -R www-data:www-data "$TARGET_DIR"
    sudo chmod -R 755 "$TARGET_DIR"
    echo "✔ Static assets successfully deployed."
else
    echo "Skipped static assets deployment."
fi

# 2. Copy Nginx Config
read -p "Copy Nginx configuration to sites-available? (y/n): " confirm_conf
if [[ "$confirm_conf" =~ ^[Yy]$ ]]; then
    echo "Copying Nginx configuration file..."
    sudo cp "$NGINX_CONF_NAME" "$NGINX_AVAILABLE"
    echo "✔ Nginx configuration copied to $NGINX_AVAILABLE"
else
    echo "Skipped Nginx configuration copy."
fi

# 3. Create Nginx Symlink
read -p "Enable site by creating symlink in sites-enabled? (y/n): " confirm_symlink
if [[ "$confirm_symlink" =~ ^[Yy]$ ]]; then
    echo "Creating symlink..."
    sudo ln -sf "$NGINX_AVAILABLE" "$NGINX_ENABLED"
    echo "✔ Symlink created at $NGINX_ENABLED"
else
    echo "Skipped symlink creation."
fi

# 4. Test and reload Nginx
echo "Testing Nginx configuration syntax..."
sudo nginx -t

read -p "Reload Nginx to apply new configurations? (y/n): " confirm_reload
if [[ "$confirm_reload" =~ ^[Yy]$ ]]; then
    echo "Reloading Nginx service..."
    sudo systemctl reload nginx
    echo "✔ Nginx successfully reloaded!"
else
    echo "Skipped Nginx reload. Please reload Nginx manually using: sudo systemctl reload nginx"
fi

echo "=== Deployment script completed. ==="
