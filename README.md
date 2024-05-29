# Key Generation Script for Android Build

This script automates the process of generating the necessary keys for building Android or LineageOS. The keys are used to sign the Android build.

## Script Overview

The script performs the following steps:

1. **Prompts the user for the build type**: AOSP or LineageOS (LOS).
2. **Prompts the user for the necessary certificate details**.
3. **Generates keys for the specified build type**.
4. **Moves the keys to the appropriate directory**.
5. **Sets up the keys for use in the build process**.

## Usage

### Running the Script

1. **Make the script executable**:
   ```sh
   Move the script to source root directory
   chmod +x generate_all_keys.sh
   ./generate_all_keys.sh
