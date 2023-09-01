Trunk = {}
Trunk.Functions = {}

Trunk.Settings = {
    MoneyList = {Index = 1, "Deposit", "Withdraw"}
}

Trunk.Functions.RefreshPlayerData = function()
    CreateThread(function()
        ESX.PlayerData = ESX.GetPlayerData()
    end)
end

Trunk.Functions.KeyboardInput = function(entryTitle, textEntry, inputText, maxLength)
    AddTextEntry(entryTitle, textEntry)
    DisplayOnscreenKeyboard(1, entryTitle, "", inputText, "", "", "", maxLength)
	blockinput = true
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
		blockinput = false
        return result
    else
        Citizen.Wait(500)
		blockinput = false
        return nil
    end
end

Trunk.Functions.ActionMoney = function(vehicleMoney, Index, vehiclePlate, vehicleClass)
    if Index == 1 then 
        local DepositAmount = Trunk.Functions.KeyboardInput("DepositAmount", "Amount", "", 6)
        if DepositAmount ~= nil then 
            DepositAmount = tonumber(DepositAmount)
            if type(DepositAmount) == "number" then 
                TriggerServerEvent("cmdTrunk:DepositMoney", vehicleMoney, vehiclePlate, DepositAmount, vehicleClass)                                     
                Wait(150)
                Trunk.Functions.RefreshPlayerData()
                TrunkMenu.Closed()
            end
        else
            ESX.ShowNotification("Wrong input")
        end
    elseif Index == 2 then 
        local WithdrawAmount = Trunk.Functions.KeyboardInput("WithdrawAmount", "Amount", "", 6)
        if WithdrawAmount ~= nil then 
            WithdrawAmount = tonumber(WithdrawAmount)
            if type(WithdrawAmount) == "number" then 
                TriggerServerEvent("cmdTrunk:WithdrawMoney", vehicleMoney, vehiclePlate, WithdrawAmount)                                           
                Wait(150)
                Trunk.Functions.RefreshPlayerData()
                TrunkMenu.Closed()
            end
        else
            ESX.ShowNotification("Wrong input")
        end
    end
end