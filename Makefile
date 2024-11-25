
.PHONY: qemu clean
qemu:
	make -C src qemu

clean:
	make -C src clean