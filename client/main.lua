local medical={bleeding=0,pain=0,lastStand=false,dead=false,injuries={}};local shown=false;local downStart=0;local deathStart=0
local function notify(t,typ)exports.szcore_ui:Notify({description=t,type=typ or'info'})end
local function partForBone(b)return SzCoreMedicalConfig.boneParts[b]or'torso'end
local function setUI()
    if medical.lastStand or medical.dead then
        shown=true;SetNuiFocus(false,false);SendNUIMessage({action='state',show=true,data=medical,lastStandSeconds=SzCoreMedicalConfig.lastStandSeconds,earlyRespawn=SzCoreMedicalConfig.earlyRespawnSeconds,bleedOut=SzCoreMedicalConfig.bleedOutSeconds,now=os.time()})
    elseif shown then shown=false;SendNUIMessage({action='state',show=false})end
end
RegisterNetEvent('szcore_death:state',function(s)medical=s or medical;if medical.lastStand and downStart==0 then downStart=GetGameTimer()end;if medical.dead and deathStart==0 then deathStart=GetGameTimer()end;if not medical.lastStand then downStart=0 end;if not medical.dead then deathStart=0 end;setUI()end)
RegisterNetEvent('szcore_death:revive',function(health)
    local ped=PlayerPedId();local c=GetEntityCoords(ped);NetworkResurrectLocalPlayer(c.x,c.y,c.z,GetEntityHeading(ped),true,false);SetEntityHealth(ped,health or 175);ClearPedBloodDamage(ped);ClearPedTasksImmediately(ped);medical.dead=false;medical.lastStand=false;setUI()
end)
RegisterNetEvent('szcore_death:healHealth',function(amount)local p=PlayerPedId();if amount>=200 then SetEntityHealth(p,200)else SetEntityHealth(p,math.min(200,GetEntityHealth(p)+amount))end;ClearPedBloodDamage(p)end)
RegisterNetEvent('szcore_death:respawn',function(coords,fee)
    local p=PlayerPedId();DoScreenFadeOut(450);Wait(550);NetworkResurrectLocalPlayer(coords.x,coords.y,coords.z,coords.w or 0.0,true,false);SetEntityHealth(p,200);ClearPedBloodDamage(p);ClearPedTasksImmediately(p);medical.dead=false;medical.lastStand=false;SetTimeout(200,function()DoScreenFadeIn(650);if fee and fee>0 then notify(('Kórházi díj: $%d'):format(fee),'info')end end);setUI()
end)
RegisterNetEvent('szcore_death:emsAlert',function(d)notify(('Segélykérés: %s'):format(d.name),'error');local b=AddBlipForCoord(d.x,d.y,d.z);SetBlipSprite(b,153);SetBlipColour(b,1);SetBlipScale(b,1.1);BeginTextCommandSetBlipName('STRING');AddTextComponentString('Sérült játékos');EndTextCommandSetBlipName(b);SetTimeout(60000,function()RemoveBlip(b)end)end)
local function treatment(target,kind,label)
    local ok,duration=exports.szcore:AwaitCallback('szcore_death:beginTreatment',target,kind)
    if not ok then return notify(duration or 'A kezelés nem indítható.','error') end
    exports.szcore_ui:Progress({label=label or 'Ellátás...',duration=duration+150})
    local done,err=exports.szcore:AwaitCallback('szcore_death:emsTreat',target,kind)
    if not done then notify(err or 'A kezelés megszakadt.','error') end
