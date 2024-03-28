#!/bin/bash

# Project Name: Etherpad Management Tool
# Description: Bash script for managing Etherpad on CPanel.
# Author: Mathieu R
# License: MIT License
# GitHub: https://github.com/MathieuRA/ether-tool

# Etherpad settings
folder_name="etherpad"

# Etherpad settings
folder_name="etherpad"

echo "Bienvenue dans l'outil de gestion Etherpad >=2.0.0 pour CPanel"
echo "Installation(i)/Démarrage(d)"
read -r method

echo "Nom du dossier d'application root"
read -r folder

echo "Nom d'hôte :"
read -r hostname

echo "Nom d'utilisateur :"
read -r username

install_etherpad() {
    local folder="$1"
    local folder_name="$2"
    local version="2.0.1"
    local extracted_folder_name="etherpad-lite-$version"
    local filename="v$version.zip"

    echo "Activation de l'environnement NodeJS"
    source /home/sc4abpa0193/nodevenv/"$folder"/20/bin/activate && cd /home/sc4abpa0193/"$folder"

    echo "Mise en place du proxy pour etherpad"
    npm install http-proxy
    echo "const proxy = require('http-proxy');" > proxy.js
    echo "proxy.createProxyServer({ target: 'http://localhost:9001' }).listen(8080);" >> proxy.js

    pwd
    echo "Téléchargement de $extracted_folder_name"
    wget "https://github.com/ether/etherpad-lite/archive/refs/tags/$filename"

    echo "Extraction des fichiers de l'archive téléchargée"
    unzip "$filename"
    rm "$filename"

    echo "Renommage du dossier $extracted_folder_name -> $folder_name"
    mv "$extracted_folder_name" "$folder_name"
    cd "$folder_name"

    echo "Installation de l'arbre des dépendances"
    bin/installDeps.sh

    echo "Démarrage du logiciel"
    nohup pnpm run prod "$@" > /dev/null 2>&1 &
}

start_etherpad() {
    local folder="$1"
    local folder_name="$2"

    echo "Activation de l'environnement NodeJS"
    source /home/sc4abpa0193/nodevenv/"$folder"/20/bin/activate && cd /home/sc4abpa0193/"$folder"

    cd "$folder_name"

    echo "Démarrage du logiciel"
    nohup pnpm run prod "$@" > /dev/null 2>&1 &
}

if [ "$method" = "i" ]; then
    ssh "$username@$hostname" "$(typeset -f install_etherpad); install_etherpad \"$folder\" \"$folder_name\""
elif [ "$method" = "d" ]; then
    ssh "$username@$hostname" "$(typeset -f start_etherpad); start_etherpad \"$folder\" \"$folder_name\""
else
    echo "Méthode inconnue : $method"
    exit 1
fi

exit 0
