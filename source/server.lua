RegisterServerEvent("cmdTrunk:GetInfos")
AddEventHandler("cmdTrunk:GetInfos", function(vehiclePlate)
    local _src = source 
    MySQL.Async.fetchAll("SELECT * FROM trunk WHERE vehiclePlate = @vehiclePlate", {
        ["vehiclePlate"]= vehiclePlate
    }, function(result)
        if result[1] then 
            local counterData = 0
            local counterMoney = 0
            for k, v in pairs(result) do
                result[k].vehicleData = json.decode(v.vehicleData)
                if result[k].vehiclePlate == vehiclePlate then 
                    if result[k].vehicleData ~= nil then 
                        for t,b in pairs(result[k].vehicleData) do 
                            counterData = counterData + result[k].vehicleData[t].count*Config.ItemWeight[result[k].vehicleData[t].name]					
                        end
                    end
                    if result[k].vehicleMoney ~= 0 then 
                        counterMoney = ESX.Math.Round(counterMoney + result[k].vehicleMoney*Config.MoneyWeight, 2)		
                    end
                end
            end
            vehicleWeight = counterData + counterMoney       
            local vehicleInfos = result
            TriggerClientEvent("cmdTrunk:OpenMenu", _src, vehicleInfos, vehicleWeight)
        else
            vehicleWeight = 0
            local vehicleInfos = {vehicleData = {}, vehiclePlate = vehiclePlate}
            MySQL.Async.execute('INSERT INTO trunk (vehiclePlate, vehicleData) VALUES (@vehiclePlate, @vehicleData)',{
                ['vehiclePlate'] = vehicleInfos.vehiclePlate,
                ['vehicleData'] = json.encode(vehicleInfos.vehicleData)
            })
            TriggerClientEvent("cmdTrunk:OpenMenu", _src, vehicleInfos, 0)
        end
    end)
end)

RegisterServerEvent("cmdTrunk:Deposit")
AddEventHandler("cmdTrunk:Deposit", function(vehiclePlate, vehicleData, itemName, itemCount, vehicleWeight, vehicleClass)
    local _src = source 
    local xPlayer = ESX.GetPlayerFromId(_src)
    if Config.ItemWeight[itemName] then 
        if (vehicleWeight+itemCount*Config.ItemWeight[itemName]) <= Config.Trunk.vehicleClass[vehicleClass] then 
            if itemCount <= xPlayer.getInventoryItem(itemName).count then
                if not vehicleData[itemName] then 
                    vehicleData[itemName] = {}
                    vehicleData[itemName].label = ESX.GetItemLabel(itemName)
                    vehicleData[itemName].name = itemName
                    vehicleData[itemName].count = itemCount
                else
                    vehicleData[itemName].count = vehicleData[itemName].count + itemCount
                end
                MySQL.Async.execute("UPDATE trunk SET vehicleData = @vehicleData WHERE vehiclePlate = @vehiclePlate", {
                    ["@vehiclePlate"] = vehiclePlate, 
                    ["@vehicleData"] = json.encode(vehicleData)
                })
                Wait(250)
                xPlayer.removeInventoryItem(itemName, itemCount)
                TriggerClientEvent('esx:showNotification', _src, "Du hast "..itemCount.." in den Kofferraum gelegt"..vehicleData[itemName].label)
                MySQL.Async.fetchAll("SELECT * FROM trunk WHERE vehiclePlate = @vehiclePlate", {
                    ["vehiclePlate"]= vehiclePlate
                }, function(dataCount)
                    if dataCount[1] then 
                        local counterData = 0
                        local counterMoney = 0
                        for k, v in pairs(dataCount) do
                            dataCount[k].vehicleData = json.decode(v.vehicleData)
                            if dataCount[k].vehiclePlate == vehiclePlate then 
                                if dataCount[k].vehicleData ~= nil then 
                                    for t,b in pairs(dataCount[k].vehicleData) do 
                                        counterData = counterData + dataCount[k].vehicleData[t].count*Config.ItemWeight[dataCount[k].vehicleData[t].name]					
                                    end
                                end
                                if dataCount[k].vehicleMoney ~= 0 then 
                                    counterMoney = ESX.Math.Round(counterMoney + dataCount[k].vehicleMoney*Config.MoneyWeight, 2)		
                                end
                            end
                        end
                        vehicleWeight = counterData + counterMoney       
                        local vehicleInfos = dataCount
                        TriggerClientEvent("cmdTrunk:OpenMenu", _src, vehicleInfos, vehicleWeight)
                    end
                end)
            else
                TriggerClientEvent('esx:showNotification', _src, "Du hast nicht genug "..ESX.GetItemLabel(itemName).." ")
            end
        else
            TriggerClientEvent('esx:showNotification', _src, "Der Kofferraum ist voll")
        end
    else
        TriggerClientEvent('esx:showNotification', _src, "Kofferraum "..ESX.GetItemLabel(itemName).." ist nicht vorhanden")
    end
end)

