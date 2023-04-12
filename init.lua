local S = minetest.get_translator("testcoin")

local sha = dofile(minetest.get_modpath("testcoin") .. "/lib/sha/sha2.lua")

-- Make the library module available to your mod
minetest.log("Hello Hash:" .. sha.sha256("Hello Hash"))

testcoin = {}
testcoin.miner_position = {}
testcoin.chain = {}
testcoin.get_translator = S
testcoin.wallet_formspec = "size[10.5,11]" ..
    "no_prepend[]" ..
    "label[0.2,0.4;TestCoin Core v0.0.1"
