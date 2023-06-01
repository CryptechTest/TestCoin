local ui = unified_inventory

local function isInteger(str)
    return tonumber(str) ~= nil
end

ui.register_button("testcoin_main", {
    type = "image",
    image = "testcoin_ui_icon.png",
    tooltip = "TestCoin"
})

local function left_menu_section(player, perplayer_formspec)
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
    return { 
        perplayer_formspec.standard_inv_bg,
        "label[", perplayer_formspec.form_header_x, ",",
        perplayer_formspec.form_header_y, ";", "TestCoin Core v", testcoin.ver, "]",
        "box[" ..
        perplayer_formspec.form_header_x + 0.1 .. "," .. perplayer_formspec.form_header_y + 0.2 .. ";4.5,5;#0c0c0c]",
        "label[" .. perplayer_formspec.form_header_x + 1.85 .. "," ..
        perplayer_formspec.form_header_y + 0.5 .. ";Balance]",
        "label[" .. perplayer_formspec.form_header_x + 1.85 ..
        "," .. perplayer_formspec.form_header_y + 1 .. ";".. balance .." TEST]",
        "button[" ..
        perplayer_formspec.form_header_x + 0.35 ..
        "," .. perplayer_formspec.form_header_y + 1.5 .. ";4,0.8;testcoin_transfer;Transfer]",
        "button[" ..
        perplayer_formspec.form_header_x + 0.35 ..
        "," .. perplayer_formspec.form_header_y + 2.4 .. ";4,0.8;testcoin_deposit;Deposit]",
        "button[" ..
        perplayer_formspec.form_header_x + 0.35 ..
        "," .. perplayer_formspec.form_header_y + 3.3 .. ";4,0.8;testcoin_withdraw;Withdraw]",
        "button[" ..
        perplayer_formspec.form_header_x + 0.35 ..
        "," .. perplayer_formspec.form_header_y + 4.2 .. ";4,0.8;testcoin_convert;Convert]",
    }
end

ui.register_page("testcoin_main", {
    get_formspec = function(player, perplayer_formspec)
        --local player_name = player:get_player_name()
        local inv = player:get_inventory()
        local balance = 0
        if inv then
            local coins = inv:get_list("testcoin")
            if #coins > 0 then
                for _, coin in ipairs(coins) do
                    if coin ~= nil and not coin:is_empty() then
                        balance = balance + coin:get_count()
                    end
                end
            end
        end
        local formspec_left = left_menu_section(player, perplayer_formspec)
        local formspec_right = {
            "box[" ..
            perplayer_formspec.form_header_x + 5.05 .. "," .. perplayer_formspec.form_header_y + 0.2 .. ";4.5,5;#0c0c0c]",
            "label[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 0.5 .. ";Blockchain Info]",
            "label[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 1 .. ";Height: " .. #testcoin.chain .. "]",
            "label[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 1.3 .. ";Timestamp: " .. testcoin.chain[#testcoin.chain].timestamp .. "]",
            "field[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 1.75 ..
            ";4.3,0.8;testcoin_blockhash;Blockhash:;" .. testcoin.chain[#testcoin.chain].hash .. "]",
            "field[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 2.9 ..
            ";4.3,0.8;testcoin_prevhash;Prevhash:;" .. testcoin.chain[#testcoin.chain].previousHash .. "]",
            "label[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 3.9 ..
            ";Tx Count: " .. #testcoin.chain[#testcoin.chain].transactions .. "]",
            "label[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 4.2 .. ";----------]",
            "label[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 4.4 .. ";Mempool]",
            "label[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 4.8 .. ";Pending Tx: " .. #testcoin.mempool .. "]",

        }

        return { formspec = table.concat(formspec_left) .. table.concat(formspec_right) }
    end,
})