RegisterServerEvent("cmdTrunk:Withdraw")
AddEventHandler("cmdTrunk:Withdraw", function(vehiclePlate, vehicleData, itemName, itemCount)
    local _src = source 
    local xPlayer = ESX.GetPlayerFromId(_src)
    if itemCount <= vehicleData[itemName].count then 
        if vehicleData[itemName].count then 
            vehicleData[itemName].count = vehicleData[itemName].count - itemCount
        end
        MySQL.Async.execute("UPDATE trunk SET vehicleData = @vehicleData WHERE vehiclePlate = @vehiclePlate", {
            ["@vehiclePlate"] = vehiclePlate, 
            ["@vehicleData"] = json.encode(vehicleData)
        })
        Wait(250)
        xPlayer.addInventoryItem(itemName, itemCount)
        TriggerClientEvent('esx:showNotification', _src, "Du hast "..itemCount.." aus dem Kofferaum genommen "..vehicleData[itemName].label)
        MySQL.Async.fetchAll("SELECT * FROM trunk WHERE vehiclePlate = @vehiclePlate", {
            ["vehiclePlate"]= vehiclePlate
        }, function(dataCount)
            if dataCount[1] then 
                local counterData = 0
                local counterMoney = 0
                for k, v in pairs(dataCount) do
                    dataCount[k].vehicleData = json.decode(v.vehicleData)
                    if dataCount[k].vehiclePlate == vehiclePlate then 
                        if dataCount[k].vehicleData ~= nil then 
                            for t,b in pairs(dataCount[k].vehicleData) do 
                                counterData = counterData + dataCount[k].vehicleData[t].count*Config.ItemWeight[dataCount[k].vehicleData[t].name]					
                            end
                        end
                        if dataCount[k].vehicleMoney ~= 0 then 
                            counterMoney = ESX.Math.Round(counterMoney + dataCount[k].vehicleMoney*Config.MoneyWeight, 2)		
                        end
                    end
                end
                vehicleWeight = counterData + counterMoney         
                local vehicleInfos = dataCount
                TriggerClientEvent("cmdTrunk:OpenMenu", _src, vehicleInfos, vehicleWeight)
            end
        end)
    else
        TriggerClientEvent('esx:showNotification', _src, "Du hast nicht genug: "..ESX.GetItemLabel(itemName).." ")
    end
end)

