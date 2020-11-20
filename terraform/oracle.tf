provider "oci" {
  tenancy_ocid = var.tenancy
  user_ocid = var.user
  fingerprint = var.fingerprint
  private_key_path = var.keypath
  region = "us-phoenix-1"
}

resource "oci_core_instance" "test_instance" {
  availability_domain = "yuqr:PHX-AD-1"
  shape = "VM.Standard.E2.1.Micro"
  compartment_id = var.tenancy
  create_vnic_details {
      subnet_id = var.subnetid
      hostname_label = var.hostname
  }
  display_name = var.displayname
  metadata = {
      ssh_authorized_keys = file(var.sshkeyfile)
  }
  source_details {
      source_type = "image"
      source_id = "ocid1.image.oc1.phx.aaaaaaaaky4luenz7yvuzz26zipiun6dzbkm7hkon7tppynpm2l6p32aen7a"
  }

}