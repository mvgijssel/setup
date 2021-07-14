## TODO
- install cockpit: https://cockpit-project.org/guide/201/feature-virtualmachines.html
- dnsmasq expiring lease will break kubernetes
  - after expiring no new lease is requested and hostname resolution stops working?
- dnsmasq expiring lease will break jump host
- move ssh config into envrc + local ssh_config, to remove logic from Vagrant / terraform files

## Status nested virtualisation on GitHub actions:

- Linux
  - No nested virtualisation possible
- Macos Sierra
  - HAXM does not have nested virtualisation
  - xhyve/hyperkit does not have nested virtualisation