ui.register_page("testcoin_convert", {
    get_formspec = function(player, perplayer_formspec)
        --local player_name = player:get_player_name()

        local formspec_left = left_menu_section(player, perplayer_formspec)
        local formspec_right = {
            "box[" ..
            perplayer_formspec.form_header_x + 5.05 .. "," .. perplayer_formspec.form_header_y + 0.2 .. ";4.5,5;#0c0c0c]",
            "label[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 0.5 .. ";Convert TestCoin]",
            -- first row coins
            "image_button[" ..
            perplayer_formspec.form_header_x + 5.4 ..
            "," .. perplayer_formspec.form_header_y + 0.75 .. ";0.6,0.6;testcoin_scc2.png;coin_scc;]",
            "image_button[" ..
            perplayer_formspec.form_header_x + 6.2 ..
            "," .. perplayer_formspec.form_header_y + 0.75 .. ";0.6,0.6;testcoin_mrx.png;coin_mrx;]",
            "image_button[" ..
            perplayer_formspec.form_header_x + 7.0 ..
            "," .. perplayer_formspec.form_header_y + 0.75 .. ";0.6,0.6;testcoin_btc.png;coin_btc;]",
            "image_button[" ..
            perplayer_formspec.form_header_x + 7.8 ..
            "," .. perplayer_formspec.form_header_y + 0.75 .. ";0.6,0.6;testcoin_eth.png;coin_eth;]",
            "image_button[" ..
            perplayer_formspec.form_header_x + 8.6 ..
            "," .. perplayer_formspec.form_header_y + 0.75 .. ";0.6,0.6;testcoin_send.png;coin_send;]",
            -- seconds row coins
            "image_button[" ..
            perplayer_formspec.form_header_x + 5.4 ..
            "," .. perplayer_formspec.form_header_y + 1.5 .. ";0.6,0.6;testcoin_coin.png;coin_6;]",
            "image_button[" ..
            perplayer_formspec.form_header_x + 6.2 ..
            "," .. perplayer_formspec.form_header_y + 1.5 .. ";0.6,0.6;testcoin_coin.png;coin_7;]",
            "image_button[" ..
            perplayer_formspec.form_header_x + 7.0 ..
            "," .. perplayer_formspec.form_header_y + 1.5 .. ";0.6,0.6;testcoin_coin.png;coin_8;]",
            "image_button[" ..
            perplayer_formspec.form_header_x + 7.8 ..
            "," .. perplayer_formspec.form_header_y + 1.5 .. ";0.6,0.6;testcoin_coin.png;coin_9;]",
            "image_button[" ..
            perplayer_formspec.form_header_x + 8.6 ..
            "," .. perplayer_formspec.form_header_y + 1.5 .. ";0.6,0.6;testcoin_coin.png;coin_10;]",
            -- fields
            "field[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 2.5 .. ";4.3,0.6;input_amount;Amount:;]",
            "field[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 3.5 .. ";4.3,0.6;input_address;Address:;]",
            -- submit
            "button[" ..
            perplayer_formspec.form_header_x + 5.15 ..
            "," .. perplayer_formspec.form_header_y + 4.2 .. ";4.3,0.8;submit_convert;Submit]",

        }

        return { formspec = table.concat(formspec_left) .. table.concat(formspec_right) }
    end,
})

ui.register_page("testcoin_deposit", {
    get_formspec = function(player, perplayer_formspec)
        --local player_name = player:get_player_name()

        local formspec_left = left_menu_section(player, perplayer_formspec)
        local formspec_right = {
            "box[" ..
            perplayer_formspec.form_header_x + 5.05 .. "," .. perplayer_formspec.form_header_y + 0.2 .. ";4.5,5;#0c0c0c]",
            "label[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 0.5 .. ";Deposit TestCoin]",

            -- inventory
            ui.make_inv_img_grid(perplayer_formspec.form_header_x + 5.5, perplayer_formspec.form_header_y + 1, 3, 2),
            "listring[current_player;main]",
            "list[current_player;testcoin_buffer;".. perplayer_formspec.form_header_x + 5.6 .. "," .. 
            perplayer_formspec.form_header_y + 1.1 .. ";3,2;0]",
            "listring[current_player;testcoin_buffer]",

            -- submit
            "button[" ..
            perplayer_formspec.form_header_x + 5.15 ..
            "," .. perplayer_formspec.form_header_y + 4.2 .. ";4.3,0.8;submit_deposit;Submit]",
        }

        return { formspec = table.concat(formspec_left) .. table.concat(formspec_right) }
    end,
})

