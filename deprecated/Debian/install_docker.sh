#!/bin/bash

echo "=== Instalando Docker ==="
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

echo "=== Agregando usuario al grupo docker ==="
sudo usermod -aG docker $USER

echo "=== Instalando Docker Compose ==="
sudo apt update
sudo apt install -y docker-compose-plugin

echo "=== Configurando Docker daemon ==="
sudo mkdir -p /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "storage-driver": "overlay2",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "default-runtime": "runc",
  "runtimes": {
    "runc": {
      "path": "runc"
    }
  },
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ],
  "max-concurrent-downloads": 3,
  "max-concurrent-uploads": 5,
  "default-ulimits": {
    "memlock": {
      "Name": "memlock",
      "Hard": -1,
      "Soft": -1
    },
    "nofile": {
      "Name": "nofile",
      "Hard": 65536,
      "Soft": 65536
    }
  }
}
EOF

echo "=== Reiniciando Docker ==="
sudo systemctl restart docker
sudo systemctl enable docker

echo "=== Configuración completada ==="
echo "Por favor, reinicia tu sesión o ejecuta: newgrp docker"
echo "Luego verifica con: docker --version && docker compose version"