---
--- Author: yutingzhan
--- DateTime: 2024-12-07 17:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoCommon = require("Protocol/ProtoCommon")

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")
local LootMgr = require("Game/Loot/LootMgr")
local DataReportUtil = require("Utils/DataReportUtil")

---@class OpsSupplyStationItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnIcon UFButton
---@field BtnPreview UFButton
---@field ImgBG UFImage
---@field ImgProps UFImage
---@field PanelAvailable UFCanvasPanel
---@field PanelReceive UFCanvasPanel
---@field TextDay UFTextBlock
---@field TextQuantity UFTextBlock
---@field AnimDone UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsSupplyStationItemView = LuaClass(UIView, true)

function OpsSupplyStationItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnIcon = nil
	--self.BtnPreview = nil
	--self.ImgBG = nil
	--self.ImgProps = nil
	--self.PanelAvailable = nil
	--self.PanelReceive = nil
	--self.TextDay = nil
	--self.TextQuantity = nil
	--self.AnimDone = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsSupplyStationItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsSupplyStationItemView:OnInit()
end

function OpsSupplyStationItemView:OnDestroy()

end

function OpsSupplyStationItemView:OnShow()
end

function OpsSupplyStationItemView:OnHide()

end

function OpsSupplyStationItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.BtnIcon, self.OnBtnIconClick)
	UIUtil.AddOnClickedEvent(self,  self.BtnPreview, self.OnBtnPreviewClick)

end

function OpsSupplyStationItemView:OnRegisterGameEvent()

end

function OpsSupplyStationItemView:OnRegisterBinder()
	local Params = self.Params
    if nil == Params then return end

    local ViewModel = Params.Data
    if nil == ViewModel or nil == ViewModel.RegisterBinder then
        return
    end

    if (self.Binders == nil) then
        self.Binders = {
            {
                "Icon",
                UIBinderSetBrushFromAssetPath.New(self, self.ImgProps)
            },
            {
                "TextDay",
                UIBinderSetText.New(self, self.TextDay)
            },
			{
                "Num",
                UIBinderSetText.New(self, self.TextQuantity)
            },
			{
                "ImgBG",
                UIBinderSetBrushFromAssetPath.New(self, self.ImgBG)
            },

			{
                "IconReceivedVisible",
                UIBinderSetIsVisible.New(self, self.PanelReceive)
            },
			{
                "IconRewardAvaiable",
                UIBinderSetIsVisible.New(self, self.PanelAvailable)
            },
			{
                "BtnPreviewVisible",
                UIBinderSetIsVisible.New(self, self.BtnPreview, false, true)
            },
        }
    end

    self:RegisterBinders(ViewModel, self.Binders)
end

function OpsSupplyStationItemView:OnBtnPreviewClick()
    if self.Params == nil or self.Params.Data == nil then return end
    local Index = 0
    if self.Params.Index == 2 then
        Index = 1
    elseif self.Params.Index == 3 then
        Index = 2
    elseif self.Params.Index == 7 then
        Index = 3
    end
    DataReportUtil.ReportActivityClickFlowData(self.Params.Data.ActivityID, Index)
    _G.PreviewMgr:OpenPreviewView(self.Params.Data.ItemID)
end

function OpsSupplyStationItemView:OnBtnIconClick()
    if self.Params == nil or self.Params.Data == nil then
        return
    end
	local IconRewardAvaiable = self.Params.Data.IconRewardAvaiable
	local ActivityID = self.Params.Data.ActivityID
	if IconRewardAvaiable then
		LootMgr:SetDealyState(true)
		OpsActivityMgr:SendActivityGetReward(ActivityID)
	else
		ItemTipsUtil.ShowTipsByResID(self.Params.Data.ItemID, self.ImgBG, nil, nil, 30)
	end
end


return OpsSupplyStationItemView