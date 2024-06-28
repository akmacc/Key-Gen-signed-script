#!/bin/bash

# Ensure the script is being run from the root of the Android build tree
if [[ ! -f "build/envsetup.sh" ]]; then
    echo "Error: This script must be run from the root of the Android build tree."
    exit 1
fi

# Source the environment
. build/envsetup.sh

# Prompt user for build type
echo "Please select the build type:"
echo "1. AOSP"
echo "2. LineageOS (LOS)"
read -p "Enter the build type (1 or 2): " build_type

# Check build type and create directory accordingly
if [[ $build_type == "1" ]]; then
    mkdir -p vendor/extra
    destination_dir="vendor/extra"
elif [[ $build_type == "2" ]]; then
    mkdir -p vendor/lineage-priv
    destination_dir="vendor/lineage-priv"
else
    echo "Invalid build type. Exiting."
    exit 1
fi

# Delete directory if it already exists
rm -rf ~/.android-certs

# Prompt user for subject information
echo "Please enter the following details:"
read -p "Country Shortform (C): " C
read -p "Country Longform (ST): " ST
read -p "Location (L): " L
read -p "Organization (O): " O
read -p "Organizational Unit (OU): " OU
read -p "Common Name (CN): " CN
read -p "Email Address (emailAddress): " emailAddress

# Construct subject string
subject="/C=$C/ST=$ST/L=$L/O=$O/OU=$OU/CN=$CN/emailAddress=$emailAddress"

# Create directory for certificates
mkdir -p ~/.android-certs

# Generate keys
mkdir ~/.android-certs

for x in releasekey platform shared media networkstack testkey bluetooth sdk_sandbox verifiedboot nfc; do \
    ./development/tools/make_key ~/.android-certs/$x "$subject"; \
done

# Ensure the destination keys directory exists
mkdir -p "$destination_dir/keys"

# Move the keys to the destination directory
mv ~/.android-certs/* "$destination_dir/keys"

# Create keys.mk

if [[ $build_type == "1" ]]; then
echo "PRODUCT_DEFAULT_DEV_CERTIFICATE := $destination_dir/keys/releasekey" > "$destination_dir/product.mk"
fi

if [[ $build_type == "2" ]]; then
echo "PRODUCT_DEFAULT_DEV_CERTIFICATE := $destination_dir/keys/releasekey" > "$destination_dir/keys/keys.mk"
fi

# Create BUILD.bazel for LineageOS
if [[ $build_type == "2" ]]; then
    cat <<EOF > "$destination_dir/keys/BUILD.bazel"
filegroup(
    name = "android_certificate_directory",
    srcs = glob([
        "*.pk8",
        "*.pem",
    ]),
    visibility = ["//visibility:public"],
)
EOF
fi

# Ensure correct file permissions
chmod -R 755 "$destination_dir/keys"

echo "Key generation and setup completed successfully."

