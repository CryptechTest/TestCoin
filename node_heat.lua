local function check_has_air(pos)
    -- check if near air...
    local pos1 = vector.subtract(pos, {
        x = 2,
        y = 1,
        z = 2
    })
    local pos2 = vector.add(pos, {
        x = 2,
        y = 2,
        z = 2
    })
    local near_air = core.find_nodes_in_area(pos1, pos2, {"air", "ctg_airs:atmos_warm"})
    if #near_air >= 1 then
        local nair = 0
        for _, n in pairs(near_air) do
            local d = vector.distance(pos, n)
            if d < 1.65 then
                nair = nair + 1
            end
        end
        return nair
    end
    return 0
end

local function check_has_air_hot(pos)
    -- check if near hot air...
    local pos1 = vector.subtract(pos, {
        x = 2,
        y = 2,
        z = 2
    })
    local pos2 = vector.add(pos, {
        x = 2,
        y = 2,
        z = 2
    })
    local near_air = core.find_nodes_in_area(pos1, pos2, {"ctg_airs:atmos_hot", "ctg_airs:atmos_warm"})
    if #near_air >= 1 then
        local nair = 0
        for _, n in pairs(near_air) do
            local d = vector.distance(pos, n)
            if d < 1.95 then
                nair = nair + 1
            end
        end
        return nair
    end
    return 0
end

local function check_has_vac(pos)
    -- check if near vacuum...
    local pos1 = vector.subtract(pos, {
        x = 2,
        y = 1,
        z = 2
    })
    local pos2 = vector.add(pos, {
        x = 2,
        y = 2,
        z = 2
    })
    local near_air = core.find_nodes_in_area(pos1, pos2, {"vacuum:vacuum", "vacuum:atmos_thin"})
    if #near_air >= 1 then
        local nair = 0
        for _, n in pairs(near_air) do
            local d = vector.distance(pos, n)
            if d < 1.95 then
                nair = nair + 1
            end
        end
        return nair
    end
    return 0
end

-- heat nearby air
local function do_near_heat(pos, stren)
    stren = stren or 0
    testcoin.fill_atmos_hot(pos, 1 + stren)
end

-- handle temperature effects and changes
local function handle_temp(pos, min, max, vac, air)
    local meta = core.get_meta(pos)
    local temp = meta:get_int("temp")
    if temp == nil then
        meta:set_int("temp", 20)
    end
    if meta:get_int("temp_over") == nil then
        meta:set_int("temp_over", 0)
    end
    if meta:get_int("temp_over_tick") == nil then
        meta:set_int("temp_over_tick", 0)
    end
    local bias = 0
    -- temp over nominal
    if temp > 30 then
        bias = -1
    end
    -- temp below nominal
    if temp < 10 then
        bias = 2
    elseif temp < 20 then
        bias = 1
    end
    -- vacuum is cold
    if vac > 1 then
        bias = bias - vac
    end
    -- if not near too much cold, check for heat...
    if vac < 2 or air < 7 then
        local has_heat = check_has_air_hot(pos)
        if has_heat > 4 then
            bias = bias + 3
        elseif has_heat > 2 then
            bias = bias + 2
        elseif has_heat > 0 then
            bias = bias + math.random(0, 1)
        end
    end
    -- if near air, bias cooling
    if air > 4 then
        bias = bias - math.random(0, 3)
        if temp > 60 then
            min = min - 2
        elseif temp > 21 then
            min = min - 1
        end
        if temp > 27 then
            max = max - 1
        end
    end
    -- near air and temp is cool
    if air > 5 and temp < 25 then
        bias = bias + 2
    elseif air > 1 and temp < 20 then
        bias = bias + 1
    end
    -- bias cooling when kinda hot...
    if temp > 75 then
        bias = bias - math.random(1, 3)
    end
    -- apply new temperature with bias + range
    local new_temp = temp + bias + math.random(min, max)
    -- temperature min
    if new_temp < 0 then
        new_temp = -1
    end
    -- temperature max
    if new_temp > 100 then
        new_temp = 100
    end
    meta:set_int("temp", new_temp)
    return new_temp
end

-- apply heat from miner work
local function apply_miner_heat(pos, miner, has_vac, has_air)
    local temp = miner.temp
    local mt = miner.miners.total
    local heat = 2
    if miner.miners.pow_miner > 0 then
        heat = heat + (miner.miners.pow_miner * 0.34)
    end
    if miner.miners.asic_miner > 0 then
        heat = heat + (miner.miners.asic_miner * 0.67)
    end
    if mt > 3 then
        temp = handle_temp(pos, 1, heat, has_vac, has_air)
        if temp > 90 then
            do_near_heat(pos, 5)
        elseif temp > 80 then
            do_near_heat(pos, 4)
        elseif temp > 70 then
            do_near_heat(pos, 3)
        else
            do_near_heat(pos, 2)
        end
    elseif mt > 0 then
        temp = handle_temp(pos, 0, heat, has_vac, has_air)
        if temp > 64 then
            do_near_heat(pos, 4)
        elseif temp > 55 then
            do_near_heat(pos, 3)
        else
            do_near_heat(pos, 2)
        end
    end
end

-- apply heat based on input temp and parameters
local function apply_temp_heat(pos, temp, has_air, has_vac)
    if has_air > 1 then
        local r = 1
        if has_air > 2 then
            r = math.random(0, 1)
        end
        if temp > 88 and has_air > 3 then
            temp = handle_temp(pos, -5, 1, has_vac, has_air)
        elseif temp > 80 and has_air > 2 then
            temp = handle_temp(pos, -3, 1, has_vac, has_air)
        elseif temp > 50 then
            temp = handle_temp(pos, -2, r, has_vac, has_air)
        else
            temp = handle_temp(pos, -1, r, has_vac, has_air)
        end
    else
        temp = handle_temp(pos, 0, 2, has_vac, has_air)
    end
    if has_vac > 1 then
        temp = handle_temp(pos, -10, -(math.max(7, has_vac)), has_vac, has_air)
    end
    return temp
end

-------------------------------------------------------
-------------------------------------------------------
-- Export

local node_heat = {}

node_heat.check_has_air = check_has_air
node_heat.check_has_air_hot = check_has_air_hot
node_heat.check_has_vac = check_has_vac
node_heat.do_near_heat = do_near_heat
node_heat.handle_temp = handle_temp
node_heat.apply_miner_heat = apply_miner_heat
node_heat.apply_temp_heat = apply_temp_heat

return node_heat
