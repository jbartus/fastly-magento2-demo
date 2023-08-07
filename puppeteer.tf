resource "google_compute_instance" "puppeteer" {
  name                      = "${var.site_name}-puppeteer"
  machine_type              = "c3-standard-4"
  depends_on                = [fastly_service_vcl.demo_service, terraform_data.magento_setup]
  allow_stopping_for_update = true
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2304-amd64"
    }
  }
  network_interface {
    network = "default"
    access_config {}
  }
  metadata = {
    ssh-keys = "ubuntu:${file("${var.ssh_pub_key}")}"
  }
  metadata_startup_script = "apt install -y libnss3 libatk1.0-0 libatk-bridge2.0-0 libx11-xcb1 libxcb-dri3-0 libxcomposite1 libxdamage1 libxfixes3 libcups2 libdrm2 libxrandr2 libgbm1 libasound2 libpangocairo-1.0-0 libgtk-3-0"
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${var.ssh_priv_key}")
    host        = self.network_interface.0.access_config.0.nat_ip
  }
  provisioner "file" {
    source      = "puppets/"
    destination = "/home/ubuntu"
  }
  provisioner "remote-exec" {
    inline = [
      "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash",
      "export NVM_DIR=\"$HOME/.nvm\"",
      "[ -s \"$NVM_DIR/nvm.sh\" ] && \\. \"$NVM_DIR/nvm.sh\"",
      "nvm install node",
      "npm install puppeteer",
      "export SITE_URL=https://${var.site_name}.freetls.fastly.net",
      "nohup bash -c 'while true; do node homepage.js && sleep `shuf -i 2-10 -n1`; done &'",
      "sleep 5 && nohup bash -c 'while true; do node promobutton.js && sleep `shuf -i 2-10 -n1`; done &'",
      "sleep 10 && nohup bash -c 'while true; do node shopper.js && sleep `shuf -i 2-10 -n1`; done &'",
    ]
  }
}