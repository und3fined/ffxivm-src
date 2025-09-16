---
--- Author: ZhengJianChuan
--- DateTime: 2023-04-06 16:29
--- Description:机遇临门活动，活动开始界面展示。
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local GoldSauserDefine = require("Game/Gate/GoldSauserDefine")
local GoldSauserMgr = require("Game/Gate/GoldSauserMgr")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local AudioUtil = require("Utils/AudioUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local CommonUtil = require("Utils/CommonUtil")

local EntertainGameID = ProtoRes.Game.GameID
local LSTR = _G.LSTR

local Path = "Texture2D'/Game/UI/Texture/Localized/chs/%s'" -- 多语言的路径
local WinImgName = "UI_Gate_Img_Providential.UI_Gate_Img_Providential"
local BeginImgName = "UI_Gate_Img_Opportunity.UI_Gate_Img_Opportunity"
local LoseImgName = "UI_Gate_Img_LoseOpportunity.UI_Gate_Img_LoseOpportunity"

---@class GateOpportunityPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgGodSend UFImage
---@field ImgLoseOpportunity UFImage
---@field ImgMissed UFImage
---@field ImgOpportunity UFImage
---@field ImgOpportunityBg UFImage
---@field ImgProvidential UFImage
---@field PopUpBG CommonPopUpBGView
---@field AnimGateIn UWidgetAnimation
---@field AnimGodSend UWidgetAnimation
---@field AnimLoseOpportunity UWidgetAnimation
---@field AnimMissed UWidgetAnimation
---@field AnimProvidential UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GateOpportunityPanelView = LuaClass(UIView, true)

function GateOpportunityPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.ImgGodSend = nil
    --self.ImgLoseOpportunity = nil
    --self.ImgMissed = nil
    --self.ImgOpportunity = nil
    --self.ImgOpportunityBg = nil
    --self.ImgProvidential = nil
    --self.PopUpBG = nil
    --self.AnimGateIn = nil
    --self.AnimGodSend = nil
    --self.AnimLoseOpportunity = nil
    --self.AnimMissed = nil
    --self.AnimProvidential = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GateOpportunityPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.PopUpBG)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GateOpportunityPanelView:OnInit()
    self.PopUpBG:SetHideOnClick(false)
end

function GateOpportunityPanelView:OnDestroy()
end

function GateOpportunityPanelView:OnShow()
    AudioUtil.LoadAndPlay2DSound(GoldSauserDefine.SignUpSuccessSoundPath)

    self.PopUpBG:SetHideOnClick(false)
    local Params = self.Params
    local PopType = GoldSauserDefine.PopType
    local Type = PopType.Gate
    if Params ~= nil then
        Type = Params.Type
    end

    local TargetAnim = nil

    if Type == PopType.Gate then
        local BGPath = string.format(Path, BeginImgName)
        local FinalPath = LocalizationUtil.GetLocalizedAssetPath(BGPath)
        UIUtil.ImageSetBrushFromAssetPath(self.ImgOpportunity, FinalPath)
        TargetAnim = self.AnimGateIn
    elseif Type == PopType.Win then
        local BGPath = string.format(Path, WinImgName)
        local FinalPath = LocalizationUtil.GetLocalizedAssetPath(BGPath)
        UIUtil.ImageSetBrushFromAssetPath(self.ImgProvidential, FinalPath)
        TargetAnim = self.AnimProvidential
    else
        local BGPath = string.format(Path, LoseImgName)
        local FinalPath = LocalizationUtil.GetLocalizedAssetPath(BGPath)
        UIUtil.ImageSetBrushFromAssetPath(self.ImgLoseOpportunity, FinalPath)
        TargetAnim = self.AnimLoseOpportunity
    end
    self:PlayAnimation(TargetAnim)
    local DelayTime = TargetAnim:GetEndTime() or 4.1
    self.ExcuteTimer = self:RegisterTimer(self.OnTimerEnd, DelayTime, 0, 1, self)
end

function GateOpportunityPanelView:OnHide()
    if self.ExcuteTimer ~= nil then
        self:UnRegisterTimer(self.ExcuteTimer)
    end

    if (self.Params.AnimFinichCallback ~= nil) then
        self.Params.AnimFinichCallback(self.Params)
    end
end

function GateOpportunityPanelView:OnRegisterUIEvent()
end

function GateOpportunityPanelView:OnRegisterGameEvent()
end

function GateOpportunityPanelView:OnRegisterBinder()
end

function GateOpportunityPanelView:OnRegisterTimer()
end

function GateOpportunityPanelView:OnTimerEnd()
    self:Hide()
end

return GateOpportunityPanelView
