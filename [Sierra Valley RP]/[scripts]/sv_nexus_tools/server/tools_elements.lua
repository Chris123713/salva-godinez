-- Element Library Tool Handlers

-- ============================================
-- SEARCH ELEMENTS
-- ============================================

RegisterTool('search_elements', {
    params = {'tags', 'element_type', 'near_coords', 'radius', 'limit', 'min_quality', 'verified_only'},
    category = Constants.ToolCategory.ELEMENTS,
    handler = function(params)
        local ElementLibrary = exports['sv_nexus_tools']:GetElementLibrary()
        if not ElementLibrary then
            return {success = false, error = 'Element library not available'}
        end

        local searchCriteria = {
            tags = params.tags,
            element_type = params.element_type,
            near_coords = params.near_coords and Utils.Vec3FromTable(params.near_coords),
            radius = params.radius or 500,
            limit = params.limit or 5,
            min_quality = params.min_quality,
            verified = params.verified_only and true or nil,
            reusable = true
        }

        local elements = ElementLibrary.Search(searchCriteria)

        return {
            success = true,
            elements = elements,
            count = #elements
        }
    end
})

-- ============================================
-- SPAWN FROM ELEMENT
-- ============================================

RegisterTool('spawn_from_element', {
    params = {'element_id', 'mission_id', 'role', 'override_model', 'override_behavior'},
    category = Constants.ToolCategory.ELEMENTS,
    async = true,
    handler = function(params, source)
        local ElementLibrary = exports['sv_nexus_tools']:GetElementLibrary()
        if not ElementLibrary then
            return {success = false, error = 'Element library not available'}
        end

        -- Get element from library
        local element = ElementLibrary.Get(params.element_id)
        if not element then
            return {success = false, error = 'Element not found: ' .. tostring(params.element_id)}
        end

        local coords = vector3(element.coords_x, element.coords_y, element.coords_z)
        local model = params.override_model or element.model
        local behavior = params.override_behavior or Constants.NpcBehavior.IDLE
        local heading = element.heading or 0.0

        local result

        -- Spawn based on element type
        if element.element_type == 'npc' then
            result = lib.callback.await('nexus:spawnNpc', source, {
                model = model or Constants.DefaultModels.NPC,
                coords = coords,
                heading = heading,
                behavior = behavior,
                networked = true
            })
        elseif element.element_type == 'vehicle' then
            result = lib.callback.await('nexus:spawnVehicle', source, {
                model = model or Constants.DefaultModels.VEHICLE,
                coords = coords,
                heading = heading,
                networked = true
            })
        elseif element.element_type == 'prop' then
            result = lib.callback.await('nexus:spawnProp', source, {
                model = model or Constants.DefaultModels.PROP,
                coords = coords,
                heading = heading,
                networked = true
            })
        elseif element.element_type == 'zone' then
            -- Zones don't spawn entities, just return coordinates
            result = {
                success = true,
                coords = coords,
                radius = element.radius or 10.0
            }
        end

        if result and result.success then
            -- Track usage in element library
            ElementLibrary.TrackUsage(params.element_id, params.mission_id, params.role)

            -- Track entity in mission if applicable
            if params.mission_id and result.netId then
                local entityType = element.element_type == 'npc' and 'npc'
                    or element.element_type == 'vehicle' and 'vehicle'
                    or 'prop'
                exports['sv_nexus_tools']:TrackMissionEntity(params.mission_id, entityType, result.netId)
            end

            return {
                success = true,
                netId = result.netId,
                coords = coords,
                element_type = element.element_type
            }
        end

        return {success = false, error = 'Failed to spawn entity from element'}
    end
})

-- ============================================
-- REQUEST ELEMENT PLACEMENT
-- ============================================

