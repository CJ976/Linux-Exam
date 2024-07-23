#!/bin/bash

# Step 1: Install Postfix
sudo apt install -y postfix

# Step 2: Navigate to the Postfix configuration folder
cd /etc/postfix

# Step 3: Backup main.cf file
sudo cp main.cf main.cf.backup

# Step 4: Configure main.cf file
sudo sed -i '/^relayhost = .*/d' main.cf  # Remove any existing relayhost entry
sudo sed -i '/^myhostname = .*/d' main.cf  # Remove any existing myhostname entry
sudo tee -a main.cf > /dev/null <<EOF
# Gmail SMTP relay configuration
relayhost = [smtp.gmail.com]:587
smtp_tls_wrappermode = yes
smtp_tls_security_level = encrypt
smtp_tls_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1

# SASL authentication
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl/sasl_passwd
smtp_sasl_security_options = noanonymous
EOF

# Step 5: Create sasl_passwd file under /etc/postfix/sasl/
sudo mkdir -p /etc/postfix/sasl
sudo tee /etc/postfix/sasl/sasl_passwd > /dev/null <<EOF
[smtp.gmail.com]:587 pawan.sharma143600@gmail.com:hicg oeei yeaw snyy
EOF

# Step 6: Update permissions and hash the sasl_passwd file
sudo chmod 400 /etc/postfix/sasl/sasl_passwd
sudo postmap /etc/postfix/sasl/sasl_passwd

# Step 7: Restart Postfix service
sudo systemctl restart postfix

# Step 8: Send a test email
echo "Test Mail" | mail -s "Postfix TEST" modim3912@gmail.com

echo "Configuration completed and test email sent."