RegisterServerEvent("cmdTrunk:DepositMoney")
AddEventHandler("cmdTrunk:DepositMoney", function(currentMoney, vehiclePlate, moneyAmount, vehicleClass)
    local _src = source 
    local xPlayer = ESX.GetPlayerFromId(_src)
    if (vehicleWeight+moneyAmount*Config.MoneyWeight) <= Config.Trunk.vehicleClass[vehicleClass] then 
        if xPlayer.getAccount('black_money').money >= moneyAmount then 
            MySQL.Async.execute("UPDATE trunk SET vehicleMoney = @vehicleMoney WHERE vehiclePlate = @vehiclePlate", {
                ["@vehiclePlate"] = vehiclePlate, 
                ["@vehicleMoney"] = currentMoney + moneyAmount
            })
            Wait(250)
            xPlayer.removeAccountMoney('black_money', moneyAmount)
            TriggerClientEvent('esx:showNotification', _src, "Du hast $"..moneyAmount.."reingelegt")
            MySQL.Async.fetchAll("SELECT * FROM trunk WHERE vehiclePlate = @vehiclePlate", {
                ["vehiclePlate"]= vehiclePlate
            }, function(dataCount)
                if dataCount[1] then 
                    local counterData = 0
                    local counterMoney = 0
                    for k, v in pairs(dataCount) do
                        dataCount[k].vehicleData = json.decode(v.vehicleData)
                        if dataCount[k].vehiclePlate == vehiclePlate then 
                            if dataCount[k].vehicleData ~= nil then 
                                for t,b in pairs(dataCount[k].vehicleData) do 
                                    counterData = counterData + dataCount[k].vehicleData[t].count*Config.ItemWeight[dataCount[k].vehicleData[t].name]					
                                end
                            end
                            if dataCount[k].vehicleMoney ~= 0 then 
                                counterMoney = ESX.Math.Round(counterMoney + dataCount[k].vehicleMoney*Config.MoneyWeight, 2)		
                            end
                        end
                    end
                    vehicleWeight = counterData + counterMoney                 
                    local vehicleInfos = dataCount
                    TriggerClientEvent("cmdTrunk:OpenMenu", _src, vehicleInfos, vehicleWeight)
                end
            end)
        else
            TriggerClientEvent('esx:showNotification', _src, "Du hast nicht genug Schwarzgeld bei dir")
        end
    else
        TriggerClientEvent('esx:showNotification', _src, "Der Kofferraum ist voll")
    end
end)

RegisterServerEvent("cmdTrunk:WithdrawMoney")
AddEventHandler("cmdTrunk:WithdrawMoney", function(currentMoney, vehiclePlate, moneyAmount)
    local _src = source 
    local xPlayer = ESX.GetPlayerFromId(_src)
    if currentMoney >= moneyAmount then 
        MySQL.Async.execute("UPDATE trunk SET vehicleMoney = @vehicleMoney WHERE vehiclePlate = @vehiclePlate", {
            ["@vehiclePlate"] = vehiclePlate, 
            ["@vehicleMoney"] = currentMoney - moneyAmount
        })
        Wait(250)
        xPlayer.addAccountMoney('black_money', moneyAmount)
        TriggerClientEvent('esx:showNotification', _src, "Du hast $"..moneyAmount.." in den Kofferraum gelegt")
        MySQL.Async.fetchAll("SELECT * FROM trunk WHERE vehiclePlate = @vehiclePlate", {
            ["vehiclePlate"]= vehiclePlate
        }, function(dataCount)
            if dataCount[1] then 
                local counterData = 0
                local counterMoney = 0
                for k, v in pairs(dataCount) do
                    dataCount[k].vehicleData = json.decode(v.vehicleData)
                    if dataCount[k].vehiclePlate == vehiclePlate then 
                        if dataCount[k].vehicleData ~= nil then 
                            for t,b in pairs(dataCount[k].vehicleData) do 
                                counterData = counterData + dataCount[k].vehicleData[t].count*Config.ItemWeight[dataCount[k].vehicleData[t].name]					
                            end
                        end
                        if dataCount[k].vehicleMoney ~= 0 then 
                            counterMoney = ESX.Math.Round(counterMoney + dataCount[k].vehicleMoney*Config.MoneyWeight, 2)		
                        end
                    end
                end
                vehicleWeight = counterData + counterMoney                 
                local vehicleInfos = dataCount
                TriggerClientEvent("cmdTrunk:OpenMenu", _src, vehicleInfos, vehicleWeight)
            end
        end)
    else
        TriggerClientEvent('esx:showNotification', _src, "Es ist nicht genug Schwarzgeld im Kofferraum")
    end
end)