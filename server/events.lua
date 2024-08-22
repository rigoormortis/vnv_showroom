RegisterServerEvent('vehicleshop:replaceShowroomVehicle', function(closestVehicleEntity, newModel)
    -- Get the old vehicle
    local oldVehicle = Ox.GetVehicleFromNetId(closestVehicleEntity)
    local oldModel = oldVehicle.model
    local coords = oldVehicle.getCoords()
    local heading = GetEntityHeading(oldVehicle.entity)
    local shopType = oldVehicle.get('shopType')

    -- Delete the old vehicle
    oldVehicle.despawn()

    local newVehicle = Ox.CreateVehicle({
        model = newModel
    }, vec3(coords.x, coords.y, coords.z), heading)
    newVehicle.setGroup('pdm')
    newVehicle.set('shopType', shopType)

    -- Update the database
    local affectedRows = MySQL.update.await(
        'UPDATE `showroom_vehicles` SET `model` = ? WHERE `model` = ? AND `shop` = ?', {
            newModel, oldModel, shopType
        })

    if affectedRows > 0 then
        print("Successfully updated the showroom vehicle!")
    else
        print("Failed to update the showroom vehicle in the database.")
    end
end)
