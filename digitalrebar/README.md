TODO:

- Print systemd to both console and serial https://github.com/systemd/systemd/issues/9899
- The ApiUrl GO variable is pointing to the IP address of the instance, not the FQDN
- Is the root partition grown through cloud-init?
- Don't set SIZE in image config / don't pass the image builder but set size on all qcow
