local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
local sha = dofile(modpath .. "/lib/sha/sha2.lua")

local world_path = core.get_worldpath()
local file = world_path .. "/testcoin/chain_data.json"

testcoin.blocks = {}

-- seed: bf532cd7b4a9af3c00cc02c54943f7a1659c5fb7906f2776b691604d603fa6bc
testcoin.vtx_coinbase = {
    hash = "00000031a3177ebd6f1e348126c87762c7e991590d52cd3d9a47df220289304d",
    ref = "00000031a3170000000000000000000000000000000000000000000000000000"
}

function testcoin.save_chain()
    local output = io.open(file, "w")
    output:write(core.write_json(testcoin.blocks))
    io.close(output);
end

function testcoin.read_chain()
    local input = io.open(file, "r")
    if input then
        testcoin.blocks = core.parse_json(input:read("*all"))
        input:close()
    else
        testcoin.add_block()
    end
end

function testcoin.add_block(data)
    local block = {
        prev_block = testcoin.chain_tip.hash,
        data = data,
        time = os.date()
    }
    local block_str = core.write_json(block)
    local hash = sha.sha256(block_str)
    local block_data = {
        block = block,
        hash = hash
    }
    table.insert(testcoin.blocks, block_data)
    testcoin.save_chain();
    local height = #testcoin.blocks
    testcoin.chain_tip.hash = hash
    testcoin.chain_tip.height = height
    testcoin.chain_tip.prev = block.prev_block
    testcoin.chain_tip.timestamp = block.time
    return hash, height
end

------------------------------------------------

local function load_chain()
    testcoin.read_chain()
	core.log("Loaded chain from file with height '" .. testcoin.chain_tip.height .. "' at hash 0x" .. testcoin.chain_tip.hash)
end

load_chain();
