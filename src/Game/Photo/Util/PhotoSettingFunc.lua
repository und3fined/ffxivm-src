local PhotoDefine = require("Game/Photo/PhotoDefine")
local CtrlDef = PhotoDefine.RoleCtrlSetting.Ctrl
local UnCtrlDef = PhotoDefine.RoleCtrlSetting.UnCtrl

local PhotoActorUtil = require("Game/Photo/Util/PhotoActorUtil")

local function SetActorVisible(Actor, IsOpen)
    _G.PhotoMgr:SetActorVisible(Actor, IsOpen)
end

local function SetActorVisibleGroup(Actors, IsOpen)
    for _, Actor in pairs(Actors) do
        SetActorVisible(Actor, IsOpen)
    end
end

local CtrlFunc = {
    --
}

CtrlFunc[CtrlDef.Self] = function(IsOpen)
    _G.FLOG_INFO("[Photo][PhotoSettingFunc] CtrlFunc-Self IsOpen = " .. tostring(IsOpen))
    local Actor = PhotoActorUtil.GetMajor()
    SetActorVisible(Actor, IsOpen)
end

CtrlFunc[CtrlDef.MyPet] = function(IsOpen)
    _G.FLOG_INFO("[Photo][PhotoSettingFunc] CtrlFunc-MyPet IsOpen = " .. tostring(IsOpen))
    local Actor = PhotoActorUtil.GetMajorPet()
    SetActorVisible(Actor, IsOpen)
end

CtrlFunc[CtrlDef.Mate] = function(IsOpen)
    _G.FLOG_INFO("[Photo][PhotoSettingFunc] CtrlFunc-Mate IsOpen = " .. tostring(IsOpen))
    local Actors = PhotoActorUtil.GetMates()
    SetActorVisibleGroup(Actors, IsOpen)
end

CtrlFunc[CtrlDef.Chocobo] = function(IsOpen)
    _G.FLOG_INFO("[Photo][PhotoSettingFunc] CtrlFunc-Chocobo IsOpen = " .. tostring(IsOpen))
    local Actors = PhotoActorUtil.GetMajorChocobo()
    SetActorVisibleGroup(Actors, IsOpen)
end

CtrlFunc[CtrlDef.Summon] = function(IsOpen)
    _G.FLOG_INFO("[Photo][PhotoSettingFunc] CtrlFunc-Summon IsOpen = " .. tostring(IsOpen))
    local Actors = PhotoActorUtil.GetMajorSummons()
    SetActorVisibleGroup(Actors, IsOpen)
end

CtrlFunc[CtrlDef.MatePet] = function(IsOpen)
    _G.FLOG_INFO("[Photo][PhotoSettingFunc] CtrlFunc-MatePet IsOpen = " .. tostring(IsOpen))
    local Actors = PhotoActorUtil.GetMatePets()
    SetActorVisibleGroup(Actors, IsOpen)
end

CtrlFunc[CtrlDef.Entourate] = function(IsOpen)
    _G.FLOG_INFO("[Photo][PhotoSettingFunc] CtrlFunc-Entourate IsOpen = " .. tostring(IsOpen))
    local Actors = PhotoActorUtil.GetEntourates()
    SetActorVisibleGroup(Actors, IsOpen)
end

--------------------------------------------------------------------------------

local UnCtrlFunc = {
   --
}

UnCtrlFunc[UnCtrlDef.Other] = function(IsOpen)
    _G.FLOG_INFO("[Photo][PhotoSettingFunc] UnCtrlFunc-Other IsOpen = " .. tostring(IsOpen))
    local Actors = PhotoActorUtil.GetPlayerOthers()
    SetActorVisibleGroup(Actors, IsOpen)
end

UnCtrlFunc[UnCtrlDef.OtherChocobo] = function(IsOpen)
    _G.FLOG_INFO("[Photo][PhotoSettingFunc] UnCtrlFunc-OtherChocobo IsOpen = " .. tostring(IsOpen))
    local Actors = PhotoActorUtil.GetPlayerOtherChocobos()
    SetActorVisibleGroup(Actors, IsOpen)
end

UnCtrlFunc[UnCtrlDef.OtherSummon] = function(IsOpen)
    _G.FLOG_INFO("[Photo][PhotoSettingFunc] UnCtrlFunc-OtherSummon IsOpen = " .. tostring(IsOpen))
    local Actors = PhotoActorUtil.GetPlayerOtherSummons()
    SetActorVisibleGroup(Actors, IsOpen)
end

UnCtrlFunc[UnCtrlDef.OtherPet] = function(IsOpen)
    _G.FLOG_INFO("[Photo][PhotoSettingFunc] UnCtrlFunc-OtherPet IsOpen = " .. tostring(IsOpen))
    local Actors = PhotoActorUtil.GetPlayerOtherPets()
    SetActorVisibleGroup(Actors, IsOpen)
end

UnCtrlFunc[UnCtrlDef.NPC] = function(IsOpen)
    _G.FLOG_INFO("[Photo][PhotoSettingFunc] UnCtrlFunc-NPC IsOpen = " .. tostring(IsOpen))
    local Actors = PhotoActorUtil.GetNPCs()
    SetActorVisibleGroup(Actors, IsOpen)
end

UnCtrlFunc[UnCtrlDef.Enemy] = function(IsOpen)
    _G.FLOG_INFO("[Photo][PhotoSettingFunc] UnCtrlFunc-Enemy IsOpen = " .. tostring(IsOpen))
    local Actors = PhotoActorUtil.GetMonsters()
    SetActorVisibleGroup(Actors, IsOpen)
end

local Func = {}

function Func.CallCtrlFunc(Ty, ...)
    if CtrlFunc[Ty] then
        return CtrlFunc[Ty](...)
    end
    _G.FLOG_ERROR('[Photo][PhotoSettingFunc].CallCtrlFunc.Ty not match function Ty = ' .. tostring(Ty))
end

function Func.CallUnCtrlFunc(Ty, ...)
    if UnCtrlFunc[Ty] then
        return UnCtrlFunc[Ty](...)
    end
    _G.FLOG_ERROR('[Photo][PhotoSettingFunc].CallUnCtrlFunc.Ty not match function Ty = ' .. tostring(Ty))
end

function Func.CallCameraFunc(Ty, IsOpen)
    _G.FLOG_INFO("[Photo][PhotoSettingFunc] UnCtrlFunc-Enemy IsOpen = " .. tostring(IsOpen))

    if IsOpen then
        _G.PhotoMgr:StartNPCLookAt()
    else
        _G.PhotoMgr:EndNPCLookAt()
    end
    -- _G.FLOG_ERROR('[Photo][PhotoSettingFunc].CallUnCtrlFunc.Ty not match function Ty = ' .. tostring(Ty))
end

function Func.CallRoleSettingFunc(Ty, SubTy, IsOpen)
    if Ty == PhotoDefine.RoleSettingType.Ctrl then
        Func.CallCtrlFunc(SubTy, IsOpen)
    elseif Ty == PhotoDefine.RoleSettingType.UnCtrl then
        Func.CallUnCtrlFunc(SubTy, IsOpen)
    elseif Ty == PhotoDefine.RoleSettingType.Camera then
        Func.CallCameraFunc(SubTy, IsOpen)
    end
end


return Func