ui.register_page("testcoin_transfer", {
    get_formspec = function(player, perplayer_formspec)
        --local player_name = player:get_player_nam

        local formspec_left = left_menu_section(player, perplayer_formspec)
        local formspec_right = {
            "box[" ..
            perplayer_formspec.form_header_x + 5.05 .. "," .. perplayer_formspec.form_header_y + 0.2 .. ";4.5,5;#0c0c0c]",
            "label[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 0.5 .. ";Transfer TestCoin]",
            
            -- fields
            "field[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 2.5 .. ";4.3,0.6;input_amount;Amount:;]",
            "field[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 3.5 .. ";4.3,0.6;input_address;Player Name:;]",
            -- submit
            "button[" ..
            perplayer_formspec.form_header_x + 5.15 ..
            "," .. perplayer_formspec.form_header_y + 4.2 .. ";4.3,0.8;submit_transfer;Submit]",
        }

        return { formspec = table.concat(formspec_left) .. table.concat(formspec_right) }
    end,
})

ui.register_page("testcoin_withdraw", {
    get_formspec = function(player, perplayer_formspec)
        --local player_name = player:get_player_name()

        local formspec_left = left_menu_section(player, perplayer_formspec)
        local formspec_right = {
            "box[" ..
            perplayer_formspec.form_header_x + 5.05 .. "," .. perplayer_formspec.form_header_y + 0.2 .. ";4.5,5;#0c0c0c]",
            "label[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 0.5 .. ";Withdraw TestCoin]",

            -- fields
            "field[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 1.5 .. ";4.3,0.6;input_amount;Amount:;]",
            -- submit
            "button[" ..
            perplayer_formspec.form_header_x + 5.15 ..
            "," .. perplayer_formspec.form_header_y + 4.2 .. ";4.3,0.8;submit_withdraw;Submit]",
        }

        return { formspec = table.concat(formspec_left) .. table.concat(formspec_right) }
    end,
})


minetest.register_allow_player_inventory_action(function(player, action, inventory, info)
    -- From detached inventory -> player inventory: put & take callbacks
    if action == "put" and info.listname:find("testcoin") then
        return 0
    end
    if action == "take" and info.listname:find("testcoin") then
        return 0
    end
    if action == "move" and (info.from_list:find("main") and info.to_list:find("testcoin_buffer")) then
	    local stack = inventory:get_stack(info.from_list, info.from_index)
        if stack ~= nil and stack:get_name() == "testcoin:coin" then
            return info.count
        end
        return 0
    end    
    if action == "move" and (info.from_list:find("testcoin") or info.to_list:find("testcoin")) then
        return 0
    end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "" then
        return
    end

    -- deposit to local
    if fields.submit_deposit then
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
        minetest.log("Found Deposit: " .. balance)
        inv:set_list("testcoin_buffer", {})
        ui.set_inventory_formspec(player, "testcoin_deposit")
        return
    end

    -- transfer to player
    if fields.submit_transfer then
        local amount = fields.input_amount
        local address = fields.input_address
        minetest.log("Amt: " .. amount .. "  Addr: " .. address)
        ui.set_inventory_formspec(player, "testcoin_transfer")
        return
    end
    
    -- convert to real coin
    if fields.submit_convert then
        local amount = fields.input_amount
        local address = fields.input_address
        minetest.log("Amt: " .. amount .. "  Addr: " .. address)        
        ui.set_inventory_formspec(player, "testcoin_convert")
        return
    end

    -- withdraw from local
    if fields.submit_withdraw then
        local amount = fields.input_amount
        minetest.log("Amt: " .. amount)

        if isInteger(amount) then
            testcoin.withdraw(player, tonumber(amount))
            ui.set_inventory_formspec(player, "testcoin_withdraw")
            return
        end
    end

    -- handle tabs
    if fields["testcoin_convert"] then
        ui.set_inventory_formspec(player, "testcoin_convert")
    elseif fields["testcoin_deposit"] then
        ui.set_inventory_formspec(player, "testcoin_deposit")
    elseif fields["testcoin_transfer"] then
        ui.set_inventory_formspec(player, "testcoin_transfer")
    elseif fields["testcoin_withdraw"] then
        ui.set_inventory_formspec(player, "testcoin_withdraw")
    end
end)

