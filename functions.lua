
-- get player wallet balance
function testcoin.get_balance(player)
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
function testcoin.deposit(player)
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
    minetest.log("Found Balance: " .. balance)
    inv:set_list("testcoin_buffer", {})
end

-- withdraw from local wallet to inventory
function testcoin.withdraw(player, amount)
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
        minetest.add_item(pos, o)
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

