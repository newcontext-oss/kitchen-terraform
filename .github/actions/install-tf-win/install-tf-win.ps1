# Powershell

# install Terraform
$FILE1="terraform_${ENV:TERRAFORM_VERSION}_windows_amd64.zip"
$URL1="https://releases.hashicorp.com/terraform/${ENV:TERRAFORM_VERSION}"
$URL1="$URL1/$FILE1"

curl --remote-name --silent $URL1
$FOUNDSUM=$(certUtil -hashfile $FILE1 SHA256 | Select-String -Quiet ${ENV:TERRAFORM_SHASUM})
if ($False -eq $FOUNDSUM) {
   exit 1
}
# unzip $FILE1 -d "$HOME/bin"
Expand-Archive -Path "$FILE1" -DestinationPath "./"

# install TerraGrunt
$FILE2="terragrunt_windows_amd64.exe"
$URL2="https://github.com/gruntwork-io/terragrunt/releases/download/v0.26.4"
$URL2="$URL2/$FILE2"
$SHASUM2="0d7eb45ebce0f1f65f40ee01152f20f4c6fdf7bf1002ee22849ee366c508f0b3"

curl --location --remote-name --silent $URL2
# shasum -a 256 $FILE2 | grep $SHASUM2
$FOUNDSUM=$(certUtil -hashfile $FILE2 SHA256 | Select-String -Quiet $SHASUM2)
if ($False -eq $FOUNDSUM) {
   exit 1
}
# chmod +x $FILE2

# install TerraForm Provider
$FILE3="terraform-provider-local_1.4.0_windows_amd64.zip"
$URL3="https://releases.hashicorp.com/terraform-provider-local/1.4.0"
$URL3="$URL3/$FILE3"
$SHASUM3="2ea6d8c503a1119b80a273eacd187516347c00a54990c47d130235e2ad53d163"

$PLUGIN_DIR_PARENT='test/terraform/11/PlugIns'
$PLUGIN_DIR_END='PlugInDirectory'
# MAJOR_VERSION=$(echo $TERRAFORM_VERSION|sed 's/0\.\([0-9][0-9]*\)\.[0-9][0-9]*$/\1/')
$MAJOR_VERSION=$(Select-String -Input $ENV:TERRAFORM_VERSION "0\.([0-9]+)\.[0-9]+" | 
                 ForEach-Object { $_.Matches[0].Groups[1].Value })
if ("$MAJOR_VERSION" -ge 15) {
   $PLUGIN_DIR_PARENT="test/terraform/post-0-15-0/PlugIns/${PLUGIN_DIR_END}/registry.terraform.io/hashicorp/local/1.4.0/"
   $PLUGIN_DIR_END="windows_amd64"
} elseif ("$MAJOR_VERSION" -ge 13) {
  $PLUGIN_DIR_PARENT="${PLUGIN_DIR_PARENT}/${PLUGIN_DIR_END}/registry.terraform.io/hashicorp/local/1.4.0/"
  $PLUGIN_DIR_END="windows_amd64"
}
New-Item -Path "$PLUGIN_DIR_PARENT" -Name "$PLUGIN_DIR_END" -ItemType Directory
curl --remote-name --silent $URL3
$FOUNDSUM=$(certUtil -hashfile $FILE3 SHA256 | Select-String -Quiet $SHASUM3)
if ($False -eq $FOUNDSUM) {
   exit 1
}
unzip $FILE3 -d "${PLUGIN_DIR_PARENT}/${PLUGIN_DIR_END}"
