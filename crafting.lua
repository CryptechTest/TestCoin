local coin = "testcoin:coin"
local mining_rig = "testcoin:lv_mining_rig"
local pow_miner = "testcoin:pow_miner"
local asic_miner = "testcoin:asic_miner"
local rig_part = "testcoin:rig_part"
local asic_chip = "testcoin:asic_chip"

local lv_air_fan = "ctg_airs:lv_air_fan"

local lua_controller = "mesecons_luacontroller:luacontroller0000"

local machine_casing = "technic:machine_casing"
local lv_cable = "technic:lv_cable"

local digimese = "digistuff:digimese"
local gpu = "digistuff:gpu"
local ram = "digistuff:ram"
local heatsink = "digistuff:heatsink"

local rtc = "digilines:rtc"

local circuit = "ship_parts:circuit_standard"
local acircuit = "ship_parts:circuit_advanced"
local fpga = "mesecons_fpga:fpga0000"

minetest.register_craft({
    output = rig_part,
    recipe = {
        { coin, coin,           coin },
        { coin, machine_casing, coin },
        { coin, coin,           coin },
    }
})

minetest.register_craft({
    output = mining_rig,
    recipe = {
        { rig_part, rig_part, rig_part },
        { rig_part, lv_cable, rig_part },
        { rig_part, rig_part, rig_part },
    }
})

minetest.register_craft({
    output = pow_miner,
    recipe = {
        { heatsink, heatsink,       heatsink },
        { ram,      lua_controller, gpu },
        { acircuit, rtc,            acircuit },
    }
})

minetest.register_craft({
    output = asic_chip,
    recipe = {
        { fpga,     heatsink,       fpga },
        { acircuit, lua_controller, acircuit },
        { fpga,     coin,           fpga },
    }
})

minetest.register_craft({
    output = asic_miner,
    recipe = {
        { circuit,  lv_air_fan, circuit },
        { ram,      asic_chip,  gpu },
        { digimese, lv_air_fan, digimese },
    }
})
