#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/kallsyms.h>
#include <linux/version.h>

#define DRIVER_AUTHOR "alexj"
#define DRIVER_DESCRIPTION "SELinux mode changer to allow loading MultiRecovery"
#define DRIVER_VERSION "0.1"

typedef bool (*selinux_is_enabled_t)(void);

unsigned long* selinux_enabled = NULL;
unsigned long* selinux_enforcing = NULL;

unsigned long status_enabled;
unsigned long status_enforcing;


static int __init selinux_mod_init(void)
{

	selinux_is_enabled_t selinux_is_enabled = (selinux_is_enabled_t)kallsyms_lookup_name("selinux_is_enabled");

	printk(KERN_INFO "[%s] module loaded\n", __this_module.name);

	if(!selinux_is_enabled)
	{
		printk(KERN_INFO "[%s] Failed to find selinux_is_enabled\n", __this_module.name);
		return 1;
	}

	status_enabled = selinux_is_enabled();
	printk(KERN_INFO "[%s] old selinux_enabled: %lu\n", __this_module.name,  status_enabled);

	selinux_enabled = (unsigned long*)kallsyms_lookup_name("selinux_enabled");
	if(!selinux_enabled)
	{
		printk(KERN_INFO "[%s] Failed to find selinux_enabled address\n", __this_module.name);
		return 1;

	}

	*selinux_enabled = 0U;
	printk(KERN_INFO "[%s] current selinux_enabled: %u\n", __this_module.name,  selinux_is_enabled());

	selinux_enforcing = (unsigned long*)kallsyms_lookup_name("selinux_enforcing");
	if(!selinux_enforcing )
	{
		printk(KERN_INFO "[%s] Failed to find selinux_enforcing address\n", __this_module.name);
		return 1;
	}

	status_enforcing = *selinux_enforcing;
	printk(KERN_INFO "[%s] old selinux_enforcing: %lu\n", __this_module.name, status_enforcing);

	*selinux_enforcing = 0U;
	printk(KERN_INFO "[%s] current selinux_enforcing: %lu\n", __this_module.name, *selinux_enforcing);

	return 0;
}

static void __exit selinux_mod_exit(void)
{
	if(selinux_enabled)
		*selinux_enabled = status_enabled;

	if(selinux_enforcing)
		*selinux_enforcing = status_enforcing;

	printk(KERN_INFO "[%s] module unloaded\n" , __this_module.name);

}

module_init(selinux_mod_init)
module_exit(selinux_mod_exit);

MODULE_AUTHOR(DRIVER_AUTHOR);
MODULE_DESCRIPTION(DRIVER_DESCRIPTION);
MODULE_VERSION(DRIVER_VERSION);
MODULE_LICENSE("GPL");

