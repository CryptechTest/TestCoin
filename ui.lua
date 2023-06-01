local ui = unified_inventory

ui.register_button("testcoin_main", {
    type = "image",
    image = "testcoin_ui_icon.png",
    tooltip = "TestCoin"
})

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
        local formspec = {
            perplayer_formspec.standard_inv_bg,
            "label[", perplayer_formspec.form_header_x, ",",
            perplayer_formspec.form_header_y, ";", "TestCoin Core v", testcoin.ver, "]",
            "box[" ..
            perplayer_formspec.form_header_x + 0.1 .. "," .. perplayer_formspec.form_header_y + 0.2 .. ";4.5,5;#0c0c0c]",
            "label[" .. perplayer_formspec.form_header_x + 1.85 .. "," ..
            perplayer_formspec.form_header_y + 0.5 .. ";Balance]",
            "label[" .. perplayer_formspec.form_header_x + 1.85 ..
            "," .. perplayer_formspec.form_header_y + 1 .. ";0 TEST]",
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

        return { formspec = table.concat(formspec) }
    end,
})

ui.register_page("testcoin_convert", {
    get_formspec = function(player, perplayer_formspec)
        --local player_name = player:get_player_name()

        local formspec = {
            perplayer_formspec.standard_inv_bg,
            "label[", perplayer_formspec.form_header_x, ",",
            perplayer_formspec.form_header_y, ";", "TestCoin Core v", testcoin.ver, "]",
            "label[", perplayer_formspec.form_header_x, ",",
            perplayer_formspec.form_header_y + 0.25, ";", "Convert TestCoin]",
        }

        return { formspec = table.concat(formspec) }
    end,
})

ui.register_page("testcoin_deposit", {
    get_formspec = function(player, perplayer_formspec)
        --local player_name = player:get_player_name()

        local formspec = {
            perplayer_formspec.standard_inv_bg,
            "label[", perplayer_formspec.form_header_x, ",",
            perplayer_formspec.form_header_y, ";", "TestCoin Core v", testcoin.ver, "]",
            "label[", perplayer_formspec.form_header_x, ",",
            perplayer_formspec.form_header_y + 0.25, ";", "Deposit TestCoin]",
        }

        return { formspec = table.concat(formspec) }
    end,
})

ui.register_page("testcoin_transfer", {
    get_formspec = function(player, perplayer_formspec)
        --local player_name = player:get_player_name()

        local formspec = {
            perplayer_formspec.standard_inv_bg,
            "label[", perplayer_formspec.form_header_x, ",",
            perplayer_formspec.form_header_y, ";", "TestCoin Core v", testcoin.ver, "]",
            "label[", perplayer_formspec.form_header_x, ",",
            perplayer_formspec.form_header_y + 0.25, ";", "Transfer TestCoin]",
        }

        return { formspec = table.concat(formspec) }
    end,
})

ui.register_page("testcoin_withdraw", {
    get_formspec = function(player, perplayer_formspec)
        --local player_name = player:get_player_name()

        local formspec = {
            perplayer_formspec.standard_inv_bg,
            "label[", perplayer_formspec.form_header_x, ",",
            perplayer_formspec.form_header_y, ";", "TestCoin Core v", testcoin.ver, "]",
            "label[", perplayer_formspec.form_header_x, ",",
            perplayer_formspec.form_header_y + 0.25, ";", "Withdraw TestCoin]",
        }

        return { formspec = table.concat(formspec) }
    end,
})


minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "" then
        return
    end
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
