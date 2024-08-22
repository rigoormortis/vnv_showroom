local config = require 'shared.config'
local shopTypes = { 'pdm', 'truckShop' } -- List all your shop types here

for _, shopType in ipairs(shopTypes) do
    local showroomModels = MySQL.query.await('SELECT * FROM `showroom_vehicles` WHERE `shop` = ?', { shopType })

    CreateThread(function()
        if showroomModels then
            local shopConfig = config.shops[shopType]
            for index, vehicleData in pairs(showroomModels) do
                if shopConfig.showroomLocations[index] then
                    local spawnLocation = shopConfig.showroomLocations[index]

                    -- Create the vehicle at the specified location
                    local vehicle = Ox.CreateVehicle({
                        model = vehicleData.model,
                    }, vec3(spawnLocation.x, spawnLocation.y, spawnLocation.z), spawnLocation.w)
                    if vehicle then
                        vehicle.setGroup(shopType)
                        vehicle.set('shopType', shopType)
                        -- Additional configuration of the vehicle can be done here, if necessary
                    end
                end
            end
        end
    end)
end
