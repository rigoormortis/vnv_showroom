exports.ox_target:addBoxZone({
    name = "pdm1",
    coords = vec3(-38.9, -1100.25, 27.0),
    size = vec3(0.45, 0.8, 1.35),
    rotation = 201.5,
    drawSprite = true,
    options = {
        {
            label = 'Change Showroom Default',
            icon = 'fa-solid fa-car-on',
            groups = 'pdm',
            onSelect = function()
                TriggerEvent('vehicleshop:openVehicleMenu', 'pdm')
            end
        }
    },
})

exports.ox_target:addBoxZone({
    name = "pdm2",
    coords = vec3(-40.3, -1094.5, 27.0),
    size = vec3(0.45, 0.8, 1.35),
    rotation = 25.75,
    drawSprite = true,
    options = {
        {
            label = 'Change Showroom Default',
            icon = 'fa-solid fa-car-on',
            groups = 'pdm',
            onSelect = function()
                TriggerEvent('vehicleshop:openVehicleMenu', 'pdm')
            end
        }
    },
})

exports.ox_target:addBoxZone({
    name = "pdm3",
    coords = vec3(-46.95, -1095.4, 27.0),
    size = vec3(0.45, 0.8, 1.35),
    rotation = 100.75,
    drawSprite = true,
    options = {
        {
            label = 'Change Showroom Default',
            icon = 'fa-solid fa-car-on',
            groups = 'pdm',
            onSelect = function()
                TriggerEvent('vehicleshop:openVehicleMenu', 'pdm')
            end
        }
    },
})

exports.ox_target:addBoxZone({
    name = "pdm4",
    coords = vec3(-51.75, -1095.1, 27.0),
    size = vec3(0.45, 0.8, 1.35),
    rotation = 208.25,
    drawSprite = true,
    options = {
        {
            label = 'Change Showroom Default',
            icon = 'fa-solid fa-car-on',
            groups = 'pdm',
            onSelect = function()
                TriggerEvent('vehicleshop:openVehicleMenu', 'pdm')
            end
        }
    },
})

exports.ox_target:addBoxZone({
    name = "pdm5",
    coords = vec3(-51.1, -1086.95, 27.0),
    size = vec3(0.45, 0.8, 1.35),
    rotation = 248.25,
    drawSprite = true,
    options = {
        {
            label = 'Change Showroom Default',
            icon = 'fa-solid fa-car-on',
            groups = 'pdm',
            onSelect = function()
                TriggerEvent('vehicleshop:openVehicleMenu', 'pdm')
            end
        }
    },
})
