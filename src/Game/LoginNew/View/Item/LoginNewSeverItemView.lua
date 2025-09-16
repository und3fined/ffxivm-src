---
--- Author: richyczhou
--- DateTime: 2024-06-25 09:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local LoginMgr = require("Game/Login/LoginMgr")
local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")

local FLOG_INFO = _G.FLOG_INFO

---@class LoginNewSeverItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgSeverState UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewSeverItemView = LuaClass(UIView, true)

function LoginNewSeverItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgSeverState = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewSeverItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewSeverItemView:OnInit()

end

function LoginNewSeverItemView:OnDestroy()

end

function LoginNewSeverItemView:OnShow()

end

function LoginNewSeverItemView:OnHide()

end

function LoginNewSeverItemView:OnRegisterUIEvent()

end

function LoginNewSeverItemView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.MapleAllNodeInfoNotify, self.OnMapleNodeInfoNotify)
end

function LoginNewSeverItemView:OnRegisterBinder()

end

function LoginNewSeverItemView:SetWorldID(WorldID)
    self.WorldID = WorldID
end

function LoginNewSeverItemView:SetState(State)
    --for i = 1, #LoginNewDefine.ServerStateConfig do
    --    local ServerState = LoginNewDefine.ServerStateConfig[i]
    --    if ServerState.State == State then
    --        self:SetStateIcon(ServerState.Icon)
    --    end
    --end

    if self.WorldID then
        local NodeInfo = LoginMgr:GetMapleNodeInfo(self.WorldID)
        if NodeInfo then
            State = NodeInfo.State
            FLOG_INFO("[LoginNewSeverItemView:SetState] WorldID:%d, State:%d", self.WorldID, State)
            self:SetStateIcon(LoginNewDefine.ServerStateConfigMap[NodeInfo.State].Icon)
            --for i = 1, #LoginNewDefine.ServerStateConfig do
            --    local ServerState = LoginNewDefine.ServerStateConfig[i]
            --    if ServerState.State == State then
            --        self:SetStateIcon(ServerState.Icon)
            --        return
            --    end
            --end
        end
    end
end

function LoginNewSeverItemView:SetStateIcon(Icon)
    if string.isnilorempty(Icon) then
        return
    end

    UIUtil.ImageSetBrushFromAssetPath(self.ImgSeverState, Icon)
end

function LoginNewSeverItemView:OnMapleNodeInfoNotify()
    self:SetState()
end

return LoginNewSeverItemView