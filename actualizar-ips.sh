#!/bin/bash

echo "Obteniendo IPs de AWS..."

NODO1=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=asterisk-nodo1" "Name=instance-state-name,Values=running" --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

NODO2=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=asterisk-nodo2" "Name=instance-state-name,Values=running" --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

KAMAILIO=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=kamailio-proxy" "Name=instance-state-name,Values=running" --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

echo "asterisk-nodo1 = $NODO1"
echo "asterisk-nodo2 = $NODO2"
echo "kamailio-proxy = $KAMAILIO"

cat > ~/projects/ansible-homelab/inventario/hosts.ini << EOF
[asterisk]
asterisk-nodo1 ansible_host=$NODO1
asterisk-nodo2 ansible_host=$NODO2

[kamailio]
kamailio-proxy ansible_host=$KAMAILIO

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/projects/ansible-homelab/ansible-homelab.pem
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF

echo ""
echo "⚠️ RECUERDA actualizar el ACL de Twilio con las nuevas IPs:"
echo " asterisk-nodo1: $NODO1/32"
echo " asterisk-nodo2: $NODO2/32"
echo " URL: https://console.twilio.com -> Elastic SIP Trunking -> Trunks -> asterisk-homelab -> Termination"
echo ""
echo "Inventario actualizado!"