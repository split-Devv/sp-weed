local QBCore = exports['qb-core']:GetCoreObject()

Citizen.CreateThread(function()
    while QBCore == nil do
        TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
        Citizen.Wait(200)
    end
    coreLoaded = true
  end)
  
  Citizen.CreateThread(function()
    while QBCore.Functions.GetPlayerData().job == nil do
      Citizen.Wait(10)
    end
    
    PlayerData = QBCore.Functions.GetPlayerData()
  end)
  
  RegisterNetEvent("QBCore:Client:OnJobUpdate")
  AddEventHandler("QBCore:Client:OnJobUpdate", function(jobInfo)
    PlayerData.job = jobInfo
  end)
  
  RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
  AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
      PlayerData = QBCore.Functions.GetPlayerData()
  end)
  
  RegisterNetEvent('QBCore:Client:OnPlayerUnload')
  AddEventHandler('QBCore:Client:OnPlayerUnload', function()
      PlayerData = {}
  end)
  
local WeedPlants = {}
local ActivePlants = {}

local inZone = 0
local setDeleteAll = false

--Creates da weed
--TODO: cache close plants
Citizen.CreateThread(function()
    while true do
        local plyCoords = GetEntityCoords(PlayerPedId())
        if WeedPlants == nil then WeedPlants = {} end
        for idx,plant in ipairs(WeedPlants) do
            if idx % 100 == 0 then
                Wait(0) --Process 100 per frame
            end
            --convert timestamp -> growth percent
            local plantcoords = json.encode(plant.coords)
            local plantGrowth = getPlantGrowthPercent(plant)
            if not setDeleteAll then
                local curStage = getStageFromPercent(plantGrowth)
                local isChanged = (ActivePlants[plant.id] and ActivePlants[plant.id].stage ~= curStage)

                if isChanged then
                    removeWeed(plant.id)
                end

                if not ActivePlants[plant.id] or isChanged then
                    local weedPlant = createWeedStageAtCoords(curStage, plant.coords)
                    ActivePlants[plant.id] = {
                        object = weedPlant,
                        stage = curStage
                    }
                end
            else
                removeWeed(plant.id)
            end
        end
        if setDeleteAll then
            WeedPlants = {}
            setDeleteAll = false
        end
        Wait(inZone > 0 and 500 or 1000)
    end
end)


RegisterNetEvent('qb-plants:Gate')
AddEventHandler('qb-plants:Gate', function()
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(hasItem)
        if hasItem then
            TriggerEvent('qb-plants:addMaleSeed')			
            Citizen.Wait(1000)
        else
            QBCore.Functions.Notify("You don't have a male seed!", "error")
        end
    end, "maleseed")
end)

local add_maleseed = false

RegisterNetEvent('qb-plants:addMaleSeed')
AddEventHandler('qb-plants:addMaleSeed', function(data)
    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)
    local finished = exports["gate-taskbar"]:taskBar(5000, "Erkek Tohum Ekleniyor")
    ClearPedTasks(PlayerPedId())
    if finished == 100 then
        QBCore.Functions.TriggerCallback('qb-plants:addMaleSeed', function(success)
            if not success then
                QBCore.Functions.Notify("You don't have a male seed.", "error")
            else
                -- TriggerServerEvent("weed:removeItem", "maleseed", 1)
                add_maleseed = true        
            end
        end, data)
    end
    Wait(200)
end)

RegisterNetEvent('qb-plants:Gate3')
AddEventHandler('qb-plants:Gate3', function()
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(hasItem)
        if hasItem then
            TriggerEvent('qb-plants:addFertilizer')			
            Citizen.Wait(1000)
        else
            QBCore.Functions.Notify("No fertilizer!", "error")
        end
    end, "fertilizer")
end)



AddEventHandler('qb-plants:addFertilizer', function (data)
    playPourAnimation()
    local finished = exports["gate-taskbar"]:taskBar(5000, "Adding Fertilizer")
    ClearPedTasks(PlayerPedId())
    if finished  then
        TriggerServerEvent("weed:removeItem", "fertilizer", 1)
        QBCore.Functions.TriggerCallback('qb-plants:addFertilizer', function(success)
            if not success then
                QBCore.Functions.Notify("No Fertilizer Added.", "error")

            end
        end, data.plantId, data.type)
    end
    Wait(200)
end)



