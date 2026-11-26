#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
DEBS_DIR="$REPO_DIR/debs"
PACKAGES_FILE="$REPO_DIR/Packages"
RELEASE_FILE="$REPO_DIR/Release"

# Start fresh
> "$PACKAGES_FILE"

for deb in "$DEBS_DIR"/*.deb; do
    [ -f "$deb" ] || continue

    debname=$(basename "$deb")
    size=$(stat -c%s "$deb" 2>/dev/null || stat -f%z "$deb" 2>/dev/null)
    md5=$(md5sum "$deb" 2>/dev/null | cut -d' ' -f1 || md5 -q "$deb" 2>/dev/null)
    sha1=$(sha1sum "$deb" 2>/dev/null | cut -d' ' -f1 || shasum -a 1 "$deb" 2>/dev/null | cut -d' ' -f1)
    sha256=$(sha256sum "$deb" 2>/dev/null | cut -d' ' -f1 || shasum -a 256 "$deb" 2>/dev/null | cut -d' ' -f1)

    # Extract control fields from the deb
    control=$(dpkg-deb -I "$deb" 2>/dev/null || true)

    get_field() {
        echo "$control" | awk -v f="$1: " '$0 ~ f {sub(f, ""); print}' | head -1
    }

    package=$(get_field "Package")
    name=$(get_field "Name")
    version=$(get_field "Version")
    arch=$(get_field "Architecture")
    maintainer=$(get_field "Maintainer")
    depends=$(get_field "Depends")
    section=$(get_field "Section")
    description=$(get_field "Description")

    cat >> "$PACKAGES_FILE" <<EOF
Package: $package
Name: $name
Version: $version
Architecture: $arch
Maintainer: $maintainer
Depends: $depends
Section: $section
Description: $description
Filename: debs/$debname
Size: $size
MD5sum: $md5
SHA1: $sha1
SHA256: $sha256

EOF
done

# Compress Packages
gzip -k -f "$PACKAGES_FILE"
bzip2 -k -f "$PACKAGES_FILE" 2>/dev/null || true

# Generate Release file
date=$(date -u "+%a, %d %b %Y %H:%M:%S %Z" 2>/dev/null || date -u)
cat > "$RELEASE_FILE" <<EOF
Origin: dungxrepo
Label: dungxrepo
Suite: stable
Version: 1.0
Codename: ios
Architectures: iphoneos-arm64
Components: main
Description: Sileo/Cydia package repository for dungxrepo
Acquire-By-Hash: yes
Date: $date
EOF

echo "Packages index generated at $PACKAGES_FILE"
echo "Release file generated at $RELEASE_FILE"
