local state={};local helpRate={};local damageRate={}
local function default()return{bleeding=0,pain=0,lastStand=false,dead=false,injuries={},downedAt=nil,deathAt=nil}end
local function p(src)return exports.szcore:GetPlayer(src)end
local function load(src)
    if state[src]then return state[src]end;local q=p(src);if not q then return nil end;local m=q.getMetadata('medical');state[src]=type(m)=='table'and m or default();state[src].injuries=state[src].injuries or{};return state[src]
end
local function sync(src)
    local s=load(src);local q=p(src);if not s or not q then return end;q.setMetadata('medical',s);q.setMetadata('dead',s.dead==true);Player(src).state:set('szcoreLastStand',s.lastStand==true,true);TriggerClientEvent('szcore_death:state',src,s)
end
local function partDamage(src,part,amount,weapon)
    local s=load(src);if not s then return end;amount=math.max(0,math.min(100,tonumber(amount)or 0));part=tostring(part or'torso');local valid={head=true,torso=true};for _,name in pairs(SzCoreMedicalConfig.boneParts or {})do valid[name]=true end;if not valid[part] then part='torso' end
    local i=s.injuries[part]or{severity=0,hits=0,weapon=nil};i.severity=math.min(100,(i.severity or 0)+math.max(2,amount*.35));i.hits=(i.hits or 0)+1;i.weapon=weapon;s.injuries[part]=i
    if amount>=20 then s.bleeding=math.min(4,(s.bleeding or 0)+1)end;s.pain=math.min(100,(s.pain or 0)+amount*.4);sync(src)
end
local function down(src)
    local s=load(src);if not s or s.dead or s.lastStand then return false end;s.lastStand=true;s.downedAt=os.time();sync(src);exports.szcore:Audit('medical.laststand',src,nil,{});return true
end
local function kill(src)
    local s=load(src);if not s then return false end;s.lastStand=false;s.dead=true;s.deathAt=os.time();sync(src);exports.szcore:Audit('medical.death',src,nil,{});return true
end
local function revive(src,health)
    local s=load(src);if not s then return false end;s.lastStand=false;s.dead=false;s.bleeding=0;s.pain=0;s.downedAt=nil;s.deathAt=nil;s.injuries={};sync(src);TriggerClientEvent('szcore_death:revive',src,health or 175);return true
end
local function heal(src,kind,part)
    local s=load(src);if not s then return false end
    if kind=='bandage'then s.bleeding=math.max(0,(s.bleeding or 0)-1);s.pain=math.max(0,(s.pain or 0)-10);if part and s.injuries[part]then s.injuries[part].severity=math.max(0,(s.injuries[part].severity or 0)-25)end
    elseif kind=='medkit'then s.bleeding=math.max(0,(s.bleeding or 0)-2);s.pain=math.max(0,(s.pain or 0)-35);for _,i in pairs(s.injuries)do i.severity=math.max(0,(i.severity or 0)-35)end;TriggerClientEvent('szcore_death:healHealth',src,45)
    elseif kind=='full'then s.bleeding=0;s.pain=0;s.injuries={};TriggerClientEvent('szcore_death:healHealth',src,200)end;sync(src);return true
end
local function nearestHospital(src)
    local ped=GetPlayerPed(src);local c=ped~=0 and GetEntityCoords(ped)or vector3(0,0,0);local best=SzCoreMedicalConfig.hospitals[1];local d=1e20
    for _,h in ipairs(SzCoreMedicalConfig.hospitals)do local x,y,z=c.x-h.coords.x,c.y-h.coords.y,c.z-h.coords.z;local q=x*x+y*y+z*z;if q<d then d=q;best=h end end;return best
