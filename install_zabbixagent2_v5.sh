#!/bin/bash

# Vérifier si l'utilisateur a les privilèges d'administration
if [ "$EUID" -ne 0 ]; then
  echo "Ce script doit être exécuté en tant qu'administrateur."
  exit 1
fi

# Mettre à jour le système
echo "Mise a jour des depots"
apt update -y

# Installer les dépendances
echo "Installation des dependance si necessaire"
apt install -y wget

# Télécharger et installer l'agent Zabbix
wget https://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.0-1+focal_all.deb
dpkg -i zabbix-release_5.0-1+focal_all.deb
apt update
echo "Installation de l'agent Zabbix"
apt install -y zabbix-agent

echo "Début de la configuration de Zabbix"

# Demander à l'utilisateur de saisir l'adresse IP du serveur Zabbix
read -p "Veuillez saisir l'adresse IP du serveur Zabbix/Proxy Zabbix : " IP_DU_SERVEUR_ZABBIX

# Demander à l'utilisateur de saisir le nom de la machine
read -p "Veuillez saisir le nom de la machine : " Nom_DE_LA_MACHINE

# Demander à l'utilisateur si les lignes TLS doivent être configurées
read -p "Voulez-vous configurer les lignes TLS ? (Oui/Non) : " CONFIGURER_TLS

# Configurer l'agent Zabbix
sed -i "s/Server=127.0.0.1/Server=$IP_DU_SERVEUR_ZABBIX/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/ServerActive=127.0.0.1/ServerActive=$IP_DU_SERVEUR_ZABBIX/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/Hostname=Zabbix server/Hostname=$Nom_DE_LA_MACHINE/" /etc/zabbix/zabbix_agentd.conf

# Configurer les lignes TLS si demandé
if [[ "$CONFIGURER_TLS" =~ ^[Oo][Uu][Ii]$ ]]; then
  sed -i 's/# TLSAccept=unencrypted/TLSAccept=psk/' /etc/zabbix/zabbix_agentd.conf
  sed -i 's/# TLSConnect=unencrypted/TLSConnect=psk/' /etc/zabbix/zabbix_agentd.conf
  read -p "Veuillez saisir l'identité TLSPSK : " TLSPSKIdentity
  read -p "Veuillez saisir le chemin vers le fichier TLSPSK : " TLSPSKFile
  echo "TLSPSKIdentity=$TLSPSKIdentity"
  echo "TLSPSKFile=$TLSPSKFile"
  sed -i 's/# TLSPSKIdentity=/TLSPSKIdentity=$TLSPSKIdentity/' /etc/zabbix/zabbix_agentd.conf
  sed -i 's/# TLSPSKFile=/TLSPSKFile=$TLSPSKFile/' /etc/zabbix/zabbix_agentd.conf
  echo "Configuration PSK effectuée"
fi

# Démarrer l'agent Zabbix 
systemctl start zabbix-agent
systemctl enable zabbix-agent

# Vérifier l'état de l'agent Zabbix
systemctl status zabbix-agent
