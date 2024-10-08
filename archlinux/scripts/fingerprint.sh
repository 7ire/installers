# !/bin/bash
#
# Utility functions
print_debug() { echo -e "\e[${1}m${2}\e[0m"; }
print_success() { print_debug "32" "$1"; }
print_info() { print_debug "36" "$1"; }



# ------------------------------------------------------------------------------
#                                   Variables
# ------------------------------------------------------------------------------
POLKIT_RULES_FILE="/etc/polkit-1/rules.d/50-default.rules"
PAM_POLKIT_FILE="/etc/pam.d/polkit-1"
USER_GROUP=$(id -gn)

# Controlla se il file di configurazione PAM per polkit esiste, altrimenti crealo
if [[ ! -f "$PAM_POLKIT_FILE" ]]; then
    sudo touch "$PAM_POLKIT_FILE"
fi

# Configurazione di PAM per polkit
echo "Configurazione di PAM per polkit..."
sudo bash -c "cat > $PAM_POLKIT_FILE" <<EOF
auth    sufficient    pam_fprintd.so
auth    include       system-auth
account include       system-auth
password include      system-auth
session include       system-auth
EOF

# Copia il file delle regole di default di polkit se non esiste
if [[ ! -f "$POLKIT_RULES_FILE" ]]; then
    echo "Copia del file delle regole di default di polkit..."
    sudo cp /usr/share/polkit-1/rules.d/50-default.rules "$POLKIT_RULES_FILE"
fi

# Modifica del gruppo di utenti nel file delle regole di polkit
sudo sed -i "s/unix-group:wheel/unix-group:$USER_GROUP/" "$POLKIT_RULES_FILE"