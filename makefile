# makefile for bootloader
bootloader.img: bootloader.asm
	nasm -f bin -o bootloader.img bootloader.asm
