--[[
itemshelf.register_shelf("testcoin:mining_rig", {
    description = "Mining Rig",
    textures = {
        "default_stone.png",
        "default_stone.png",
        "default_stone.png",
        "default_stone.png",
        "default_stone.png",
        "default_stone.png",
    },
    nodebox = {
        type = "fixed",
        fixed = {
            { -0.5,    -0.5,    0.4375, 0.5,     0.5,     0.5 },    -- NodeBox1
            { -0.5,    -0.5,    -0.5,   -0.4375, 0.5,     0.4375 }, -- NodeBox2
            { -0.4375, -0.5,    -0.5,   0.4375,  -0.4375, 0.4375 }, -- NodeBox3
            { 0.4375,  -0.5,    -0.5,   0.5,     0.5,     0.4375 }, -- NodeBox4
            { -0.4375, 0.4375,  -0.5,   0.4375,  0.5,     0.4375 }, -- NodeBox5
            { -0.4375, -0.0625, -0.5,   0.4375,  0.0625,  0.4375 }, -- NodeBox6
        }
    },
    capacity = 6,
    shown_items = 6,
})
]]
--



local function get_formspec()
    return "size[8,7]" ..
        default.gui_bg ..
        default.gui_bg_img ..
        default.gui_slots ..
        "list[context;main;0.25,0.5;3,2]" ..
        "list[context;module;4.75,1.5;3,1]" ..
        "list[current_player;main;0,2.75;8,1]" ..
        "list[current_player;main;0,4;8,3;8]" ..
        "listring[context;main]" ..
        "listring[context;module]" ..
        "listring[current_player;main]" ..
        "label[0.25,0;Miners]" ..
        "label[3.2,0.2;Hashrate: 0 hps]" ..
        "label[4.75,1.05;Upgrades]" ..
        "button[3.25,0.75;1.5,0.8;;On]" ..
        "button[3.25,1.75;1.5,0.8;;Off]" ..
        "field[5.05,0.6;3,1;channel;Channel;]"
    --"list[context;main;2.5,0.25;3,2;]" ..
    --"list[current_player;main;0,2.75;8,1;]" ..
    --"list[current_player;main;0,4;8,3;8]" ..
    --"listring[context;main]" ..
    --"listring[current_player;main]"
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
                --minetest.log("Size: "..dump(temp_size))
                local ent = minetest.add_entity(obj_pos, "testcoin:item")
                ent:set_properties({
                    wield_item = temp_texture,
                    visual_size = { x = 0.8 / max_shown_items, y = 0.8 / max_shown_items }
                })
                ent:set_yaw(minetest.dir_to_yaw(minetest.facedir_to_dir(node.param2)))
            end
        end
    end
end


minetest.register_node("testcoin:mining_rig", {
    description = "Mining Rig",
    tiles = {
        "default_stone.png",
        "default_stone.png",
        "default_stone.png",
        "default_stone.png",
        "default_stone.png",
        "default_stone.png",
    },
    paramtype = "light",
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = {
            { -0.5,    -0.5,    0.4375, 0.5,     0.5,     0.5 },    -- NodeBox1
            { -0.5,    -0.5,    -0.5,   -0.4375, 0.5,     0.4375 }, -- NodeBox2
            { -0.4375, -0.5,    -0.5,   0.4375,  -0.4375, 0.4375 }, -- NodeBox3
            { 0.4375,  -0.5,    -0.5,   0.5,     0.5,     0.4375 }, -- NodeBox4
            { -0.4375, 0.4375,  -0.5,   0.4375,  0.5,     0.4375 }, -- NodeBox5
            { -0.4375, -0.0625, -0.5,   0.4375,  0.0625,  0.4375 }, -- NodeBox6
        }
    },
    mesh = nil,
    groups = { oddly_breakable_by_hand = 2, choppy = 2, itemshelf_shown_items = 6 },
    on_construct = function(pos)
        -- Initialize inventory
        local meta = minetest.get_meta(pos)
        minetest.log(dump(meta))
        local inv = meta:get_inventory()
        inv:set_size("main", 6)
        inv:set_size("module", 3)
        -- Initialize formspec
        meta:set_string("formspec", get_formspec())
        -- If given half_depth, initialize the displacement
        --if def.half_depth == true then
        --    meta:set_float("itemshelf:depth_displacement", -0.1475)
        --end
        -- Initialize custom displacements if defined
        --if def.vertical_offset then
        --    meta:set_float("itemshelf:vertical_displacement", def.vertical_offset)
        --end
        --if def.depth_offset then
        --    meta:set_float("itemshelf:depth_displacement", def.depth_offset)
        --end
    end,
    allow_metadata_inventory_move = function(pos, from_list, from_index,
                                             to_list, to_index, count, player)
        if minetest.is_protected(pos, player:get_player_name()) then
            return 0
        end
        return count
    end,
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        if minetest.is_protected(pos, player:get_player_name()) then
            return 0
        end
        return stack:get_count()
    end,
    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        if minetest.is_protected(pos, player:get_player_name()) then
            return 0
        end
        return stack:get_count()
    end,
    on_metadata_inventory_put = update_shelf,
    on_metadata_inventory_take = update_shelf,
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
    on_rotate = function(pos, node, user, mode, new_param2) --{name = node.name, param1 = node.param1, param2 = node.param2}, user, mode, new_param2)
        -- Rotate
        node.param2 = new_param2
        minetest.swap_node(pos, node)
        update_shelf(pos)
        -- Disable rotation by screwdriver
        return false
    end,
})
-- Entity for item displayed on shelf
minetest.register_entity("testcoin:item", {
    hp_max = 1,
    visual = "wielditem",
    visual_size = { x = 0.3, y = 0.3 },
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
            self.visual_size = { x = self.visualsize, y = self.visualsize }
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
    end,
})
