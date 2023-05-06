local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)
local datadir = minetest.get_worldpath() .. "/testcoin"
local chain_data = datadir .. "/chain.json"
local sha = dofile(modpath .. "/lib/sha/sha2.lua")

testcoin = {}

testcoin.miner_position = {}
testcoin.get_translator = S
testcoin.wallet_formspec = "size[10.5,11]" ..
    "no_prepend[]" ..
    "label[0.2,0.4;TestCoin Core v0.0.1"



testcoin.sha256 = sha.sha256

local function to_hex(str)
    local hex = ""
    for i = 1, #str do
        hex = hex .. string.format("%02x", str:byte(i))
    end
    return hex
end

local function from_hex(hex)
    local str = ""
    for i = 1, #hex, 2 do
        local char = tonumber(hex:sub(i, i + 1), 16)
        str = str .. string.char(char)
    end
    return str
end

local chain = {}

local function get_miner()
    return nil
end

local function get_staker()
    local staker = nil
    local stakers = {}
    local total_balance = 0
    for _, player in ipairs(minetest.get_connected_players()) do
        local inv = player:get_inventory()
        if inv then
            local coins = inv:get_list("testcoin")
            if #coins > 0 then
                local balance = 0
                for _, coin in ipairs(coins) do
                    if coin ~= nil and not coin:is_empty() then
                        balance = balance + coin:get_count()
                    end
                end
                if balance > 0 then
                    stakers[#stakers + 1] = { staker = player:get_player_name(), balance = balance }
                    total_balance = total_balance + balance
                end
            end
        end
    end
    if #stakers > 0 and total_balance > 0 then
        local n = #stakers
        while n > 1 do
            local k = math.random(n)
            stakers[n], stakers[k] = stakers[k], stakers[n]
            n = n - 1
        end
        local seed = math.floor(math.random() * 1000000) % 4294967296
        local rng = PcgRandom(seed)
        local random_value = rng:next(0, total_balance - 1)
        local current_balance = 0

        for _, staker_info in ipairs(stakers) do
            current_balance = current_balance + staker_info.balance
            if current_balance > random_value then
                staker = staker_info
                break
            end
        end
    end
    return staker
end

testcoin = {}
testcoin.get_block = function(index)
    return chain[index] or nil
end
testcoin.deserialize_block = function(data)
    local block = {}
    if data and #data > 0 then
        local parts = {}
        for part in data:gmatch("([^,]+)") do
            table.insert(parts, part)
        end
        if #parts[1] > 1 and #parts[1] % 2 == 0 then
            block.data = parts[1]
        else
            block.data = ""
        end
        block.hash = parts[2] or "0000000000000000000000000000000000000000000000000000000000000000"
        block.index = tonumber(parts[3])
        block.previousHash = parts[4]
        block.timestamp = tonumber(parts[5])
        block.transactions = testcoin.deserialize_transactions(parts[6])
    end

    return block
end

testcoin.deserialize_transaction = function(data)
    if data and #data > 0 then
        local parts = {}
        for part in data:gmatch("([^:]+)") do
            table.insert(parts, part)
        end

        if #parts == 2 then
            local participants = {}
            for participant in parts[1]:gmatch("([^%->]+)") do
                table.insert(participants, participant)
            end

            if #participants == 2 then
                local recipient = participants[2]:gsub(":(%d+)$", "")
                return {
                    from = participants[1],
                    to = recipient,
                    amount = math.floor(tonumber(parts[2])),
                }
            end
        end
    end


    return nil
end

testcoin.deserialize_transactions = function(data)
    local transactions = {}
    if data and #data > 0 then
        local parts = {}
        for part in data:gmatch("([^;]+)") do
            table.insert(parts, part)
        end
        for i, tx in ipairs(parts) do
            local transaction = testcoin.deserialize_transaction(tx)
            if transaction then
                transactions[i] = transaction
            end
        end
    end

    return transactions
end



testcoin.serialize_block = function(block)
    local s = ""

    s = s .. block.data .. ","
    s = s .. (block.hash or "0000000000000000000000000000000000000000000000000000000000000000") .. ","
    s = s .. block.index .. ","
    s = s .. block.previousHash .. ","
    s = s .. block.timestamp .. ","
    s = s .. testcoin.serialize_transactions(block.transactions) .. ","

    return s
end


testcoin.serialize_transaction = function(tx)
    local s = tx.from .. "->" .. tx.to .. ":" .. tx.amount .. ";"
    return s
end

testcoin.serialize_transactions = function(transactions)
    local s = ""

    for _, tx in ipairs(transactions) do
        s = s .. testcoin.serialize_transaction(tx)
    end

    return s
end



-- Load the blockchain data from file when the server starts
minetest.register_on_mods_loaded(function()
    minetest.mkdir(datadir)
    chain = testcoin.load_chain()
    if #chain == 0 then
        -- add the genesis block
        chain[1] = {
            index = math.floor(1),
            timestamp = math.floor(os.time()),
            transactions = {},
            previousHash = "0000000000000000000000000000000000000000000000000000000000000000",
            data = to_hex(
                "Test Coin is the unofficial official fake blockchain and cryptocurrency of Minetest. Unlike real cryptocurrencies, Test Coin has no value in the real world, but in Minetest, it's the hottest thing since lava."),
            hash = testcoin.sha256(to_hex(
                testcoin.serialize_block({
                    index = math.floor(1),
                    timestamp = math.floor(os.time()),
                    transactions = {},
                    previousHash = "0000000000000000000000000000000000000000000000000000000000000000",
                    data = to_hex(
                        "Test Coin is the unofficial official fake blockchain and cryptocurrency of Minetest. Unlike real cryptocurrencies, Test Coin has no value in the real world, but in Minetest, it's the hottest thing since lava.")
                })
            ))
        }
    end
end)

-- Save the blockchain data to file when the server stops
minetest.register_on_shutdown(function()
    testcoin.save_chain()
end)


-- Load the blockchain data from a file
testcoin.load_chain = function()
    local file = io.open(chain_data, "r")
    if not file then
        return {}
    end

    local blockchain = {}
    local contents = file:read("*a")
    if #contents > 0 then
        blockchain = minetest.parse_json(contents)
    end
    file:close()
    return blockchain or {}
end

-- Save the blockchain data to a file
testcoin.save_chain = function()
    local file = io.open(chain_data, "w")
    if not file then
        print("Error saving blockchain data: unable to open file")
        return
    end
    local data = minetest.write_json(chain, true)
    -- replace null with empty array
    data = data:gsub('"transactions"%s:%s*null', '"transactions" : []')
    -- convert index to integer
    data = data:gsub('"index"%s:%s*([%d.]+)', function(i) return '"index" : ' .. math.floor(tonumber(i)) end)
    -- convert timestamp to integer
    data = data:gsub('"timestamp"%s:%s*([%d.]+)', function(t) return '"timestamp" : ' .. math.floor(tonumber(t)) end)
    file:write(data)
    file:close()
end


testcoin.mine_block = function(data)
    local miner = get_miner()
    if miner == nil then
        minetest.log("TestCoin: No active miners")
        return
    end
    local staker = get_staker()
    if staker ~= nil then
        -- add staker to the block
    else
        minetest.log("TestCoin: No active stakers")
    end
    local height = #chain + 1
    local timestamp = math.floor(os.time())
    chain[height] = {
        index = math.floor(height),
        timestamp = timestamp,
        transactions = {},
        previousHash = chain[height - 1],
        data = data or "",
        hash = testcoin.sha256(to_hex(
            testcoin.serialize_block({
                index = math.floor(height),
                timestamp = timestamp,
                transactions = {},
                previousHash = chain[height - 1],
                data = data or ""
            })
        ))
    }
    -- add transactions to the block
    -- add block to chain
end
