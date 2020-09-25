variable "do_token" {}
variable "base_domain" {}

terraform {
  backend "http" {}
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
  required_version = ">= 0.13"
}

provider "digitalocean" {
    token = var.do_token
}

data "digitalocean_ssh_key" "default" {
  name = "default"
}

data "digitalocean_domain" "default" {
  name = var.base_domain
}

resource "digitalocean_droplet" "example" {
  image    = "debian-10-x64"
  name     = "foo-bar"
  region   = "fra1"
  size     = "s-1vcpu-1gb"
  ssh_keys = [
    data.digitalocean_ssh_key.default.fingerprint
  ]
}

resource "digitalocean_droplet" "foo" {
  image    = "debian-10-x64"
  name     = "foo"
  region   = "fra1"
  size     = "s-1vcpu-1gb"
  ssh_keys = [
    data.digitalocean_ssh_key.default.fingerprint
  ]
}

resource "digitalocean_record" "example" {
  domain = data.digitalocean_domain.default.name
  type   = "A"
  name   = digitalocean_droplet.example.name
  value  = digitalocean_droplet.example.ipv4_address
}

resource "digitalocean_record" "foo" {
  domain = data.digitalocean_domain.default.name
  type   = "A"
  name   = digitalocean_droplet.foo.name
  value  = digitalocean_droplet.foo.ipv4_address
}

output "domain" {
  value = digitalocean_record.example.fqdn
}


output "domain_foo" {
  value = digitalocean_record.foo.fqdn
}