local QBCore = exports['qb-core']:GetCoreObject()

local charPed = nil
isTrainMoving = false 



Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if NetworkIsSessionStarted() then
			TriggerEvent('qb-multicharacter:client:chooseChar')
			return
		end
	end
end)

Config = {
  PedCoords = {x = -3962.103, y = 2013.484, z = 500.91, h = 66.137 , r = 1.0},
  HiddenCoords = {x = -3968.355, y = 2005.308, z = 500.91, h = 67.523, r = 1.0},
  CamCoords = {x = 75.76, y = -1122.13, z = 314.1, h = 26.88 , r = 1.0},
  DefaultSpawn = {x = -1035.71, y = -2731.87, z = 12.86, h = 250.553 , r = 1.0},
}

--- CODE

local choosingCharacter = false
local cam = nil

function openCharMenu(bool)
    print(bool)
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        action = "ui",
        toggle = bool,
    })
    choosingCharacter = bool
    skyCam(bool)
end


RegisterNUICallback('closeUI', function()
    openCharMenu(false)
end)

RegisterNUICallback('disconnectButton', function()
    SetEntityAsMissionEntity(charPed, true, true)
    DeleteEntity(charPed)
    deleteTrain()
    TriggerServerEvent('qb-multicharacter:server:disconnect')
end)

RegisterNUICallback('selectCharacter', function(data)
    local cData = data.cData
    DoScreenFadeOut(10)
    TriggerServerEvent('qb-multicharacter:server:loadUserData', cData)
    openCharMenu(false)
    SetEntityAsMissionEntity(charPed, true, true)
    DeleteEntity(charPed)
end)

RegisterNetEvent('qb-multicharacter:client:closeNUIdefault', function() -- This event is only for no starting apartments
    SetNuiFocus(false, false)
    DoScreenFadeOut(500)
    Citizen.Wait(2000)
    SetEntityCoords(PlayerPedId(), Config.DefaultSpawn.x, Config.DefaultSpawn.y, Config.DefaultSpawn.z)
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
    Citizen.Wait(500)
    openCharMenu()
    SetEntityVisible(PlayerPedId(), true)
    Citizen.Wait(500)
    DoScreenFadeIn(250)
    TriggerEvent('qb-weathersync:client:EnableSync')
    TriggerEvent('qb-clothes:client:CreateFirstCharacter')
end)


RegisterNetEvent('qb-multicharacter:client:closeNUI')
AddEventHandler('qb-multicharacter:client:closeNUI', function()
    SetNuiFocus(false, false)
end)

local Countdown = 1


RegisterNetEvent('qb-multicharacter:client:chooseChar')
AddEventHandler('qb-multicharacter:client:chooseChar', function()
    SetNuiFocus(false, false)
    DoScreenFadeOut(10)
    Citizen.Wait(1000)
    local interior = GetInteriorAtCoords(-1054.08, -2765.75, 4.64, 56.81)
    LoadInterior(interior)
    while not IsInteriorReady(interior) do
        Citizen.Wait(1000)
        print("[Loading Selector Interior, Please Wait!]")
    end
    FreezeEntityPosition(GetPlayerPed(), true)
    SetEntityCoords(GetPlayerPed(), Config.HiddenCoords.x, Config.HiddenCoords.y, Config.HiddenCoords.z)
    Citizen.Wait(1500)
    ShutdownLoadingScreenNui()
    NetworkSetTalkerProximity(0.0)
    DoScreenFadeOut(0)
    DoScreenFadeIn(1000)
   -- spawnTrain()
    openCharMenu(true)
end)

function selectChar()
    openCharMenu(true)
end

RegisterNUICallback('cDataPed', function(data)
    local cData = data.cData
    RequestModel(GetHashKey("mp_m_freemode_01"))

    while not HasModelLoaded(GetHashKey("mp_m_freemode_01")) do
        Wait(1)
    end
    
    SetEntityAsMissionEntity(charPed, true, true)
    DeleteEntity(charPed)

    if cData ~= nil then
        QBCore.Functions.TriggerCallback('qb-multicharacter:server:getSkin', function(model, data)
            if model ~= nil then
                model = model ~= nil and tonumber(model) or false

                if not IsModelInCdimage(model) or not IsModelValid(model) then setDefault() return end
            
                Citizen.CreateThread(function()
                    RequestModel(model)
            
                    while not HasModelLoaded(model) do
                        Citizen.Wait(0)
                    end

                    charPed = CreatePed(3, model, 283.88, -993.71, -92.79, 179.97, false, true)
                    
                    data = json.decode(data)
            
                    TriggerEvent('qb-clothing:client:loadPlayerClothing', data, charPed)
                end)
            else
                charPed = CreatePed(4, GetHashKey("mp_m_freemode_01"), 283.88, -993.71, -92.79, 179.97, false, true)
            end
        end, cData.citizenid)
    else
        charPed = CreatePed(4, GetHashKey("mp_m_freemode_01"), 283.88, -993.71, -92.79, 179.97, false, true)
    end

    Citizen.Wait(100)
    
    SetEntityHeading(charPed, 89.5)
    FreezeEntityPosition(charPed, false)
    SetEntityInvincible(charPed, true)
    PlaceObjectOnGroundProperly(charPed)
    SetBlockingOfNonTemporaryEvents(charPed, true)
end)


RegisterNUICallback('setupCharacters', function()
    QBCore.Functions.TriggerCallback("qb-multicharacter:server:setupCharacters", function(result)
        SendNUIMessage({
            action = "setupCharacters",
            characters = result
        })
    end)
end)

RegisterNUICallback('removeBlur', function()
    SetTimecycleModifier('default')
end)

RegisterNUICallback('createNewCharacter', function(data)
    local cData = data
    DoScreenFadeOut(150)
    if cData.gender == "Male" then
        cData.gender = 0
    elseif cData.gender == "Female" then
        cData.gender = 1
    end

    TriggerServerEvent('qb-multicharacter:server:createCharacter', cData)
    TriggerServerEvent('qb-multicharacter:server:GiveStarterItems')
    Citizen.Wait(500)
end)

RegisterNUICallback('removeCharacter', function(data)
    TriggerServerEvent('qb-multicharacter:server:deleteCharacter', data.citizenid)
end)


function skyCam(bool)
    if bool then
       TriggerEvent('CAMERAPOS:StartSkyCamera')
    else
        SetTimecycleModifier('default')
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        RenderScriptCams(false, false, 1, true, true)
        FreezeEntityPosition(GetPlayerPed(-1), false)
        --TriggerScreenblurFadeOut(
       -- 5000 --[[ number ]]
    --)
    end
end
