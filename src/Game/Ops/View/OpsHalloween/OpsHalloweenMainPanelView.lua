---
--- Author: Administrator
--- DateTime: 2025-02-24 10:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local OpsHalloweenMainPanelVM = require("Game/Ops/VM/OpsHalloween/OpsHalloweenMainPanelVM")
local OpsSeasonActivityDefine = require("Game/Ops/OpsSeasonActivityDefine")
local DataReportUtil = require("Utils/DataReportUtil")
local SaveKey = require("Define/SaveKey")

---@class OpsHalloweenMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnMakeup UFButton
---@field BtnMancr UFButton
---@field BtnPaly UFButton
---@field BtnProm UFButton
---@field BtnShop UFButton
---@field CommInforBtn_UIBP CommInforBtnView
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field EFF1 UFCanvasPanel
---@field Halloween_gargoyle USpineWidget
---@field IconMakeup USizeBox
---@field IconMancr USizeBox
---@field IconPassedMakeup UFImage
---@field IconPassedProm UFImage
---@field IconProm USizeBox
---@field IconTaskMakeup UFImage
---@field IconTaskMancr UFImage
---@field IconTaskProm UFImage
---@field ImgMakeup_Lock UFImage
---@field ImgManor_Lock UFImage
---@field MakeupRedDot CommonRedDotView
---@field MancrRedDot CommonRedDotView
---@field OpsActivityTime OpsActivityTimeItemView
---@field PanelFootprint UFCanvasPanel
---@field PromRedDot CommonRedDotView
---@field ShareTips OpsActivityShareTipsItemView
---@field TextSubTitle UFTextBlock
---@field TextTitle UFTextBlock
---@field TextTitleMakeup UFTextBlock
---@field TextTitleMancr UFTextBlock
---@field TextTitleProm UFTextBlock
---@field TextTitleShop UFTextBlock
---@field AnimBack UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLock1 UWidgetAnimation
---@field AnimLock2 UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimNext UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsHalloweenMainPanelView = LuaClass(UIView, true)

function OpsHalloweenMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnMakeup = nil
	--self.BtnMancr = nil
	--self.BtnPaly = nil
	--self.BtnProm = nil
	--self.BtnShop = nil
	--self.CommInforBtn_UIBP = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.EFF1 = nil
	--self.Halloween_gargoyle = nil
	--self.IconMakeup = nil
	--self.IconMancr = nil
	--self.IconPassedMakeup = nil
	--self.IconPassedProm = nil
	--self.IconProm = nil
	--self.IconTaskMakeup = nil
	--self.IconTaskMancr = nil
	--self.IconTaskProm = nil
	--self.ImgMakeup_Lock = nil
	--self.ImgManor_Lock = nil
	--self.MakeupRedDot = nil
	--self.MancrRedDot = nil
	--self.OpsActivityTime = nil
	--self.PanelFootprint = nil
	--self.PromRedDot = nil
	--self.ShareTips = nil
	--self.TextSubTitle = nil
	--self.TextTitle = nil
	--self.TextTitleMakeup = nil
	--self.TextTitleMancr = nil
	--self.TextTitleProm = nil
	--self.TextTitleShop = nil
	--self.AnimBack = nil
	--self.AnimIn = nil
	--self.AnimLock1 = nil
	--self.AnimLock2 = nil
	--self.AnimLoop = nil
	--self.AnimNext = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsHalloweenMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommInforBtn_UIBP)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	self:AddSubView(self.MakeupRedDot)
	self:AddSubView(self.MancrRedDot)
	self:AddSubView(self.OpsActivityTime)
	self:AddSubView(self.PromRedDot)
	self:AddSubView(self.ShareTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsHalloweenMainPanelView:OnInit()
	self.ViewModel = OpsHalloweenMainPanelVM.New()
	self.Binders = {
        {"TitleText", UIBinderSetText.New(self, self.TextTitle)},
		{"SubTitleText", UIBinderSetText.New(self, self.TextSubTitle)},
       	{"WonderfulBallText", UIBinderSetText.New(self, self.TextTitleProm)},
		{"MakeupBallText", UIBinderSetText.New(self, self.TextTitleMakeup)},
		{"HauntedManorText", UIBinderSetText.New(self, self.TextTitleMancr)},
		{"SeasonShopText", UIBinderSetText.New(self, self.TextTitleShop)},
		{"WonderfulBallFinish", UIBinderSetIsVisible.New(self, self.IconPassedProm)},
		{"MakeupBallFinish", UIBinderSetIsVisible.New(self, self.IconPassedMakeup)},
		{"LockHauntedManor", UIBinderSetIsVisible.New(self, self.ImgManor_Lock)},
		{"LockMakeupBall", UIBinderSetIsVisible.New(self, self.ImgMakeup_Lock)},
		{"EFF1Visible", UIBinderSetIsVisible.New(self, self.EFF1)},
		{"PanelFootprintVisible", UIBinderSetIsVisible.New(self, self.PanelFootprint)},

    }
end

function OpsHalloweenMainPanelView:OnDestroy()

end

function OpsHalloweenMainPanelView:OnShow()
	if self.Params == nil then
		return
	end
	if self.Params.ActivityID == nil then
		return
	end

	self.ViewModel:Update(self.Params)
	if self.ViewModel.WonderfulBallNode then
		self.PromRedDot:SetRedDotNameByString(self.ViewModel:GetBtnRedName(tostring(self.Params.ActivityID).."/"..tostring(self.ViewModel.WonderfulBallNode.Head.NodeID)))
	end

	if self.ViewModel.HauntedManorNode then
		self.MancrRedDot:SetRedDotNameByString(self.ViewModel:GetBtnRedName(tostring(self.Params.ActivityID).."/"..tostring(self.ViewModel.HauntedManorNode.Head.NodeID)))
	end

	if self.ViewModel.MakeupBallNode then
		self.MakeupRedDot:SetRedDotNameByString(self.ViewModel:GetBtnRedName(tostring(self.Params.ActivityID).."/"..tostring(self.ViewModel.MakeupBallNode.Head.NodeID)))
	end

	local OpsHalloweenAutoPlayVideo = _G.UE.USaveMgr.GetInt(SaveKey.OpsHalloweenAutoPlayVideo, 0, true) or 0
	if OpsHalloweenAutoPlayVideo == 0 then
		self:OnClickActivityPlay()
		_G.UE.USaveMgr.SetInt(SaveKey.OpsHalloweenAutoPlayVideo, 1, true)
	end
	
end

function OpsHalloweenMainPanelView:OnHide()

end

function OpsHalloweenMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnProm, self.OnClickedWonderfulBall)
	UIUtil.AddOnClickedEvent(self, self.BtnMancr, self.OnClickedHauntedManor)
	UIUtil.AddOnClickedEvent(self, self.BtnMakeup, self.OnClickedMakeupBall)
	UIUtil.AddOnClickedEvent(self, self.BtnShop, self.OnClickSeasonShop)

	UIUtil.AddOnClickedEvent(self, self.BtnPaly, self.OnClickActivityPlay)
