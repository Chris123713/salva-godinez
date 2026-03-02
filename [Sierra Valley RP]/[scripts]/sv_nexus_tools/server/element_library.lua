-- Element Library: Reusable Mission Assets
-- Manages modular elements (NPCs, vehicles, props, zones) that can be reused across missions

local ElementLibrary = {}

-- ============================================
-- ELEMENT CRUD OPERATIONS
-- ============================================

--- Create a new element in the library
---@param data table Element data
---@return table|nil element Created element or nil on error
---@return string? error Error message if failed
function ElementLibrary.Create(data)
    if not data.element_type or not data.coords_x or not data.coords_y or not data.coords_z then
        return nil, 'Missing required fields: element_type, coords_x, coords_y, coords_z'
    end

    local id = Utils.GenerateUUID()

    local success = MySQL.insert.await([[
        INSERT INTO nexus_elements
        (id, element_type, model, coords_x, coords_y, coords_z, heading, radius,
         source_mission_id, source_blueprint_id, reusable, verified, quality_score,
         primary_tag, location_tag, notes, created_by)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        id,
        data.element_type,
        data.model,
        data.coords_x,
        data.coords_y,
        data.coords_z,
        data.heading or 0.0,
        data.radius,
        data.source_mission_id,
        data.source_blueprint_id,
        data.reusable ~= false,
        data.verified or false,
        data.quality_score or 0.5,
        data.primary_tag,
        data.location_tag,
        data.notes,
        data.created_by
    })

    if not success then
        return nil, 'Database insert failed'
    end

    -- Add tags if provided
    if data.tags and #data.tags > 0 then
        for _, tag in ipairs(data.tags) do
            ElementLibrary.AddTag(id, tag.name, tag.category or 'custom', tag.weight or 1.0)
        end
    end

    local element = ElementLibrary.Get(id)
    Utils.Success('Created element:', id, '-', data.element_type, 'at', data.coords_x, data.coords_y, data.coords_z)

    return element
end

--- Get an element by ID
---@param id string Element ID
---@return table|nil element
function ElementLibrary.Get(id)
    local element = MySQL.single.await([[
        SELECT e.*,
               GROUP_CONCAT(DISTINCT CONCAT(t.tag_name, ':', t.tag_category)) as tag_list
        FROM nexus_elements e
        LEFT JOIN nexus_element_tags t ON e.id = t.element_id
        WHERE e.id = ?
        GROUP BY e.id
    ]], {id})

    if element and element.tag_list then
        element.tags = {}
        for tag in string.gmatch(element.tag_list, '[^,]+') do
            local name, category = string.match(tag, '([^:]+):([^:]+)')
            if name then
                table.insert(element.tags, {name = name, category = category})
            end
        end
        element.tag_list = nil
    end

    return element
end

--- Update an element
---@param id string Element ID
---@param data table Fields to update
---@return boolean success
function ElementLibrary.Update(id, data)
    local sets = {}
    local values = {}

    local allowedFields = {
        'element_type', 'model', 'coords_x', 'coords_y', 'coords_z', 'heading', 'radius',
        'reusable', 'verified', 'quality_score', 'primary_tag', 'location_tag', 'notes'
    }

    for _, field in ipairs(allowedFields) do
        if data[field] ~= nil then
            table.insert(sets, field .. ' = ?')
            table.insert(values, data[field])
        end
    end

    if #sets == 0 then
        return false
    end

    table.insert(values, id)

    local affected = MySQL.update.await(
        'UPDATE nexus_elements SET ' .. table.concat(sets, ', ') .. ' WHERE id = ?',
        values
    )

    return affected > 0
end

--- Delete an element
---@param id string Element ID
---@return boolean success
function ElementLibrary.Delete(id)
    local affected = MySQL.update.await('DELETE FROM nexus_elements WHERE id = ?', {id})
    return affected > 0
end

--- Clone an element to a new location
---@param sourceId string Source element ID
---@param newCoords table {x, y, z, heading?}
---@param createdBy string? Creator identifier
---@return table|nil element Cloned element
function ElementLibrary.Clone(sourceId, newCoords, createdBy)
    local source = ElementLibrary.Get(sourceId)
    if not source then
        return nil, 'Source element not found'
    end

    local cloneData = {
        element_type = source.element_type,
        model = source.model,
        coords_x = newCoords.x or newCoords[1],
        coords_y = newCoords.y or newCoords[2],
        coords_z = newCoords.z or newCoords[3],
        heading = newCoords.heading or newCoords.w or newCoords[4] or source.heading,
        radius = source.radius,
        reusable = true,
        verified = false,
        quality_score = 0.5,
        primary_tag = source.primary_tag,
        location_tag = source.location_tag,
        notes = 'Cloned from ' .. sourceId,
        created_by = createdBy,
        tags = source.tags
    }

    return ElementLibrary.Create(cloneData)
end

-- ============================================
-- TAG MANAGEMENT
-- ============================================

--- Add a tag to an element
---@param elementId string Element ID
---@param tagName string Tag name
---@param category string? Tag category (role, location, use_case, scenario, custom)
---@param weight number? Tag weight (default 1.0)
---@return boolean success
function ElementLibrary.AddTag(elementId, tagName, category, weight)
    category = category or 'custom'
    weight = weight or 1.0

    local success = MySQL.insert.await([[
        INSERT IGNORE INTO nexus_element_tags (element_id, tag_name, tag_category, weight)
        VALUES (?, ?, ?, ?)
    ]], {elementId, tagName, category, weight})

    return success ~= nil
end

--- Remove a tag from an element
---@param elementId string Element ID
---@param tagName string Tag name
---@return boolean success
function ElementLibrary.RemoveTag(elementId, tagName)
    local affected = MySQL.update.await([[
        DELETE FROM nexus_element_tags WHERE element_id = ? AND tag_name = ?
    ]], {elementId, tagName})

    return affected > 0
end

--- Get all tags for an element
---@param elementId string Element ID
---@return table tags Array of {name, category, weight}
function ElementLibrary.GetTags(elementId)
    local rows = MySQL.query.await([[
        SELECT tag_name as name, tag_category as category, weight
        FROM nexus_element_tags
        WHERE element_id = ?
        ORDER BY weight DESC
    ]], {elementId})

    return rows or {}
end

-- ============================================
-- SEARCH OPERATIONS
-- ============================================

--- Search elements by criteria
---@param criteria table Search criteria
---@return table elements Array of matching elements
function ElementLibrary.Search(criteria)
    local where = {'1=1'}
    local params = {}

    -- Element type filter
    if criteria.element_type then
        table.insert(where, 'e.element_type = ?')
        table.insert(params, criteria.element_type)
    end

    -- Tag filter (any of the provided tags)
    if criteria.tags and #criteria.tags > 0 then
        local tagPlaceholders = {}
        for _, tag in ipairs(criteria.tags) do
            table.insert(tagPlaceholders, '?')
            table.insert(params, tag)
        end
        table.insert(where, string.format(
            'e.id IN (SELECT element_id FROM nexus_element_tags WHERE tag_name IN (%s))',
            table.concat(tagPlaceholders, ', ')
        ))
    end

    -- Location proximity filter
    if criteria.near_coords then
        local coords = Utils.Vec3FromTable(criteria.near_coords)
        local radius = criteria.radius or 500

        table.insert(where, string.format(
            'SQRT(POW(e.coords_x - ?, 2) + POW(e.coords_y - ?, 2)) <= ?'
        ))
        table.insert(params, coords.x)
        table.insert(params, coords.y)
        table.insert(params, radius)
    end

    -- Reusable filter
    if criteria.reusable ~= nil then
        table.insert(where, 'e.reusable = ?')
        table.insert(params, criteria.reusable)
    end

    -- Verified filter
    if criteria.verified ~= nil then
        table.insert(where, 'e.verified = ?')
        table.insert(params, criteria.verified)
    end

    -- Quality threshold
    if criteria.min_quality then
        table.insert(where, 'e.quality_score >= ?')
        table.insert(params, criteria.min_quality)
    end

    -- Primary tag filter
    if criteria.primary_tag then
        table.insert(where, 'e.primary_tag = ?')
        table.insert(params, criteria.primary_tag)
    end

    -- Location tag filter
    if criteria.location_tag then
        table.insert(where, 'e.location_tag = ?')
        table.insert(params, criteria.location_tag)
    end

    local limit = criteria.limit or 10
    table.insert(params, limit)

    local query = string.format([[
        SELECT e.*,
               GROUP_CONCAT(DISTINCT t.tag_name) as all_tags,
               COUNT(DISTINCT u.id) as usage_count,
               SUM(CASE WHEN u.was_successful = TRUE THEN 1 ELSE 0 END) as successful_uses
        FROM nexus_elements e
        LEFT JOIN nexus_element_tags t ON e.id = t.element_id
        LEFT JOIN nexus_element_usage u ON e.id = u.element_id
        WHERE %s
        GROUP BY e.id
        ORDER BY e.quality_score DESC, usage_count DESC
        LIMIT ?
    ]], table.concat(where, ' AND '))

    local rows = MySQL.query.await(query, params)

    -- Parse tags
    if rows then
        for _, row in ipairs(rows) do
            if row.all_tags then
                row.tags = {}
                for tag in string.gmatch(row.all_tags, '[^,]+') do
                    table.insert(row.tags, tag)
                end
            else
                row.tags = {}
            end
            row.all_tags = nil
        end
    end

    return rows or {}
end

--- Search elements by text query (searches tags, notes, model)
---@param query string Search text
---@param limit number? Max results
---@return table elements Array of matching elements
function ElementLibrary.TextSearch(query, limit)
    limit = limit or 10
    local searchPattern = '%' .. query .. '%'

    local rows = MySQL.query.await([[
        SELECT DISTINCT e.*,
               GROUP_CONCAT(DISTINCT t.tag_name) as all_tags
        FROM nexus_elements e
        LEFT JOIN nexus_element_tags t ON e.id = t.element_id
        WHERE e.model LIKE ?
           OR e.notes LIKE ?
           OR e.primary_tag LIKE ?
           OR e.location_tag LIKE ?
           OR t.tag_name LIKE ?
        GROUP BY e.id
        ORDER BY e.quality_score DESC
        LIMIT ?
    ]], {searchPattern, searchPattern, searchPattern, searchPattern, searchPattern, limit})

    return rows or {}
end

--- Find similar elements (based on tags and location)
---@param elementId string Reference element ID
---@param limit number? Max results
---@return table elements Array of similar elements
function ElementLibrary.FindSimilar(elementId, limit)
    limit = limit or 5

    local source = ElementLibrary.Get(elementId)
    if not source then
        return {}
    end

    local tags = {}
    if source.tags then
        for _, t in ipairs(source.tags) do
            table.insert(tags, t.name)
        end
    end

    return ElementLibrary.Search({
        element_type = source.element_type,
        tags = tags,
        near_coords = {x = source.coords_x, y = source.coords_y, z = source.coords_z},
        radius = 200,
        limit = limit + 1  -- Extra to exclude self
    })
end

-- ============================================
-- USAGE TRACKING
-- ============================================

--- Track element usage in a mission
---@param elementId string Element ID
---@param missionId string Mission ID
---@param role string Role in mission (e.g., 'contact_npc', 'getaway_vehicle')
---@return boolean success
function ElementLibrary.TrackUsage(elementId, missionId, role)
    local success = MySQL.insert.await([[
        INSERT INTO nexus_element_usage (element_id, mission_id, role_in_mission)
        VALUES (?, ?, ?)
        ON DUPLICATE KEY UPDATE role_in_mission = ?
    ]], {elementId, missionId, role, role})

    return success ~= nil
end

--- Record mission outcome for an element
---@param elementId string Element ID
---@param missionId string Mission ID
---@param wasSuccessful boolean Whether mission completed successfully
---@return boolean success
function ElementLibrary.RecordOutcome(elementId, missionId, wasSuccessful)
    local affected = MySQL.update.await([[
        UPDATE nexus_element_usage
        SET was_successful = ?
        WHERE element_id = ? AND mission_id = ?
    ]], {wasSuccessful, elementId, missionId})

    return affected > 0
end

--- Get usage history for an element
---@param elementId string Element ID
---@return table history Array of usage records
function ElementLibrary.GetUsageHistory(elementId)
    local rows = MySQL.query.await([[
        SELECT u.*, m.type as mission_type, m.status as mission_status
        FROM nexus_element_usage u
        LEFT JOIN nexus_missions m ON u.mission_id = m.id
        WHERE u.element_id = ?
        ORDER BY u.spawned_at DESC
        LIMIT 50
    ]], {elementId})

    return rows or {}
end

--- Get top performing elements by type
---@param elementType string Element type (npc, vehicle, prop, zone)
---@param limit number? Max results
---@return table elements Array of top elements
function ElementLibrary.GetTopElements(elementType, limit)
    limit = limit or 10

    local rows = MySQL.query.await([[
        SELECT e.*,
               COUNT(u.id) as total_uses,
               SUM(CASE WHEN u.was_successful = TRUE THEN 1 ELSE 0 END) as successful_uses,
               e.quality_score
        FROM nexus_elements e
        LEFT JOIN nexus_element_usage u ON e.id = u.element_id
        WHERE e.element_type = ?
          AND e.reusable = TRUE
          AND e.verified = TRUE
        GROUP BY e.id
        HAVING total_uses > 0
        ORDER BY e.quality_score DESC, successful_uses DESC
        LIMIT ?
    ]], {elementType, limit})

    return rows or {}
end

-- ============================================
-- BULK OPERATIONS
-- ============================================

--- Import elements from a blueprint
---@param blueprintId string Blueprint ID
---@param elements table Array of element data from blueprint
---@return table results Array of {success, element_id, error?}
function ElementLibrary.ImportFromBlueprint(blueprintId, elements)
    local results = {}

    for i, data in ipairs(elements) do
        data.source_blueprint_id = blueprintId
        local element, err = ElementLibrary.Create(data)

        table.insert(results, {
            index = i,
            success = element ~= nil,
            element_id = element and element.id or nil,
            error = err
        })
    end

    return results
end

--- Verify an element (mark as human-reviewed and good quality)
---@param elementId string Element ID
---@param verifiedBy string Who verified
---@return boolean success
function ElementLibrary.Verify(elementId, verifiedBy)
    local affected = MySQL.update.await([[
        UPDATE nexus_elements
        SET verified = TRUE, quality_score = GREATEST(quality_score, 0.7)
        WHERE id = ?
    ]], {elementId})

    if affected > 0 then
        Utils.Success('Element verified:', elementId, 'by', verifiedBy)
    end

    return affected > 0
end

--- Get elements needing verification (unverified with usage)
---@param limit number? Max results
---@return table elements Array of elements needing review
function ElementLibrary.GetNeedingVerification(limit)
    limit = limit or 20

    local rows = MySQL.query.await([[
        SELECT e.*, COUNT(u.id) as usage_count
        FROM nexus_elements e
        LEFT JOIN nexus_element_usage u ON e.id = u.element_id
        WHERE e.verified = FALSE
          AND e.reusable = TRUE
        GROUP BY e.id
        HAVING usage_count > 0
        ORDER BY usage_count DESC
        LIMIT ?
    ]], {limit})

    return rows or {}
end

-- ============================================
-- TAG TAXONOMY
-- ============================================

--- Get available tags by category
---@param category string? Optional category filter
---@return table tags Array of {name, category, count}
function ElementLibrary.GetTagTaxonomy(category)
    local query, params

    if category then
        query = [[
            SELECT tag_name as name, tag_category as category, COUNT(*) as count
            FROM nexus_element_tags
            WHERE tag_category = ?
            GROUP BY tag_name, tag_category
            ORDER BY count DESC
        ]]
        params = {category}
    else
        query = [[
            SELECT tag_name as name, tag_category as category, COUNT(*) as count
            FROM nexus_element_tags
            GROUP BY tag_name, tag_category
            ORDER BY tag_category, count DESC
        ]]
        params = {}
    end

    local rows = MySQL.query.await(query, params)
    return rows or {}
end

--- Suggested tag categories constant (for LLM guidance)
ElementLibrary.TagCategories = {
    role = {
        'contact_npc', 'informant', 'enemy', 'guard', 'victim', 'hostage',
        'witness', 'getaway_driver', 'lookout', 'hacker', 'vip'
    },
    location = {
        'alley', 'parking', 'industrial', 'residential', 'commercial',
        'dock', 'rooftop', 'interior', 'rural', 'beach', 'highway'
    },
    use_case = {
        'npc_standing', 'npc_sitting', 'npc_prone', 'vehicle_parked',
        'vehicle_crashed', 'vehicle_running', 'prop_interactive', 'prop_loot',
        'zone_restricted', 'zone_safe', 'zone_combat'
    },
    scenario = {
        'crash_scene', 'heist', 'investigation', 'delivery', 'pursuit',
        'rescue', 'gang_meeting', 'stakeout', 'ambush', 'escort'
    }
}

-- ============================================
-- EXPORTS
-- ============================================

exports('CreateElement', ElementLibrary.Create)
exports('GetElement', ElementLibrary.Get)
exports('UpdateElement', ElementLibrary.Update)
exports('DeleteElement', ElementLibrary.Delete)
exports('CloneElement', ElementLibrary.Clone)
exports('AddElementTag', ElementLibrary.AddTag)
exports('RemoveElementTag', ElementLibrary.RemoveTag)
exports('GetElementTags', ElementLibrary.GetTags)
exports('SearchElements', ElementLibrary.Search)
exports('TextSearchElements', ElementLibrary.TextSearch)
exports('FindSimilarElements', ElementLibrary.FindSimilar)
exports('TrackElementUsage', ElementLibrary.TrackUsage)
exports('RecordElementOutcome', ElementLibrary.RecordOutcome)
exports('GetElementUsageHistory', ElementLibrary.GetUsageHistory)
exports('GetTopElements', ElementLibrary.GetTopElements)
exports('ImportElementsFromBlueprint', ElementLibrary.ImportFromBlueprint)
exports('VerifyElement', ElementLibrary.Verify)
exports('GetElementsNeedingVerification', ElementLibrary.GetNeedingVerification)
exports('GetTagTaxonomy', ElementLibrary.GetTagTaxonomy)
exports('GetElementLibrary', function() return ElementLibrary end)

return ElementLibrary
