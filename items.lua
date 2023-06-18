minetest.register_craftitem("testcoin:coin", {
    description = "TestCoin",
    inventory_image = "testcoin_coin.png",
    wield_scale = {
        x = 0.3,
        y = 0.3,
        z = 0.3
    },
    stack_max = 10000
})

minetest.register_craftitem("testcoin:asic_chip", {
    description = "ASIC Chip",
    inventory_image = "testcoin_asic_chip.png"
})

minetest.register_craftitem("testcoin:rig_part", {
    description = "Mining Rig Part",
    inventory_image = "testcoin_rig_part.png"
})

--[[minetest.register_craftitem("testcoin:pow_miner", {
    description = "PoW Miner",
    inventory_image = "testcoin_pow_miner.png",
    stack_max = 1,
    
})--]]

minetest.register_node("testcoin:pow_miner", {
    description = "PoW Miner",
    stack_max = 1,
    inventory_image = "testcoin_pow_miner.png",
    tiles = {"testcoin_pow_miner_top.png", "testcoin_pow_miner_top.png", "testcoin_pow_miner_side.png",
             "testcoin_pow_miner_side.png", "testcoin_pow_miner_back.png", "testcoin_pow_miner_front.png"},
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    sunlight_propagates = true,
    node_box = {
        type = "fixed",
        fixed = {{-0.4375, -0.5, -0.5, 0.0625, 0.5, 0.5} -- NodeBox1
        }
    },
    groups = {
        cracky = 1,
        oddly_breakable_by_hand = 1,
        asic = 1
    },
    sounds = default.node_sound_metal_defaults()
})

--[[minetest.register_craftitem("testcoin:asic_miner", {
    description = "ASIC Miner",
    inventory_image = "testcoin_asic_miner.png",
    stack_max = 1,
})--]]

minetest.register_node("testcoin:asic_miner", {
    description = "ASIC Miner",
    stack_max = 1,
    inventory_image = "testcoin_asic_miner.png",
    tiles = {"testcoin_asic_miner_top.png", "testcoin_asic_miner_top.png", "testcoin_asic_miner_left.png",
             "testcoin_asic_miner_right.png", "testcoin_asic_miner_back.png", "testcoin_asic_miner_front.png"},
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    sunlight_propagates = true,
    node_box = {
        type = "fixed",
        fixed = {{-0.4375, -0.5, -0.5, 0.0625, 0.5, 0.5} -- NodeBox1
        }
    },
    groups = {
        cracky = 1,
        oddly_breakable_by_hand = 1,
        asic = 2
    },
    sounds = default.node_sound_metal_defaults()
})