RegisterNetEvent('qb-plants:Gate2')
AddEventHandler('qb-plants:Gate2', function()
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(hasItem)
        if hasItem then
            TriggerEvent('qb-plants:addWater')			
            Citizen.Wait(1000)
        else
            QBCore.Functions.Notify("You have no water!", "error")
        end
    end, "marijuana_water")
end)

local add_water = false


RegisterNetEvent('qb-plants:addWater')
AddEventHandler('qb-plants:addWater', function(data)
    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)
    local finished = exports["gate-taskbar"]:taskBar(5000, "Adding Water")
    ClearPedTasks(PlayerPedId())
    if finished  then
        add_water = true        
        QBCore.Functions.TriggerCallback('qb-plants:addWater', function(success)
            if not success then
            add_water = false        
                QBCore.Functions.Notify("Could not add water!", "error")
            end
        end, data)
    end
    Wait(200)
    showPlantMenu(data)
end)



Citizen.CreateThread(function()
    for id,zone in ipairs(WeedZones) do
        exports["gate-polyzone"]:AddCircleZone("qb-plants:weed_zone", zone[1], zone[2])

        local weed = {
            `bkr_prop_weed_01_small_01b`,
            'bkr_prop_weed_med_01a',
            'bkr_prop_weed_med_01b',
            'bkr_prop_weed_lrg_01a',
            'bkr_prop_weed_lrg_01b',
        }
        exports['qb-target']:AddTargetModel(weed, {
            options = {
                {
                    event = "qb-plants:checkPlant",
                    icon = "fas fa-cannabis",
                    args = 'allahyok',
                    label = "Check it",
                },
            },
            job = {"all"},
            distance = 3
        })
        -- local weed2 = {
        --     `prop_weed_01`,
        
        -- }

        -- exports['qb-target']:AddTargetModel(weed2, {
        --     options = {
        --         -- {
        --         --     event = "qb-plants:checkPlant",
        --         --     icon = "fas fa-cannabis",
        --         --     args = 'allahyok',
        --         --     label = "Check it",
        --         -- },
        --         {
        --             event = "qb-plants:pickPlant",
        --             icon = "fas fa-cannabis",
        --             label = "Gather Your Herbs",
        --         },
        --     },
        --     job = {"all"},
        --     distance = 3
        -- })
        
    end
end)

RegisterNetEvent('qb-plants:useitem')
AddEventHandler('qb-plants:useitem', function()
    if inZone > 0 then
        TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)
        local finished = exports["gate-taskbar"]:taskBar(5000, "Sowing the Seed")
        ClearPedTasks(PlayerPedId())
        if finished then
            local plyCoords = GetEntityCoords(PlayerPedId())
            local offsetCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 0.7, 0)
            local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(offsetCoords.x, offsetCoords.y, offsetCoords.z, offsetCoords.x, offsetCoords.y, offsetCoords.z - 2, 1, 0, 4)
            local retval, hit, endCoords, _, materialHash, _ = GetShapeTestResultIncludingMaterial(rayHandle)
            TriggerServerEvent("qb-plants:plantSeed", endCoords)
            TriggerServerEvent("weed:removeItem", "femaleseed", 1)
        end
    else
        QBCore.Functions.Notify("You have to find a better area to plant this.", "error")
    end
end)

