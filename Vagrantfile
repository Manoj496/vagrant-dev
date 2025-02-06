# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.define "c2-dev"
  
  config.vm.box = "hashicorp/bionic64"
  config.vm.hostname = "c2-dev"

  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"

  config.vm.network "forwarded_port", guest: 80, host: 8081  # Changed host port to 8081
  config.vm.network "forwarded_port", guest: 91, host: 9192  # Changed host port to 9192
  config.vm.network "forwarded_port", guest: 9191, host: 9191  # Changed host port to 9192
  
  config.vm.network "private_network", ip: "192.168.33.10"

  # Specify the exact network interface name for the public network bridge
  config.vm.network "public_network", bridge: "Intel(R) Dual Band Wireless-AC 3165"

  config.vm.synced_folder "../encryption-dev", "/opt/c2/encryption"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4096"
  end

  config.vm.provision "shell", inline: <<-SHELL
  sudo apt-get update
  sudo sysctl net.ipv6.conf.all.disable_ipv6=1
  sudo apt-get install -y software-properties-common
  sudo add-apt-repository ppa:ondrej/php -y
  sudo apt-get update
  sudo apt-get install -y php7.2 php7.2-fpm php7.2-cli php7.2-mbstring php7.2-xml
  sudo apt-get install -y nginx

  # Install mcrypt dependencies
  sudo apt-get install -y libmcrypt-dev php-pear php7.2-dev
  sudo pecl install mcrypt-1.0.1

  # Enable mcrypt extension
  echo "extension=mcrypt.so" | sudo tee /etc/php/7.2/fpm/php.ini
  sudo phpenmod mcrypt

  sudo mkdir -p /etc/nginx/sites-available
  sudo mkdir -p /etc/nginx/sites-enabled

  sudo bash -c 'cat > /etc/nginx/sites-available/default' << EOF
  server {
    listen 9191;
    root /opt/c2/encryption/public;
    index index.php index.html index.htm;
    server_name localhost;

    client_max_body_size 100M;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \\.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
  }
EOF

  sudo sed -i 's|location ~ .php$ {|location ~ \\.php$ {|' /etc/nginx/sites-available/default
  sudo sed -i 's|try_files .*|try_files \\$uri \\$uri/ /index.php?\\$args;|' /etc/nginx/sites-available/default
  sudo sed -i 's|fastcgi_param SCRIPT_FILENAME .*|fastcgi_param SCRIPT_FILENAME \\$document_root\\$fastcgi_script_name;|' /etc/nginx/sites-available/default
  sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

  sudo systemctl enable php7.2-fpm
  sudo systemctl start php7.2-fpm
  sudo systemctl enable nginx
  sudo systemctl start nginx
SHELL


  config.vm.provision :shell, :path => "provision/shell/c2.sh"
  config.vm.provision :shell, :path => "provision/shell/nginx.sh"
end
