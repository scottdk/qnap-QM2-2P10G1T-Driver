obj-m += tehuti_qnap.o
tehuti_qnap-objs := tehuti_modified.o

KDIR := /lib/modules/$(shell uname -r)/build

all:
	make -C $(KDIR) M=$(PWD) modules

clean:
	make -C $(KDIR) M=$(PWD) clean

install:
	sudo rmmod tehuti_qnap 2>/dev/null || true
	sudo rmmod tehuti 2>/dev/null || true
	sudo insmod tehuti_qnap.ko
	echo "1fc9 4027" | sudo tee /sys/bus/pci/drivers/tehuti_qnap/new_id

.PHONY: all clean install