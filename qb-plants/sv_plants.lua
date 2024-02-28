QBCore = exports["qb-core"]:GetCoreObject()

RegisterServerEvent('weed:removeItem')
AddEventHandler('weed:removeItem', function(item , amount)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    xPlayer.Functions.RemoveItem(item , amount)
end)

RegisterServerEvent('weed:addItem')
AddEventHandler('weed:addItem', function(item , amount)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    xPlayer.Functions.AddItem(item, amount)
end)

-- QBCore.Functions.CreateUseableItem(PlantConfig.FemaleSeedItem, function(source)
--     local xPlayer = QBCore.Functions.GetPlayer(source)
--     if xPlayer.Functions.RemoveItem (PlantConfig.FemaleSeedItem, 1) then 
--         TriggerClientEvent('qb-plants:client:useitem', source)
--     end
-- end)


QBCore.Functions.CreateUseableItem(PlantConfig.FemaleSeedItem, function(source, item)
	local Player = QBCore.Functions.GetPlayer(source)
    TriggerClientEvent("qb-plants:useitem", source)
end)

RegisterServerEvent('qb-plants:plantSeed')
AddEventHandler('qb-plants:plantSeed', function(coords)
    local timestamp = os.time()
    exports.oxmysql:execute('INSERT INTO plants (coords, timestamp, plantgender, water, fertilizer) VALUES (@coords, @state, @pg, @water, @fertilizer)', {
        ['@coords'] = json.encode(coords),
        ['@state'] = timestamp,
        ['@pg'] = 0,
        ['@water'] = 0,
        ['@fertilizer'] = 0,
    }, function(rowschanged)
        if rowschanged then
            print(rowschanged.insertId)
            exports.oxmysql:execute('SELECT * FROM plants WHERE id = @id', {["@id"] = rowschanged.insertId}, function(plant)
                TriggerClientEvent('qb-plants:trigger_zone', -1, 2, plant[1])
            end)
        end
    end)
end)

QBCore.Functions.CreateCallback('qb-plants:getPlants', function(source, cb)
    exports.oxmysql:execute('SELECT * FROM plants', {}, function(plants)
        cb(plants)
    end)
end)

QBCore.Functions.CreateCallback('qb-plants:removePlant', function(source, cb, pId)
    exports.oxmysql:execute('DELETE FROM plants WHERE id = @id', {["@id"] = pId}, function(plants)
        cb(true)
        TriggerClientEvent('qb-plants:trigger_zone', -1, 4, pId)
    end)
end)

QBCore.Functions.CreateCallback('qb-plants:harvestPlant', function(source, cb, pId)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local plant = getPlantById(pId)
    local qua = 100 - tonumber(plant.water / 20) - tonumber(plant.fertilizer / 10)
    if plant.plantgender == 1 then
        if xPlayer.Functions.AddItem(PlantConfig.FemaleSeedItem, math.random(PlantConfig.SeedsFromMale[1], PlantConfig.SeedsFromMale[2])) then
            exports.oxmysql:execute('DELETE FROM plants WHERE id = @id', {["@id"] = pId}, function(plants)
                cb(true)
                TriggerClientEvent('qb-plants:trigger_zone', -1, 4, pId)
            end)
            return
        end
    end


    if xPlayer.Functions.AddItem(PlantConfig.GiveDopeItem, math.random(PlantConfig.DopeFromFemale[1], PlantConfig.DopeFromFemale[2]), nil, {quality = qua}) then
        exports.oxmysql:execute('DELETE FROM plants WHERE id = @id', {["@id"] = pId}, function(plants)
            cb(true)
            TriggerClientEvent('qb-plants:trigger_zone', -1, 4, pId)
        end)
    end
end)

QBCore.Functions.CreateCallback('qb-plants:addWater', function(source, cb, key)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    if xPlayer.Functions.RemoveItem (PlantConfig.WaterItem, 1) then
        exports.oxmysql:execute('UPDATE plants SET water = (water + @water) WHERE id = @id', {["@id"] = key, ['@water'] = math.random(PlantConfig.WaterAdd[1], PlantConfig.WaterAdd[2])}, function(rowschanged)
            exports.oxmysql:execute('SELECT * FROM plants WHERE id = @id', {["@id"] = key}, function(plant)
                cb(true)
                TriggerClientEvent('qb-plants:trigger_zone', -1, 3, plant[1])
            end)
        end)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('qb-plants:addMaleSeed', function(source, cb, key)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    if xPlayer.Functions.RemoveItem (PlantConfig.MaleSeedItem, 1) then
        exports.oxmysql:execute('UPDATE plants SET plantgender = 1 WHERE id = @id', {["@id"] = key}, function(rowschanged)
            exports.oxmysql:execute('SELECT * FROM plants WHERE id = @id', {["@id"] = key}, function(plant)
                cb(true)
                TriggerClientEvent('qb-plants:trigger_zone', -1, 3, plant[1])
            end)
        end)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('qb-plants:addFertilizer', function(source, cb, key, type)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local fert = 0
    if type == 'p' then
        fert = PlantConfig.PWeight
    elseif type == 'n' then
        fert = PlantConfig.NWeight
    elseif type == 'k' then
        fert = PlantConfig.KWeight
    end
    if xPlayer.Functions.RemoveItem (PlantConfig.FertilizerItem, 1) then
        exports.oxmysql:execute('UPDATE plants SET fertilizer = (fertilizer + @fert)WHERE id = @id', {["@id"] = key, ["@fert"] = fert}, function(rowschanged)
            exports.oxmysql:execute('SELECT * FROM plants WHERE id = @id', {["@id"] = key}, function(plant)
                cb(true)
                TriggerClientEvent('qb-plants:trigger_zone', -1, 3, plant[1])
            end)
        end)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('qb-plants:CheckItem', function(source, cb, item)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    local item = xPlayer.Functions.GetItemByName(item).amount
    if item > 0 then
        cb(true)
    else
        cb(false)
    end
end)

getPlantById = function(plantId)
    local plants = {}
    local result = exports.oxmysql:executeSync('SELECT * FROM plants WHERE id = @id', {["@id"] = plantId})
    print(json.encode(result[1]))
    return result[1]
end

