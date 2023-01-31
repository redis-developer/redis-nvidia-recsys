Host *
  User ubuntu
  IdentityFile ~/.ssh/${vpc_name}.pem
  ForwardAgent yes
  GSSAPIAuthentication no
  VerifyHostKeyDNS no
  HashKnownHosts no
  TCPKeepAlive yes
  ServerAliveInterval 300
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
  IdentitiesOnly yes