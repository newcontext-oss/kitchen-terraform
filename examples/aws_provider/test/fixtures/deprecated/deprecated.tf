module "example" {
  source = "../../../"

  public_key_pathname = "${var.public_key_pathname}"
  region              = "${var.region}"
}
