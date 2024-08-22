local config = require 'shared.config'
local vehicles = require 'shared.vehicles'
local topVehicleStats = require 'shared.topVehicleStats'

local function replaceShowroomVehicle(newModel)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local closestVehicle = lib.getClosestVehicle(playerCoords, 10.0, false) -- maxDistance set to 10 for a broader search

    if closestVehicle then
        -- Trigger server event with the closest vehicle's entity and the new model
        TriggerServerEvent('vehicleshop:replaceShowroomVehicle', VehToNet(closestVehicle), newModel)
    else
        print("No nearby vehicle found!")
    end
end

local function getCategoryForVehicleType(vehicleType)
    for category, data in pairs(topVehicleStats) do
        for _, type in ipairs(data.types) do
            if type == vehicleType then
                return category
            end
        end
    end
    return nil -- return nil if no match is found
end

local function getAttributePercentage(vehicleType, attributeValue, attributeName)
    local category = getCategoryForVehicleType(vehicleType)

    if not category or not topVehicleStats[category][attributeName] then
        return 0 -- return 0 if vehicle type doesn't match any category or the attribute is invalid
    end

    local topAttributeValue = topVehicleStats[category][attributeName]
    return (attributeValue / topAttributeValue * 100)
end

local function openVehicleDetails(vehicleModel)
    local vehicleData = vehicles[vehicleModel]
    local vehicleType = vehicleData.type

    local options = {
        {
            title = 'Speed',
            progress = getAttributePercentage(vehicleType, vehicleData.speed, "speed"),
            readOnly = true,
            colorScheme = 'red'
        },
        {
            title = 'Handling',
            progress = getAttributePercentage(vehicleType, vehicleData.handling, "handling"),
            readOnly = true,
            colorScheme = 'red'
        },
        {
            title = 'Acceleration',
            progress = getAttributePercentage(vehicleType, vehicleData.acceleration, "acceleration"),
            readOnly = true,
            colorScheme = 'red'
        },
        {
            title = 'Braking',
            progress = getAttributePercentage(vehicleType, vehicleData.braking, "braking"),
            readOnly = true,
            colorScheme = 'red'
        },
        {
            title = 'Seats: ' .. vehicleData["seats"],
            readOnly = true
        },
        {
            title = 'Price: $' .. vehicleData["price"],
            readOnly = true,
        },
        {
            title = 'Buy (WIP)',
            icon = 'money-bill-wave',
            onSelect = function()
                -- Buying logic goes here
            end,
            iconColor = 'green'
        },
        {
            title = 'Place in Showroom',
            icon = 'warehouse',
            onSelect = function()
                replaceShowroomVehicle(vehicleModel)
            end
        },
        {
            title = 'Back to Vehicle Classes',
            menu = 'class_selection' -- This links back to the previous menu
        }
    }

    -- Register the vehicle details context
    lib.registerContext({
        id = 'vehicle_details',
        title = vehicleData["make"] .. ' ' .. vehicleData["name"],
        options = options
    })

    -- Show the vehicle details context
    lib.showContext('vehicle_details')
end



-- Generate context menu options for vehicles within a class
local function generateVehicleOptions(classGroup)
    local options = {}

    -- Sort the classGroup based on price
    table.sort(classGroup, function(a, b)
        return vehicles[a]["price"] < vehicles[b]["price"]
    end)

    for _, vehicle in ipairs(classGroup) do
        local vehicleData = vehicles[vehicle]

        table.insert(options, {
            title = vehicleData["name"],
            description = "Price: $" .. vehicleData["price"],
            icon = 'car',
            onSelect = function()
                openVehicleDetails(vehicle) -- Open the details for the selected vehicle
            end,
            metadata = {
                {
                    label = 'Make',
                    value = vehicleData["make"] or vehicleData["name"],
                },
                {
                    label = 'Speed',
                    progress = getAttributePercentage(vehicleData.type, vehicleData.speed, "speed")
                },
                {
                    label = 'Handling',
                    progress = getAttributePercentage(vehicleData.type, vehicleData.handling, "handling")
                },
                {
                    label = 'Acceleration',
                    progress = getAttributePercentage(vehicleData.type, vehicleData.acceleration, "acceleration")
                },
                {
                    label = 'Braking',
                    progress = getAttributePercentage(vehicleData.type, vehicleData.braking, "braking")
                },
            }
        })
    end

    return options
