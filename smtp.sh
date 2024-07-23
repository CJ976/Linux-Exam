#!/bin/bash

# Step 1: Ensure Postfix is installed
echo "Step 1: Installing Postfix if not already installed..."
sudo apt update
sudo apt install -y postfix

# Step 2: Navigate to the /etc/postfix folder
echo "Step 2: Navigating to /etc/postfix..."
cd /etc/postfix

# Step 3: Configure main.cf file
echo "Step 3: Configuring main.cf..."
sudo cp main.cf main.cf.backup  # Backup original main.cf

# Ensure smtp_tls_security_level is set correctly
sudo sed -i '/^smtp_tls_security_level\s*=/d' main.cf
echo "smtp_tls_security_level = may" | sudo tee -a main.cf

# Remove existing relayhost entries if they exist
sudo sed -i '/^relayhost\s*=/d' main.cf

# Append additional configuration settings
sudo bash -c 'cat <<EOL >> main.cf
relayhost = [smtp.gmail.com]:587
myhostname = $(hostname -f)

# Location of sasl_passwd we saved
smtp_sasl_password_maps = hash:/etc/postfix/sasl/sasl_passwd

# Enables SASL authentication for postfix
smtp_sasl_auth_enable = yes

# Disallow methods that allow anonymous authentication
smtp_sasl_security_options = noanonymous
EOL'

# Step 4: Create sasl_passwd file under /etc/postfix/sasl/
echo "Step 4: Creating sasl_passwd file..."
sudo mkdir -p /etc/postfix/sasl
echo "[smtp.gmail.com]:587 rcdelhi01@ignou.ac.in@gmail.com:wufw yoyx skgg xbmk" | sudo tee /etc/postfix/sasl/sasl_passwd > /dev/null

# Step 5: Postmap sasl_passwd and restart postfix service
echo "Step 5: Updating Postfix configuration and restarting service..."
sudo postmap /etc/postfix/sasl/sasl_passwd
sudo systemctl restart postfix

# Step 6: Send a test email
echo "Step 6: Sending test email..."

# Prompt user for recipient email
read -p "Enter recipient email address: " recipient_email

# Send test email
echo "Test Mail" | mail -s "Postfix TEST" "$recipient_email"

echo "Setup completed. Check your email for the test message."