end

function OpsHalloweenMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OpsActivityUpdate, self.UpdateActivityUI)

end

function OpsHalloweenMainPanelView:UpdateActivityUI()
	if self.Params == nil then
		return
	end
	
	if self.Params.ActivityID == nil then
		return
	end

	local Activity = self.Params.Activity
    local Detail = _G.OpsActivityMgr.ActivityNodeMap[self.Params.ActivityID] or {}
    self.Params:UpdateVM({Activity = Activity, Detail = Detail})

	self.ViewModel:Update(self.Params)
end

function OpsHalloweenMainPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function OpsHalloweenMainPanelView:OnClickedWonderfulBall()
	DataReportUtil.ReportActivityFlowData("HalloweenActionTypeClickFlow", self.Params.ActivityID, OpsSeasonActivityDefine.HalloweenActionType.ClickedWonderfulBall)
	if self.ViewModel.WonderfulBallNode then
		_G.UIViewMgr:ShowView(_G.UIViewID.OpsHalloweenPromPanel, {Node = self.ViewModel.WonderfulBallNode, IconPath =  "Texture2D'/Game/Assets/Icon/071000HUD/UI_Icon_071341.UI_Icon_071341'", WonderfulBall = true})
	end

	self.ViewModel:ClickWonderfulBallNode()
end

function OpsHalloweenMainPanelView:OnClickedHauntedManor()
	DataReportUtil.ReportActivityFlowData("HalloweenActionTypeClickFlow", self.Params.ActivityID, OpsSeasonActivityDefine.HalloweenActionType.ClickedHauntedManor)
	if self.ViewModel.LockHauntedManor == true then
		_G.MsgTipsUtil.ShowTips(_G.LSTR(1560007)) 
		self:PlayAnimation(self.AnimLock1)
		return
	end

	self:PlayAnimation(self.AnimNext)

	_G.UIViewMgr:ShowView(_G.UIViewID.OpsHalloweenMancrPanel, {HideCallBack = function()
		self:PlayAnimation(self.AnimBack)
	end
	})

	self.ViewModel:ClickHauntedManorNode()
end

function OpsHalloweenMainPanelView:OnClickedMakeupBall()
	DataReportUtil.ReportActivityFlowData("HalloweenActionTypeClickFlow", self.Params.ActivityID, OpsSeasonActivityDefine.HalloweenActionType.ClickedMakeupBall)
	if self.ViewModel.LockMakeupBall == true then
		_G.MsgTipsUtil.ShowTips(_G.LSTR(1560007)) 
		self:PlayAnimation(self.AnimLock2)
		return
	end
	if self.ViewModel.MakeupBallNode then
		_G.UIViewMgr:ShowView(_G.UIViewID.OpsHalloweenPromPanel, {Node = self.ViewModel.MakeupBallNode, IconPath =  "Texture2D'/Game/Assets/Icon/071000HUD/UI_Icon_071221.UI_Icon_071221'"})
	end

	self.ViewModel:ClickMakeupBallNode()
end

function OpsHalloweenMainPanelView:OnClickSeasonShop()
	DataReportUtil.ReportActivityFlowData("HalloweenActionTypeClickFlow", self.Params.ActivityID, OpsSeasonActivityDefine.HalloweenActionType.ClickedSeasonShop)
	local Info = self.ViewModel:GetSeasonShopInfo()
	if Info then
		_G.OpsActivityMgr:Jump(Info.JumpType, Info.JumpParam)
	end
end

function OpsHalloweenMainPanelView:OnClickActivityPlay()
	--_G.OpsSeasonActivityMgr:PlayHalloweenAni()
	DataReportUtil.ReportActivityFlowData("HalloweenActionTypeClickFlow", self.Params.ActivityID, OpsSeasonActivityDefine.HalloweenActionType.ClickPlay)
	if self.ViewModel.VideoShowNodeInfo then
		_G.UIViewMgr:ShowView(_G.UIViewID.CommonVideoPlayerView, {VideoPath = self.ViewModel.VideoShowNodeInfo.StrParam})
	end
	
end

return OpsHalloweenMainPanelView