KDIR = /lib/modules/$(shell uname -r)/build

obj-m += ip_vs_mh.o

ip_vs_mh.ko: ip_vs_mh.c
	make -C $(KDIR) M=$(PWD) modules
