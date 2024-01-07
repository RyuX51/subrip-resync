#!/bin/sh

# Check if the build configuration is set to Release
if [ "${CONFIGURATION}" != "Release" ]; then
  exit
fi

# This script is designed to increment the build number consistently across all
# targets.

# Navigating to the project directory inside the source root.
cd "$SRCROOT/$PRODUCT_NAME"

# Get the current date in the format "YYYYMMDD".
current_date=$(date "+%Y%m%d")

# Parse the 'Config.xcconfig' file to retrieve the previous build number. 
# The 'awk' command is used to find the line containing "BUILD_NUMBER"
# and the 'tr' command is used to remove any spaces.
previous_build_number=$(awk -F "=" '/BUILD_NUMBER/ {print $2}' Config.xcconfig | tr -d ' ')

# Extract the date part and the counter part from the previous build number.
# Assuming the previous build number format was "YYYYMMDDCOUNTER" without a dot.
previous_date="${previous_build_number:0:8}"
counter="${previous_build_number:9}"  # Adjust the index to skip the dot.

# If the current date matches the date from the previous build number, 
# increment the counter. Otherwise, reset the counter to 1.
new_counter=$((current_date == previous_date ? counter + 1 : 1))

# Combine the current date and the new counter to create the new build number,
# adding a dot between the date and the counter.
new_build_number="${current_date}.${new_counter}"

# Use 'sed' command to replace the previous build number with the new build 
# number in the 'Config.xcconfig' file.
sed -i -e "/BUILD_NUMBER =/ s/= .*/= $new_build_number/" Config.xcconfig

# Remove the backup file created by 'sed' command.
rm -f Config.xcconfig-e