RegisterNetEvent('qb-plants:trigger_zone')
AddEventHandler("qb-plants:trigger_zone", function (type, pData)
    --Update all plants
    if type == 1 then
        print(type, "type")
        print(json.encode(pData), "pData")
        for _,plant in ipairs(WeedPlants) do
            local keep = false
            for _,newPlant in ipairs(pData) do
                if plant.id == newPlant.id then
                    keep = true
                    break
                end
            end

            if not keep then
                removeWeed(plant.id)
            end
        end
        WeedPlants = pData
    end
    --New plant being added
    if type == 2 then
        WeedPlants[#WeedPlants+1] = pData
    end
    --Plant being harvested/updated
    if type == 3 then
        for idx,plant in ipairs(WeedPlants) do
            if plant.id == pData.id then
                WeedPlants[idx] = pData
                break
            end
        end
    end
    --Plant being removed
    if type == 4 then
        for idx,plant in ipairs(WeedPlants) do
            if plant.id == pData then
                table.remove(WeedPlants, idx)
                removeWeed(plant.id)
                break
            end
        end
    end
end)

RegisterNetEvent('qb-plants:checkPlant', function(test)
    local pedCoords = GetEntityCoords(PlayerPedId())
    local object = nil
    local x1,y1,z1 = table.unpack(GetEntityCoords(PlayerPedId()))
    for k,v in ipairs(PlantConfig.GrowthObjects) do
        local closestObject = GetClosestObjectOfType(x1, y1, z1, 2.0, v.hash, false, false, false)
        if closestObject ~= nil and closestObject ~= 0 then
            object = closestObject
            break
        end
    end
    local plantId = getPlantId(object)

    if not plantId then return end
    showPlantMenu(plantId)
end)

AddEventHandler('qb-plants:removePlant', function(data)
    print(data)
    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)
    local finished = exports["gate-taskbar"]:taskBar(10000, "Removing Plant")
    ClearPedTasks(PlayerPedId())
    if finished  then
        local getFertilizer = getPlantGrowthPercent(getPlantById(data)) > 20.0
        QBCore.Functions.TriggerCallback('qb-plants:removePlant', function(success) 
            if not success then
                print("Could not remove. pid:", data)
            else
                removeWeed(data)
                add_maleseed = false
            end
        end, data)
    end
end)

AddEventHandler('qb-plants:pickplant2', function(data)
    print(data)
    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)
    local finished = exports["gate-taskbar"]:taskBar(10000, "The crops are collected")
    ClearPedTasks(PlayerPedId())
    if finished  then
        local getFertilizer = getPlantGrowthPercent(getPlantById(data)) > 20.0
        QBCore.Functions.TriggerCallback('qb-plants:removePlant', function(success) 
            TriggerServerEvent("weed:addItem","weed_ak47",1)
            TriggerServerEvent("weed:addItem","weed_ak47",1)
            TriggerServerEvent("weed:addItem","weed_ak47",1)
            if not success then
                print("Could not remove. pid:", data)
            else
                removeWeed(data)
                add_maleseed = false
            end
        end, data)
    end
end)

AddEventHandler("qb-plants:pickPlant", function()
    local pedCoords = GetEntityCoords(PlayerPedId())
    local object = nil
    local x1,y1,z1 = table.unpack(GetEntityCoords(PlayerPedId()))
    for k,v in ipairs(PlantConfig.GrowthObjects) do
        local closestObject = GetClosestObjectOfType(x1, y1, z1, 30.0, v.hash, false, false, false)
        if closestObject ~= nil and closestObject ~= 0 then
            object = closestObject
            break
        end
    end
    local plantId = getPlantId(object)
    if not plantId then return end
    local plant = getPlantById(plantId)
    local growth = getPlantGrowthPercent(plant)
    print(math.floor(growth), "growth", PlantConfig.HarvestPercent)
    if getPlantGrowthPercent(plant) < PlantConfig.HarvestPercent then
         QBCore.Functions.Notify("This plant is not ready to be harvested.", "error")

        return
    end
    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)
    local finished = exports["gate-taskbar"]:taskBar(10000, "Harvesting")
    ClearPedTasks(PlayerPedId())
    if finished then
        QBCore.Functions.TriggerCallback('qb-plants:harvestPlant', function(cb)
            if not cb then
            end
        end, plantId)
    end
end)

AddEventHandler("gate-polyzone:enter", function(zone, data)
    if zone == "qb-plants:weed_zone" then
        inZone = inZone + 1
        if inZone == 1 then
            QBCore.Functions.TriggerCallback('qb-plants:getPlants', function(cb)
                WeedPlants = cb
            end)
        end
    end
end)

AddEventHandler("gate-polyzone:exit", function(zone, data)
    if zone == "qb-plants:weed_zone" then
        inZone = inZone - 1
        if inZone < 0 then inZone = 0 end
        if inZone == 0 then
            setDeleteAll = true
        end
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for idx,plant in pairs(ActivePlants) do
        DeleteObject(plant.object)
    end
end)

function createWeedStageAtCoords(pStage, pCoords)
    local model = PlantConfig.GrowthObjects[pStage].hash
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
    coords = json.decode(pCoords)
    local plantObject = CreateObject(model, coords.x, coords.y, coords.z + PlantConfig.GrowthObjects[pStage].zOffset, 0, 0, 0)
    FreezeEntityPosition(plantObject, true)
    SetEntityHeading(plantObject, math.random(0, 360) + 0.0)
    return plantObject