end
local function respawnPenalty(src,q)
    if GetResourceState('szcore_inventory')=='started' and (SzCoreMedicalConfig.clearWeaponsOnRespawn or SzCoreMedicalConfig.clearInventoryOnRespawn) then
        local inv=exports.szcore_inventory:GetPlayerInventory(src)
        if inv then
            for slot,e in pairs(inv.items or {}) do
                local def=SzCoreItems[e.name]
                if SzCoreMedicalConfig.clearInventoryOnRespawn or (SzCoreMedicalConfig.clearWeaponsOnRespawn and def and def.weapon) then exports.szcore_inventory:RemoveItemBySlot('player:'..q.PlayerData.citizenid,slot,e.amount) end
            end
            exports.szcore_inventory:FlushInventory('player:'..q.PlayerData.citizenid);TriggerClientEvent('szcore_inventory:refresh',src)
        end
    end
    if SzCoreMedicalConfig.clearCashOnRespawn then q.setMoney('cash',0,'hospital_respawn') end
end
local function respawn(src)
    local q=p(src);local s=load(src);if not q or not s or not s.dead then return false,'not_dead'end
    if s.deathAt and os.time()-s.deathAt < SzCoreMedicalConfig.earlyRespawnSeconds then return false,'too_early' end
    local fee=SzCoreMedicalConfig.respawnFee;if fee>0 then q.removeMoney('bank',fee,'hospital_respawn')end
    respawnPenalty(src,q)
    s.dead=false;s.lastStand=false;s.bleeding=0;s.pain=0;s.injuries={};s.deathAt=nil;s.downedAt=nil;sync(src)
    local h=nearestHospital(src);TriggerClientEvent('szcore_death:respawn',src,{x=h.coords.x,y=h.coords.y,z=h.coords.z,w=h.coords.w},fee);return true
end
RegisterNetEvent('szcore_death:damage',function(part,amount,weapon)
    local src=source;local n=GetGameTimer();if damageRate[src]and n-damageRate[src]<120 then return end;damageRate[src]=n;partDamage(src,part,amount,weapon)
end)
RegisterNetEvent('szcore_death:downed',function()local ped=GetPlayerPed(source);if ped~=0 and GetEntityHealth(ped)<=125 then down(source)end end)
RegisterNetEvent('szcore_death:bleedout',function()local s=load(source);if s and s.lastStand and s.downedAt and os.time()-s.downedAt>=SzCoreMedicalConfig.lastStandSeconds-2 then kill(source)end end)
RegisterNetEvent('szcore_death:requestHelp',function()
    local src=source;local now=os.time();if helpRate[src]and now-helpRate[src]<SzCoreMedicalConfig.helpCooldownSeconds then return end;helpRate[src]=now
    local ped=GetPlayerPed(src);local c=GetEntityCoords(ped);local q=p(src);for _,sid in ipairs(exports.szcore:GetPlayerSourcesByJob('ambulance',true))do TriggerClientEvent('szcore_death:emsAlert',sid,{source=src,name=q and q.PlayerData.name or('ID '..src),x=c.x,y=c.y,z=c.z})end
end)
exports.szcore:CreateCallback('szcore_death:respawn',function(source)return respawn(source)end)
exports.szcore:CreateCallback('szcore_death:get',function(source)return load(source)end)
local function emsAllowed(src,target)
    local q=p(src);target=tonumber(target);if not q or not target or q.PlayerData.job.name~='ambulance' or not q.PlayerData.job.onduty then return nil,'no_permission' end
    if not exports.szcore:ValidateDistance(src,target,3.5) then return nil,'too_far' end
    return q
end
exports.szcore:CreateCallback('szcore_death:emsStatus',function(source,target)local q,err=emsAllowed(source,target);if not q then return nil,err end;return load(tonumber(target))end)
local treatments={}
local treatmentDefs={bandage={item='bandage',ms=3500},medkit={item='medkit',ms=5500},firstaid={item='firstaid',ms=8000},heal={item='bandage',ms=4500},revive={item='firstaid',ms=8000}}
local function beginTreatment(src,target,kind)
    local def=treatmentDefs[kind];target=tonumber(target) or src
    local q,t=p(src),p(target);if not def or not q or not t then return false,'invalid_treatment' end
    local own=load(src);if own and (own.dead or own.lastStand) then return false,'incapacitated' end
    if target~=src and not emsAllowed(src,target) then return false,'no_permission' end
    if (kind=='firstaid' or kind=='revive') then local m=load(target);if target==src or not m or not(m.dead or m.lastStand)then return false,'not_downed'end end
    local prior=treatments[src];if prior and GetGameTimer()<=prior.expires then return false,'treatment_busy' end
    if exports.szcore_inventory:GetItemCount('player:'..q.PlayerData.citizenid,def.item)<1 then return false,'missing_item' end
    treatments[src]={kind=kind,target=target,cid=q.PlayerData.citizenid,targetCid=t.PlayerData.citizenid,ready=GetGameTimer()+def.ms,expires=GetGameTimer()+def.ms+15000}
    return true,def.ms
