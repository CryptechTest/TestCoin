local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
local S = core.get_translator(modname)
testcoin = {}
testcoin.ver = '0.0.1'
testcoin.miner_position = {}
testcoin.get_translator = S
dofile(modpath .. "/functions.lua")
dofile(modpath .. "/items.lua")
dofile(modpath .. "/digilines.lua")
dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/crafting.lua")
dofile(modpath .. "/ui.lua")

core.register_on_joinplayer(function(player, last_login)
    local inv = player:get_inventory()
    if not inv:set_size("testcoin", 4096) then
        core.log("warning", "Failed to set inventory size")
    end
    inv = player:get_inventory()
    if not inv:set_size("testcoin_buffer", 6) then
        core.log("Failed to create buffer inv")
    end
end)


local loot = {
    { name = 'testcoin:coin', chance = 0.1, count = { 1, 4 },  y = { 128, -3333 } },
    { name = 'testcoin:coin', chance = 0.1, count = { 2, 8 },  y = { -3334, -6666 } },
    { name = 'testcoin:coin', chance = 0.1, count = { 4, 16 }, y = { -6667, -9999 } },
    { name = 'testcoin:coin', chance = 0.1, count = { 8, 32 }, y = { -10000, -11000 } },
}

dungeon_loot.register(loot)