end

local function searchVehicle(shopType)
    local dialogData = lib.inputDialog("Vehicle Search", {
        {
            type = 'input',
            label = 'Vehicle Name/Model'
        }
    })

    if not dialogData or not dialogData[1] or dialogData[1] == "" then
        return
    end

    local searchTerm = string.lower(dialogData[1])
    local foundVehicles = {}

    for model, vehicleData in pairs(vehicles) do
        if string.find(string.lower(vehicleData["name"]), searchTerm) or string.find(string.lower(model), searchTerm) then
            if not config.restrictedVehicles[model] and not vehicleData["weapons"] and not config.shops[shopType].excludedClasses[vehicleData["class"]] then
                table.insert(foundVehicles, model)
            end
        end
    end

    if #foundVehicles == 0 then
        lib.notify({
            title = 'Error!',
            description = 'No vehicle by that name or model was found.',
            type = 'error',
            duration = 3500
        })
        return
    end

    -- Register and display search results context menu
    local searchOptions = generateVehicleOptions(foundVehicles)

    lib.registerContext({
        id = 'search_results',
        title = 'Search Results',
        menu = 'class_selection',
        options = searchOptions
    })

    lib.showContext('search_results')
end

-- Group vehicles by class with filtering
local function groupVehiclesByClass(vehicles, excludedClasses)
    local grouped = {}

    for k, v in pairs(vehicles) do
        local class = v["class"]

        -- Exclude vehicles with weapons, certain classes, and restricted models
        if not v["weapons"] and not excludedClasses[class] and not config.restrictedVehicles[k] then
            if not grouped[class] then
                grouped[class] = {}
            end

            table.insert(grouped[class], k)
        end
    end

    return grouped
end

local function openVehicleMenu(shopType)
    local shopConfig = config.shops[shopType]
    if not shopConfig then
        print("Invalid shop type provided!")
        return
    end

    local groupedVehicles = groupVehiclesByClass(vehicles, shopConfig.excludedClasses)

    -- Generate class selection menu
    local classOptions = {}
    table.insert(classOptions, 1, {
        title = "Search",
        description = "Search for a vehicle by name or model",
        icon = 'search',
        onSelect = function()
            searchVehicle(shopType) -- pass the current shopType
        end
    })

    local sortedClasses = {}
    for class, _ in pairs(groupedVehicles) do
        table.insert(sortedClasses, class)
    end

    table.sort(sortedClasses, function(a, b)
        local classNameA = config.classMapping[tonumber(a)] or "Unknown"
        local classNameB = config.classMapping[tonumber(b)] or "Unknown"
        return classNameA:lower() < classNameB:lower()
    end)

    for _, class in ipairs(sortedClasses) do
        local vehicleListId = 'vehicle_list_' .. class
        local className = config.classMapping[tonumber(class)] or "Unknown"

        table.insert(classOptions, {
            title = className,
            menu = vehicleListId,
            icon = 'list'
        })

        -- Register vehicle selection menu for this class
        lib.registerContext({
            id = vehicleListId,
            title = "Select Vehicle (" .. className .. ")",
            menu = 'class_selection',
            options = generateVehicleOptions(groupedVehicles[class])
        })
    end

    -- Register class selection menu
    lib.registerContext({
        id = 'class_selection',
        title = 'Select Vehicle Class',
        options = classOptions
    })

    -- Show class selection menu
    lib.showContext('class_selection')
end

AddEventHandler('vehicleshop:openVehicleMenu', function(shopType)
    openVehicleMenu(shopType or 'pdm') -- default to pdm if no shopType provided
end)