end
local function finishTreatment(src,target,kind)
    local task=treatments[src];target=tonumber(target) or src
    if not task or task.kind~=kind or task.target~=target then return false,'no_treatment' end
    local now=GetGameTimer();if now<task.ready then return false,'too_early' end
    treatments[src]=nil
    local q,t=p(src),p(target);local own=load(src)
    if now>task.expires or not q or not t or q.PlayerData.citizenid~=task.cid or t.PlayerData.citizenid~=task.targetCid or (own and (own.dead or own.lastStand)) then return false,'expired' end
    if target~=src and not emsAllowed(src,target) then return false,'no_permission' end
    local def=treatmentDefs[kind]
    if not exports.szcore_inventory:RemoveItem('player:'..task.cid,def.item,1) then return false,'missing_item' end
    if kind=='firstaid' or kind=='revive' then return revive(target,150) end
    return heal(target,kind=='heal' and 'bandage' or kind)
end
exports.szcore:CreateCallback('szcore_death:beginTreatment',beginTreatment)
exports.szcore:CreateCallback('szcore_death:emsTreat',function(src,target,kind)return finishTreatment(src,target,kind)end)
exports('GetMedicalState',load);exports('GetInjuries',function(src)local s=load(src);return s and s.injuries or{}end);exports('Heal',heal);exports('Revive',revive);exports('Kill',kill);exports('Respawn',function(src,coords)if coords then local s=load(src);if s then s.dead=false;s.lastStand=false;s.bleeding=0;s.pain=0;s.injuries={};sync(src);TriggerClientEvent('szcore_death:respawn',src,coords,0);return true end end;return respawn(src)end)
CreateThread(function()
    while GetResourceState('szcore_inventory')~='started'do Wait(500)end
    exports.szcore_inventory:RegisterUsableItem('bandage',function(src)local q=p(src);if not q then return false end;local inv='player:'..q.PlayerData.citizenid;if exports.szcore_inventory:GetItemCount(inv,'bandage')>0 then TriggerClientEvent('szcore_death:useMedical',src,'bandage');return true end;return false end)
    exports.szcore_inventory:RegisterUsableItem('medkit',function(src)local q=p(src);if not q then return false end;local inv='player:'..q.PlayerData.citizenid;if exports.szcore_inventory:GetItemCount(inv,'medkit')>0 then TriggerClientEvent('szcore_death:useMedical',src,'medkit');return true end;return false end)
    if SzCoreItems.firstaid then exports.szcore_inventory:RegisterUsableItem('firstaid',function(src)TriggerClientEvent('szcore_death:useFirstAid',src);return true end)end
    if SzCoreItems.painkillers then exports.szcore_inventory:RegisterUsableItem('painkillers',function(src)local q=p(src);if not q then return false end;local inv='player:'..q.PlayerData.citizenid;if not exports.szcore_inventory:RemoveItem(inv,'painkillers',1)then return false end;local s=load(src);if s then s.pain=math.max(0,(s.pain or 0)-30);sync(src)end;TriggerClientEvent('szcore_ui:notify',src,{type='success',description='A fájdalom enyhült.'});return true end)end
end)
RegisterNetEvent('szcore_death:finishMedical',function(kind,target)finishTreatment(source,target,kind)end)
AddEventHandler('szcore:server:playerLoaded',function(src)local s=load(src);if s then sync(src)end end)
AddEventHandler('playerDropped',function()treatments[source]=nil;state[source]=nil;helpRate[source]=nil;damageRate[source]=nil end)
AddEventHandler('szcore:server:playerUnloaded',function(src)state[src]=nil;treatments[src]=nil;helpRate[src]=nil;damageRate[src]=nil end)