end
RegisterNetEvent('szcore_death:useMedical',function(kind)treatment(GetPlayerServerId(PlayerId()),kind)end)
RegisterNetEvent('szcore_death:useFirstAid',function()
    local c=GetEntityCoords(PlayerPedId());local target,dist=nil,3.01
    for _,pid in ipairs(GetActivePlayers())do if pid~=PlayerId()then local d=#(c-GetEntityCoords(GetPlayerPed(pid)));if d<dist then target=GetPlayerServerId(pid);dist=d end end end
    if not target then return notify('Nincs sérült a közelben.','error')end
    treatment(target,'firstaid','Újraélesztés...')
end)
AddEventHandler('gameEventTriggered',function(name,args)
    if name~='CEventNetworkEntityDamage'then return end;local victim=args[1];if victim~=PlayerPedId()or medical.dead then return end
    local health=GetEntityHealth(victim);local _,bone=GetPedLastDamageBone(victim);local amount=math.max(5,math.min(60,math.max(0,200-health)));TriggerServerEvent('szcore_death:damage',partForBone(bone),amount,tostring(args[7]or 0))
    if health<=101 and not medical.lastStand then
        local c=GetEntityCoords(victim);NetworkResurrectLocalPlayer(c.x,c.y,c.z,GetEntityHeading(victim),true,false);SetEntityHealth(victim,110);TriggerServerEvent('szcore_death:downed')
    end
end)
CreateThread(function()
    while true do
        if medical.lastStand then
            local ped=PlayerPedId();DisableAllControlActions(0);EnableControlAction(0,1,true);EnableControlAction(0,2,true);EnableControlAction(0,249,true)
            RequestAnimDict('combat@damage@writhe');if HasAnimDictLoaded('combat@damage@writhe')and not IsEntityPlayingAnim(ped,'combat@damage@writhe','writhe_loop',3)then TaskPlayAnim(ped,'combat@damage@writhe','writhe_loop',8.0,-8.0,-1,1,0,false,false,false)end
            if downStart>0 and GetGameTimer()-downStart>=SzCoreMedicalConfig.lastStandSeconds*1000 then TriggerServerEvent('szcore_death:bleedout');Wait(1500)end;Wait(0)
        elseif medical.dead then DisableAllControlActions(0);EnableControlAction(0,1,true);EnableControlAction(0,2,true);Wait(0)
        else Wait(650)end
    end
end)
CreateThread(function()
    while true do
        if medical.bleeding and medical.bleeding>0 and not medical.dead then
            Wait(math.max(2500,9000-medical.bleeding*1200));local p=PlayerPedId();if not medical.lastStand then SetEntityHealth(p,math.max(105,GetEntityHealth(p)-medical.bleeding*2))end
        else Wait(3000)end
    end
end)
RegisterNUICallback('help',function(_,cb)TriggerServerEvent('szcore_death:requestHelp');notify('Segélykérés elküldve.','success');cb({ok=true})end)
RegisterNUICallback('respawn',function(_,cb)local ok,err=exports.szcore:AwaitCallback('szcore_death:respawn');if not ok then notify(err or'Még nem tudsz újraéledni.','error')end;cb({ok=ok})end)
local function nearestPlayer(max)
    local me=PlayerPedId();local c=GetEntityCoords(me);local target,dist=nil,(max or 3.5)+.01
    for _,pid in ipairs(GetActivePlayers()) do if pid~=PlayerId() then local d=#(c-GetEntityCoords(GetPlayerPed(pid)));if d<dist then dist=d;target=GetPlayerServerId(pid) end end end
    return target,dist
end
if SzCoreMedicalConfig.enableEmsCommands then
    RegisterCommand('status',function()local t=nearestPlayer(3.5);if not t then return notify('Nincs játékos a közelben.','error')end;local s,err=exports.szcore:AwaitCallback('szcore_death:emsStatus',t);if not s then return notify(err or'Nincs jogosultság.','error')end;local count=0;for _ in pairs(s.injuries or{})do count=count+1 end;notify(('Vérzés: %d/4 | Fájdalom: %d%% | Sérülések: %d'):format(s.bleeding or 0,math.floor(s.pain or 0),count),'info')end,false)
    RegisterCommand('emstreat',function()local t=nearestPlayer(3.5);if t then treatment(t,'heal','Sebellátás...')end end,false)
    RegisterCommand('revivep',function()local t=nearestPlayer(3.5);if t then treatment(t,'revive','Újraélesztés...')end end,false)
    RegisterCommand('911e',function()TriggerServerEvent('szcore_death:requestHelp')end,false)
end
exports('IsDead',function()return medical.dead end);exports('IsLastStand',function()return medical.lastStand end);exports('GetMedicalState',function()return medical end)
AddEventHandler('szcore:client:onPlayerUnloaded',function()medical={bleeding=0,pain=0,lastStand=false,dead=false,injuries={}};setUI()end)
