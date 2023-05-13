local function get_formspec(pos, data)
    local meta = minetest.get_meta(pos)
    local def_chan = meta:get_string("digilines_channel")
    local hashrate = meta:get_string("hashrate")

    return
        "size[8,7]" .. default.gui_bg .. default.gui_bg_img .. default.gui_slots .. "list[context;main;0.25,0.5;3,2]" ..
        "list[context;module;4.75,1.5;3,1]" .. "list[current_player;main;0,2.75;8,1]" ..
        "list[current_player;main;0,4;8,3;8]" .. "listring[context;main]" .. "listring[context;module]" ..
        "listring[current_player;main]" .. "label[0.25,0;Miners]" .. "label[3.2,0.2;" .. hashrate .. " hps]" ..
        "label[4.75,1.05;Upgrades]" .. "button[3.25,0.75;1.5,0.8;on;On]" .. "button[3.25,1.75;1.5,0.8;off;Off]" ..
        "field[5.05,0.6;3,1;channel;Channel;" .. def_chan .. "]"
end

local temp_texture
local temp_size

local function get_obj_dir(param2)
    return ((param2 + 1) % 4)
end

local function update_shelf(pos)
    -- Remove all objects
    local objs = minetest.get_objects_inside_radius(pos, 0.75)
    for _, obj in pairs(objs) do
        obj:remove()
    end

    local node = minetest.get_node(pos)
    local meta = minetest.get_meta(pos)
    -- Calculate directions
    local node_dir = minetest.facedir_to_dir(((node.param2 + 2) % 4))
    local obj_dir = minetest.facedir_to_dir(get_obj_dir(node.param2))
    -- Get maximum number of shown items (4 or 6)
    local max_shown_items = minetest.get_item_group(node.name, "itemshelf_shown_items")
    -- Get custom displacement properties
    local depth_displacement = meta:get_float("testcoin:depth_displacement") or 0
    local vertical_displacement = meta:get_float("testcoin:vertical_displacement") or 0
    if depth_displacement == 0 then
        depth_displacement = 0.25
    end
    if vertical_displacement == 0 then
        vertical_displacement = 0.2
    end
    minetest.log("displacements: " .. dump(depth_displacement) .. ", " .. dump(vertical_displacement))
    -- Calculate the horizontal displacement. This one is hardcoded so that either 4 or 6
    -- items are properly displayed.
    local horizontal_displacement = 0.715
    if max_shown_items == 6 then
        horizontal_displacement = 0.555
    end

    -- Calculate initial position for entities
    -- local start_pos = {
    -- 	x=pos.x - (0.25 * obj_dir.x) - (node_dir.x * 0.25),
    -- 	y=pos.y + 0.25,
    -- 	z=pos.z - (0.25 * obj_dir.z) - (node_dir.z * 0.25)
    -- }
    -- How the below works: Following is a top view of a node
    --                              | +z (N) 0
    --                              |
    -- 					------------------------
    -- 					|           |          |
    -- 					|           |          |
    -- 					|           |          |
    --     -x (W) 3     |           | (0,0)    |      +x (E) 1
    --     -------------|-----------+----------|--------------
    -- 					|           |          |
    -- 					|           |          |
    -- 					|           |          |
    -- 					|           |          |
    -- 					------------------------
    -- 				                |
    -- 								| -z (S) 2

    -- From the picture above, your front could be at either -z, -z, x or z.
    -- To get the entity closer to the front, you need to add a certain amount
    -- (e.g. 0.25) to the x and z coordinates, and then multiply these by the
    -- the node direction (which is a vector pointing outwards of the node face).
    -- Therefore, start_pos is:
    local start_pos = {
        x = pos.x - (obj_dir.x * horizontal_displacement) + (node_dir.x * depth_displacement),
        y = pos.y + vertical_displacement,
        z = pos.z - (obj_dir.z * horizontal_displacement) + (node_dir.z * depth_displacement)
    }

    -- Calculate amount of objects in the inventory
    local inv = minetest.get_meta(pos):get_inventory()
    local list = inv:get_list("main")
    local obj_count = 0
    for key, itemstack in pairs(list) do
        if not itemstack:is_empty() then
            obj_count = obj_count + 1
        end
    end
    minetest.log("Found " .. dump(obj_count) .. " items on shelf inventory")
    if obj_count > 0 then
        local shown_items = math.min(#list, max_shown_items)
        for i = 1, shown_items do
            local offset = i
            if i > (shown_items / 2) then
                offset = i - (shown_items / 2)
            end
            if i == ((shown_items / 2) + 1) then
                start_pos.y = start_pos.y - 0.5125
            end
            local item_displacement = 0.475
            if shown_items == 6 then
                item_displacement = 0.2775
            end
            local obj_pos = {
                x = start_pos.x + (item_displacement * offset * obj_dir.x), --- (node_dir.z * overhead * 0.25),
                y = start_pos.y,
                z = start_pos.z + (item_displacement * offset * obj_dir.z)  --- (node_dir.x * overhead * 0.25)
            }

            if not list[i]:is_empty() then
                minetest.log("Adding item entity at " .. minetest.pos_to_string(obj_pos))
                temp_texture = list[i]:get_name()
                temp_size = 0.8 / max_shown_items
                -- minetest.log("Size: "..dump(temp_size))
                local ent = minetest.add_entity(obj_pos, "testcoin:item")
                ent:set_properties({
                    wield_item = temp_texture,
                    visual_size = {
                        x = 0.8 / max_shown_items,
                        y = 0.8 / max_shown_items
                    }
                })
                ent:set_yaw(minetest.dir_to_yaw(minetest.facedir_to_dir(node.param2)))
            end
        end
    end
end

local time_scl = 25

local function round(v)
    return math.floor(v + 0.5)
end

-------------------------------------------------------

-- register_mining_rig
local function register_mining_rig(data)
    local tier = data.tier
    local ltier = string.lower(tier)
    local machine_name = data.machine_name
    local machine_desc = data.machine_desc
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

    -- technic run
    local run = function(pos, node)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        local eu_input = meta:get_int(tier .. "_EU_input")

        local machine_desc_tier = machine_desc:format(tier)
        local machine_node = data.modname .. ":" .. ltier .. "_" .. machine_name
        local machine_demand_active = data.demand
        local machine_demand_idle = data.demand[1] * 0.6

        -- Setup meta data if it does not exist.
        if not eu_input then
            meta:set_int(tier .. "_EU_demand", machine_demand_active[1])
            meta:set_int(tier .. "_EU_input", 0)
            return
        end

        if not meta:get_int("enabled") then
            meta:set_int("enabled", 0)
            return
        end

        local EU_upgrade, tube_upgrade = 0, 0
        if data.upgrade then
            EU_upgrade, tube_upgrade = technic.handle_machine_upgrades(meta)
        end

        local powered = eu_input >= machine_demand_active[EU_upgrade + 1]
        if powered then
            meta:set_int("src_time", meta:get_int("src_time") + round(data.speed * 10 * 1.0))
        end
        while true do
            local enabled = meta:get_int("enabled") == 1

            if (not enabled) then
                -- technic.swap_node(pos, machine_node)
                meta:set_string("infotext", S("%s Disabled"):format(machine_desc_tier))
                meta:set_int(tier .. "_EU_demand", 0)
                meta:set_int("src_time", 0)
                meta:set_string("formspec", get_formspec(pos, data))

                return
            end

            -- technic.swap_node(pos, machine_node .. "_active")
            meta:set_int(tier .. "_EU_demand", machine_demand_active[EU_upgrade + 1])

            if powered then
                -- technic.swap_node(pos, machine_node .. "_active")
                meta:set_string("infotext", S("%s Operational"):format(machine_desc_tier))
                meta:set_int(tier .. "_EU_demand", machine_demand_idle)
                meta:set_int("src_time", 0)
                meta:set_string("formspec", get_formspec(pos, data))
                -- apply gravity
                -- ship_machine.apply_gravity(pos)
                return
            end

            -- meta:set_string("infotext", S("%s Active"):format(machine_desc_tier))
            if meta:get_int("src_time") < round(time_scl * 10) then
                local item_percent = (math.floor(meta:get_int("src_time") / round(time_scl * 10) * 100))
                if not powered then
                    -- technic.swap_node(pos, machine_node)
                    meta:set_string("infotext", S("%s Unpowered"):format(machine_desc_tier))
                    meta:set_string("formspec", get_formspec(pos, data))
                    -- ship_machine.reset_generator(meta)
                    return
                end
                meta:set_string("formspec", get_formspec(pos, data))
                return
            end

            meta:set_int("src_time", meta:get_int("src_time") - round(time_scl * 10))
            -- return
        end
    end

    -------------------------------------------------------
    -- register machine node

    local node_name = data.modname .. ":" .. ltier .. "_" .. machine_name
    minetest.register_node(node_name, {
        description = data.machine_desc,
        tiles = {ltier .. "_" .. tmachine_name .. "_top.png", ltier .. "_" .. tmachine_name .. "_bottom.png",
                 ltier .. "_" .. tmachine_name .. "_side.png", ltier .. "_" .. tmachine_name .. "_side.png",
                 ltier .. "_" .. tmachine_name .. "_back.png", ltier .. "_" .. tmachine_name .. "_front.png"},
        paramtype = "light",
        paramtype2 = "facedir",
        drawtype = "nodebox",
        node_box = {
            type = "fixed",
            fixed = { { -0.5, -0.5, -0.5, -0.4375, 0.5, 0.5 },     -- NodeBox2
                { -0.4375, -0.5,    -0.5, 0.4375,  -0.4375, 0.5 }, -- NodeBox3
                { 0.4375,  -0.5,    -0.5, 0.5,     0.5,     0.5 }, -- NodeBox4
                { -0.4375, 0.4375,  -0.5, 0.4375,  0.5,     0.5 }, -- NodeBox5
                { -0.4375, -0.0625, -0.5, 0.4375,  0.0625,  0.5 }  -- NodeBox6
            }
        },
        mesh = nil,
        drop = data.modname .. ":" .. ltier .. "_" .. machine_name,
        groups = groups,
        sounds = default.node_sound_metal_defaults(),
        on_construct = function(pos)
            local meta = minetest.get_meta(pos)
            minetest.log(dump(meta))
            -- Initialize data
            meta:set_int("enabled", 1)
            meta:set_int("hashrate", 0)
            meta:set_string("digilines_channel", machine_name .. "(" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ")")
            -- Initialize inventory
            local inv = meta:get_inventory()
            inv:set_size("main", 6)
            inv:set_size("module", 3)
            -- Initialize formspec
            meta:set_string("formspec", get_formspec(pos))
        end,
        allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
            if minetest.is_protected(pos, player:get_player_name()) then
                return 0
            end
            return technic.machine_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
        end,
        allow_metadata_inventory_put = function(pos, listname, index, stack, player)
            if minetest.is_protected(pos, player:get_player_name()) then
                return 0
            end
            return technic.machine_inventory_put(pos, listname, index, stack, player)
        end,
        allow_metadata_inventory_take = function(pos, listname, index, stack, player)
            if minetest.is_protected(pos, player:get_player_name()) then
                return 0
            end
            return technic.machine_inventory_take(pos, listname, index, stack, player)
        end,
        on_metadata_inventory_put = update_shelf,
        on_metadata_inventory_take = update_shelf,
        technic_run = run,
        after_dig_node = function(pos, oldnode, oldmetadata, digger)
            return technic.machine_after_dig_node
        end,
        can_dig = technic.machine_can_dig,
        on_dig = function(pos, node, digger)
            -- Clear all object objects
            local objs = minetest.get_objects_inside_radius(pos, 0.7)
            for _, obj in pairs(objs) do
                obj:remove()
            end
            -- Pop-up items
            minetest.add_item(pos, node.name)
            local meta = minetest.get_meta(pos)
            local list = meta:get_inventory():get_list("main")
            for _, item in pairs(list) do
                local drop_pos = {
                    x = math.random(pos.x - 0.5, pos.x + 0.5),
                    y = pos.y,
                    z = math.random(pos.z - 0.5, pos.z + 0.5)
                }
                minetest.add_item(drop_pos, item:to_string())
            end
            -- Remove node
            minetest.remove_node(pos)
        end,
        on_blast = function(pos)
            minetest.add_item(pos, minetest.get_node(pos).name)
            local meta = minetest.get_meta(pos)
            local list = meta:get_inventory():get_list("main")
            for _, item in pairs(list) do
                local drop_pos = {
                    x = math.random(pos.x - 0.5, pos.x + 0.5),
                    y = pos.y,
                    z = math.random(pos.z - 0.5, pos.z + 0.5)
                }
                minetest.add_item(drop_pos, item:to_string())
            end
            -- Remove node
            minetest.remove_node(pos)
            return nil
        end,
        -- Screwdriver support
        on_rotate = function(pos, node, user, mode, new_param2) -- {name = node.name, param1 = node.param1, param2 = node.param2}, user, mode, new_param2)
            -- Rotate
            node.param2 = new_param2
            minetest.swap_node(pos, node)
            update_shelf(pos)
            -- Disable rotation by screwdriver
            return false
        end,
        on_receive_fields = function(pos, formname, fields, sender)
            if fields.quit then
                return
            end
            local node = minetest.get_node(pos)
            local meta = minetest.get_meta(pos)

            if fields.on then
                meta:set_int("enabled", 1)
            end
            if fields.off then
                meta:set_int("enabled", 0)
            end
            if fields.channel then
                meta:set_string("digilines_channel", fields.channel)
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
    demand = { 100 },
    speed = 1
})

