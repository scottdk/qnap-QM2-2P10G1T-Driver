#include <linux/module.h>
#include <linux/export-internal.h>
#include <linux/compiler.h>

MODULE_INFO(name, KBUILD_MODNAME);

__visible struct module __this_module
__section(".gnu.linkonce.this_module") = {
	.name = KBUILD_MODNAME,
	.init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
	.exit = cleanup_module,
#endif
	.arch = MODULE_ARCH_INIT,
};



static const struct modversion_info ____versions[]
__used __section("__versions") = {
	{ 0x122c3a7e, "_printk" },
	{ 0xf0fdf6cb, "__stack_chk_fail" },
	{ 0x782dd9c4, "__napi_schedule" },
	{ 0xa916b694, "strnlen" },
	{ 0xc6cbbc89, "capable" },
	{ 0x7cd8d75e, "page_offset_base" },
	{ 0x476b165a, "sized_strscpy" },
	{ 0x578b6071, "__dma_sync_single_for_cpu" },
	{ 0x92d5838e, "request_threaded_irq" },
	{ 0x1b2fa1a9, "vmalloc_noprof" },
	{ 0xbc3b728d, "dma_alloc_attrs" },
	{ 0xa6f68b0d, "pci_read_config_word" },
	{ 0x7c144d9e, "napi_enable" },
	{ 0x5ad3b867, "netif_receive_skb" },
	{ 0x7e208c17, "register_netdev" },
	{ 0xe124e80b, "free_netdev" },
	{ 0x4c9d28b0, "phys_base" },
	{ 0xde80cd09, "ioremap" },
	{ 0x6ee5fb3e, "ethtool_op_get_link" },
	{ 0x75ca79b5, "__fortify_panic" },
	{ 0xd35cce70, "_raw_spin_unlock_irqrestore" },
	{ 0x73bda4ec, "netif_tx_wake_queue" },
	{ 0x31dfb5ce, "pci_set_master" },
	{ 0x5b8239ca, "__x86_return_thunk" },
	{ 0x6b10bee1, "_copy_to_user" },
	{ 0x6e151b8a, "__netdev_alloc_skb" },
	{ 0x15ba50a6, "jiffies" },
	{ 0x48f4c0c9, "dma_set_coherent_mask" },
	{ 0x4885343e, "pv_ops" },
	{ 0x97651e6c, "vmemmap_base" },
	{ 0xfaa0a3c1, "dma_free_attrs" },
	{ 0x999e8297, "vfree" },
	{ 0x2ab14075, "pci_release_regions" },
	{ 0xeae3dfd6, "__const_udelay" },
	{ 0x56470118, "__warn_printk" },
	{ 0x8a386dc5, "netif_carrier_off" },
	{ 0xf30e5caf, "netif_carrier_on" },
	{ 0x91c03c45, "pci_disable_device" },
	{ 0xfe33309d, "dma_set_mask" },
	{ 0xee4084f6, "napi_schedule_prep" },
	{ 0x49c032a, "napi_disable" },
	{ 0xb5b54b34, "_raw_spin_unlock" },
	{ 0xd4ec10e6, "BUG_func" },
	{ 0x1b6e29ca, "netdev_info" },
	{ 0x99c91d5f, "alloc_etherdev_mqs" },
	{ 0xc1514a3b, "free_irq" },
	{ 0xc31db0ce, "is_vmalloc_addr" },
	{ 0xc6d09aa9, "release_firmware" },
	{ 0x13c49cc2, "_copy_from_user" },
	{ 0xd04dd275, "pci_enable_device" },
	{ 0x4a5b8a26, "skb_put" },
	{ 0xd73ba43c, "consume_skb" },
	{ 0xa6c77e2f, "netif_napi_add_weight" },
	{ 0x62ade952, "unregister_netdev" },
	{ 0x1d748233, "dma_unmap_page_attrs" },
	{ 0x483225a7, "request_firmware" },
	{ 0x7fe6d2cf, "__pci_register_driver" },
	{ 0xedc03953, "iounmap" },
	{ 0x499e2859, "pci_request_regions" },
	{ 0x69acdf38, "memcpy" },
	{ 0x67c383e9, "eth_validate_addr" },
	{ 0x25837ddb, "dev_kfree_skb_irq_reason" },
	{ 0xba8fbd64, "_raw_spin_lock" },
	{ 0xf109b761, "pci_unregister_driver" },
	{ 0x88c399ec, "netdev_err" },
	{ 0xbdfb6dbb, "__fentry__" },
	{ 0xbf7088e3, "dev_driver_string" },
	{ 0xe2de1a78, "dev_addr_mod" },
	{ 0xc36f75d3, "eth_type_trans" },
	{ 0x70fec1ed, "dma_map_page_attrs" },
	{ 0x420ac979, "napi_complete_done" },
	{ 0xd91dd160, "module_layout" },
};

MODULE_INFO(depends, "");

MODULE_ALIAS("pci:v00001FC9d00003009sv*sd*bc*sc*i*");
MODULE_ALIAS("pci:v00001FC9d00003010sv*sd*bc*sc*i*");
MODULE_ALIAS("pci:v00001FC9d00003014sv*sd*bc*sc*i*");
MODULE_ALIAS("pci:v00001FC9d00004027sv*sd*bc*sc*i*");
