# makefile for bootloader
boot.img: bootloader2.asm
	nasm -f bin -o boot.img bootloader2.asm
