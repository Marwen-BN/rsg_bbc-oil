--------------------------------------- Pulling Essentials -------------------------------------------
local RSGCore = exports['rsg-core']:GetCoreObject()


----- Oil Delivery Setup -----
function beginningstage()
  Wait(1000)
   RSGCore.Functions.Notify(Config.Language.FillYourOilWagon, 'success', 6000) --prints on your screen
  local pl = PlayerPedId()
  local mathr1 = math.random(1, #OilWagonTable.FillPoints) --Gets a random set of coords from OilWagontable.FillPoints
  local fillcoords = OilWagonTable.FillPoints[mathr1] --gets a random set of coords from OilWagonTable.FillPoints
  
  --Blip and Waypoint setup
  local blip1 = Citizen.InvokeNative(0x554D9D53F696D002, -1282792512, fillcoords.fillpoint.x, fillcoords.fillpoint.y, fillcoords.fillpoint.z, 5) --creates blip using natives
  Citizen.InvokeNative(0x9CB1A1623062F402, blip1, Config.Language.FillBlipName) --names blip
   StartGpsMultiRoute(6, true, true)
   AddPointToGpsMultiRoute(fillcoords.fillpoint.x, fillcoords.fillpoint.y, fillcoords.fillpoint.z) --Creates the gps waypoint
   SetGpsMultiRouteRender(true)
  -------------Dist Check for fill Setup-----------------
  distcheck(fillcoords.fillpoint.x, fillcoords.fillpoint.y, fillcoords.fillpoint.z, 3, Createdwagon) --triggers the dist check function and passes this data too it
  if Playerdead or WagonDestroyed then --if variable is true(you are dead or wagon destroyed) then
    RemoveBlip(blip1) --removes the blip
    ClearGpsMultiRoute() --Removes the gps waypoint
     RSGCore.Functions.Notify(Config.Language.Missionfailed, 'success', 6000) return --prints on screen then return(return ends the function preventing code below from running essentially creatin a dead check)
  end
  FreezeEntityPosition(Createdwagon, true) --freezes the wagon
  RemoveBlip(blip1) --removes blip
  ClearGpsMultiRoute() --Removes the gps waypoint

  -------Progress bar / Fill Wagon Setup----------
  TaskLeaveAnyVehicle(pl, 0, 0)
   RSGCore.Functions.Notify(Config.Language.FillingOilwagon, 'success', 6000) --prints on screen
  Wait(3000) --waits 3 second for leaving wagon anim to finish
  SetEntityHeading(pl, GetEntityHeading(Createdwagon))
  Wait(500) --waits 800 ms gives the script time to run it all
  TaskStartScenarioInPlace(pl, joaat('WORLD_CAMP_JACK_ES_BUCKET_POUR'), Config.OilWagonFillTime, true, false, false, false)

  ----------------------------------------------
  Wait(Config.OilWagonFillTime) --waits until the anim / progressbar above is over
  if Progressbardeadcheck then
    Progressbardeadcheck = false --resest the variable so you can do a new mission
    ClearPedTasksImmediately(pl)
     RSGCore.Functions.Notify(Config.Language.Missionfailed, 'success', 6000) --printson screen
    DeleteEntity(Createdwagon) return --deletes wagon and return (deletewagon causes mission to fail in deadcheck, return ends the function here and does not allow it too continue(failing the mission))
  end
  ClearPedTasksImmediately(pl)
  TaskEnterVehicle(pl, Createdwagon, 4000, -1, 0)
  deliveroil() --triggers function for next part of mission
end

-----------------------Deliver oil Mission&return wagon included here------------------------------
function deliveroil()
  FreezeEntityPosition(Createdwagon, false)
  Wait(200)
   RSGCore.Functions.Notify(Config.Language.GoDeliver, 'success', 6000)

  --Coord Randomization
  local mathr1 = math.random(1, #Config.OilDeliveryPoints) --Gets a random set of coords from config
  local fillcoords = Config.OilDeliveryPoints[mathr1] --gets a random set of coords from config
  
  --Blip and Waypoint Setup
  local blip2 = Citizen.InvokeNative(0x554D9D53F696D002, -1282792512, fillcoords.DeliveryPoint.x, fillcoords.DeliveryPoint.y, fillcoords.DeliveryPoint.z, 5) --creates a blip using natives
  Citizen.InvokeNative(0x9CB1A1623062F402, blip2, Config.Language.DeliverBlipName) --names the blip
  StartGpsMultiRoute(6, true, true)
  AddPointToGpsMultiRoute(fillcoords.DeliveryPoint.x, fillcoords.DeliveryPoint.y, fillcoords.DeliveryPoint.z) --Creates the gps waypoint
  SetGpsMultiRouteRender(true)
  --Spawning Ped Setup
  local model = joaat('rcsp_dutch3_males_01')
  modelload(model) --triggers the function to load the model
  local createdped = CreatePed(model, fillcoords.NpcSpawn.x, fillcoords.NpcSpawn.y, fillcoords.NpcSpawn.z - 1, fillcoords.NpcSpawn.h, true, true, true, true) --spawns the ped as networked so everyone can see him
  Citizen.InvokeNative(0x283978A15512B2FE, createdped, true) -- sets ped into random outfit, stops it being invis
  SetEntityInvincible(createdped, true) --sets ped invincible to prevent bugs
  FreezeEntityPosition(createdped, true) --freezes the ped in place (will only unfreeze once wagon is detected as close by the loop below, this is done to create more immersion instead of the ped just spawning when you get there)
  
  --Distance Check Setup wagon to delivery point
  distcheck(fillcoords.DeliveryPoint.x, fillcoords.DeliveryPoint.y, fillcoords.DeliveryPoint.z, 3, Createdwagon)
  if Playerdead or WagonDestroyed then --if either var is true then
    DeletePed(createdped) --deletes ped
    RemoveBlip(blip2) --removes blip
    ClearGpsMultiRoute() --clears gps
     RSGCore.Functions.Notify(Config.Language.Missionfailed, 'success', 6000) return --prints on screen then returns(return breaks loop here ending the mission/function)
  end
  FreezeEntityPosition(createdped, false) --unfreezes the ped so he can then move properly in the code below
  FreezeEntityPosition(Createdwagon, true) --freezes the wagon in place
  RemoveBlip(blip2) --removes the blip
  ClearGpsMultiRoute() --Removes the gps waypoint

  --Distance Check Setup Ped To Wagon
  TaskGoToEntity(createdped, Createdwagon, -1, 1.0, 5.0, 1073741824, 1) --(pulled from legacy_medic) makes the ped walk until it is within a distance of 2
  local cw = GetEntityCoords(Createdwagon) --gets the wagons coords
  distcheck(cw.x, cw.y, cw.z, 5, createdped)

  --Filling Up Setup
  TaskStartScenarioInPlace(createdped, joaat('WORLD_PLAYER_CHORES_BUCKET_PUT_DOWN_FULL'), Config.OilWagonFillTime, true, false, false, false)
 -- progressbar.start(Config.Language.UnloadingOil, Config.OilWagonFillTime, function() --creates a progress bar that shows
 -- end, 'circle') --part of progressbar
  Citizen.Wait(Config.OilWagonFillTime) --makes it wait the time to fill the wagon(so the progress bar can finish before the code continue)
  if Progressbardeadcheck then --if you or wagon die then (this will run once after the progress bar so if you die during progress bar it will still continue until this runs)
     RSGCore.Functions.Notify(Config.Language.Missionfailed, 'success', 6000) --prints on screen
    Progressbardeadcheck = false --resets variable so you can do a new mission
    ClearPedTasksImmediately(createdped) --clears the peds tasks
    DeletePed(createdped) --deletes the ped
    DeleteEntity(Createdwagon) return --deletes wagon in the dead check function(return will end the function here preventing the code below from running(creating a mission fail))
  end
  ClearPedTasksImmediately(createdped) --clears anim from ped
  FreezeEntityPosition(Createdwagon, false) --Unfreezes The Wagon
   RSGCore.Functions.Notify(Config.Language.OilDelivered, 'success', 6000) --prints on screen
   RSGCore.Functions.Notify(Config.Language.ReturnOilWagon, 'success', 6000)
  
  --------------------This will handle the despawning of the ped, and the return wagon mission---------------------------
  --Waypoint and Blip Setup
  local oilbl = Citizen.InvokeNative(0x554D9D53F696D002, -1282792512, OilWagonTable.WagonSpawnCoords.x, OilWagonTable.WagonSpawnCoords.y, OilWagonTable.WagonSpawnCoords.z, 5) --creates a blip using natives
  Citizen.InvokeNative(0x9CB1A1623062F402, blip2, Config.Language.ReturnBlip) --names the blip
 StartGpsMultiRoute(6, true, true)
 AddPointToGpsMultiRoute(OilWagonTable.WagonSpawnCoords.x, OilWagonTable.WagonSpawnCoords.y, OilWagonTable.WagonSpawnCoords.z) --Creates the gps waypoint
 SetGpsMultiRouteRender(true)
  --Distance Check setup for deleting ped
  local pedcoord = GetEntityCoords(createdped)
  distcheck(pedcoord.x, pedcoord.y, pedcoord.z, 70, Createdwagon)
  if Playerdead or WagonDestroyed then --if true then
    RemoveBlip(oilbl) --deletes blip
    ClearGpsMultiRoute() --Removes the gps waypoint
     RSGCore.Functions.Notify(Config.Language.Missionfailed, 'success', 6000) return --prints on screen return ends function here acting as misison fail
  end


  --Dist Check for returning wagon
  distcheck(OilWagonTable.WagonSpawnCoords.x, OilWagonTable.WagonSpawnCoords.y, OilWagonTable.WagonSpawnCoords.z, 5, Createdwagon)
  if Playerdead or WagonDestroyed then
    RemoveBlip(oilbl)
    ClearGpsMultiRoute() --Removes the gps waypoint
     RSGCore.Functions.Notify(Config.Language.Missionfailed, 'success', 6000) return
  end
  TaskLeaveAnyVehicle(PlayerPedId(), 0, 0) --makes the player get off the wagon
  FreezeEntityPosition(Createdwagon, true) --freezes it in place so you can not move it(breaks loop so the code below the loop can run)
  RemoveBlip(oilbl) --removes the blip
  ClearGpsMultiRoute() --clears the gps waypoint and breaks loop so code below can run
   RSGCore.Functions.Notify(Config.Language.CollectOilDeliveryPay, 'success', 6000) --will print on screen
  
  --Distance Check for Player To Manager Ped
  distcheck(OilWagonTable.ManagerSpawn.x, OilWagonTable.ManagerSpawn.y, OilWagonTable.ManagerSpawn.z, 3, PlayerPedId())
  if Playerdead or WagonDestroyed then --if variable true then
    DeleteEntity(Createdwagon)
     RSGCore.Functions.Notify(Config.Language.Missionfailed, 'success', 6000) return --prints on screen, then returns ending function here and failing misison
  end
  DeleteEntity(Createdwagon) --deletes the wagon
   RSGCore.Functions.Notify(Config.Language.ThankYouHeresYourPayOil, 'success', 6000) --prints on screen
  TriggerServerEvent('bcc:oil:PayoutOilMission', Wagon) --triggers the server event to add the money to your character(event uses the level system to add money depending on level)
  TriggerServerEvent('bcc-oil:WagonInSpawnHandler', false)
  Inmission = false --sets var false allowing player to start a new mission
end

---------- Sniffing Oil Setup ---------------
Citizen.CreateThread(function()
  if Config.SniffOil.enable then
    while true do
      Wait(5)
      local pl = PlayerPedId()
      local plc = GetEntityCoords(pl)
      local dist = GetDistanceBetweenCoords(plc.x, plc.y, plc.z, Config.SniffOil.Coords.x, Config.SniffOil.Coords.y, Config.SniffOil.Coords.z, true)
      if dist < 3 then
        BccUtils.Misc.DrawText3D(Config.SniffOil.Coords.x, Config.SniffOil.Coords.y, Config.SniffOil.Coords.z, Config.Language.SniffOil)
        if IsControlJustReleased(0, 0x760A9C6F) then
          AnimpostfxPlay('MP_BountyLagrasSwamp')
          Wait(Config.SniffOil.EffectTime)
          AnimpostfxStopAll()
        end
      elseif dist > 200 then
        Wait(2000)
      end
    end
  end
end)

----------------------------Oil Mission Tables----------------------
OilWagonTable = {} --creates the table
OilWagonTable.ManagerSpawn = {x = 498.05, y = 672.98, z = 121.04, h = 73.92} --This is where the manager npc will spawn(Do not change!!)
OilWagonTable.WagonSpawnCoords = {x = 509.52, y = 694.24, z = 115.8, h = 263.92} --this is the x y z and heaing where the wagons will spawn

--This is the table that the initial wagon fill spot will be
OilWagonTable.FillPoints = {
  {
    fillpoint = {x = 589.99, y = 635.94, z = 112.96},
    objectspawn = {x = 595.82, y = 628.48, z = 110.81},
  },
  {
    fillpoint = {x = 480.53, y = 701.24, z = 116.32},
    objectspawn = {x = 478.51, y = 693.82, z = 116.16},
  },
  {
    fillpoint = {x = 546.13, y = 578.9, z = 111.07},
    objectspawn = {x = 553.94, y = 579.91, z = 111.15},
  },
}