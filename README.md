# Postfix SMTP Allowed Domains - Plugin for aaPanel

## Overview
The **Postfix SMTP Allowed Domains Plugin** for **aaPanel** enables administrators to restrict SMTP sending to specific allowed domains. This plugin automatically configures Postfix to enforce sender restrictions using an `allowed_domains` list.

## Features
- **Restricts SMTP sending** to predefined domains.
- **Automatically configures** Postfix to enforce restrictions.
- **Manages allowed domains** directly from aaPanel.
- **Supports adding and removing domains** dynamically without manual file editing.

### Postfix Configuration Changes
Upon installation, the plugin automatically checks if the setup already exists. If not, it updates `/etc/postfix/main.cf` by adding:
```
smtpd_sender_restrictions = check_sender_access hash:/etc/postfix/allowed_domains
```

## Installation
1. Download the plugin postfix_allowed_domains.zip and save it in a suitable directory.
2. Import it into aaPanel under **App Store > Third-party Plug-ins > Import Plugins**.

## Uninstallation
To remove the plugin, go to **App Store > Third-party Plug-ins > Uninstall Plugin**.

### Features following

### Lists Allowed Domains
Retrieves the current list of allowed domains

### Adds an Allowed Domain
Option To Add a domain to the allowed list

### Removes an Allowed Domain
Option To Remove a domain from the allowed list

### The plugin manages the allowed domains file

```bash
/etc/postfix/allowed_domains
```

### Each domain is added in the following format:
```
example.com OK
anotherdomain.com OK
```
### After modifying the file, the plugin runs:
```bash
sudo postmap /etc/postfix/allowed_domains
sudo systemctl restart postfix
```

## Support
If you encounter issues, please open an issue on GitHub.

## License
This project is open-source and licensed under the MIT License.
