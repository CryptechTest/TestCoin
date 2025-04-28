local temp_texture
local temp_size

local function get_obj_dir(param2)
    return ((param2 + 1) % 4)
end

local function update_shelf(pos)
    -- Remove all objects
    local objs = core.objects_inside_radius(pos, 1)
    for obj in objs do
        obj:remove()
    end

    local node = core.get_node(pos)
    local meta = core.get_meta(pos)
    -- Calculate directions
    local node_dir = core.facedir_to_dir(((node.param2 + 2) % 4))
    local obj_dir = core.facedir_to_dir(get_obj_dir(node.param2))
    -- Get maximum number of shown items (4 or 6)
    local max_shown_items = core.get_item_group(node.name, "itemshelf_shown_items")
    -- Get custom displacement properties
    local depth_displacement = meta:get_float("testcoin:depth_displacement") or 0
    local vertical_displacement = meta:get_float("testcoin:vertical_displacement") or 0
    if depth_displacement == 0 then
        depth_displacement = 0.25
    end
    if vertical_displacement == 0 then
        vertical_displacement = 0.5
    end
    --core.log("displacements: " .. dump(depth_displacement) .. ", " .. dump(vertical_displacement))
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
    local inv = core.get_meta(pos):get_inventory()
    local list = inv:get_list("main")
    local obj_count = 0
    for key, itemstack in pairs(list) do
        if not itemstack:is_empty() then
            obj_count = obj_count + 1
        end
    end
    --core.log("Found " .. dump(obj_count) .. " items on shelf inventory")
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
                z = start_pos.z + (item_displacement * offset * obj_dir.z) --- (node_dir.x * overhead * 0.25)
            }

            if not list[i]:is_empty() then
                --core.log("Adding item entity at " .. core.pos_to_string(obj_pos))
                temp_texture = list[i]:get_name()
                temp_size = 0.5625
                -- core.log("Size: "..dump(temp_size))
                local ent = core.add_entity(obj_pos, "testcoin:item")
                ent:set_properties({
                    wield_item = temp_texture
                })
                ent:set_yaw(core.dir_to_yaw(core.facedir_to_dir(node.param2)))
            end
        end
    end
end

-- Entity for item displayed on shelf
core.register_entity("testcoin:item", {
    hp_max = 1,
    visual = "item",
    visual_size = {
        x = 1,
        y = 1,
        z = 1
    },
    wield_scale = {
        x = 1,
        y = 1,
        z = 1
    },
    collisionbox = {0, 0, 0, 0, 0, 0},
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
            self.visualsize = temp_size + 0.6
            temp_size = nil
        elseif staticdata ~= nil and staticdata ~= "" then
            self.visualsize = data.visualsize
        end
        -- Set visual size if available
        if self.visualsize ~= nil then
            self.visual_size = {
                x = self.visualsize,
                y = self.visualsize,
                z = self.visualsize
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

-------------------------------------------------------
-- Export

local shelf = {}

shelf.update = update_shelf

return shelf