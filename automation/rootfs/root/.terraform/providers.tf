terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.60.0"
    }
    boundary = {
      source = "hashicorp/boundary"
      version = "1.1.4"
    }
    consul = {
      source = "hashicorp/consul"
      version = "2.17.0"
    }
    vault = {
      source = "hashicorp/vault"
      version = "3.14.0"
    }
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "15.10.0"
    }
    rabbitmq = {
      source = "cyrilgdn/rabbitmq"
      version = "1.8.0"
    }
  }
}
