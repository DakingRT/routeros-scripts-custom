# Custom RouterOS Scripts by DakingRT

This repository hosts a small collection of RouterOS **custom scripts** that build on top of the excellent  
[eworm/routeros-scripts](https://git.eworm.de/cgit/routeros-scripts/about/) framework.

> **Use at your own risk** – see the licence section below.

## Requirements

1. A MikroTik device running RouterOS 7.x.  
2. The upstream framework already installed on the router (`global-config.rsc`, `global-config-overlay.rsc`, `global-functions.rsc`).  
   Follow the instructions on the eworm project page first.

## Installation


The framework provides the helper function `$ScriptInstallUpdate`.  
Install any script by naming it (or several, comma-separated) and passing the **base-url** of this repository:

\nFiles participated:
x `custom-scripts.rsc` -  Your config file.
x `custom-scripts.template.rsc` - overlay template; copy its contents into your custom-scripts.rsc and fill in the variables it lists.

### One-liner install

```rsc
:global ScriptInstallUpdate;
$ScriptInstallUpdate custom-scripts,custom-scripts.template.rsc \
    "base-url=https://raw.githusercontent.com/DakingRT/routeros-scripts-custom/main/" \
    "url-suffix="
```

> After the first install run  
> `/system/script run global-config`  
> to load any new variables.


## Available scripts

### duckdns-update — keep your Duck DNS record fresh

*File:* `duckdns-update.rsc`  
*Type:* **normal script** (triggered by a scheduler you create)  

| Variable (placed in **global-config-overlay** or in `global-config-overlay.d/custom-scripts`) | Example | Description |
|------------------------------------------------------------|---------|-------------|
| `DuckDnsWanInterface` | `pppoe-out1`       | Interface that holds the public IP |
| `DuckDnsDomain`       | `myhome.duckdns.org` | Duck DNS sub-domain |
| `DuckDnsToken`        | `1234abcd-…`       | Token shown in Duck DNS dashboard |

#### Quick setup

1. **Install the script** (see command above).  
2. **Edit your overlay** and add the three variables.  
3. **Reload configuration**  
   ```rsc
   /system/script run global-config
   ```  
4. **Create a 5-minute scheduler**  
   ```rsc
   /system/scheduler/add name="duckdns-update" \
       start-time=startup interval=5m \
       on-event="/system/script/run duckdns-update;"
   ```

The updater now checks every five minutes; if the WAN IP changes it calls the Duck DNS API, writes to the log and (optionally) triggers eworm’s notification helper.

---

## Licence and warranty

This project is released under the **GNU General Public License v3**.  
See the file `COPYING.md` for the full text.

This software is provided **without any warranty**; you use it entirely at your own risk.