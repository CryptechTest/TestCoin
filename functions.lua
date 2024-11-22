
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

local function get_miner()
    return nil
end

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

testcoin.mine_block = function(data)
    local miner = get_miner()
    if miner == nil then
        core.log("TestCoin: No active miners")
        return
    end
    -- reward the miner
    local staker = get_staker()
    if staker ~= nil then
        -- reward the staker
    else
        core.log("TestCoin: No active stakers")
    end
end

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