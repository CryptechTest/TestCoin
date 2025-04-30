local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
local sha = dofile(modpath .. "/lib/sha/sha2.lua")

-------------------------------------------------------
-------------------------------------------------------

local function ShuffleInPlace(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end

local function shuffle(tbl, rng)
    for i = #tbl, 2, -1 do
      local j = rng:next(i)
      tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

local function miner_count(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

-- gets random active miner
local function get_active_miner(round, total_hashrate, target)
    -- performs loop using input rate count as tries,
    -- returns true if random value equals 0 on find check
    local function find_winner(rate, target, bias)
        local r = math.random(0, rate + bias)
        --core.log("target= " .. target .. "  result= " .. r .. "  round= " .. round)
        if r >= target then
            core.log("target= " .. target .. "  result= " .. r .. "  round= " .. round .. "  WINNER!")
            return true
        end
        return false
    end
    -- total miner rigs active
    local t_miners = miner_count(testcoin.miners_active);
    if t_miners == 0 or total_hashrate <= 0 then
        return t_miners, nil
    end
    -- shuffle the active miners...
    local _miners = testcoin.miners_active --shuffle(testcoin.miners_active, rng)
    -- iterate over active miners
    for _, miner in pairs(_miners) do
        local node = core.get_node_or_nil(miner.pos)
        if node ~= nil then
            -- calculate effective hashrate
            local pow_rate, asic_rate = testcoin.calc_hashrate(miner)
            -- check pow miners
            if find_winner(pow_rate, target, 1) then
                return t_miners, miner
            end
            -- check asic miners
            if find_winner(asic_rate, target, 0) then
                return t_miners, miner
            end
        end
    end
    return t_miners, nil
end

-- get random miner
local function get_miner()
    local t_miners = miner_count(testcoin.miners_active);
    local miner = nil
    -- total hashrate of miners
    local total_hashrate = testcoin.calc_hashrate_total()
    -- calculate hash target threshold
    local seed = math.floor(math.random() * 1000000) % 4294967296
    local rng = PcgRandom(seed)
    local target = rng:next(0, (total_hashrate * 2) / (t_miners * 0.5))
    ShuffleInPlace(testcoin.miners_active)
    for i = 0, 7 do
        t_miners, miner = get_active_miner(i, total_hashrate, target)
        if t_miners == 0 or miner ~= nil then
            break
        end
    end
    return t_miners, total_hashrate, miner
end

-- get random staker
local function get_staker()
    local staker = nil
    local stakers = {}
    local total_balance = 0
    for _, player in ipairs(core.get_connected_players()) do
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
                    stakers[#stakers + 1] = { 
                        staker = player:get_player_name(), 
                        hash = sha.sha256("player:" .. player:get_player_name()),
                        balance = balance 
                    }
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

-- perform reward miner with testcoin
local function reward_miner(miner, amt)
    local _amt = amt or 1
    local meta = core.get_meta(miner.pos)
    local inv = meta:get_inventory()
    local inv_reward = inv:get_list("reward")
    local itemstack = ItemStack("testcoin:coin");
    itemstack:set_count(amt)
    inv:add_item("reward", itemstack);
end

-- perform reward staker with testcoin
local function reward_staker(staker, amt)
    local function check_full(inv, stack)
        local one_item_stack = ItemStack(stack)
        one_item_stack:set_count(1)
        if not inv:room_for_item("testcoin", one_item_stack) then
            return true
        end
        return false
    end
    local _amt = amt or 1
    local _amt = math.min(_amt, staker.balance)
    local player = minetest.get_player_by_name(staker.staker)
    --local meta = player:get_meta()
    local inv = player:get_inventory()
    local itemstack = ItemStack("testcoin:coin");
    itemstack:set_count(_amt)
    if check_full(inv, itemstack) then
        local pos = vector.add(player.get_pos(), {x = 0, y = 1, z = 0})
        core.add_item(pos, itemstack)
        return true
    end
    inv:add_item("testcoin", itemstack);
end

-- create a new block in the chain
local function create_block(miner, staker, data)
    if miner == nil then
        return nil
    end
    local function random_bytes(count)
        count = count or 1
        local str = ""
        for i = 1, count do
            str = str .. string.format("%02x", math.random(0, 0xFF))
        end
        return str
    end
    -- block data
    local _data = {}
    _data.ver = data.ver or testcoin.ver
    _data.diff = data.diff or 1
    _data.nonce = data.nonce or random_bytes(8)
    -- add miner to block
    local tx_data = {
        vin = {},
        n_vin = 0,
        vout = {},
        n_vout = 0
    }
    -- add coinbase rewards
    table.insert(tx_data.vin, { hash = testcoin.vtx_coinbase.ref, amount = 0 })
    table.insert(tx_data.vout, { hash = miner.hash_id, amount = 10 })
    if staker then
        table.insert(tx_data.vout, { hash = staker.hash, amount = 10 })
    end
    -- add standard tx...
    for _, v in pairs(data.vin or {}) do
        if v.amount > 0 then
            table.insert(tx_data.vin, { hash = v.hash, amount = v.amount })
        end
    end
    for _, v in pairs(data.vout or {}) do
        if v.amount > 0 then
            table.insert(tx_data.vout, { hash = v.hash, amount = v.amount })    
        end
    end
    -- total vin and vout counts
    tx_data.n_vin = math.floor(#tx_data.vin)
    tx_data.n_vout = math.floor(#tx_data.vout)
    -- serialize to json
    local tx_nonce = random_bytes(2)
    local tx_str = core.write_json(tx_data) .. ":" .. tx_nonce
    -- build block tx data
    _data.tx = {
        hash_sum = sha.sha256(tx_str),
        data = tx_data,
        nonce = tx_nonce
    }
    -- add block to chain...
    local hash, height = testcoin.add_block(_data);
    core.log(height .. ": " .. hash);
    return hash, height
end

-- try and mine a testcoin block
local mine_block = function(data)
    local miner_count, hashrate, miner = get_miner()
    if miner == nil then
        if miner_count == 0 then
            core.log("TestCoin: No active miners")
        end
        return
    end
    -- reward the miner
    reward_miner(miner, 10);

    local staker = get_staker()
    if staker ~= nil then
        -- reward the staker
        reward_staker(staker, 10)
    else
        core.log("TestCoin: No active stakers")
    end
    
    core.log("TestCoin: Miner found block!  Total Hashrate: " .. hashrate)
    create_block(miner, staker, data)
end

--------------------------------------------------------
--------------------------------------------------------
-- Public functions
--------------------------------------------------------

-- calculate the hashrate for a given miner rig
function testcoin.calc_hashrate(miner)
    local t = 1
    if miner.tier == "MV" then
        t = 1.5
    elseif miner.tier == "HV" then
        t = 2
    end
    local pow_miners = miner.miners.pow_miner or 0
    local asic_miners = miner.miners.asic_miner or 0
    local pow_rate = (10 * pow_miners * 1 * t) + (math.random() * 2);
    local asic_rate = (10 * asic_miners * 2 * t) + (math.random() * 2);
    if miner.miners.total > 0 then
        miner.rate = pow_rate + asic_rate
        local meta = core.get_meta(miner.pos)
        meta:set_int("hashrate", miner.rate);
    end
    return pow_rate, asic_rate
end

-- calculate the hashrate for all active miners
function testcoin.calc_hashrate_total()
    local total = 0
    -- iterate over active miners
    for _, miner in pairs(testcoin.miners_active) do
        local node = core.get_node_or_nil(miner.pos)
        if node ~= nil then
            local pow_rate, asic_rate = testcoin.calc_hashrate(miner)
            total = total + pow_rate + asic_rate
        end
    end
    return total
end

----------------------------

-- run the blockchain
testcoin.run_chain = function()
    local data = {
        vin = {},
        vout = {}
    }    
    table.insert(data.vin, { hash = "0", amount = 0 })
    table.insert(data.vout, { hash = "0", amount = 0 })
    mine_block(data)
end

-- get player wallet balance
testcoin.get_balance = function(player)
    local balance = 0
    local inv = player:get_inventory()
    if inv == nil or inv:is_empty("testcoin") then
        return balance
    end
    local coins = inv:get_list("testcoin")
    for _, coin in ipairs(coins) do
        if coin ~= nil and not coin:is_empty() then
            balance = balance + coin:get_count()
        end
    end
    return balance
end

-- deposit from inventory buffer to local wallet
testcoin.deposit = function(player)
    local balance = 0
    local inv = player:get_inventory()
    local coins = inv:get_list("testcoin_buffer")
    if #coins > 0 then
        for _, coin in ipairs(coins) do
            if coin ~= nil and not coin:is_empty() then
                balance = balance + coin:get_count()
                inv:add_item("testcoin", coin)
            end
        end
    end
    core.log("Found Balance: " .. balance)
    inv:set_list("testcoin_buffer", {})
end

-- withdraw from local wallet to inventory
testcoin.withdraw = function(player, amount)
    local stacks = math.floor(math.floor(amount) / 10000)
    local rem = math.floor(amount) % 10000

    local balance = testcoin.get_balance(player)
    if math.floor(amount) > balance then
       return false, "Insufficient Funds"
    end
    
    local inv = player:get_inventory()
    local over = {}
    for i=1, stacks do
        local s = ItemStack({name = "testcoin:coin", count = 10000})
        local o = inv:add_item("main", s)
        if o:get_count() > 0 then
            table.insert(over, o)
        end
    end
    if rem > 0 then
        local s = ItemStack({name = "testcoin:coin", count = rem})
        local o = inv:add_item("main", s)
        if o:get_count() > 0 then
            table.insert(over, o)
        end
    end
    for _, o in ipairs(over) do
        local pos = player:get_pos()
        pos.y = pos.y + 1
        core.add_item(pos, o)
    end
    local out = 0
    local coins = inv:get_list("testcoin")
    if #coins > 0 then
        for i, coin in ipairs(coins) do
            if out < math.floor(amount) and coin ~= nil and not coin:is_empty() then
                local count = coin:get_count()
                if out + count <= math.floor(amount) then
                    out = out + count
                    inv:remove_item("testcoin", coin)
                else
                    local diff = math.floor(amount) - out
                    coin:set_count(count - diff)
                    inv:set_stack("testcoin", i, coin)
                    out = out + diff
                end
            end
        end
    end

    return true, "Withdraw of " .. amount .. " TestCoin complete"
end

-- create a new transaction of testcoin between inventories
testcoin.create_transaction = function(from, to, amount)
    local finv = from:get_inventory()
    local tinv = to:get_inventory()
    if math.floor(amount) <= 0 then
        return false, "Invalid amount"
    end
    if finv and tinv then
        if finv:is_empty("testcoin") then
            return false, "Insufficient funds"
        end
        local balance = testcoin.get_balance(from)
        if balance < math.floor(amount) then
            return false, "Insufficient funds"
        end

        if balance >= math.floor(amount) then
            local stacks = math.floor(amount / 10000)
            local rem = amount % 10000
            for _ = 1, stacks do
                local s = ItemStack({ name = "testcoin:coin", count = 10000 })
                local c = finv:remove_item("testcoin", s)
                local r = tinv:add_item("testcoin", c)
                if r and not r:is_empty() then
                    local pos = to:get_pos()
                    pos.y = pos.y + 0.5
                    core.add_item(pos, r)
                end
            end
            if rem > 0 then
                local s = ItemStack("testcoin:coin")
                s:set_count(rem)
                local c = finv:remove_item("testcoin", s)
                local r = tinv:add_item("testcoin", c)
                if r and not r:is_empty() then
                    local pos = to:get_pos()
                    pos.y = pos.y + 0.5
                    core.add_item(pos, r)
                end
            end
            return true, "Transaction complete"
        else
            return false, "Insufficient funds"
        end
    else
        return false, "Invalid transaction"
    end
end

-------------------------------------------------------
-------------------------------------------------------
---------------- Atmos functions ----------------------
-------------------------------------------------------

local function str_pos(pos)
    return pos.x .. ":" .. pos.y .. ":" .. pos.z
end

local function has_pos(tab, val)
    return tab[str_pos(val)] ~= nil
end

local function shuffle(t)
    local tbl = {}
    for i = 1, #t do
        tbl[i] = t[i]
    end
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

local function is_air_node(pos, use_hot)
    use_hot = use_hot or false
    local node = core.get_node(pos)
    local g_atmos = core.get_item_group(node.name, "atmosphere")
    if node.name == "air" or g_atmos == 1 or g_atmos == 10 then
        return true
    end
    if use_hot and g_atmos == 11 then
        return true
    end
    return false
end

local function traverse_atmos_local(pos_orig, pos, r)
    local positions = {{
        x = pos.x + 1,
        y = pos.y,
        z = pos.z
    }, {
        x = pos.x - 1,
        y = pos.y,
        z = pos.z
    }, {
        x = pos.x,
        y = pos.y + 1,
        z = pos.z
    }, {
        x = pos.x,
        y = pos.y - 1,
        z = pos.z
    }, {
        x = pos.x,
        y = pos.y,
        z = pos.z + 1
    }, {
        x = pos.x,
        y = pos.y,
        z = pos.z - 1
    }}
    local nodes = {}
    local dist = vector.distance({
        x = pos.x,
        y = pos.y,
        z = pos.z
    }, {
        x = pos_orig.x,
        y = pos_orig.y,
        z = pos_orig.z
    })
    nodes[str_pos(pos)] = pos
    if (dist > r) then
        return nodes;
    end
    for i, cur_pos in pairs(shuffle(positions)) do
        if is_air_node(cur_pos, true) then
            nodes[str_pos(cur_pos)] = cur_pos
        end
    end
    return nodes;
end

local function traverse_atmos(pos, pos_next, r, depth)
    if pos_next == nil then
        pos_next = pos;
    end
    local nodes = {};    
    -- depth check
    local max_depth = math.min(r, 5)
    if depth > max_depth then
        return nodes
    end
    depth = depth + 1
    -- add pos to listing
    nodes[str_pos(pos_next)] = pos_next
    -- traverse nodes in local area
    local trav_nodes = traverse_atmos_local(pos, pos_next, r);
    for _, tpos in pairs(trav_nodes) do
        -- add to listing
        if not has_pos(nodes, tpos) then
            nodes[str_pos(tpos)] = tpos
            if math.random(0, 1) <= 0 then
                -- traverse atmos for next pos in chain
                local atmoss = traverse_atmos(pos, tpos, r, depth);
                for i, n in pairs(atmoss) do
                    nodes[str_pos(n)] = n
                end
            end
        end

    end
    -- return nodes
    return nodes;
end

function testcoin.fill_atmos_hot(origin, r)
    -- traverse nearby atmos
    local nodes = traverse_atmos(origin, nil, r, 0);
    -- minetest.log("found " .. #nodes);
    local count = 0;
    -- iterate over nodes found
    for i, node_pos in pairs(nodes) do
        if (count > 1 + (4 * r)) then
            break
        end
        count = count + 1;
        if is_air_node(node_pos) then
            core.set_node(node_pos, {
                name = "ctg_airs:atmos_hot"
            })
        end
    end
    return count
end