-- Entity for item displayed on shelf
minetest.register_entity("testcoin:item", {
    hp_max = 1,
    visual = "wielditem",
    visual_size = {
        x = 0.3,
        y = 0.3
    },
    collisionbox = { 0, 0, 0, 0, 0, 0 },
    physical = false,
    on_activate = function(self, staticdata)
        -- Staticdata
        local data = {}
        if staticdata ~= nil and staticdata ~= "" then
            local cols = string.split(staticdata, "|")
            data["itemstring"] = cols[1]
            data["visualsize"] = tonumber(cols[2])
        end

        -- Texture
        if temp_texture ~= nil then
            -- Set texture from temp
            self.itemstring = temp_texture
            temp_texture = nil
        elseif staticdata ~= nil and staticdata ~= "" then
            -- Set texture from static data
            self.itemstring = data.itemstring
        end
        -- Set texture if available
        if self.itemstring ~= nil then
            self.wield_item = self.itemstring
        end

        -- Visual size
        if temp_size ~= nil then
            self.visualsize = temp_size
            temp_size = nil
        elseif staticdata ~= nil and staticdata ~= "" then
            self.visualsize = data.visualsize
        end
        -- Set visual size if available
        if self.visualsize ~= nil then
            self.visual_size = {
                x = self.visualsize,
                y = self.visualsize
            }
        end

        -- Set object properties
        self.object:set_properties(self)
    end,
    get_staticdata = function(self)
        local result = ""
        if self.itemstring ~= nil then
            result = self.itemstring .. "|"
        end
        if self.visualsize ~= nil then
            result = result .. self.visualsize
        end
        return result
    end
})
