#!/bin/bash
# ============================================
# Z-gen Blog Platform - EC2 Setup Script
# Run this script on a fresh Ubuntu EC2 instance
# ============================================

set -e

echo "🛤️  Setting up Z-gen Blog Platform..."
echo "==========================================="

# --- Update system ---
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# --- Install Node.js 20.x ---
echo "📦 Installing Node.js 20.x..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

echo "Node.js version: $(node -v)"
echo "npm version: $(npm -v)"

# --- Install PostgreSQL ---
echo "📦 Installing PostgreSQL..."
sudo apt install -y postgresql postgresql-contrib

# --- Install Nginx ---
echo "📦 Installing Nginx..."
sudo apt install -y nginx

# --- Install PM2 (process manager) ---
echo "📦 Installing PM2..."
sudo npm install -g pm2

# --- Configure PostgreSQL ---
echo "🗄️  Configuring PostgreSQL..."
sudo -u postgres psql <<EOF
CREATE USER z_gen_user WITH PASSWORD 'z_gen_pass_2026';
CREATE DATABASE z_gen_db OWNER z_gen_user;
GRANT ALL PRIVILEGES ON DATABASE z_gen_db TO z_gen_user;
\c z_gen_db
GRANT ALL ON SCHEMA public TO z_gen_user;
EOF

echo "✅ PostgreSQL configured"

# --- Set up project directory ---
echo "📁 Setting up project..."
sudo mkdir -p /var/www/z-gen
sudo chown -R $USER:$USER /var/www/z-gen

# Copy project files (assumes you've transferred them to ~/Z-gen)
cp -r ~/Z-gen/* /var/www/z-gen/

# --- Install backend dependencies ---
echo "📦 Installing backend dependencies..."
cd /var/www/z-gen/backend
npm install --production

# --- Build frontend ---
echo "🔨 Building frontend..."
cd /var/www/z-gen/frontend
npm install
npm run build

# --- Configure Nginx ---
echo "🌐 Configuring Nginx..."
sudo cp /var/www/z-gen/deploy/z-gen-nginx.conf /etc/nginx/sites-available/z-gen
sudo ln -sf /etc/nginx/sites-available/z-gen /etc/nginx/sites-enabled/z-gen
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx

# --- Start backend with PM2 ---
echo "🚀 Starting backend with PM2..."
cd /var/www/z-gen/backend
pm2 start src/index.js --name z-gen-backend
pm2 save
pm2 startup systemd -u $USER --hp /home/$USER | tail -1 | sudo bash

echo ""
echo "==========================================="
echo "🎉 Z-gen is now live!"
echo "==========================================="
echo ""
echo "Access your blog at: http://16.16.200.133"
echo ""
echo "Useful commands:"
echo "  pm2 status          - Check backend status"
echo "  pm2 logs            - View backend logs"
echo "  pm2 restart all     - Restart backend"
echo "  sudo systemctl restart nginx - Restart Nginx"
echo ""
