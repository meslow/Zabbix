#!/bin/bash

# Pour executer penser a faire un chmod +x install_zabbixagent2_v5.sh
# Vérifier si l'utilisateur a les privilèges d'administration
if [ "$EUID" -ne 0 ]; then
  echo "Ce script doit être exécuté en tant qu'administrateur."
  exit 1
fi

# Mettre à jour le système
# apt update && apt upgrade -y
apt update -y

# Installer les dépendances
apt install -y wget

# Télécharger et installer l'agent Zabbix
wget https://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.0-1+focal_all.deb
dpkg -i zabbix-release_5.0-1+focal_all.deb
apt update
apt install -y zabbix-agent

# Configurer l'agent Zabbix
sed -i 's/Server=127.0.0.1/Server=IP_DU_SERVEUR_ZABBIX/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/ServerActive=127.0.0.1/ServerActive=IP_DU_SERVEUR_ZABBIX/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/Hostname=Zabbix server/Hostname=Nom_DE_LA_MACHINE/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/# TLSAccept=unencrypted/TLSAccept=psk/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/# TLSConnect=unencrypted/TLSConnect=psk/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/# TLSPSKIdentity=NOM_IDENTITE' /etc/zabbix/zabbix_agentd.conf
sed -i 's/# TLSPSKFile=/TLSPSKFile=/etc/zabbix/pskfile.psk' /etc/zabbix/zabbix_agentd.conf

# Démarrer l'agent Zabbix
systemctl start zabbix-agent
systemctl enable zabbix-agent

# Vérifier l'état de l'agent Zabbix
systemctl status zabbix-agent