end

function removeWeed(pPlantId)
    if ActivePlants[pPlantId] then
        DeleteObject(ActivePlants[pPlantId].object)
        ActivePlants[pPlantId] = nil
    end
end

function getStageFromPercent(pPercent)
    local growthObjects = #PlantConfig.GrowthObjects - 1
    local percentPerStage = 100 / growthObjects
    return math.floor((pPercent / percentPerStage) + 1.5)
end

function getPlantGrowthPercent(pPlant)
    local timeDiff = (GetCloudTimeAsInt() - pPlant.timestamp) / 60
    local genderFactor = (pPlant.plantgender == 1 and PlantConfig.MaleFactor or 1)
    local fertilizerFactor = pPlant.fertilizer >= 50 and PlantConfig.FertilizerFactor or 1.0
    local growthFactors = (PlantConfig.GrowthTime * genderFactor * fertilizerFactor)
    local growth = math.min((timeDiff / growthFactors) * 100, 100.0)
    return growth
end

function getPlantId(pEntity)
    for plantId,plant in pairs(ActivePlants) do
        if plant.object == pEntity then
            print(plantId)
            return plantId
        end
    end
end

function getPlantById(pPlantId)
    for _,plant in pairs(WeedPlants) do
        if plant.id == pPlantId then
            return plant
        end
    end
end

function playPourAnimation()
    RequestAnimDict("weapon@w_sp_jerrycan")
    while ( not HasAnimDictLoaded( "weapon@w_sp_jerrycan" ) ) do
        Wait(0)
    end
    TaskPlayAnim(PlayerPedId(),"weapon@w_sp_jerrycan","fire",2.0, -8, -1,49, 0, 0, 0, 0)
end

function showPlantMenu(pPlantId)
    local plant = getPlantById(pPlantId)
    local PlayerData = QBCore.Functions.GetPlayerData()
    local growth = getPlantGrowthPercent(plant)
    local water = math.min(plant.water, 100)
    local myjob = PlayerData.job.name
    if add_maleseed then
        text = "<b style='color:green;'>Male Seed Available</b>"
    else
        text = "<b style='color:red;'>No Male Seeds</b>"
    end
    local context = {
        {
            isMenuHeader = true,
            disabled = true,
            icon = "fas fa-box-archive",
            header = "Plant Processes",
            txt = text,
        },
        {
            id = 2,
            icon = "fas fa-database",
            disabled = true,
            header = 'Plant Height: <b>' .. string.format("%.2f", growth) .. '% </b>',
        },
        {
            id = 3,
            icon = "fas fa-database",
            disabled = true,
            header = 'Water: <b>' .. string.format("%.2f", water),
        }
    }

    if growth < PlantConfig.HarvestPercent then
        context[#context+1] = {
            id = 4,
            header = "Add Male Seed",
            txt = "Get the plant pregnant",
            params = {
                event = "qb-plants:Gate",
                args = pPlantId,
            },
        }
    end
    if growth < PlantConfig.HarvestPercent then
            context[#context+1] = {
            id = 4,
            header = 'Add Water to the Plant',
            txt = 'Water: <b>' .. string.format("%.2f", water) .. '% </b>',
            params = {
                event = "qb-plants:addWater",
                args = pPlantId,
            },
        }
    end
    if growth < PlantConfig.HarvestPercent then
        context[#context+1] = {
            id = 5,
            header = "Add Fertilizer",
            txt = "Fertilizer increases the yield of the plant",
            params = {
                event = "qb-plants:Gate3",
                args = {
                    plantId = pPlantId,
                    type = "n",
                },
            },
        }
    end
    if growth >= 95 or myjob == "police" or myjob == "judge" then
        context[#context+1] = {
        id = 4,
        header = "Eliminate the Pot",
        txt = "Hmm, this looks like an illegal plant",
        params = {
            event = "qb-plants:removePlant",
            args = pPlantId,
        },
    }
    end
    if growth >= 99 then
        context[#context+1] = {
        id = 6,
        header = "Gather the Crops",
        txt = "Gather your crops",
        params = {
            event = "qb-plants:pickplant2",
            args = pPlantId,
        },
    }
    end
    Wait(100)
    exports["qb-menu"]:openMenu(context)
end


