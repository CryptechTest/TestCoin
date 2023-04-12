local S = minetest.get_translator("testcoin")

testcoin = {}
testcoin.miner_position = {}
testcoin.chain = {}
testcoin.get_translator = S
testcoin.wallet_formspec = "size[10.5,11]" ..
    "no_prepend[]" ..
    "label[0.2,0.4;TestCoin Core v0.0.1"
