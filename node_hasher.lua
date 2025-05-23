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
            total = total + (count * (miner_draw.asic - deduction.asic) * 1.06)
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
            upgrades[iname] = (upgrades[iname] or 0) + 1
        elseif name == "technic:control_logic_unit" then
            local iname = 'control';
            upgrades[iname] = (upgrades[iname] or 0) + 1
        elseif name == "testcoin:control_logic_unit_adv" then
            local iname = 'control_adv';
            upgrades[iname] = (upgrades[iname] or 0) + 1
        elseif name == "ship_parts:eviromental_sys" then
            local iname = 'enviroment';
            upgrades[iname] = (upgrades[iname] or 0) + 1
        elseif name == "ship_machine:bottle_of_coolant" then
            local iname = 'coolant';
            upgrades[iname] = (upgrades[iname] or 0) + 1
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
    elseif name == "testcoin:control_logic_unit_adv" then
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
        -- reduces heat
        if tier == "HV" then
            hasher.heat.handle_temp(pos, -(2 * upgrades.heatsink), 0, 0, 5)
            reduction = reduction + 10
        elseif tier == "MV" then
            hasher.heat.handle_temp(pos, -(1 * upgrades.heatsink), 0, 0, 5)
            reduction = reduction + 30
        else
            hasher.heat.handle_temp(pos, -(1 * upgrades.heatsink), 0, 0, 5)
            reduction = reduction + 20
        end
    end
    if upgrades.control then
        -- boosts hashrate slightly and gives power reduction
        if tier == "HV" then
            reduction = reduction + (300 * upgrades.control)
        elseif tier == "MV" then
            reduction = reduction + (250 * upgrades.control)
        else
            reduction = reduction + (200 * upgrades.control)
        end
    end
    if upgrades.control_adv then
        -- boosts hashrate, uses more power and generates more heat
        if tier == "HV" then
            hasher.heat.handle_temp(pos, 1, upgrades.control_adv, 0, 5)
            reduction = reduction - (250 * upgrades.control_adv)
        elseif tier == "MV" then
            hasher.heat.handle_temp(pos, 1, upgrades.control_adv + 1, 0, 5)
            reduction = reduction - (200 * upgrades.control_adv)
        else
            hasher.heat.handle_temp(pos, 0, upgrades.control_adv + 1, 0, 5)
            reduction = reduction - (200 * upgrades.control_adv)
        end
    end
    if upgrades.enviroment then
        -- reduces heat and does small power reduction
        if tier == "HV" then
            hasher.heat.handle_temp(pos, -(2 * upgrades.enviroment), 0, 0, 3)
            reduction = reduction + 50
        else
            hasher.heat.handle_temp(pos, -(2 * upgrades.enviroment), 1, 0, 5)
            reduction = reduction + 80
        end
    end
    if upgrades.coolant then
        -- instant reduce heat
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
        r_b = math.random(0, 70000) -- asic
        over_tick = over_tick + 3
    elseif temp >= 90 then
        r_a = math.random(0, 400000) -- pow
        r_b = math.random(0, 200000) -- asic
        over_tick = over_tick + math.random(2, 3)
    elseif temp >= 85 then
        r_a = math.random(0, 2000000) -- pow
        r_b = math.random(0, 1000000) -- asic
        over_tick = over_tick + 2
    elseif temp >= 80 then
        r_a = math.random(0, 50000000) -- pow
        r_b = math.random(0, 25000000) -- asic
        over_tick = over_tick + math.random(1, 2)
    elseif temp >= 70 then
        r_a = math.random(0, 90000000) -- pow
        r_b = math.random(0, 50000000) -- asic
        over_tick = over_tick + math.random(0, 1)
    else
        if over_tick > 0 then
            over_tick = over_tick + math.random(-1, 1)
            meta:set_int("temp_over_tick", over_tick)
        end
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

local function spawn_particle(pos, dir_x, dir_y, dir_z, acl_x, acl_y, acl_z, size, time, amount, tier)
    local t_name = "testcoin_miner_effect_1.png"
    if tier == "MV" then
        t_name = "testcoin_miner_effect_2.png"
    elseif tier == "HV" then
        t_name = "testcoin_miner_effect_3.png"
    end
    local texture = {
        name = t_name,
        blend = "alpha",
        scale = 1.5,
        alpha = 1.0,
        alpha_tween = {1, 1, 0.5, 0.01},
        scale_tween = {{
            x = 1.75,
            y = 1.75
        }, {
            x = 0.1,
            y = 0.1
        }}
    }

    local prt = {
        texture = texture,
        vel = 1,
        time = (time or 6),
        size = (size or 1),
        glow = math.random(6, 10),
        cols = true
    }

    local rx = dir_x * prt.vel * (-math.random(0.3 * 100, 0.7 * 100) / 100)
    local ry = dir_y * prt.vel * (-math.random(0.3 * 100, 0.7 * 100) / 100)
    local rz = dir_z * prt.vel * (-math.random(0.3 * 100, 0.7 * 100) / 100)
    minetest.add_particlespawner({
        amount = amount + 2,
        -- pos = pos,
        minpos = {
            x = pos.x + -0.35,
            y = pos.y + -0.35,
            z = pos.z + -0.35
        },
        maxpos = {
            x = pos.x + 0.35,
            y = pos.y + 0.35,
            z = pos.z + 0.35
        },
        minvel = {
            x = rx * 0.25,
            y = ry * 0.25,
            z = rz * 0.25
        },
        maxvel = {
            x = rx,
            y = ry,
            z = rz
        },
        minacc = {
            x = acl_x * 0.5,
            y = acl_y * 0.5,
            z = acl_z * 0.5
        },
        maxacc = {
            x = acl_x * 2,
            y = acl_y * 2,
            z = acl_z * 2
        },
        time = prt.time + 2,
        minexptime = prt.time - math.random(0, 1),
        maxexptime = prt.time * 2,
        minsize = ((math.random(0.37, 0.63)) * 2 + 1.6) * prt.size,
        maxsize = ((math.random(0.77, 0.93)) * 2 + 1.6) * prt.size,
        collisiondetection = prt.cols,
        vertical = false,
        texture = texture,
        -- animation = animation,
        glow = prt.glow
    })
end

local is_player_near = function(pos)
    local objs = core.get_objects_inside_radius(pos, 16)
    for _, obj in pairs(objs) do
        if obj:is_player() then
            return true;
        end
    end
    return false;
end

local function particle_effect(pos, c, tier)
    if not is_player_near(pos) then
        return
    end
    local node = minetest.get_node(pos)
    local param2 = node.param2
    local dir = param2;
    local xdir = 0;
    local zdir = 0;
    if param2 == 0 then
        dir = 2
        zdir = 1.0
    elseif param2 == 1 then
        dir = 3
        xdir = 1.0
    elseif param2 == 2 then
        dir = 0
        zdir = -1.0
    elseif param2 == 3 then
        dir = 1
        xdir = -1.0
    end
    spawn_particle(pos, xdir * 1, math.random(-0.02, 0.005), zdir * 1, math.random(0.02, 0.1) * xdir, 0.2,
                   math.random(0.02, 0.1) * zdir, 0.25, 2, 3 * c, tier)
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
hasher.particle_effect = particle_effect

return hasher
