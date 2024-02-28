PlantConfig = {

    --Script automatically splits this into %'s
    GrowthObjects = {
        {hash = `bkr_prop_weed_01_small_01b`, zOffset = -0.5},
        {hash = `bkr_prop_weed_med_01a`, zOffset = -3.0},
        {hash = `bkr_prop_weed_med_01b`, zOffset = -3.0},
        {hash = `bkr_prop_weed_lrg_01a`, zOffset = -3.0},
        {hash = `bkr_prop_weed_lrg_01b`, zOffset = -3.0},
    },
    -- Plant Growing time in minutes
    GrowthTime = 2,
    -- How much longer should a male plant take to grow less is faster
    MaleFactor = 0.9,
    -- How many seeds should come from a male plant (range)
    SeedsFromMale = {5, 8},
    -- How many dopes should come from a female plant (range)
    DopeFromFemale = {3, 6},
    -- Percent at which the plant becomes harvestable
    HarvestPercent = 95,
    -- Time between plant harvests (minutes)
    TimeBetweenHarvest = 400,
    -- How much should 1 water bottle add, if you want to give 20, set {20, 20}
    WaterAdd = {16, 20},
    FertilizerItem = 'weed_nutrition',
    WaterItem = 'marijuana_water',
    MaleSeedItem = 'maleseed',
    FemaleSeedItem = 'femaleseed',
    GiveDopeItem = 'weed',
    -- less is faster growth but less quality
    FertilizerFactor = 0.9,
    -- Affects how much each nutrient contributes to the final quality
    NWeight = 25,
    PWeight = 50,
    KWeight = 25,
}


WeedZones = {
    -- x, y, z, radius
    {vector3(1990.48, 4897.5, 42.83), 44,0},
    {vector3(2005.93, 4929.87, 42.76), 20.16},
    {vector3(2031.39, 4905.51, 42.75), 228.8},
    {vector3(2005.14, 4877.69, 42.75), 134.18},
}

notify = function(msg)
    QBCore.Functions.Notify(msg)
end