RegisterTool('request_element_placement', {
    params = {'requirements', 'element_type', 'suggested_tags', 'priority', 'near_coords'},
    category = Constants.ToolCategory.ELEMENTS,
    handler = function(params, source)
        local requestId = Utils.GenerateUUID()

        -- Insert into placement requests table
        local success = MySQL.insert.await([[
            INSERT INTO nexus_placement_requests
            (id, element_type, requirements, suggested_tags, priority, status, created_at)
            VALUES (?, ?, ?, ?, ?, 'pending', NOW())
        ]], {
            requestId,
            params.element_type,
            params.requirements,
            params.suggested_tags and json.encode(params.suggested_tags) or nil,
            params.priority or 'normal'
        })

        if success then
            -- Notify admins about new placement request
            local admins = GetPlayers()
            for _, playerId in ipairs(admins) do
                if Utils.HasPermission(playerId, 'admin') then
                    TriggerClientEvent('nexus:client:newPlacementRequest', playerId, {
                        requestId = requestId,
                        requirements = params.requirements,
                        element_type = params.element_type,
                        priority = params.priority
                    })
                end
            end

            Utils.Debug('Created placement request:', requestId)
            return {
                success = true,
                request_id = requestId,
                queued = true
            }
        end

        return {success = false, error = 'Failed to create placement request'}
    end
})

-- ============================================
-- ELEMENT MANAGEMENT TOOLS (Admin)
-- ============================================

RegisterTool('create_element', {
    params = {'element_type', 'coords', 'model', 'heading', 'radius', 'primary_tag', 'location_tag', 'notes', 'tags'},
    category = Constants.ToolCategory.ELEMENTS,
    handler = function(params, source)
        if not Utils.HasPermission(source, 'admin') then
            return {success = false, error = 'Admin permission required'}
        end

        local ElementLibrary = exports['sv_nexus_tools']:GetElementLibrary()
        if not ElementLibrary then
            return {success = false, error = 'Element library not available'}
        end

        local coords = Utils.Vec3FromTable(params.coords)
        local citizenid = Utils.GetCitizenId(source)

        local element, err = ElementLibrary.Create({
            element_type = params.element_type,
            model = params.model,
            coords_x = coords.x,
            coords_y = coords.y,
            coords_z = coords.z,
            heading = params.heading or 0.0,
            radius = params.radius,
            primary_tag = params.primary_tag,
            location_tag = params.location_tag,
            notes = params.notes,
            tags = params.tags,
            created_by = citizenid or tostring(source),
            reusable = true,
            verified = false
        })

        if element then
            return {success = true, element_id = element.id}
        end
        return {success = false, error = err or 'Failed to create element'}
    end
})

RegisterTool('verify_element', {
    params = {'element_id'},
    category = Constants.ToolCategory.ELEMENTS,
    handler = function(params, source)
        if not Utils.HasPermission(source, 'admin') then
            return {success = false, error = 'Admin permission required'}
        end

        local ElementLibrary = exports['sv_nexus_tools']:GetElementLibrary()
        if not ElementLibrary then
            return {success = false, error = 'Element library not available'}
        end

        local citizenid = Utils.GetCitizenId(source) or tostring(source)
        local success = ElementLibrary.Verify(params.element_id, citizenid)

        return {success = success}
    end
})

RegisterTool('add_element_tag', {
    params = {'element_id', 'tag_name', 'tag_category', 'weight'},
    category = Constants.ToolCategory.ELEMENTS,
    handler = function(params, source)
        local ElementLibrary = exports['sv_nexus_tools']:GetElementLibrary()
        if not ElementLibrary then
            return {success = false, error = 'Element library not available'}
        end

        local success = ElementLibrary.AddTag(
            params.element_id,
            params.tag_name,
            params.tag_category or 'custom',
            params.weight or 1.0
        )

        return {success = success}
    end
})

RegisterTool('get_top_elements', {
    params = {'element_type', 'limit'},
    category = Constants.ToolCategory.ELEMENTS,
    handler = function(params)
        local ElementLibrary = exports['sv_nexus_tools']:GetElementLibrary()
        if not ElementLibrary then
            return {success = false, error = 'Element library not available'}
        end

        local elements = ElementLibrary.GetTopElements(params.element_type, params.limit or 10)
        return {success = true, elements = elements, count = #elements}
    end
})

Utils.Success('Registered element library tools')
