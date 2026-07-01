# makefile for bootloader
bootloader.img: stage1.bin stage2.bin
	cat stage1.bin stage2.bin > bootloader.img && truncate -s 1440K bootloader.img
stage1.bin: boot-stage1.asm
	nasm -f bin -o stage1.bin boot-stage1.asm
stage2.bin: stage2.asm
	nasm -f bin -o stage2.bin stage2.asm
clean:
	rm -rf *.bin *.img
