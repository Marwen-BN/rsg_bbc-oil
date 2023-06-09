local RSGCore = exports['rsg-core']:GetCoreObject()
------- Oil Wagon Robbery Setup -----
Robableoilwagon, Roboilwagondeadcheck = 0, false
local fillcoords, mathr1 = nil, 0
RegisterNetEvent('bcc-oil:RobOilWagon', function()
  --variables
  Inmission = true --sets the variable too true(which will when true no allow the nui menu to be used to trigger a new function)
  
  --Loading Wagon Model
  Robableoilwagon = 'oilwagon02x' --sets the variable to the string wagon hash
  modelload(Robableoilwagon) --triggers the function to load the model

  --Coord Randomization
  mathr1 = math.random(1, #Config.OilWagonrobberyLocations) --Gets a random set of coords from OilWagontable.FillPoints
  fillcoords = Config.OilWagonrobberyLocations[mathr1] --gets a random set of coords from OilWagonTable.FillPoints
  
  --Wagon Spawn
  Robableoilwagon = CreateVehicle(Robableoilwagon, fillcoords.wagonlocation.x, fillcoords.wagonlocation.y, fillcoords.wagonlocation.z, fillcoords.wagonlocation.h, true, true) --creates the oilwagon at the location and sets it too the variable so it can be used in a net event
  TriggerEvent('bcc-oil:roboilwagonhelper') --triggers the event that will check if you die during the misison
  Citizen.InvokeNative(0x23f74c2fda6e7c61, 953018525, Robableoilwagon) --sets the blip that tracks the ped
  FreezeEntityPosition(Robableoilwagon, true) --freezes the wagon in place
  RSGCore.Functions.Notify(Config.Language.RobOilWagonOpeningtext, 'success', 6000) --prints on screen

  --Waypoint Setup
  StartGpsMultiRoute(6, true, true)
  AddPointToGpsMultiRoute(fillcoords.wagonlocation.x, fillcoords.wagonlocation.y, fillcoords.wagonlocation.z) --Creates the gps waypoint
  SetGpsMultiRouteRender(true)
  --Distance Check Setup
  local cw = GetEntityCoords(Robableoilwagon)
  distcheck(cw.x, cw.y, cw.z, 30, PlayerPedId())
  if Roboilwagondeadcheck then --if variable true then (if your dead or wagon destroyed)
    RSGCore.Functions.Notify(Config.Language.Missionfailed, 'success', 6000) --prints on screen
    DeleteEntity(Robableoilwagon) --deletes the wagon
    ClearGpsMultiRoute() return --clears your gps and returns ending the function here
  end
  ClearGpsMultiRoute() --clears your gps
  RSGCore.Functions.Notify(Config.Language.RobOilWagonKillGaurds, 'success', 6000) --prints on screen

  --Spawning enemy Peds
  MutltiPedSpawnDeadCheck(fillcoords.pedlocation, 'wagonrob') --triggers the function to spawn multiple peds with a deadcheck
end)

function roboilwagonreturnwagon()
  --Init Setup
  FreezeEntityPosition(Robableoilwagon, false) --unfreezes the wagon
  RSGCore.Functions.Notify(Config.Language.RobOilWagonReturnWagon, 'success', 6000) --prints on screen
  
  --Blip and Waypoint Setup
  local blip1 = Citizen.InvokeNative(0x554D9D53F696D002, -1282792512, fillcoords.returnlocation.x, fillcoords.returnlocation.y, fillcoords.returnlocation.z, 5) --creates blip using natives
  Citizen.InvokeNative(0x9CB1A1623062F402, blip1, Config.Language.RobOilWagonReturnBlip) --names blip
  StartGpsMultiRoute(6, true, true)
  AddPointToGpsMultiRoute(fillcoords.returnlocation.x, fillcoords.returnlocation.y, fillcoords.returnlocation.z) --Creates the gps waypoint
  SetGpsMultiRouteRender(true)
  --Distance Check Setup for returning the wagon
  distcheck(fillcoords.returnlocation.x, fillcoords.returnlocation.y, fillcoords.returnlocation.z, 10, Robableoilwagon)
  if Roboilwagondeadcheck then --if varibale true then (if you die or wagon broke)
    ClearGpsMultiRoute() --clears your gps and returns ending the function here
    RemoveBlip(blip1) --removes blip
    RSGCore.Functions.Notify(Config.Language.Missionfailed, 'success', 6000) --prints on screen
    DeleteEntity(Robableoilwagon) return --deletes the wagon then returns ending the function here not allowing the code below to run
  end

  --End of mission setup
  Inmission = false --sets variable too false allowing you too do another misison
  FreezeEntityPosition(Robableoilwagon, true) --freezes the wagon
  RemoveBlip(blip1) --removes blip
  ClearGpsMultiRoute() --clears your gps and returns ending the function here
  TaskLeaveAnyVehicle(PlayerPedId(), 0, 0) --makes the player get off the wagon
  Wait(6000) --waits 4 seconds
  DeleteEntity(Robableoilwagon) --deletes the wagon
  RSGCore.Functions.Notify(Config.Language.RobOilWagonSuccess, 'success', 6000) --prints on screen
  TriggerServerEvent('bcc-oil:RobberyPayout') --triggers server event and passes variable (this is what pays you)
end

--Deadcheck event
AddEventHandler('bcc-oil:roboilwagonhelper', function() --makes the event have code to run
  Wait(400) --gives the script some breathign room
  while Inmission do
    Citizen.Wait(100)
    if IsEntityDead(PlayerPedId()) == 1 or GetEntityHealth(Robableoilwagon) == 0 or DoesEntityExist(Robableoilwagon) == false then
      Roboilwagondeadcheck = true --sets var to true
      Inmission = false --sets var too false allowing you to do another mission
      Wait(3000) --waits 3 seconds
      Roboilwagondeadcheck = false break --resets variable and breaks loop
    end
  end
end)
---------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------Rob Oil Company Variables Setup-------------------------------------------------------------------
Roboilcodeadcheck = false --this is the var used to check if player dies during mission
local fillcoords2, missionoverend3dtext = nil, false
RegisterNetEvent('bcc-oil:RobOilCo', function()
  --Begining Setup
  RSGCore.Functions.Notify(Config.Language.RobOilCoBlip, 'success', 6000) --Prints on screen
  Inmission = true --sets var true not allowing player to start another mission
  TriggerEvent('bcc-oil:roboilcohelper') --triggers the deadcheck event(has to be an event since they run async unlike functions)
  
  --Coord Randomization
  local mathr12 = math.random(1, #Config.RobOilCompany) --Gets a random set of coords from OilWagontable.FillPoints
  fillcoords2 = Config.RobOilCompany[mathr12] --gets a random set of coords from OilWagonTable.FillPoints
  
  --Blip and Waypoint Setup
  local blip1 = Citizen.InvokeNative(0x554D9D53F696D002, -1282792512, fillcoords2.lootlocation.x, fillcoords2.lootlocation.y, fillcoords2.lootlocation.z, 5) --creates blip using natives
  Citizen.InvokeNative(0x9CB1A1623062F402, blip1, Config.Language.RobOilCoBlip) --names blip
  StartGpsMultiRoute(6, true, true)
  AddPointToGpsMultiRoute(fillcoords2.lootlocation.x, fillcoords2.lootlocation.y, fillcoords2.lootlocation.z) --Creates the gps waypoint
  SetGpsMultiRouteRender(true)
  
  --Distance Check Setup for close to lockpick Location
  distcheck(fillcoords2.lootlocation.x, fillcoords2.lootlocation.y, fillcoords2.lootlocation.z, 5, PlayerPedId())
  if Roboilcodeadcheck then --if var is true then
    RemoveBlip(blip1) --removes blip
    ClearGpsMultiRoute() --clears your gps and returns ending the function here
    RSGCore.Functions.Notify(Config.Language.Missionfailed, 'success', 6000) return --prints on screen and returns ending the function here preventing code below from running
  end
  RemoveBlip(blip1) --removes the blip
  ClearGpsMultiRoute() --clears your gps and returns ending the function here
  local cfg = {
    focus = true, -- Should minigame take nui focus
    cursor = true, -- Should minigame have cursor  (required for lockpick)
    maxattempts = Config.LockPick.MaxAttemptsPerLock, -- How many fail attempts are allowed before game over
    threshold = Config.LockPick.difficulty, -- +- threshold to the stage degree (bigger number means easier)
    hintdelay = Config.LockPick.hintdelay, --milliseconds delay on when the circle will shake to show lockpick is in the right position.
    stages = {
      {
        deg = 25 -- 0-360 degrees
      },
      {
        deg = 0 -- 0-360 degrees
      },
      {
        deg = 300 -- 0-360 degrees
      }
    }
  }
  while true do
    Wait(5)
    local pl = GetEntityCoords(PlayerPedId())
    local dist = GetDistanceBetweenCoords(fillcoords2.lootlocation.x, fillcoords2.lootlocation.y, fillcoords2.lootlocation.z, pl.x, pl.y, pl.z, true)
    if dist < 3 then
      if IsControlJustReleased(0, 0x760A9C6F) then --if G is pressed then
        MiniGame.Start('lockpick', cfg, function(result)
          if result.unlocked then
            if not Config.RobOilCoEnemyPeds then
              missionoverend3dtext = true --sets var true which is used to disable the 3d text from showing
              Inmission = false --resets the var allowing player to start a new misison
              RSGCore.Functions.Notify(Config.Language.RobberySuccess, 'success', 6000) --prints on screen
              TriggerServerEvent('bcc-oil:OilCoRobberyPayout', fillcoords2) --triggers server event and passes the variable too it breaks loop
            else --if the option is anything else
              MutltiPedSpawnDeadCheck(Config.RobOilCoEnemyPedsLocations, 'oilcorob')
              Inmission = false --trigger function to spawn enemy peds and break loop when done
            end
          else --else if you did not do it right
            if not Config.RobOilCoEnemyPeds then
              missionoverend3dtext = true --sets var true which is used to disable the 3d text from showing
              Inmission = false --resets the var allowing player to start a new misison
              RSGCore.Functions.Notify(Config.Language.Missionfailed, 'success', 6000) --prints on screen and breaks loop
            else --if it is true then
              MutltiPedSpawnDeadCheck(Config.RobOilCoEnemyPedsLocations, 'oilcorob') 
              Inmission = false --spawn all the enemy peds, and when its done break the loop
            end
          end
        end) break
      end
    elseif dist > 200 then
      Wait(2000)
    end
  end
end)

AddEventHandler('bcc-oil:roboilcohelper', function() --this makes the event have code to run
  while Inmission do
    Wait(5)
    local pl = GetEntityCoords(PlayerPedId()) --gets players coords
    local dist = GetDistanceBetweenCoords(pl.x, pl.y, pl.z, fillcoords2.lootlocation.x, fillcoords2.lootlocation.y, fillcoords2.lootlocation.z, true)
    if dist < 15 then
      if not missionoverend3dtext then --if var is false then
        BccUtils.Misc.DrawText3D(fillcoords2.lootlocation.x, fillcoords2.lootlocation.y, fillcoords2.lootlocation.z, Config.Language.PressGToLockPick) --draws text on coords
      else --else its not false then
        missionoverend3dtext = false break --resets var and breaks loop
      end
    elseif dist > 200 then
      Wait(2000)
    end
    if IsEntityDead(PlayerPedId()) then
      Inmission = false --resets the var allowing player to start a new misison
      Roboilcodeadcheck = true --set var true
      Wait(10000) --waits 10 seconds
      Roboilcodeadcheck = false --resets var so this can run again
    end
  end
end)