
local LuaClass = require("Core/LuaClass")
local ActorUtil = require("Utils/ActorUtil")
local FunctionBase = require("Game/Interactive/FunctionItem/FunctionBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")

local FunctionNpcOld = LuaClass(FunctionBase)


function FunctionNpcOld:Ctor()
    self.FuncType = LuaFuncType.OLDNPC_FUNC
end

function FunctionNpcOld:OnInit(DisplayName, FuncParams)
end

function FunctionNpcOld:OnClick()
    local funcType = self.FuncParams.FuncType
    if funcType == ProtoRes.interact_func_type.INTERACT_FUNC_DIALOGG then
        NpcDialogMgr:PlayDialogLib(self.FuncParams.FuncValue[1], nil)
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_OPEN_UI) then
        local ViewID = self.FuncParams.FuncValue[1]
        if (ViewID ~= nil) then
            InteractiveMgr:ShowView(ViewID, true)
        end

    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_ENTER_PWORLD) then
        -- 旧的副本入口已经不用了 -v_hggzhang
    elseif (funcType == ProtoRes.interact_func_type.INTERACT_FUNC_ENTER_ENTERTAIN) then
        local EntertainType = self.FuncParams.FuncValue[1]
        if EntertainType == ProtoCS.EntertainType.ENTERTAIN_TYPE_FANTASY_CARD then
            _G.MagicCardMgr:SendNpcFantasyCard(self.ResID, self.EntityID)
            InteractiveMgr:ShowView(_G.UIViewID.MagicCardEnterConfirmPanel, false)
        end
    else
        --没有处理的部分
        FLOG_ERROR("FunctionNpcOld:OnClick No this type: %d", funcType)
        return false
    end

    return true
end

return FunctionNpcOld
