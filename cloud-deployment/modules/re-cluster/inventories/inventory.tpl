%{ for i, name in re-data-node-eip-public-dns ~}
${name} internal_ip=${re-node-internal-ips[i]} external_ip=${re-node-eip-ips[i]}
%{ endfor ~}