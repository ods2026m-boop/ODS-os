#!/bin/bash

# License: Apache-2.0

set -e

# --- Configuration ---
ISO_INPUT="ODS-os-1.0.iso"
ISO_OUTPUT="ODS-os-1.0-new.iso"
VOLUME_LABEL="ODS-os-1.0"
WORK_DIR="debspin-work"
CHROOT_DIR="squash-edit"

echo "[+] Creating new filesystem.squashfs..."
sudo rm -f filesystem.squashfs
sudo mksquashfs $CHROOT_DIR filesystem.squashfs -comp xz -b 1M -noappend -no-xattrs

echo "[+] Copying to the live directory..."
sudo cp filesystem.squashfs $WORK_DIR/live/filesystem.squashfs

echo "[+] Updating filesystem size (filesystem.size)..."
sudo bash -c "du -sx --block-size=1 $WORK_DIR/live/filesystem.squashfs | cut -f1 > $WORK_DIR/live/filesystem.size"

echo "[+] Building final ISO with xorriso..."
sudo xorriso -as mkisofs \
  -r -V "$VOLUME_LABEL" \
  -o $ISO_OUTPUT \
  -J -joliet-long -l \
  -b isolinux/isolinux.bin \
  -c isolinux/boot.cat \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  $WORK_DIR/

echo "[!] Done! The file $ISO_OUTPUT is ready."
