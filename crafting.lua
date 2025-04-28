local coin = "testcoin:coin"
local mining_rig_lv = "testcoin:lv_mining_rig"
local mining_rig_mv = "testcoin:mv_mining_rig"
local mining_rig_hv = "testcoin:hv_mining_rig"
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

local nick = "ctg_world:nickel_ingot"
local tita = "ctg_world:titanium_ingot"
local hidum = "ctg_world:hiduminium_stock"

local lv_tr = "technic:lv_transformer"
local mv_tr = "technic:mv_transformer"
local hv_tr = "technic:hv_transformer"

core.register_craft({
    output = rig_part,
    recipe = {
        { coin, coin,           coin },
        { coin, machine_casing, coin },
        { coin, coin,           coin },
    }
})

core.register_craft({
    output = mining_rig_lv,
    recipe = {
        { rig_part, nick, rig_part },
        { rig_part, lv_cable, rig_part },
        { rig_part, lv_tr, rig_part },
    }
})

core.register_craft({
    output = mining_rig_mv,
    recipe = {
        { rig_part, tita, rig_part },
        { rig_part, mining_rig_lv, rig_part },
        { rig_part, mv_tr, rig_part },
    }
})

core.register_craft({
    output = mining_rig_hv,
    recipe = {
        { rig_part, rig_part, rig_part },
        { hidum, mining_rig_mv, hidum },
        { rig_part, hv_tr, rig_part },
    }
})

core.register_craft({
    output = pow_miner,
    recipe = {
        { heatsink, digimese,       heatsink },
        { ram,      lua_controller, gpu },
        { acircuit, rtc,            acircuit },
    }
})

core.register_craft({
    output = asic_chip,
    recipe = {
        { fpga,     heatsink,       fpga },
        { acircuit, lua_controller, acircuit },
        { fpga,     coin,           fpga },
    }
})

core.register_craft({
    output = asic_miner,
    recipe = {
        { circuit,  lv_air_fan, circuit },
        { ram,      asic_chip,  gpu },
        { digimese, lv_air_fan, digimese },
    }
})
