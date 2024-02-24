# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {

  cloud {
    organization = "KingstonLtd"

    workspaces {
      name = "wsp1"
    }
  }


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.43"
    }
  }

  required_version = "~> 1.2"
}