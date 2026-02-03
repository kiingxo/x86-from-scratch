#!/bin/bash

echo "Building King OS..."

# Assemble bootloader
echo "Assembling bootloader..."
nasm -f bin boot_sect.asm -o boot_sect.bin

# Assemble kernel
echo "Assembling kernel..."
nasm -f bin kernel.asm -o kernel.bin

# Create disk image (512 bytes boot + 8 sectors kernel)
echo "Creating disk image..."
dd if=/dev/zero of=os.img bs=512 count=2880
dd if=boot_sect.bin of=os.img bs=512 count=1 conv=notrunc
dd if=kernel.bin of=os.img bs=512 seek=1 conv=notrunc

echo "Build complete!"
echo "Run: qemu-system-x86_64 -fda os.img"
