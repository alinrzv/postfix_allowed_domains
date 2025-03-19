#!/bin/bash
PATH=/www/server/panel/pyenv/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

install_tmp='/tmp/bt_install.pl'
PLUGIN_DIR="/www/server/panel/plugin/postfix_allowed_domains"
POSTFIX_CONFIG="/etc/postfix/main.cf"
POSTFIX_ALLOWED_FILE="/etc/postfix/allowed_domains"
PLUGIN_ICON_SRC="$PLUGIN_DIR/postfix_allowed_domains.png"
PLUGIN_ICON_DEST="/www/server/panel/BTPanel/static/vite/images/soft-ico/ico-postfix_allowed_domains.png"
RESTRICTION_LINE="smtpd_sender_restrictions = check_sender_access hash:/etc/postfix/allowed_domains"

Install_postfix_allowed_domains()
{
    echo 'Installing Postfix Allowed Domains Plugin...'

    if [ ! -f "$POSTFIX_ALLOWED_FILE" ]; then
        echo "Creating allowed domains file..."
        touch "$POSTFIX_ALLOWED_FILE"
        postmap "$POSTFIX_ALLOWED_FILE"
    else
        echo "Allowed domains file already exists."
    fi

    if grep -qF "$RESTRICTION_LINE" "$POSTFIX_CONFIG"; then
        echo "Postfix configuration already has SMTP SEND ONLY from postfix_allowed_domains."
    else
        echo "Enabling SMTP SEND ONLY from postfix_allowed_domains to Postfix configuration..."
        echo "$RESTRICTION_LINE" >> "$POSTFIX_CONFIG"
    fi

    if [ -f "$PLUGIN_ICON_DEST" ]; then
        echo "Removing old plugin icon..."
        rm -f "$PLUGIN_ICON_DEST"
    fi

    if [ -f "$PLUGIN_ICON_SRC" ]; then
        echo "Copying new plugin icon..."
        cp "$PLUGIN_ICON_SRC" "$PLUGIN_ICON_DEST"
        chmod 0755 "$PLUGIN_ICON_DEST"
    fi

    echo "Restarting Postfix..."
    systemctl restart postfix

    echo 'Postfix Allowed Domains Plugin installed successfully!'
}

Uninstall_postfix_allowed_domains()
{
    echo "Uninstalling Postfix Allowed Domains Plugin..."

    echo "Removing plugin directory..."
    rm -rf "$PLUGIN_DIR"

    # Remove the restriction line from the config, handling possible spaces or tabs
    if grep -q "smtpd_sender_restrictions.*allowed_domains" "$POSTFIX_CONFIG"; then
        echo "Removing SMTP SEND ONLY from postfix_allowed_domains from Postfix configuration..."
        sed -i "/^[[:space:]]*smtpd_sender_restrictions[[:space:]]*=[[:space:]]*check_sender_access[[:space:]]*hash:\/etc\/postfix\/allowed_domains[[:space:]]*$/d" "$POSTFIX_CONFIG"
    else
        echo "SMTP SEND ONLY from postfix_allowed_domains not found in Postfix configuration, ignoring setting removal..."
    fi

    # Double-check if the line is actually removed
    if grep -q "smtpd_sender_restrictions.*allowed_domains" "$POSTFIX_CONFIG"; then
        echo "Error: The smtpd_sender_restrictions line is still present in main.cf!"
    else
        echo "Successfully removed smtpd_sender_restrictions from main.cf."
    fi

    if [ -f "$PLUGIN_ICON_DEST" ]; then
        echo "Removing plugin icon..."
        rm -f "$PLUGIN_ICON_DEST"
    fi

    echo "Restarting Postfix..."
    systemctl restart postfix
    systemctl reload postfix  # Ensure the configuration reloads

    echo "Postfix Allowed Domains Plugin removed."
}

action=$1
if [ "$action" == 'install' ]; then
    Install_postfix_allowed_domains
else
    Uninstall_postfix_allowed_domains
fi
