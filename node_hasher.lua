local modname = core.get_current_modname()
local S = core.get_translator(modname)

local modpath = core.get_modpath(modname)
local node_shelf = dofile(modpath .. "/node_shelf.lua")
local node_heat = dofile(modpath .. "/node_heat.lua")

local hasher = {}
hasher.shelf = node_shelf
hasher.heat = node_heat

-------------------------------------------------------

local function get_hashing_cards(inv)
    local inv_main = inv:get_list("main")
    local inv_module = inv:get_list("module")

    local miners = {
        total = 0,
        pow_miner = 0,
        asic_miner = 0,
        pow_broke = 0,
        asic_broke = 0,
        stacks = {
            pow = {},
            asic = {}
        }
    }
    for i, stack in ipairs(inv_main) do
        local group_asic = core.get_item_group(stack:get_name(), "asic")
        local group_broke = core.get_item_group(stack:get_name(), "asic_broken")
        if group_asic > 0 then
            local name = stack:get_name()
            if group_broke == 1 then
                -- pow miner
                name = "pow_miner_broke"
            elseif group_broke == 2 then
                -- asic miner
                name = "asic_miner_broke"
            elseif group_asic == 1 then
                -- pow miner
                name = "pow_miner"
                table.insert(miners.stacks.pow, stack)
            elseif group_asic == 2 then
                -- asic miner
                name = "asic_miner"
                table.insert(miners.stacks.asic, stack)
            end
            local count = miners[name] or 0
            miners[name] = count + 1
            miners.total = miners.total + 1
        end
    end
    return miners
end

local function get_power_draw(miners, tier)
    local miner_draw = {
        pow = 1050,
        asic = 2000
    }
    local deduction = {
        pow = 0,
        asic = 0,
        total = 0
    }
    if tier == "MV" then
        deduction = {
            pow = 200,
            asic = 100,
            total = 25
        }
    elseif tier == "HV" then
        deduction = {
            pow = 300,
            asic = 200,
            total = 100
        }
    end
    local total = 0
    for miner, count in pairs(miners) do
        if miner == "pow_miner" then
            total = total + (count * (miner_draw.pow - deduction.pow))
        elseif miner == "asic_miner" then
            total = total + (count * (miner_draw.asic - deduction.asic))
        elseif miner == "pow_miner_broke" then
            total = total + (count * (miner_draw.pow - deduction.pow) * 1.08)
        elseif miner == "asic_miner_broke" then
            total = total + (count * (miner_draw.asic - deduction.asic) * 1.08)
        end
    end
    return (total - deduction.total) + math.random(-2, 3);
end

local function get_upgrades(pos)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    local inv_module = inv:get_list("module")
    local upgrades = {}
    for i, stack in ipairs(inv_module) do
        local name = stack:get_name()
        if name == "digistuff:heatsink" then
            local iname = 'heatsink';
            upgrades[iname] = upgrades[iname] or 1
        elseif name == "technic:control_logic_unit" then
            local iname = 'control';
            upgrades[iname] = upgrades[iname] or 1
        elseif name == "ship_parts:eviromental_sys" then
            local iname = 'enviroment';
            upgrades[iname] = upgrades[iname] or 1
        elseif name == "ship_machine:bottle_of_coolant" then
            local iname = 'coolant';
            upgrades[iname] = upgrades[iname] or 1
        end
    end
    return upgrades
end

local function is_upgrade_part(itemstack)
    local name = itemstack:get_name()
    if name == "digistuff:heatsink" then
        return true
    elseif name == "technic:control_logic_unit" then
        return true
    elseif name == "ship_parts:eviromental_sys" then
        return true
    elseif name == "ship_machine:bottle_of_coolant" then
        return true
    else
        return false
    end
end

local function spend_upgrade(pos, iname)
    local spent = false
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    local inv_module = inv:get_list("module")
    for i, stack in ipairs(inv_module) do
        local name = stack:get_name()
        if name == "ship_machine:bottle_of_coolant" and iname == "coolant" then
            local temp = meta:get_int("temp")
            if temp < 30 and math.random(0, 7) > 0 then
                break
            elseif temp < 40 and math.random(0, 5) > 0 then
                break
            elseif temp < 50 and math.random(0, 3) > 0 then
                break
            elseif math.random(0, 1) > 0 then
                break
            end
            spent = true
            stack:take_item(1)
            inv:set_stack("module", i, stack)
            inv:add_item("reward", "vessels:glass_bottle")
            local adj = 21
            if temp < 10 then
                adj = 5
            elseif temp < 20 then
                adj = 10
            end
            local new_temp = temp - adj
            if new_temp < 0 then
                new_temp = -1
            end
            meta:set_int("temp", new_temp)
            break
        end
    end
    return spent
