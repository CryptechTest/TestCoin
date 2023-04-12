local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

dofile(modpath .. "/chain.lua")
testcoin = {}
testcoin.miner_position = {}
testcoin.chain = {}
testcoin.get_translator = S
testcoin.wallet_formspec = "size[10.5,11]" ..
    "no_prepend[]" ..
    "label[0.2,0.4;TestCoin Core v0.0.1"
