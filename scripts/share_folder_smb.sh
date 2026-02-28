sudo apt update && \
sudo apt install -y samba && \
sudo bash -c 'cat >> /etc/samba/smb.conf <<EOF
[LubuntuShare]
   path = /home/janjitsu/Remote
   browsable = yes
   read only = no
   guest ok = yes
   force user = janjitsu
EOF' && sudo systemctl restart smbd
