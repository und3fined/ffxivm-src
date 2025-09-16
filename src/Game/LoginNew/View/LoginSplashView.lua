---
--- Author: richyczhou
--- DateTime: 2024-07-08 10:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local PreLoginMgr = require("Game/LoginNew/Mgr/PreLoginMgr")
local UIUtil = require("Utils/UIUtil")

---@class LoginSplashView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BlackScreen UImage
---@field MovieImage UImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginSplashView = LuaClass(UIView, true)

function LoginSplashView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BlackScreen = nil
	--self.MovieImage = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginSplashView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginSplashView:OnInit()

end

function LoginSplashView:OnDestroy()

end

function LoginSplashView:OnShow()
    self.BlackScreen:SetVisibility(_G.UE.ESlateVisibility.Visible)

    PreLoginMgr:ShowSparkMore(function()
        self:Hide()
        self:StartDolphin()
    end)
end

function LoginSplashView:OnHide()
    self.BlackScreen:SetVisibility(_G.UE.ESlateVisibility.Visible)
end

function LoginSplashView:OnRegisterUIEvent()

end

function LoginSplashView:OnRegisterGameEvent()

end

function LoginSplashView:OnRegisterTimer()
    _G.FLOG_INFO("[LoginSplashView:OnRegisterTimer] ")
    self.TimerId = self:RegisterTimer(self.OnHideBlackScreenTimer, 0.3, 0, 0)
end

function LoginSplashView:OnHideBlackScreenTimer()
    _G.FLOG_INFO("[LoginSplashView:OnHideBlackScreenTimer] ")
    --self:UnRegisterTimer(self, self.TimerId)
    self:UnRegisterAllTimer()
    self.BlackScreen:SetVisibility(_G.UE.ESlateVisibility.Hidden)
end

function LoginSplashView:StartDolphin()
    _G.FLOG_INFO("[LoginSplashView:StartDolphin] ")
    local DolphinActorUpdaterPath = "Blueprint'/Game/BluePrint/PreLogin/DolphinActorUpdater_BP.DolphinActorUpdater_BP_C'"

    --local function Callback()
    --    local DolphinActorUpdaterCls = _G.ObjectMgr:GetClass(DolphinActorUpdaterPath)
    --    if DolphinActorUpdaterCls == nil then
    --        _G.FLOG_ERROR("[LoginSplashView:StartDolphin] DolphinActorUpdaterCls is nil")
    --        return
    --    end
    --
    --    _G.FLOG_INFO("[LoginSplashView:StartDolphin] SpawnActor")
    --    _G.CommonUtil.SpawnActor(DolphinActorUpdaterCls)
    --end
    --_G.ObjectMgr:LoadClassAsync(DolphinActorUpdaterPath, Callback)

    local DolphinActorUpdaterCls = _G.ObjectMgr:LoadClassSync(DolphinActorUpdaterPath)
    if DolphinActorUpdaterCls == nil then
        _G.FLOG_ERROR("[LoginSplashView:StartDolphin] DolphinActorUpdaterCls is nil")
        return
    end
    _G.FLOG_INFO("[LoginSplashView:StartDolphin] SpawnActor")
    _G.CommonUtil.SpawnActor(DolphinActorUpdaterCls)
end

return LoginSplashView