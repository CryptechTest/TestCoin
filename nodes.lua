local modname = core.get_current_modname()
local S = core.get_translator(modname)

local modpath = core.get_modpath(modname)
local sha = dofile(modpath .. "/lib/sha/sha2.lua")
local n_hasher = dofile(modpath .. "/node_hasher.lua")

local connect_default = {"bottom", "back"}

local time_scl = 25

local function round(v)
    return math.floor(v + 0.5)
end

local function play_sound_fan(pos)
    minetest.sound_play("testcoin_miner_fan", {
        pos = pos,
        gain = math.random(0.21, 0.47),
        pitch = math.random(0.86, 1.08),
        fade = 3,
        max_hear_distance = 10
    })
end

-------------------------------------------------------

-- register_mining_rig
local function register_mining_rig(data)
    data.tube = 1
    local tier = data.tier
    local ltier = string.lower(tier)
    local machine_name = data.machine_name
    local machine_desc = tier .. " " .. data.machine_desc
    local tmachine_name = string.lower(machine_name)

    local groups = {
        oddly_breakable_by_hand = 2,
        choppy = 2,
        itemshelf_shown_items = 6,
        technic_machine = 1,
        ["technic_" .. ltier] = 1,
        mining_rig = 1,
        metal = 1
    }

    -------------------------------------------------------
    -------------------------------------------------------

    local function get_formspec(pos, data)
        local meta = core.get_meta(pos)
        local def_chan = meta:get_string("digilines_channel")
        local edit_mode = meta:get_int("edit_mode")
        local hashrate = meta:get_string("hashrate") or 0
        local enabled = meta:get_int("enabled") == 1
        local heat = meta:get_int("temp") or -3
        local en_demand = meta:get_int(tier .. "_EU_demand") or 0
        local eff = meta:get_int("efficiency") or 0
        local temp_over = meta:get_int("temp_over") or 0

        local on_btn, off_btn
        if enabled then
            on_btn = "< On >"
            off_btn = "Off"
        else
            on_btn = "On"
            off_btn = "< Off >"
        end

        local _heat = ""
        if heat > 95 then
            _heat = core.colorize('#f51005', heat .. " °c")
        elseif heat > 90 then
            _heat = core.colorize('#ff0f0f', heat .. " °c")
        elseif heat > 85 then
            _heat = core.colorize('#f72411', heat .. " °c")
        elseif heat > 80 then
            _heat = core.colorize('#fc3b19', heat .. " °c")
        elseif heat > 75 then
            _heat = core.colorize('#fc4112', heat .. " °c")
        elseif heat > 70 then
            _heat = core.colorize('#fc5c12', heat .. " °c")
        elseif heat > 60 then
            _heat = core.colorize('#fc8b12', heat .. " °c")
        elseif heat > 50 then
            _heat = core.colorize('#fcae12', heat .. " °c")
        elseif heat > 45 then
            _heat = core.colorize('#fcd112', heat .. " °c")
        elseif heat > 40 then
            _heat = core.colorize('#e5fc12', heat .. " °c")
        elseif heat > 35 then
            _heat = core.colorize('#c1fc12', heat .. " °c")
        elseif heat > 30 then
            _heat = core.colorize('#aafc12', heat .. " °c")
        elseif heat > 25 then
            _heat = core.colorize('#5cfc12', heat .. " °c")
        elseif heat > 20 then
            _heat = core.colorize('#12fc77', heat .. " °c")
        elseif heat > 15 then
            _heat = core.colorize('#12fcbe', heat .. " °c")
        elseif heat > 10 then
            _heat = core.colorize('#12e8fc', heat .. " °c")
        elseif heat > 5 then
            _heat = core.colorize('#127bfc', heat .. " °c")
        elseif heat > 0 then
            _heat = core.colorize('#1239fc', heat .. " °c")
        else
            _heat = core.colorize('#3112fc', heat .. " °c")
        end

        local _eff = eff .. "%"
        if eff >= 99 then
            _eff = core.colorize('#12fc2d', _eff)
        elseif eff >= 80 then
            _eff = core.colorize('#54fc12', _eff)
        elseif eff >= 60 then
            _eff = core.colorize('#c5fc12', _eff)
        elseif eff >= 30 then
            _eff = core.colorize('#fc5c12', _eff)
        else
            _eff = core.colorize('#ff0f0f', _eff)
        end

        local mslots = 2
        if tier == "MV" or tier == "HV" then
            mslots = 3
        end

        local _hashrate = "~" .. hashrate .. " hps";
        if temp_over >= 3 then
            _hashrate = core.colorize('#ff0f0f', _hashrate)
        elseif temp_over == 2 then
            _hashrate = core.colorize('#f5671b', _hashrate)
        elseif temp_over == 1 then
            _hashrate = core.colorize('#faa60a', _hashrate)
        else
            _hashrate = core.colorize('#0afc8f', _hashrate)
        end
        if edit_mode == 1 then
            _hashrate = core.colorize('#7a7a7a', _hashrate)
        end

        local _en_demand = core.colorize('#5a85db', en_demand);
        if en_demand > 0 then
            _en_demand = core.colorize('#05a9f5', en_demand);
        end

        local save = ""
        if edit_mode == 1 then
            save = "button[6.0,2.45;1.0,0.25;save;Save]"
        end

        return "size[8,8]" .. default.gui_bg .. default.gui_bg_img .. default.gui_slots ..
                   "list[context;main;0.25,0.25;3,2]" .. "list[current_player;main;0,3.95;8,1]" ..
                   "list[context;module;0.25,2.6;" .. mslots .. ",1]" .. "list[context;reward;4.75,0.25;3,2]" ..
                   "list[current_player;main;0,5.15;8,3;8]" .. "listring[context;main]" .. "listring[context;module]" ..
                   "listring[context;reward]" .. "listring[current_player;main]" .. "label[0.25,-0.15;Miners]" ..
                   "label[3.25,-0.15;Hashes]" .. "label[3.25,0.185;" .. _hashrate .. "]" .. "label[0.25,2.2;Upgrades]" ..
                   "button[3.25,0.7;1.5,0.8;on;" .. on_btn .. "]" .. "button[3.25,1.4;1.5,0.8;off;" .. off_btn .. "]" ..
                   "label[4.75,-0.15;Rewards]" .. "field[5.05,3.1;3,1;channel;Channel;" .. def_chan .. "]" ..
                   "button[6.76,2.45;1.0,0.25;edit;Edit]" .. save ..
                   "label[3.25,3.1;Te= " .. _heat .. "]" .. "label[3.25,2.3;Eu= " .. _en_demand .. "]" ..
                   "label[3.25,2.7;Eff= " .. _eff .. "]"

    end

    -------------------------------------------------------
    -------------------------------------------------------

    if data.tube then
        groups.tubedevice = 1
        groups.tubedevice_receiver = 1
    end
    local active_groups = {
        not_in_creative_inventory = 1
    }
    for k, v in pairs(groups) do
        active_groups[k] = v
    end

    local tube = {
        input_inventory = 'reward',
        insert_object = function(pos, node, stack, direction)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            local added = nil
            local g_miner = core.get_item_group(stack:get_name(), "asic")
            if g_miner > 0 then
                added = inv:add_item("main", stack)
            end
            local g_module = n_hasher.is_upgrade_part(stack)
            if g_module then
                added = inv:add_item("module", stack)
            end
            return added
        end,
        can_insert = function(pos, node, stack, direction)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            local g_miner = core.get_item_group(stack:get_name(), "asic")
            if g_miner > 0 then
                return inv:room_for_item("main", stack)
            end
            local g_module = n_hasher.is_upgrade_part(stack)
            if g_module then
                return inv:room_for_item("module", stack)
            end
            return false
        end,
        connect_sides = {
            left = 1,
            right = 1,
            -- back = 1,
            top = 1,
            bottom = 1
        }
    }

    if data.can_insert then
        tube.can_insert = data.can_insert
    end
    if data.insert_object then
        tube.insert_object = data.insert_object
    end

    -------------------------------------------------------
    -------------------------------------------------------

    -- technic run
    local run = function(pos, node)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        local machine_node = data.modname .. ":" .. ltier .. "_" .. machine_name
        local machine_desc_tier = machine_desc:format(tier)
        local eu_input = meta:get_int(tier .. "_EU_input")

        -- tick check for run interval
        local tick = (meta:get_int("tick") or 0) + 1
        if tick < 3 then
            meta:set_int("tick", tick)
            return
        end
        meta:set_int("tick", math.random(0, 1))

        -- Setup meta data if it does not exist.
        if not eu_input then
            meta:set_int(tier .. "_EU_demand", data.demand[1])
            meta:set_int(tier .. "_EU_input", 0)
            return
        end
        if meta:get_int("edit_mode") == nil then
            meta:set_string("edit_mode", 0)
        end

        -- get upgrades, apply and get power reduction
        local upgrades = n_hasher.get_upgrades(pos)
        local power_reduction = n_hasher.apply_upgrades(pos, upgrades, tier)

        -- get miners
        local miners = n_hasher.get_hashing_cards(inv)
        -- get miner power demand
        local miner_demand = n_hasher.get_power_draw(miners, tier) - power_reduction
        -- calc power draws...
        local machine_demand_active = data.demand[1] + miner_demand
        local machine_demand_idle = (data.demand[1] * 0.4) + (miner_demand * 0.6)
        local running = eu_input >= machine_demand_active - 5
        local powered = eu_input >= machine_demand_idle - 5

        -- check area atmos
        local has_air = n_hasher.heat.check_has_air(pos)
        local has_vac = n_hasher.heat.check_has_vac(pos)
        local temp = meta:get_int("temp")
        temp = n_hasher.heat.apply_temp_heat(pos, temp, has_air, has_vac)
        -- get enabled
        local enabled = meta:get_int("enabled") == 1

        -- check has air
        if has_air < 1 and powered and enabled then
            if has_vac >= 3 then
                meta:set_string("infotext", S("%s Error - No local atmosphere!"):format(machine_desc_tier))
                meta:set_int(tier .. "_EU_demand", 0)
            elseif temp >= 99 then
                meta:set_string("infotext", S("%s Disabled - Nearby air too hot!"):format(machine_desc_tier))
                meta:set_int(tier .. "_EU_demand", 0)
            else
                meta:set_string("infotext", S("%s Warning - Nearby air too warm!"):format(machine_desc_tier))
                meta:set_int(tier .. "_EU_demand", machine_demand_idle)
            end
            meta:set_int("temp_over", 3)
            -- meta:set_int("src_time", 0)
            if meta:get_int("edit_mode") == 0 then
                meta:set_string("formspec", get_formspec(pos, data))
            end
            return
        end

        -- check and handle running miners
        if powered and running and miners.total > 0 then
            local pos_str = pos.x .. "," .. pos.y .. "," .. pos.z
            local hash_id = sha.sha256(pos_str)
            if temp >= 80 then
                local olt = miners.total
                local sub = 1;
                if temp >= 85 then
                    sub = 3;
                end
                miners.asic_miner = math.max(0, miners.asic_miner - sub)
                miners.pow_miner = math.max(0, miners.pow_miner - sub)
                local eff = ((miners.asic_miner + miners.pow_miner) / olt) * 100
                meta:set_int("efficiency", eff)
                meta:set_int("temp_over", 2)
                -- change to damage hashing card due to high heat
                n_hasher.damage_miner_hasher(pos, miners, temp)
            else
                if temp >= 65 then
                    n_hasher.damage_miner_hasher(pos, miners, temp)
                end
                n_hasher.particle_effect(pos, miners.total, tier)
                local olt = miners.total
                local eff = ((miners.asic_miner + miners.pow_miner) / olt) * 100
                meta:set_int("efficiency", eff)
                meta:set_int("temp_over", 0)
                local over_tick = meta:get_int("temp_over_tick")
                if over_tick > 0 then
                    meta:set_int("temp_over_tick", over_tick - 1)
                end
            end
            local miner = {
                hash_id = hash_id,
                pos = pos,
                miners = miners,
                upgrades = upgrades,
                tier = tier,
                rate = 0,
                temp = temp
            }
            testcoin.calc_hashrate(miner)
            testcoin.miners_active[pos_str] = miner
            if miners.total > 0 then
                n_hasher.heat.apply_miner_heat(pos, miner, has_vac, has_air)
            end
            if temp >= 50 then
                core.after(25, function()
                    n_hasher.heat.do_near_heat(pos, 3)
                end)
            end
        end
        -- tick src timer if powered
        if powered then
            meta:set_int("src_time", meta:get_int("src_time") + round(data.speed * 10 * 1.0))
        end

        while true do
            if (not enabled) then
                local pos_str = pos.x .. "," .. pos.y .. "," .. pos.z
                if testcoin.miners_active[pos_str] ~= nil then
                    testcoin.miners_active[pos_str] = nil
                end
                meta:set_int("temp_over", 3)
                meta:set_int("hashrate", 0)
                -- technic.swap_node(pos, machine_node)
                meta:set_string("infotext", S("%s Disabled"):format(machine_desc_tier))
                meta:set_int(tier .. "_EU_demand", 0)
                meta:set_int("src_time", 0)
                if meta:get_int("edit_mode") == 0 then
                    meta:set_string("formspec", get_formspec(pos, data))
                end
                return
            end

            -- technic.swap_node(pos, machine_node .. "_active")
            meta:set_int(tier .. "_EU_demand", machine_demand_idle)
            if has_air then
                meta:set_int(tier .. "_EU_demand", machine_demand_active)
            end

            if (not powered and not running) or miners.total == 0 then
                -- meta:set_int(tier .. "_EU_demand", machine_demand_idle)
                local pos_str = pos.x .. "," .. pos.y .. "," .. pos.z
                if testcoin.miners_active[pos_str] ~= nil then
                    testcoin.miners_active[pos_str] = nil
                end
                meta:set_int("temp_over", 1)
                if temp >= 55 then
                    n_hasher.heat.do_near_heat(pos)
                end
            elseif running then
                meta:set_string("infotext", S("%s Operational"):format(machine_desc_tier))
            elseif powered then
                meta:set_string("infotext", S("%s Initializing"):format(machine_desc_tier))
            end

            if math.random(0, 2) == 0 then
                play_sound_fan(pos)
            end

            -- meta:set_string("infotext", S("%s Active"):format(machine_desc_tier))
            if meta:get_int("src_time") < round(time_scl * 10) then
                local item_percent = math.floor(meta:get_int("src_time") / round(time_scl * 10)) * 100
                if not running then
                    meta:set_string("infotext", S("%s Powered"):format(machine_desc_tier))
                    -- meta:set_string("formspec", get_formspec(pos, data))
                    -- meta:set_int("temp_over", 2)
                    -- meta:set_int("hashrate", 0)
                elseif not powered and not running then
                    -- technic.swap_node(pos, machine_node)
                    meta:set_string("infotext", S("%s Unpowered"):format(machine_desc_tier))
                    -- meta:set_string("formspec", get_formspec(pos, data))
                    meta:set_int("temp_over", 3)
                    meta:set_int("hashrate", 0)
                    -- meta:set_int(tier .. "_EU_demand", 0)
                end
                if meta:get_int("edit_mode") == 0 then
                    meta:set_string("formspec", get_formspec(pos, data))
                end
                return
            end

            meta:set_int("src_time", meta:get_int("src_time") - round(time_scl * 10))
            -- return
        end
    end

    -------------------------------------------------------
    -- register machine node

    local node_name = data.modname .. ":" .. ltier .. "_" .. machine_name
    core.register_node(node_name, {
        description = machine_desc,
        tiles = {ltier .. "_" .. tmachine_name .. "_top.png", ltier .. "_" .. tmachine_name .. "_bottom.png",
                 ltier .. "_" .. tmachine_name .. "_side.png", ltier .. "_" .. tmachine_name .. "_side.png",
                 ltier .. "_" .. tmachine_name .. "_back.png", ltier .. "_" .. tmachine_name .. "_front.png"},
        paramtype = "light",
        paramtype2 = "facedir",
        drawtype = "nodebox",
        node_box = {
            type = "fixed",
            fixed = {{-0.5, -0.5, -0.5, -0.4375, 0.5, 0.5}, -- NodeBox2
            {-0.4375, -0.5, -0.5, 0.4375, -0.4375, 0.5}, -- NodeBox3
            {0.4375, -0.5, -0.5, 0.5, 0.5, 0.5}, -- NodeBox4
            {-0.4375, 0.4375, -0.5, 0.4375, 0.5, 0.5}, -- NodeBox5
            {-0.4375, -0.0625, -0.5, 0.4375, 0.0625, 0.5} -- NodeBox6
            }
        },
        selection_box = {
            type = "fixed",
            fixed = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}}
        },
        mesh = nil,
        drop = data.modname .. ":" .. ltier .. "_" .. machine_name,
        groups = groups,
        tube = data.tube and tube or nil,
        connect_sides = data.connect_sides or connect_default,
        sounds = default.node_sound_metal_defaults(),
        on_construct = function(pos)
            local meta = core.get_meta(pos)
            -- core.log(dump(meta))
            -- Initialize data
            meta:set_int("tube_time", 0)
            meta:set_int("enabled", 1)
            meta:set_int("edit_mode", 0)
            meta:set_int("hashrate", 0)
            meta:set_int("temp", 20)
            meta:set_int("temp_over", 0)
            meta:set_int("temp_over_tick", 0)
            meta:set_int("efficiency", 0)
            meta:set_int("tick", 0)
            meta:set_string("digilines_channel", machine_name .. "(" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ")")
            -- Initialize inventory
            local inv = meta:get_inventory()
            inv:set_size("main", 6)
            inv:set_size("module", 3)
            inv:set_size("reward", 6)
            -- Initialize formspec
            meta:set_string("formspec", get_formspec(pos, data))
        end,
        allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
            if core.is_protected(pos, player:get_player_name()) then
                return 0
            end
            local stack = core.get_meta(pos):get_inventory():get_stack(from_list, from_index)
            if to_list == "module" then
                if not n_hasher.is_upgrade_part(stack) then
                    return 0
                end
            end
            if to_list == "main" then
                local g_miner = core.get_item_group(stack:get_name(), "asic")
                if g_miner == 0 then
                    return 0
                end
            end
            if to_list == "reward" then
                if stack:get_name() ~= "testcoin:coin" then
                    return 0
                end
            end
            return technic.machine_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
        end,
        allow_metadata_inventory_put = function(pos, listname, index, stack, player)
            if core.is_protected(pos, player:get_player_name()) then
                return 0
            end
            if listname == "module" then
                if not n_hasher.is_upgrade_part(stack) then
                    return 0
                end
            end
            if listname == "main" then
                local g_miner = core.get_item_group(stack:get_name(), "asic")
                if g_miner == 0 then
                    return 0
                end
            end
            if listname == "reward" then
                if stack:get_name() ~= "testcoin:coin" then
                    return 0
                end
            end
            return technic.machine_inventory_put(pos, listname, index, stack, player)
        end,
        allow_metadata_inventory_take = function(pos, listname, index, stack, player)
            if core.is_protected(pos, player:get_player_name()) then
                return 0
            end
            return technic.machine_inventory_take(pos, listname, index, stack, player)
        end,
        -- on_metadata_inventory_put = update_shelf,
        -- on_metadata_inventory_take = update_shelf,
        on_metadata_inventory_put = n_hasher.shelf.update,
        on_metadata_inventory_take = n_hasher.shelf.update,
        technic_run = run,
        after_place_node = function(pos, placer, itemstack, pointed_thing)
            if data.tube then
                pipeworks.after_place(pos)
            end
            local meta = minetest.get_meta(pos)
            meta:set_string("infotext", machine_desc)
        end,
        after_dig_node = function(pos, oldnode, oldmetadata, digger)
            if data.tube then
                pipeworks.after_dig(pos)
            end
            return technic.machine_after_dig_node
        end,
        can_dig = technic.machine_can_dig,
        on_dig = function(pos, node, digger)
            -- Clear all object objects
            local objs = core.objects_inside_radius(pos, 1)
            for obj in objs do
                if obj:get_luaentity() and obj:get_luaentity().name == "testcoin:item" then
                    obj:remove()
                end
            end
            -- Remove miner
            local pos_str = pos.x .. "," .. pos.y .. "," .. pos.z
            if testcoin.miners_active[pos_str] ~= nil then
                testcoin.miners_active[pos_str] = nil
            end
            -- Pop-up items
            core.add_item(pos, node.name)
            local meta = core.get_meta(pos)
            local list1 = meta:get_inventory():get_list("main")
            for _, item in pairs(list1) do
                local drop_pos = {
                    x = math.random(pos.x - 0.5, pos.x + 0.5),
                    y = pos.y,
                    z = math.random(pos.z - 0.5, pos.z + 0.5)
                }
                core.add_item(drop_pos, item:to_string())
            end
            local list2 = meta:get_inventory():get_list("reward")
            for _, item in pairs(list2) do
                local drop_pos = {
                    x = math.random(pos.x - 0.5, pos.x + 0.5),
                    y = pos.y,
                    z = math.random(pos.z - 0.5, pos.z + 0.5)
                }
                core.add_item(drop_pos, item:to_string())
            end
            local list3 = meta:get_inventory():get_list("module")
            for _, item in pairs(list3) do
                local drop_pos = {
                    x = math.random(pos.x - 0.5, pos.x + 0.5),
                    y = pos.y,
                    z = math.random(pos.z - 0.5, pos.z + 0.5)
                }
                core.add_item(drop_pos, item:to_string())
            end
            -- Remove node
            core.remove_node(pos)
        end,
        on_blast = function(pos)
            core.add_item(pos, core.get_node(pos).name)
            local pos_str = pos.x .. "," .. pos.y .. "," .. pos.z
            if testcoin.miners_active[pos_str] ~= nil then
                testcoin.miners_active[pos_str] = nil
            end
            local meta = core.get_meta(pos)
            local list1 = meta:get_inventory():get_list("main")
            for _, item in pairs(list1) do
                local drop_pos = {
                    x = math.random(pos.x - 0.5, pos.x + 0.5),
                    y = pos.y,
                    z = math.random(pos.z - 0.5, pos.z + 0.5)
                }
                core.add_item(drop_pos, item:to_string())
            end
            local list2 = meta:get_inventory():get_list("reward")
            for _, item in pairs(list2) do
                local drop_pos = {
                    x = math.random(pos.x - 0.5, pos.x + 0.5),
                    y = pos.y,
                    z = math.random(pos.z - 0.5, pos.z + 0.5)
                }
                core.add_item(drop_pos, item:to_string())
            end
            local list3 = meta:get_inventory():get_list("module")
            for _, item in pairs(list3) do
                local drop_pos = {
                    x = math.random(pos.x - 0.5, pos.x + 0.5),
                    y = pos.y,
                    z = math.random(pos.z - 0.5, pos.z + 0.5)
                }
                core.add_item(drop_pos, item:to_string())
            end
            -- Remove node
            core.remove_node(pos)
            return nil
        end,
        -- Screwdriver support
        on_rotate = function(pos, node, user, mode, new_param2) -- {name = node.name, param1 = node.param1, param2 = node.param2}, user, mode, new_param2)
            -- Rotate
            node.param2 = new_param2
            core.swap_node(pos, node)
            -- update_shelf(pos)
            n_hasher.shelf.update(pos)
            -- Disable rotation by screwdriver
            return false
        end,
        on_receive_fields = function(pos, formname, fields, sender)
            local meta = core.get_meta(pos)
            if fields.quit then
                meta:set_int("edit_mode", 0)
                return
            end
            --local node = core.get_node(pos)

            if fields.on then
                meta:set_int("enabled", 1)
            end
            if fields.off then
                meta:set_int("enabled", 0)
            end
            if fields.edit then
                if meta:get_int("edit_mode") == 0 then
                    meta:set_int("edit_mode", 1)
                else
                    meta:set_int("edit_mode", 0)
                end
            end
            if fields.save and fields.channel then
                meta:set_string("digilines_channel", fields.channel)
                meta:set_int("edit_mode", 0)
            end
            local formspec = get_formspec(pos, data)
            meta:set_string("formspec", formspec)
        end,
        digiline = {
            receptor = {
                action = function()
                end
            },
            effector = {
                action = testcoin.rig_digiline_effector
            }
        }
    })

    technic.register_machine(tier, node_name, technic.receiver)
end

-------------------------------------------------------
-------------------------------------------------------

-- Register Rig
register_mining_rig({
    tier = "LV",
    modname = "testcoin",
    machine_name = "mining_rig",
    machine_desc = "Mining Rig",
    demand = {200},
    speed = 1
})
register_mining_rig({
    tier = "MV",
    modname = "testcoin",
    machine_name = "mining_rig",
    machine_desc = "Mining Chassis",
    demand = {500},
    speed = 2
})
register_mining_rig({
    tier = "HV",
    modname = "testcoin",
    machine_name = "mining_rig",
    machine_desc = "Mining Rack",
    demand = {750},
    speed = 3
})
