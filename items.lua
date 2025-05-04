core.register_craftitem("testcoin:coin", {
    description = "TestCoin",
    inventory_image = "testcoin_coin.png",
    wield_scale = {
        x = 0.3,
        y = 0.3,
        z = 0.3
    },
    stack_max = 10000
})

core.register_craftitem("testcoin:asic_chip", {
    description = "ASIC Chip",
    stack_max = 32,
    inventory_image = "testcoin_asic_chip.png"
})

core.register_craftitem("testcoin:rig_part", {
    description = "Mining Rig Part",
    inventory_image = "testcoin_rig_part.png"
})

core.register_craftitem("testcoin:chip", {
    description = "Mining Chip Blue",
    stack_max = 32,
    inventory_image = "testcoin_chip.png"
})

core.register_craftitem("testcoin:chip_green", {
    description = "Mining Chip Green",
    stack_max = 32,
    inventory_image = "testcoin_chip_green.png"
})

core.register_craftitem("testcoin:chip_red", {
    description = "Mining Chip Red",
    stack_max = 32,
    inventory_image = "testcoin_chip_red.png"
})

core.register_craftitem("testcoin:control_logic_unit_adv", {
    description = "Advanced Control Logic Unit",
    stack_max = 8,
    inventory_image = "testcoin_control_logic_unit_adv.png",
    wield_scale = {
        x = 0.6,
        y = 0.6,
        z = 0.6
    }
})

core.register_node("testcoin:pow_miner", {
    description = "PoW Miner",
    stack_max = 1,
    inventory_image = "testcoin_pow_miner.png",
    wield_scale = {
        x = 0.5,
        y = 0.5,
        z = 0.5
    },
    tiles = {"testcoin_pow_miner_top.png", "testcoin_pow_miner_bottom.png", "testcoin_pow_miner_left.png",
             "testcoin_pow_miner_right.png", "testcoin_pow_miner_back.png", "testcoin_pow_miner_front.png"},
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    wield_image = "testcoin_pow_miner.png",
    sunlight_propagates = true,
    node_box = {
		type = "fixed",
		fixed = {
			{-0.0625, -0.5, -0.125, 0.0625, -0.25, 0.125},
		}
	},
    groups = {
        cracky = 1,
        oddly_breakable_by_hand = 1,
        asic = 1
    },
    sounds = default.node_sound_metal_defaults()
})

core.register_node("testcoin:pow_miner_broke", {
    description = "Broken PoW Miner",
    stack_max = 1,
    inventory_image = "testcoin_pow_miner_broken.png",
    wield_scale = {
        x = 0.5,
        y = 0.5,
        z = 0.5
    },
    tiles = {"testcoin_pow_miner_broken_top.png", "testcoin_pow_miner_broken_bottom.png", "testcoin_pow_miner_broken_left.png",
             "testcoin_pow_miner_broken_right.png", "testcoin_pow_miner_broken_back.png", "testcoin_pow_miner_broken_front.png"},
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    wield_image = "testcoin_pow_miner_broken.png",
    sunlight_propagates = true,
    node_box = {
		type = "fixed",
		fixed = {
			{-0.0625, -0.5, -0.125, 0.0625, -0.25, 0.125},
		}
	},
    groups = {
        cracky = 1,
        oddly_breakable_by_hand = 1,
        asic = 1,
        asic_broken = 1,
        not_in_creative_inventory = 1
    },
    sounds = default.node_sound_metal_defaults()
})

core.register_node("testcoin:asic_miner", {
    description = "ASIC Miner",
    stack_max = 1,
    inventory_image = "testcoin_asic_miner.png",
    wield_scale = {
        x = 0.5,
        y = 0.5,
        z = 0.5
    },
    tiles = {"testcoin_asic_miner_top.png", "testcoin_asic_miner_bottom.png", "testcoin_asic_miner_left.png",
             "testcoin_asic_miner_right.png", "testcoin_asic_miner_back.png", "testcoin_asic_miner_front.png"},
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    wield_image = "testcoin_asic_miner.png",
    sunlight_propagates = true,
    node_box = {
		type = "fixed",
		fixed = {
			{-0.0625, -0.5, -0.125, 0.0625, -0.25, 0.125},
		}
	},
    groups = {
        cracky = 1,
        oddly_breakable_by_hand = 1,
        asic = 2
    },
    sounds = default.node_sound_metal_defaults()
})

core.register_node("testcoin:asic_miner_broke", {
    description = "Broken ASIC Miner",
    stack_max = 1,
    inventory_image = "testcoin_asic_miner_broken.png",
    wield_scale = {
        x = 0.5,
        y = 0.5,
        z = 0.5
    },
    tiles = {"testcoin_asic_miner_broken_top.png", "testcoin_asic_miner_broken_bottom.png", "testcoin_asic_miner_broken_left.png",
             "testcoin_asic_miner_broken_right.png", "testcoin_asic_miner_broken_back.png", "testcoin_asic_miner_broken_front.png"},
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    wield_image = "testcoin_asic_miner_broken.png",
    sunlight_propagates = true,
    node_box = {
		type = "fixed",
		fixed = {
			{-0.0625, -0.5, -0.125, 0.0625, -0.25, 0.125},
		}
	},
    groups = {
        cracky = 1,
        oddly_breakable_by_hand = 1,
        asic = 2,
        asic_broken = 2,
        not_in_creative_inventory = 1
    },
    sounds = default.node_sound_metal_defaults()
})
