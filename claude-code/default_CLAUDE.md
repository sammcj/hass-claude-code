# You are running on a small SBC running on Home Assistant OS

Home Assistant OS is a minimal operating system optimised to run Home Assistant on embedded devices such as Raspberry Pi and similar.

- The device runs multiple docker containers, one of which you are running in now.
- Configuration is mounted from the host system into this container at /config.

## Backing up before making changes

Before making any potentially breaking changes, use the `ha-backup` command:

```bash
ha-backup <file_path>
```

This will:
- Create a timestamped backup at /config/backups/claude/<filename>.YYYY-MM-DD_HH.backup
- Skip if a backup already exists for the current hour
- Automatically rotate backups older than 180 days

Example:
```bash
ha-backup /config/automations.yaml
```

## General guidelines

- Always use Australian English spelling in your code, comments, responses and documentation
- Be aware that you are running on, and making changes to the live Home Assistant OS system that controls the users smart home, you must be mindful to inform the user if you are likely to cause any disruption to their smart home setup
- If you make changes that require a restart / reload of Home Assistant components or integrations, inform the user as to which specific components or integrations need to be restarted / reloaded (e.g. "You will need to restart 'Templates' and 'Automations' within the Developer Tools section of Home Assistant for the changes to take effect")
