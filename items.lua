minetest.register_craftitem("testcoin:coin", {
    description = "TestCoin",
    inventory_image = "testcoin_coin.png",
    wield_scale = { x = 0.3, y = 0.3, z = 0.3 },
    stack_max = 10000,
})

minetest.register_craftitem("testcoin:asic_chip", {
    description = "ASIC Chip",
    inventory_image = "testcoin_asic_chip.png",
})

minetest.register_craftitem("testcoin:rig_part", {
    description = "Mining Rig Part",
    inventory_image = "testcoin_rig_part.png",
})


minetest.register_craftitem("testcoin:pow_miner", {
    description = "PoW Miner",
    inventory_image = "testcoin_pow_miner.png",
    stack_max = 1,
})


minetest.register_craftitem("testcoin:asic_miner", {
    description = "ASIC Miner",
    inventory_image = "testcoin_asic_miner.png",
    stack_max = 1,
})
