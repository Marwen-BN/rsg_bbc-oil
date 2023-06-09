
local RSGCore = exports['rsg-core']:GetCoreObject()
--Function for beggining the mission
function supplymissionbeginstage() --function used to fill your wagon with the supplies
    local repeatamount, pl = 0, PlayerPedId()
    repeat --repeat until repeatamount == 3 (this basically allows this code to run 3 times similar to if you made a function of this code and called it 3 times, just does it in less code)
        repeatamount = repeatamount + 1 --repeat amount = repeatamount + 1 so everytime this is ran it will add one
         RSGCore.Functions.Notify(Config.Language.SupplyWagonMisisonBegin, 'success', 6000) --prints on your screen

        --Coord Randomization
        local mathr1 = math.random(1, #SupplyMission.SupplyMisisonPickupLocation) --Gets a random set of coords from table
        local fillcoords = SupplyMission.SupplyMisisonPickupLocation[mathr1] --gets a random set of coords from table(table is in the config)
        
        --Blip and Waypoint Setup
        local blip1 = Citizen.InvokeNative(0x554D9D53F696D002, -1282792512, fillcoords.location.x, fillcoords.location.y, fillcoords.location.z, 5) --creates blip using natives
        Citizen.InvokeNative(0x9CB1A1623062F402, blip1, Config.Language.Pickupsupplyblip) --names blip
        StartGpsMultiRoute(6, true, true)
		AddPointToGpsMultiRoute(fillcoords.location.x, fillcoords.location.y, fillcoords.location.z) --Creates the gps waypoint
        SetGpsMultiRouteRender(true)
        --Distance Check Setup for picking up boxes
        FreezeEntityPosition(Createdwagon, true) --freezes wagon in  place
        distcheck(fillcoords.location.x, fillcoords.location.y, fillcoords.location.z, 3, pl)
        if Playerdead or WagonDestroyed then --if variable true then
            RemoveBlip(blip1) --removes blip
            ClearGpsMultiRoute() --Removes the gps waypoint
            repeatamount = 3
             RSGCore.Functions.Notify(Config.Language.Missionfailed, 'success', 6000) return --prints on screen then returns to end the function here not allowing more code below to run failing mission
        end
        RemoveBlip(blip1) --removes blip
        ClearGpsMultiRoute() --clears gps

        --pulled from syn construction, carrying box setup
         RSGCore.Functions.Notify(Config.Language.Grabbingsupplies, 'success', 6000) --prints on screen
        FreezeEntityPosition(pl, true)
        TaskStartScenarioInPlace(pl, joaat('WORLD_HUMAN_FARMER_WEEDING'), 4000, true, false, false, false)
        Wait(4000) --waits 4 seconds allowing anim to finish
        ClearPedTasksImmediately(pl)
        FreezeEntityPosition(pl, false)
        local props = CreateObject(joaat("p_crate03x"), 0, 0, 0, 1, 0, 1)
        PlayerCarryBox(props) --triggers function to make player carry the box
         RSGCore.Functions.Notify(Config.Language.Putsuppliesonwagon, 'success', 6000) --prints on screen
        
        --Dist Check Setup for player to wagon loading boxes onto wagon
        local wc = GetEntityCoords(Createdwagon) --gets the wagons coords
        distcheck(wc.x, wc.y, wc.z, 3, pl)
        ClearPedTasksImmediately(pl)
        DeleteEntity(props) --delete object
        if Playerdead or WagonDestroyed then --if variable true then
            repeatamount = 3 --sets repeat amount to 3 so the repeat wont run again if you die
            DeleteEntity(props) --delete object
            ClearPedTasksImmediately(pl)
             RSGCore.Functions.Notify(Config.Language.Missionfailed, 'success', 6000) return --prints on screen then returns ending function here failing mission
        end
    until repeatamount == 3 --if variable == 3 then it will not repeat again if less than 3 it will repeat
    FreezeEntityPosition(Createdwagon, false) --unfreezes the wagon once the repeat is over
    deliversupplies() --triggers the next function/part of mission
end

function deliversupplies()
    local repeatamount, pl = 0, PlayerPedId()

    --Coords Randomization
    local mathr1 = math.random(1, #Config.SupplyDeliveryLocations) --Gets a random set of coords from table
    local fillcoords = Config.SupplyDeliveryLocations[mathr1] --gets a random set of coords from table(table is in the config)
     RSGCore.Functions.Notify(Config.Language.DeliverSupplies, 'success', 6000) --prints on screen
    
    --Mission Start
    repeat --repeat until
        repeatamount = repeatamount + 1 --adds 1 to the repeat amount variable
        
        --Blip and Waypoint Setup
        local blip1 = Citizen.InvokeNative(0x554D9D53F696D002, -1282792512, fillcoords.x, fillcoords.y, fillcoords.z, 5) --creates blip using natives
        Citizen.InvokeNative(0x9CB1A1623062F402, blip1, Config.Language.DeliverSupplies) --names blip
       StartGpsMultiRoute(6, true, true)
	   AddPointToGpsMultiRoute(fillcoords.x, fillcoords.y, fillcoords.z) --creates waypoint
       SetGpsMultiRouteRender(true)
        --Dist Check Setup wagon to drop off location
        distcheck(fillcoords.x, fillcoords.y, fillcoords.z, 15, Createdwagon)
        if Playerdead or WagonDestroyed then --if deadcheck true then
            RemoveBlip(blip1) --removes blip
            ClearGpsMultiRoute() --Removes the gps waypoint
             RSGCore.Functions.Notify(Config.Language.Missionfailed, 'success', 6000) --prints on screen
            repeatamount = 3 return --sets variable too 3 preventing the repeat from running again then returns to end the function here
        end
        FreezeEntityPosition(Createdwagon, true) --freezes the wagon
         RSGCore.Functions.Notify(Config.Language.GetSuppliesFromWagon, 'success', 6000) --prints on screen

        --Dist Check Player to pick up supplies from wagon
        local wc = GetEntityCoords(Createdwagon)
        distcheck(wc.x, wc.y, wc.z, 3, pl)
        if Playerdead or WagonDestroyed then --if deadcheck true then
            repeatamount = 3 --sets variable too 3
            RemoveBlip(blip1) --removes blip
            ClearGpsMultiRoute() --Removes the gps waypoint
             RSGCore.Functions.Notify(Config.Language.Missionfailed, 'success', 6000) return --prints on screen then returns to break function here
        end
         RSGCore.Functions.Notify(Config.Language.DeliverSupplies, 'success', 6000) --prints on screen
        
        --Picking up/ Holding Supplies animation setup
        local props = CreateObject(joaat("p_crate03x"), 0, 0, 0, 1, 0, 1)
        PlayerCarryBox(props) --triggers the function to make the player hold the box

        --Dist check setup for delivering the supples
        distcheck(fillcoords.x, fillcoords.y, fillcoords.z, 2, pl)
        DeleteEntity(props) --deletes the prop(box)
        ClearPedTasksImmediately(pl)
        RemoveBlip(blip1) --removes blip
    until repeatamount == 3 --repeats until the variable = 3 then it wont repeat again
    if Playerdead or WagonDestroyed then --if variable true then
        RemoveBlip(blip1) --remove blip
        ClearGpsMultiRoute() --Removes the gps waypoint
         RSGCore.Functions.Notify(Config.Language.Missionfailed, 'success', 6000) return --prints on screen then returns ending the function here
    end
    ClearGpsMultiRoute() --Removes the gps waypoint
    FreezeEntityPosition(Createdwagon, false) --unfreezes the wagon
    supplymissionend() --triggers the next function
end

function supplymissionend()
     RSGCore.Functions.Notify(Config.Language.ReturnSupplyWagon, 'success', 6000) --prints on screen
    
    --Blip and Waypoint Setup
    local blip1 = Citizen.InvokeNative(0x554D9D53F696D002, -1282792512, OilWagonTable.WagonSpawnCoords.x, OilWagonTable.WagonSpawnCoords.y, OilWagonTable.WagonSpawnCoords.z, 5) --creates blip using natives
    Citizen.InvokeNative(0x9CB1A1623062F402, blip1, Config.Language.ManagerBlip) --names blip
    StartGpsMultiRoute(6, true, true)
    AddPointToGpsMultiRoute(OilWagonTable.WagonSpawnCoords.x, OilWagonTable.WagonSpawnCoords.y, OilWagonTable.WagonSpawnCoords.z) --creates waypoint
    SetGpsMultiRouteRender(true)
    --Dist check setup wagon to return spot
    distcheck(OilWagonTable.WagonSpawnCoords.x, OilWagonTable.WagonSpawnCoords.y, OilWagonTable.WagonSpawnCoords.z, 5, Createdwagon)
    if Playerdead or WagonDestroyed then --if variable true then
        RemoveBlip(blip1) --remove blip
        ClearGpsMultiRoute() --Removes the gps waypoint
         RSGCore.Functions.Notify(Config.Language.Missionfailed, 'success', 6000) return --prints on screen then return too end function here
    end
    TaskLeaveAnyVehicle(PlayerPedId(), 0, 0) --makes the player get off the wagon
    FreezeEntityPosition(Createdwagon, true) --freezes the wagon
    RemoveBlip(blip1) --removes the blip
    ClearGpsMultiRoute() --Removes the gps waypoint
     RSGCore.Functions.Notify(Config.Language.CollectOilDeliveryPay, 'success', 6000) --prints on screen
    
    --Distance check player to manager setup
    distcheck(OilWagonTable.ManagerSpawn.x, OilWagonTable.ManagerSpawn.y, OilWagonTable.ManagerSpawn.z, 3, PlayerPedId())
    if Playerdead or WagonDestroyed then --if true then
         RSGCore.Functions.Notify(Config.Language.Missionfailed, 'success', 6000) return --print on screen then return too end function here
    end

    --Mission end setup
     RSGCore.Functions.Notify(Config.Language.ThankYouHeresYourPayOil, 'success', 6000) --prints on screen
    DeleteEntity(Createdwagon) --deletes wagon
    TriggerServerEvent('bcc-oil:WagonInSpawnHandler', false)
    TriggerServerEvent('bcc:oil:PayoutOilMission', Wagon) --triggers the server event to add the money to your character(event uses the level system to add money depending on level)
    Inmission = false --sets var false allowing player to start a new mission
end

-----------------Tables-------------------------------
SupplyMission = {}

--THis is the table that will be used for setting the pickup / filling wagon part of the mission the script will randomly choose one of the locations set
SupplyMission.SupplyMisisonPickupLocation = {
    {
        location = {x = 505.56, y = 710.05, z = 116.39}, --pickup coords
    },
    {
        location = {x = 492.16, y = 706.42, z = 117.36},
    },
    {
        location = {x = 474.7, y = 696.03, z = 116.12},
    },
}