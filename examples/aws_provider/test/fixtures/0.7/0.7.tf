module "example" {
  source = "../../../"

  access_key          = "${var.access_key}"
  public_key_pathname = "${var.public_key_pathname}"
  region              = "${var.region}"
  secret_key          = "${var.secret_key}"
}