end

local function apply_upgrades(pos, upgrades, tier)
    local reduction = 0
    if upgrades.heatsink then
        if tier == "HV" then
            hasher.heat.handle_temp(pos, -(2 * upgrades.heatsink), 1, 0, 5)
        else
            hasher.heat.handle_temp(pos, -(1 * upgrades.heatsink), 0, 0, 5)
        end
        reduction = reduction + 10
        if tier == "MV" then
            reduction = reduction + 20
        end
    end
    if upgrades.control then
        hasher.heat.handle_temp(pos, -(1 * upgrades.control), 0, 0, 5)
        if tier == "HV" then
            reduction = reduction + (300 * upgrades.control)
        else
            reduction = reduction + (200 * upgrades.control)
        end
    end
    if upgrades.enviroment then
        if tier == "HV" then
            hasher.heat.handle_temp(pos, -(2 * upgrades.enviroment), 0, 0, 3)
        else
            hasher.heat.handle_temp(pos, -(2 * upgrades.enviroment), 1, 0, 5)
        end
        reduction = reduction + 50
    end
    if upgrades.coolant then
        if spend_upgrade(pos, 'coolant') then
            reduction = reduction + 400
        end
    end
    return reduction
end

-- handle damage of hashing card if miner is too hot
local function damage_miner_hasher(pos, miners, temp)
    local meta = core.get_meta(pos)
    local over_tick = meta:get_int("temp_over_tick")
    local r_a, r_b
    if temp >= 95 then
        r_a = math.random(0, 100000) -- pow
        r_b = math.random(0, 50000) -- asic
        over_tick = over_tick + 2
    elseif temp >= 90 then
        r_a = math.random(0, 400000) -- pow
        r_b = math.random(0, 200000) -- asic
        over_tick = over_tick + math.random(1, 2)
    elseif temp >= 85 then
        r_a = math.random(0, 2000000) -- pow
        r_b = math.random(0, 1000000) -- asic
        over_tick = over_tick + 1
    elseif temp >= 80 then
        r_a = math.random(0, 50000000) -- pow
        r_b = math.random(0, 25000000) -- asic
        over_tick = over_tick + math.random(0, 1)
    else
        over_tick = over_tick + math.random(-1, 0)
        meta:set_int("temp_over_tick", over_tick)
        return
    end
    meta:set_int("temp_over_tick", over_tick)
    if r_a <= over_tick or r_b <= over_tick then
        local inv = meta:get_inventory()
        local list = meta:get_inventory():get_list("main")
        local indexes_a = {}
        local indexes_b = {}
        for i, item in pairs(list) do
            local m_card = core.get_item_group(item:get_name(), "asic")
            if m_card > 0 then
                if item:get_name() == "testcoin:pow_miner" and r_a <= over_tick then
                    table.insert(indexes_a, {
                        stack = item,
                        index = i,
                        new_item = "testcoin:pow_miner_broke"
                    })
                elseif item:get_name() == "testcoin:asic_miner" and r_b <= over_tick then
                    table.insert(indexes_b, {
                        stack = item,
                        index = i,
                        new_item = "testcoin:asic_miner_broke"
                    })
                end
            end
        end
        if #indexes_a > 0 then
            local item = indexes_a[math.random(1, #indexes_a)]
            item.stack:set_count(0)
            inv:set_stack("main", item.index, item.new_item)
            -- update_shelf(pos)
            hasher.shelf.update(pos)
        end
        if #indexes_b > 0 then
            local item = indexes_b[math.random(1, #indexes_b)]
            item.stack:set_count(0)
            inv:set_stack("main", item.index, item.new_item)
            -- update_shelf(pos)
            hasher.shelf.update(pos)
        end
    end
end

-------------------------------------------------------
-- Export

hasher.get_hashing_cards = get_hashing_cards
hasher.get_power_draw = get_power_draw
hasher.get_upgrades = get_upgrades
hasher.is_upgrade_part = is_upgrade_part
hasher.spend_upgrade = spend_upgrade
hasher.apply_upgrades = apply_upgrades
hasher.damage_miner_hasher = damage_miner_hasher

return hasher
