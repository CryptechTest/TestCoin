testcoin.rig_digiline_effector = function(pos, node, channel, msg)
    local m = core.get_meta(pos)
    local set_channel = m:get_string("digilines_channel")

    local msgt = type(msg)

    if msgt ~= "table" then
        return
    end

    if channel ~= set_channel then
        return
    end

    if msg.command == "status" then
        local node = core.get_node(pos)
        local name = node.name
        local tier = "LV"
        if name == "testcoin:mv_mining_rig" then
            tier = "MV"
        elseif name == "testcoin:hv_mining_rig" then
            tier = "HV"
        end
        local meta = core.get_meta(pos)
        digilines.receptor_send(pos, digilines.rules.default, channel, {
            command = msg.command,
            enabled = meta:get_int("enabled"),
            hashrate = meta:get_int("hashrate"),
            energy = meta:get_int(tier .. "_EU_demand"),
            efficiency = meta:get_int("efficiency"),
            temperature = meta:get_int("temp")
        })
    end

    if msg.command == "enable" then
        local meta = core.get_meta(pos)
        meta:set_int("enabled", 1)
    end

    if msg.command == "disable" then
        local meta = core.get_meta(pos)
        meta:set_int("enabled", 0)
    end

end
