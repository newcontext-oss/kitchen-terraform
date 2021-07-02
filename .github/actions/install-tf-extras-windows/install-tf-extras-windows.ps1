# Powershell

# install TerraForm Provider
$FILE="terraform-provider-local_1.4.0_windows_amd64.zip"
$URL="https://releases.hashicorp.com/terraform-provider-local/1.4.0/$FILE"
$SHASUM="2ea6d8c503a1119b80a273eacd187516347c00a54990c47d130235e2ad53d163"

New-Item -Path "$PLUGIN_DIRECTORY" -ItemType Directory
curl --remote-name --silent $URL
$FOUNDSUM=$(certUtil -hashfile $FILE SHA256 | Select-String -Quiet $SHASUM)
if ($False -eq $FOUNDSUM) {
   exit 1
}
unzip $FILE -d "${PLUGIN_DIRECTORY}"
