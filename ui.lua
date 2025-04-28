local ui = unified_inventory

local selected_coin = {}
local coin_rate = {}

local function isInteger(str)
    return tonumber(str) ~= nil
end

local function register_coin_rates()
    coin_rate['scc'] = 0.000096;
    coin_rate['mrx'] = 7.56;
    coin_rate['btc'] = 0.000000001;
    coin_rate['eth'] = 0.000000031;
    coin_rate['send'] = 10;
    coin_rate['pep'] = 0.5;
    coin_rate['pivx'] = 0.000001;
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
            "image[" .. perplayer_formspec.form_header_x + 5.05 .. "," .. perplayer_formspec.form_header_y + 0.45 ..
            ";4.5,4.5;testcoin_coin.png;]",
            
            "label[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 0.5 .. ";Blockchain Info]",
            "label[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 1 .. ";Height: " .. testcoin.chain_tip.height .. "]",
            "label[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 1.3 .. ";Timestamp: " .. testcoin.chain_tip.timestamp .. "]",
            "field[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 1.75 ..
            ";4.3,0.8;testcoin_blockhash;Blockhash:;" .. testcoin.chain_tip.hash .. "]",
            "field[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 2.9 ..
            ";4.3,0.8;testcoin_prevhash;Prevhash:;" .. testcoin.chain_tip.prev .. "]",
            --[["label[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 3.9 ..
            ";Tx Count: " .. #testcoin.chain[#testcoin.chain].transactions .. "]",
            "label[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 4.2 .. ";----------]",
            "label[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 4.4 .. ";Mempool]",
            "label[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 4.8 .. ";Pending Tx: " .. #testcoin.mempool .. "]",]]

        }
            --[[
            {
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
            
        }]]--

        return { formspec = table.concat(formspec_left) .. table.concat(formspec_right) }
    end,
})

