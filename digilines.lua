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
        local meta = core.get_meta(pos)
        digilines.receptor_send(pos, digilines.rules.default, channel, {
            command = msg.command,
            hashrate = meta:get_int("hashrate"),
            demand = meta:get_int("LV_EU_demand"),
            enable = meta:get_int("enabled")
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
