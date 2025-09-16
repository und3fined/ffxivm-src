---
--- Author: richyczhou
--- DateTime: 2025-03-30 16:21
--- Description:
---

local AccountUtil = require("Utils/AccountUtil")
local UIView = require("UI/UIView")
local EventID = require("Define/EventID")
local LuaClass = require("Core/LuaClass")
local LocalizationUtil = require("Utils/LocalizationUtil")
local TimeUtil = require("Utils/TimeUtil")
local UIUtil = require("Utils/UIUtil")

local FLOG_INFO = _G.FLOG_INFO

---@class LoginNewAssemblePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose UButton
---@field Button1 UButton
---@field Button2 UButton
---@field Button3 UButton
---@field Button4 UButton
---@field ImgBg1_1 UFImage
---@field ImgBg2_1 UFImage
---@field ImgBg3_1 UFImage
---@field ImgBg4_1 UFImage
---@field ImgBubble2_1 UFImage
---@field ImgBubble3 UFImage
---@field ImgMask UImage
---@field ImgShare UFImage
---@field ImgTime UImage
---@field PanelBubble UFCanvasPanel
---@field PanelTips UCanvasPanel
---@field TextNum1 UTextBlock
---@field TextNumNew UTextBlock
---@field AnimBubbleAwardLoop UWidgetAnimation
---@field AnimBubbleIn UWidgetAnimation
---@field AnimBubbleOut UWidgetAnimation
---@field AnimBubbleShareLoop UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewAssemblePanelView = LuaClass(UIView, true)

function LoginNewAssemblePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.Button1 = nil
	--self.Button2 = nil
	--self.Button3 = nil
	--self.Button4 = nil
	--self.ImgBg1_1 = nil
	--self.ImgBg2_1 = nil
	--self.ImgBg3_1 = nil
	--self.ImgBg4_1 = nil
	--self.ImgBubble2_1 = nil
	--self.ImgBubble3 = nil
	--self.ImgMask = nil
	--self.ImgShare = nil
	--self.ImgTime = nil
	--self.PanelBubble = nil
	--self.PanelTips = nil
	--self.TextNum1 = nil
	--self.TextNumNew = nil
	--self.AnimBubbleAwardLoop = nil
	--self.AnimBubbleIn = nil
	--self.AnimBubbleOut = nil
	--self.AnimBubbleShareLoop = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewAssemblePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewAssemblePanelView:OnInit()

end

function LoginNewAssemblePanelView:OnDestroy()

end

function LoginNewAssemblePanelView:OnShow()
    FLOG_INFO("[LoginNewAssemblePanelView:OnShow] ")
    self:ShowFromLogin()

    UIUtil.SetIsVisible(self.PanelTips, true);
    UIUtil.SetIsVisible(self.TextNum1, false);
    UIUtil.SetIsVisible(self.TextNumNew, true);

    local OpeningTimestamp = _G.UE.UIntegrationMgr.Get():GetOpeningTimestamp();
    self.OpeningTimestamp = OpeningTimestamp - 28800;
    FLOG_INFO("[LoginNewAssemblePanelView:OnShow] OpeningTimestamp: %d", self.OpeningTimestamp)

    if self.OpeningTimestamp > 0 then
        self:UpdateRemainTime();
        self.TimerId = self:RegisterTimer(function()
            self:UpdateRemainTime();
        end, 1, 1, 0)
    end
end

function LoginNewAssemblePanelView:OnHide()

end

function LoginNewAssemblePanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnClose, self.OnClickBtnClose)
    UIUtil.AddOnClickedEvent(self, self.Button1, self.OnClickBtnOne)
    UIUtil.AddOnClickedEvent(self, self.Button2, self.OnClickBtnTwo)
    UIUtil.AddOnClickedEvent(self, self.Button3, self.OnClickBtnThree)
    UIUtil.AddOnClickedEvent(self, self.Button4, self.OnClickBtnFour)
end

function LoginNewAssemblePanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.ShowIntegration, self.OnShowIntegration)
end

function LoginNewAssemblePanelView:OnRegisterBinder()

end

function LoginNewAssemblePanelView:OnClickBtnClose()
    FLOG_INFO("[LoginNewAssemblePanelView:OnClickBtnClose] ")
    --self:Hide()
end

function LoginNewAssemblePanelView:OnClickBtn(BtnID)
    local Url = _G.UE.UIntegrationMgr.Get():GetBtnChannelUrl(BtnID);
    if string.isnilorempty(Url) then
        _G.FLOG_WARNING("[LoginNewAssemblePanelView:OnClickBtnOne] BtnID:%d, Url is empty...", BtnID)
        return
    end
    FLOG_INFO("[LoginNewAssemblePanelView:OnClickBtnOne] BtnID:%d, Url:%s", BtnID, Url)
    AccountUtil.OpenUrlWithParam(Url)
end

function LoginNewAssemblePanelView:OnClickBtnOne()
    self:OnClickBtn(1)
end

function LoginNewAssemblePanelView:OnClickBtnTwo()
    self:OnClickBtn(2)
end

function LoginNewAssemblePanelView:OnClickBtnThree()
    self:OnClickBtn(3)
end

function LoginNewAssemblePanelView:OnClickBtnFour()
    self:OnClickBtn(4)
end

function LoginNewAssemblePanelView:OnShowIntegration()
    FLOG_INFO("[LoginNewAssemblePanelView:OnShowIntegration] ")
    self:ShowFromLogin()
end

function LoginNewAssemblePanelView:UpdateRemainTime()
    local CurServerTime = TimeUtil.GetServerTime();
    local RemainingSeconds = self.OpeningTimestamp - CurServerTime;
    --FLOG_INFO("[LoginNewAssemblePanelView:UpdateRemainTime] OpeningTimestamp:%d, ServerTime:%d, RemainingSeconds :%d", self.OpeningTimestamp, CurServerTime, RemainingSeconds)

    if RemainingSeconds < 0 then
        UIUtil.SetIsVisible(self.PanelTips, false);
        if self.TimerId then
            self:UnRegisterTimer(self.TimerId)
            self.TimerId = nil
        end
        return;
    end

    local RemainingTime = LocalizationUtil.GetCountdownTimeForLongTime(RemainingSeconds);
    if self.TextNumNew then
        self.TextNumNew:SetText(RemainingTime)
    end
end

return LoginNewAssemblePanelView