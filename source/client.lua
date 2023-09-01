OpenMenu, vehiclePlate, vehicle, vehicleInfos = false, nil, nil, {}
local vehicleWeight = nil

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
end)

TrunkMenu = RageUI.CreateMenu("Trunk", "Possible Actions")
TrunkDepositMenu = RageUI.CreateSubMenu(TrunkMenu, "Your Inventory", "Possible Actions")
TrunkWithdrawMenu = RageUI.CreateSubMenu(TrunkMenu, "Trunk", "Possible Actions")
TrunkMenu.Closed = function()
    RageUI.Visible(TrunkMenu, false)
    RageUI.Visible(TrunkDepositMenu, false)
    RageUI.Visible(TrunkWithdrawMenu, false)
    FreezeEntityPosition(PlayerPedId(), false)
    OpenMenu = false
end

RegisterNetEvent("cmdTrunk:getWeight")
AddEventHandler("cmdTrunk:getWeight", function(newWeight)
    vehicleWeight = newWeight
end)

local OpenMenu = false

RegisterNetEvent("cmdTrunk:OpenMenu")
AddEventHandler("cmdTrunk:OpenMenu", function(vehicleInfos, vehicleWeight)
    if OpenMenu then
        OpenMenu = false
        RageUI.Visible(TrunkMenu, false)
    else
        OpenMenu = true
        vehicleInfos = vehicleInfos
        Wait(50)
        RageUI.Visible(TrunkMenu, true)
        local playerPed = PlayerPedId()
        local vehicle = nil
        local vehiclePlate = ""
        local vehicleMoney = 0
        local vehicleData = {}

        CreateThread(function()
            while OpenMenu do
                for k,v in pairs(vehicleInfos) do
                    vehicleData = v.vehicleData
                    if v.vehiclePlate ~= nil then
                        vehiclePlate = v.vehiclePlate
                        vehicleMoney = v.vehicleMoney
                    else
                        vehicleData = {}
                        vehiclePlate = plate
                        vehicleMoney = 0
                    end
                end
                local playerCoords = GetEntityCoords(playerPed)
                if not IsPedSittingInAnyVehicle(playerPed) then
                    local closestVehicle = GetClosestVehicle(playerCoords.x, playerCoords.y, playerCoords.z, 5.0, 0, 71)
                    if closestVehicle ~= 0 then
                        vehicle = closestVehicle
                    else
                        vehicle = nil
                    end
                else
                    vehicle = GetVehiclePedIsIn(playerPed, false)
                end

                if vehicle == nil or #(playerCoords - GetEntityCoords(vehicle)) > 3.0 then
                    OpenMenu = false
                    RageUI.Visible(TrunkMenu, false)
                end

                RageUI.IsVisible(TrunkMenu, function()
                    RageUI.Separator("License Plate: " .. vehiclePlate)
                    RageUI.Separator("Weight: " .. vehicleWeight .. "/" .. Config.Trunk.vehicleClass[GetVehicleClass(vehicle)] .. "KG")
                    RageUI.List("Money Amount: $" .. vehicleMoney .. " ", Trunk.Settings.MoneyList, Trunk.Settings.MoneyList.Index, false, {}, true, {
                        onListChange = function(Index)
                            Trunk.Settings.MoneyList.Index = Index
                        end,
                        onSelected = function(Index)
                            Trunk.Functions.ActionMoney(vehicleMoney, Index, vehiclePlate, GetVehicleClass(vehicle))
                        end
                    })
                    RageUI.Button("Deposit", false, {RightLabel = "→"}, true, {
                        onSelected = function()
                            Trunk.Functions.RefreshPlayerData()
                        end
                    }, TrunkDepositMenu)
                    RageUI.Button("Withdraw", false, {RightLabel = "→"}, true, {}, TrunkWithdrawMenu)
                end)

                RageUI.IsVisible(TrunkDepositMenu, function()
                    RageUI.Separator("↓ Items ↓")
                    for k,v in pairs(ESX.PlayerData.inventory) do
                        if v.count > 0 then
                            RageUI.Button(v.label.." - ["..v.count.."]", false , {RightLabel = "Deposit →"}, true , {
                                onSelected = function()
                                    local DepositCount = Trunk.Functions.KeyboardInput("DepositCount", "Quantity:", "", 3)
                                    if DepositCount ~= nil then
                                        DepositCount = tonumber(DepositCount)
                                        if type(DepositCount) == "number" then
                                            TriggerServerEvent("cmdTrunk:Deposit", vehiclePlate, vehicleData, v.name, DepositCount, vehicleWeight, GetVehicleClass(vehicle))
                                            Wait(150)
                                            Trunk.Functions.RefreshPlayerData()
                                            TrunkMenu.Closed()
                                        end
                                    else
                                        ESX.ShowNotification("Invalid input")
                                    end
                                end
                            })
                        end
                    end
                end)

                RageUI.IsVisible(TrunkWithdrawMenu, function()
                    RageUI.Separator("↓ Contents ↓")
                    for k,v in pairs(vehicleInfos) do
                        if v.vehicleData ~= nil then
                            for t,b in pairs(v.vehicleData) do
                                if v.vehicleData[t].count > 0 then
                                    RageUI.Button(v.vehicleData[t].label.." - ["..v.vehicleData[t].count.."]", false , {RightLabel = "Withdraw →"}, true , {
                                        onSelected = function()
                                            local WithdrawCount = Trunk.Functions.KeyboardInput("WithdrawCount", "Quantity:", "", 3)
                                            if WithdrawCount ~= nil then
                                                WithdrawCount = tonumber(WithdrawCount)
                                                if type(WithdrawCount) == "number" then
                                                    TriggerServerEvent("cmdTrunk:Withdraw", vehiclePlate, vehicleData, v.vehicleData[t].name, WithdrawCount)
                                                    Wait(150)
                                                    Trunk.Functions.RefreshPlayerData()
                                                    TrunkMenu.Closed()
                                                end
                                            end
                                        end
                                    })
                                end
                            end
                        end
                    end
                end)

                Wait(0)
            end
        end)
    end
end)

Keys.Register('L', 'Trunk', 'Open Trunk', function()
    vehiclePlate = nil
    vehicle = nil
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed, true)
    local player, distance = ESX.Game.GetClosestPlayer()
    if player ~= -1 and distance <= 2.0 then
        ESX.ShowNotification("Another player is already at the trunk.")
    else
        if IsPedInAnyVehicle(playerPed,  false) then
            ESX.ShowNotification("ERROR NOTIFY")  
            return
        else
            if GetVehicleDoorLockStatus(vehicle) == 2 then 
                ESX.ShowNotification("The vehicle is locked")
                return end
            vehicle = GetClosestVehicle(playerCoords.x, playerCoords.y, playerCoords.z, 3.5, 0, 71)
            plate = GetVehicleNumberPlateText(vehicle)
        end
        if vehicle ~= 0 then
            TriggerServerEvent("cmdTrunk:GetInfos", plate)
        else
            ESX.ShowNotification("No vehicle nearby")
        end
    end
end)