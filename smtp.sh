#!/bin/bash

# Step 1: Install Postfix
sudo apt install -y postfix

# Step 2: Navigate to the Postfix configuration folder
cd /etc/postfix

# Step 3: Configure main.cf file
sudo cp main.cf main.cf.backup  # Backup the original main.cf file
sudo sed -i 's/^relayhost = .*/relayhost = [smtp.gmail.com]:587/' main.cf
sudo sed -i 's/^myhostname = .*/myhostname = '"$(hostname)"'/' main.cf

# Step 4: Add configuration at the end of main.cf
sudo tee -a main.cf > /dev/null <<EOF
# Location of sasl_passwd we saved
smtp_sasl_password_maps = hash:/etc/postfix/sasl/sasl_passwd

# Enables SASL authentication for postfix
smtp_sasl_auth_enable = yes
smtp_tls_security_level = encrypt

# Disallow methods that allow anonymous authentication
smtp_sasl_security_options = noanonymous
EOF

# Step 5: Create sasl_passwd file under /etc/postfix/sasl/
sudo mkdir -p /etc/postfix/sasl
sudo tee /etc/postfix/sasl/sasl_passwd > /dev/null <<EOF
[smtp.gmail.com]:587 your-email@gmail.com:your-password
EOF

# Step 6: Update permissions and hash the sasl_passwd file
sudo chmod 400 /etc/postfix/sasl/sasl_passwd
sudo postmap /etc/postfix/sasl/sasl_passwd

# Step 7: Restart Postfix service
sudo systemctl restart postfix

# Step 8: Send a test email
echo "Test Mail" | mail -s "Postfix TEST" recipient-email@gmail.com

echo "Configuration completed and test email sent."
