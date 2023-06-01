
-- get player wallet balance
local function get_balance(player)
    local balance = 0
    local inv = player:get_inventory()
    local coins = inv:get_list("testcoin")
    if #coins > 0 then
        for _, coin in ipairs(coins) do
            if coin ~= nil and not coin:is_empty() then
                balance = balance + coin:get_count()
            end
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
    local stacks = amount / 10000
    local rem = amount % 10000

    minetest.log("stacks: " .. stacks .. "  rem: " .. rem )

    local balance = get_balance(player)
    if amount > balance then
       return false
    end
    
    local total_amt = amount
    local total_out = balance
    local inv = player:get_inventory()

    if stacks >= 1 then
        for i=1, stacks do
            local s = ItemStack("testcoin:coin")
            s:set_count(10000)
            inv:add_item("main", s)
        end
    end
    if rem > 0 then
        local s = ItemStack("testcoin:coin")
        s:set_count(rem)
        inv:add_item("main", s)
    end
    
    local coins = inv:get_list("testcoin")
    if #coins > 0 then
        for _, coin in ipairs(coins) do
            if coin ~= nil and not coin:is_empty() then
                if stacks >= 1 and coin:get_count() == 10000 then
                    inv:remove_item("testcoin", coin)
                    stacks = stacks - 1
                    total_amt = total_amt - 10000
                    total_out = total_out - 10000
                elseif rem > 0 and stacks < 1 then
                    local v = coin:get_count()
                    -- remove orig
                    inv:remove_item("testcoin", coin)
                    -- replace old
                    local s = ItemStack("testcoin:coin")
                    s:set_count(v - total_amt)
                    inv:add_item("testcoin", s)
                    rem = 0
                    total_amt = 0
                    total_out = 0
                end
            end
        end
    end

    return true
end

function testcoin.transfer(player_from, amount, player_name_to)
    local player_to = minetest.get_player_by_name(player_name_to)

    local stacks = amount / 10000
    local rem = amount % 10000

    minetest.log("stacks: " .. stacks .. "  rem: " .. rem )

    local balance = get_balance(player_from)
    if amount > balance then
       return false
    end
    
    local total_amt = amount
    local total_out = balance
    local inv_from = player_from:get_inventory()
    local inv_to = player_to:get_inventory()

    if stacks >= 1 then
        for i=1, stacks do
            local s = ItemStack("testcoin:coin")
            s:set_count(10000)
            inv_to:add_item("testcoin", s)
        end
    end
    if rem > 0 then
        local s = ItemStack("testcoin:coin")
        s:set_count(rem)
        inv_to:add_item("testcoin", s)
    end
    
    local coins = inv_from:get_list("testcoin")
    if #coins > 0 then
        for _, coin in ipairs(coins) do
            if coin ~= nil and not coin:is_empty() then
                if stacks >= 1 and coin:get_count() == 10000 then
                    inv_from:remove_item("testcoin", coin)
                    stacks = stacks - 1
                    total_amt = total_amt - 10000
                    total_out = total_out - 10000
                elseif rem > 0 and stacks < 1 then
                    local v = coin:get_count()
                    -- remove orig
                    inv_from:remove_item("testcoin", coin)
                    -- replace old
                    local s = ItemStack("testcoin:coin")
                    s:set_count(v - total_amt)
                    inv_from:add_item("testcoin", s)
                    rem = 0
                    total_amt = 0
                    total_out = 0
                end
            end
        end
    end

    minetest.chat_send_player(player_to:get_name(), "Received " .. amount .. " Coins from " .. player_from:get_name())
    minetest.chat_send_player(player_from:get_name(), "Sent " .. amount .. " Coins to " .. player_to:get_name())

    return true
end