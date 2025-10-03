install ssh 
    yum install ssh
systemctl status ssh
    systemctl enable ssh --now

# Check Firewall
sudo ufw status

sudo lsof -i -P -n | grep LISTEN

sudo ufw allow ssh 
sudo ufc status verbose
