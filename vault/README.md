Generate public/private key pair
Use public key in packer build


Server sets up "master" trusted authorized key stored in Vault
Vault signs other public keys


vault
- Enable ssh: `vault secrets enable -path=ssh-client-signer ssh`
- Generate keypair: `vault write ssh-client-signer/config/ca generate_signing_key=true`
- 
vault secrets enable -path=ssh-client-signer ssh