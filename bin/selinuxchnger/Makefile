KERNEL_BUILD := /home/alex/kernel/sony/eagle
KERNEL_CROSS_COMPILE := /usr/local/share/arm-eabi-4.7/bin/arm-eabi-

obj-m += selinux_mod.o

all:
	$(MAKE) ARCH=arm -C $(KERNEL_BUILD) CROSS_COMPILE=$(KERNEL_CROSS_COMPILE) M=$(PWD) modules

clean:
	$(MAKE) ARCH=arm -C $(KERNEL_BUILD) M=$(PWD) clean 2> /dev/null
	rm -f modules.order *~