ui.register_page("testcoin_convert", {
    register_coin_rates();
    get_formspec = function(player, perplayer_formspec)
        local player_name = player:get_player_name()
        local sel = selected_coin[player_name]

        local formspec_left = left_menu_section(player, perplayer_formspec)
        local formspec_right = {
            "box[" ..
            perplayer_formspec.form_header_x + 5.05 .. "," .. perplayer_formspec.form_header_y + 0.2 .. ";4.5,5;#0c0c0c]",
            "label[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 0.5 .. ";Convert TestCoin]",
            -- first row coins
            "image_button[" ..
            perplayer_formspec.form_header_x + 5.4 .. "," .. perplayer_formspec.form_header_y + 0.75 .. 
            ";0.6,0.6;testcoin_scc2.png;coin_scc;;true;".. tostring(sel == "scc") ..";]",
            "image_button[" ..
            perplayer_formspec.form_header_x + 6.2 .. "," .. perplayer_formspec.form_header_y + 0.75 .. 
            ";0.6,0.6;testcoin_mrx.png;coin_mrx;;true;".. tostring(sel == "mrx") ..";]",
            "image_button[" ..
            perplayer_formspec.form_header_x + 7.0 .. "," .. perplayer_formspec.form_header_y + 0.75 .. 
            ";0.6,0.6;testcoin_btc.png;coin_btc;;true;".. tostring(sel == "btc") ..";]",
            "image_button[" ..
            perplayer_formspec.form_header_x + 7.8 .. "," .. perplayer_formspec.form_header_y + 0.75 .. 
            ";0.6,0.6;testcoin_eth.png;coin_eth;;true;".. tostring(sel == "eth") ..";]",
            "image_button[" ..
            perplayer_formspec.form_header_x + 8.6 .. "," .. perplayer_formspec.form_header_y + 0.75 .. 
            ";0.6,0.6;testcoin_send.png;coin_send;;true;".. tostring(sel == "send") ..";]",
            -- seconds row coins            
            "image_button[" ..
            perplayer_formspec.form_header_x + 5.4 .. "," .. perplayer_formspec.form_header_y + 1.5 .. 
            ";0.6,0.6;testcoin_coin.png;coin_8;]",
            "image_button[" ..
            perplayer_formspec.form_header_x + 6.2 .. "," .. perplayer_formspec.form_header_y + 1.5 .. 
            ";0.6,0.6;testcoin_pep2.png;coin_pep;;true;".. tostring(sel == "pep") ..";]",
            "image_button[" ..
            perplayer_formspec.form_header_x + 7.0 .. "," .. perplayer_formspec.form_header_y + 1.5 .. 
            ";0.6,0.6;testcoin_coin.png;coin_9;]",
            "image_button[" ..
            perplayer_formspec.form_header_x + 7.8 .. "," .. perplayer_formspec.form_header_y + 1.5 .. 
            ";0.6,0.6;testcoin_pivx1.png;coin_pivx;;true;".. tostring(sel == "pivx") ..";]",
            "image_button[" ..
            perplayer_formspec.form_header_x + 8.6 .. "," .. perplayer_formspec.form_header_y + 1.5 .. 
            ";0.6,0.6;testcoin_coin.png;coin_10;]",
            -- fields
            "field[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 2.5 .. ";4.3,0.6;input_amount;TestCoin Amount:;]",
            "field[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 3.5 .. ";4.3,0.6;input_address;Address:;]",
            -- submit
            "button[" ..
            perplayer_formspec.form_header_x + 5.15 ..
            "," .. perplayer_formspec.form_header_y + 4.2 .. ";4.3,0.8;submit_convert;Submit]",
            "tooltip[coin_scc;1 TestCoin per " .. coin_rate['scc'] .. " SCC;]",
            "tooltip[coin_mrx;1 TestCoin per " .. coin_rate['mrx'] .. " MRX;]",
            "tooltip[coin_btc;1 TestCoin per " .. coin_rate['btc'] .. " BTC;]",
            "tooltip[coin_eth;1 TestCoin per " .. coin_rate['eth'] .. " ETH;]",
            "tooltip[coin_send;1 TestCoin per " .. coin_rate['send'] .. " SEND;]",
            "tooltip[coin_pep;1 TestCoin per " .. coin_rate['pep'] .. " PEP;]",
            "tooltip[coin_pivx;1 TestCoin per " .. coin_rate['pivx'] .. " PIVX;]"
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

            "image[" .. perplayer_formspec.form_header_x + 6.75 .. "," .. perplayer_formspec.form_header_y + 0.9 ..
            ";1,1;testcoin_coin.png;]",
            
            -- fields
            "field[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 3.5 .. ";4.3,0.6;input_amount;TestCoin Amount:;]",
            "field[" .. perplayer_formspec.form_header_x + 5.15 .. "," ..
            perplayer_formspec.form_header_y + 2.5 .. ";4.3,0.6;input_address;Player Name:;]",
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
            perplayer_formspec.form_header_y + 1.5 .. ";4.3,0.6;input_amount;TestCoin Amount:;]",
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
        testcoin.deposit(player)
        ui.set_inventory_formspec(player, "testcoin_deposit")
        return
    end

    -- transfer to player
    if fields.submit_transfer then
        local amount = fields.input_amount
        local address = fields.input_address
        if isInteger(amount) then
            local receiver = minetest.get_player_by_name(address)
            if receiver ~= nil then
                local success, message = testcoin.create_transaction(player, receiver, tonumber(amount))
                if not success then                    
                    minetest.chat_send_player(player:get_player_name(), message)
                    return
                else
                    minetest.chat_send_player(address, "Received " .. amount .. " TestCoin from " .. player:get_player_name())
                    minetest.chat_send_player(player:get_player_name(), "Sent " .. amount .. " TestCoin to " .. address)
                
                    ui.set_inventory_formspec(player, "testcoin_transfer")
                    return
                end
            else
                minetest.chat_send_player(player:get_player_name(), "Player not found")
            end
        else
            minetest.chat_send_player(player:get_player_name(), "Invalid amount")
        end
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
        if isInteger(amount) then
            testcoin.withdraw(player, tonumber(amount))
            ui.set_inventory_formspec(player, "testcoin_withdraw")
            return
        end
    end

    local player_name = player:get_player_name()
    if fields.coin_scc then
        selected_coin[player_name] = "scc"
        ui.set_inventory_formspec(player, "testcoin_convert")
        return
    elseif fields.coin_mrx then
        selected_coin[player_name] = "mrx"
        ui.set_inventory_formspec(player, "testcoin_convert")
        return
    elseif fields.coin_btc then
        selected_coin[player_name] = "btc"
        ui.set_inventory_formspec(player, "testcoin_convert")
        return
    elseif fields.coin_eth then
        selected_coin[player_name] = "eth"
        ui.set_inventory_formspec(player, "testcoin_convert")
        return
    elseif fields.coin_send then
        selected_coin[player_name] = "send"
        ui.set_inventory_formspec(player, "testcoin_convert")
        return
    elseif fields.coin_pep then
        selected_coin[player_name] = "pep"
        ui.set_inventory_formspec(player, "testcoin_convert")
        return
    elseif fields.coin_pivx then
        selected_coin[player_name] = "pivx"
        ui.set_inventory_formspec(player, "testcoin_convert")
        return
    elseif fields.coin_8 then
        selected_coin[player_name] = ""
        ui.set_inventory_formspec(player, "testcoin_convert")
        return
    elseif fields.coin_9 then
        selected_coin[player_name] = ""
        ui.set_inventory_formspec(player, "testcoin_convert")
        return
    elseif fields.coin_10 then
        selected_coin[player_name] = ""
        ui.set_inventory_formspec(player, "testcoin_convert")
        return
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

