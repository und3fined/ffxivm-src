local PhotoDefine = require("Game/Photo/PhotoDefine")
local TabMainDef = PhotoDefine.UITabMain
local SubMainDef = PhotoDefine.UITabSub

local Util = {}

local function GiveAllRoleAct(IsGiveAll)
    _G.PhotoMgr:UpdatePlayAniRoleList()
end

local function GiveAllRoleStat(IsGiveAll)
    _G.PhotoMgr:SwitchRole4EffGroup(not IsGiveAll)
end

function Util.CallGiveAllFunc(MainTy, SubTy, IsGiveAll, ...)

    if MainTy == TabMainDef.Role then
        if SubTy == SubMainDef[TabMainDef.Role].Act or SubTy == SubMainDef[TabMainDef.Role].Emo then
            GiveAllRoleAct(IsGiveAll, ...)
            return
        elseif SubTy == SubMainDef[TabMainDef.Role].Stat then
            GiveAllRoleStat(IsGiveAll, ...)
           return 
        end
    end
    
    _G.FLOG_ERROR(string.format("Andre.PhotoGiveAllFunc.CallGiveAllFunc Err MainTy : %s, SubTy : %s",
                tostring(MainTy), 
                tostring(SubTy)))
end

function Util.CallGiveAllFuncAuto(...)
    local PhotoVM = _G.PhotoVM
    local MainTy = PhotoVM.MainTabIdx
	local SubTy = PhotoVM.SubTabIdx
    local IsGiveAll = PhotoVM.IsGiveAll
    Util.CallGiveAllFunc(MainTy, SubTy, IsGiveAll, ...)
end
return Util