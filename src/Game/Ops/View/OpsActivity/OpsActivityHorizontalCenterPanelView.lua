---
--- Author: yutingzhan
--- DateTime: 2025-06-04 14:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local OpsActivityLeftandRightPanelVM = require("Game/Ops/VM/OpsActivityLeftandRightPanelVM")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local ProtoCS = require("Protocol/ProtoCS")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

---@class OpsActivityHorizontalCenterPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn_Video UFButton
---@field ButtonMask UButton
---@field CommBtnGoto CommBtnLView
---@field CommBtnGoto2 CommBtnXLView
---@field IconVideco UFImage
---@field ImgLine UFImage
---@field ImgLine02 UFImage
---@field ImgLinebg UFImage
---@field PanelBtn UFCanvasPanel
---@field PanelReward UFCanvasPanel
---@field PanelVideo UFCanvasPanel
---@field ShareTips OpsActivityShareTipsItemView
---@field TableViewSlot UTableView
---@field TextSubTitle UFTextBlock
---@field TextTitle UFTextBlock
---@field Time OpsActivityTimeItemView
---@field UMGVideoPlayer_UIBP UMGVideoPlayerView
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsActivityHorizontalCenterPanelView = LuaClass(UIView, true)

function OpsActivityHorizontalCenterPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn_Video = nil
	--self.ButtonMask = nil
	--self.CommBtnGoto = nil
	--self.CommBtnGoto2 = nil
	--self.IconVideco = nil
	--self.ImgLine = nil
	--self.ImgLine02 = nil
	--self.ImgLinebg = nil
	--self.PanelBtn = nil
	--self.PanelReward = nil
	--self.PanelVideo = nil
	--self.ShareTips = nil
	--self.TableViewSlot = nil
	--self.TextSubTitle = nil
	--self.TextTitle = nil
	--self.Time = nil
	--self.UMGVideoPlayer_UIBP = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsActivityHorizontalCenterPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBtnGoto)
	self:AddSubView(self.CommBtnGoto2)
	self:AddSubView(self.ShareTips)
	self:AddSubView(self.Time)
	self:AddSubView(self.UMGVideoPlayer_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsActivityHorizontalCenterPanelView:OnInit()
	self.ViewModel = OpsActivityLeftandRightPanelVM.New()
	self.AwardTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot, self.OnClickedSelectMemberItem, true)
	self.Binders = {
        {"TextTitle", UIBinderSetText.New(self, self.TextTitle)},
		{"TextSubTitle", UIBinderSetText.New(self, self.TextSubTitle)},
		{"bShowSubTitle", UIBinderSetIsVisible.New(self, self.TextSubTitle)},
        {"AwardVMList", UIBinderUpdateBindableList.New(self, self.AwardTableViewAdapter)},
		{"bShowCommBtnGoto", UIBinderSetIsVisible.New(self, self.CommBtnGoto)},
		{"bShowTableViewSlot", UIBinderSetIsVisible.New(self, self.TableViewSlot)},
		{"bShowTableViewSlot", UIBinderSetIsVisible.New(self, self.ImgLine)},
		{"bShowTableViewSlot", UIBinderSetIsVisible.New(self, self.ImgLine02)},
		{"bShowTableViewSlot", UIBinderSetIsVisible.New(self, self.ImgLinebg)},
		{"bShowPanelReward", UIBinderSetIsVisible.New(self, self.PanelReward)},
		{"bShowCommBtnGoto2", UIBinderSetIsVisible.New(self, self.CommBtnGoto2)},
    }
	UIUtil.SetIsVisible(self.PanelVideo, false)
	self.UMGVideoPlayer_UIBP:HideAllUI()
end

function OpsActivityHorizontalCenterPanelView:OnDestroy()

end

function OpsActivityHorizontalCenterPanelView:OnShow()
	if self.Params == nil then
		return
	end
	if self.Params.ActivityID == nil then
		return
	end
	self:SetTextColor()
	self.Params.IsHorizontalCenterPanel = true
	self.ViewModel:Update(self.Params)
	if self.ViewModel.bShowCommBtnGoto then
		if self.ViewModel.IsLoginDay then
			self:SetBtnState(self.CommBtnGoto)
		else
			self.CommBtnGoto:SetIsRecommendState(true)
			self.CommBtnGoto:SetText(self.ViewModel.BtnContent)
		end
	end
	if self.ViewModel.bShowCommBtnGoto2 then
		if self.ViewModel.IsLoginDay then
			self:SetBtnState(self.CommBtnGoto2)
		else
			self.CommBtnGoto2:SetIsRecommendState(true)
			self.CommBtnGoto2:SetText(self.ViewModel.BtnContent)
		end
	end

	if self.ViewModel.bShowVideo then
		self.UMGVideoPlayer_UIBP:SetVideoPath(self.ViewModel.VideoPath)
		self.UMGVideoPlayer_UIBP:SetPlayMovieEndCallBack(self, self.PlayMovieEnd)
		UIUtil.SetIsVisible(self.PanelVideo, true)
		UIUtil.SetIsVisible(self.UMGVideoPlayer_UIBP, true)
	else
		UIUtil.SetIsVisible(self.PanelVideo, false)
		UIUtil.SetIsVisible(self.UMGVideoPlayer_UIBP, false)
	end
end

function OpsActivityHorizontalCenterPanelView:SetBtnState(BtnWidget)
	if self.ViewModel.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
		BtnWidget:SetIsRecommendState(true)
		BtnWidget:SetText(LSTR(100132))
	elseif self.ViewModel.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
		BtnWidget:SetIsDoneState(true)
		BtnWidget:SetText(LSTR(100037))
	elseif self.ViewModel.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
		BtnWidget:SetIsDisabledState(true, true)
		BtnWidget:SetText(LSTR(100132))
	end
end

function OpsActivityHorizontalCenterPanelView:OnHide()
	self.UMGVideoPlayer_UIBP:OnClose()
end

function OpsActivityHorizontalCenterPanelView:PlayMovieEnd()
	self.UMGVideoPlayer_UIBP:OnResume()
end


function OpsActivityHorizontalCenterPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.CommBtnGoto, self.OnCommBtnGotoClick)
	UIUtil.AddOnClickedEvent(self,  self.CommBtnGoto2, self.OnCommBtnGotoClick)
	UIUtil.AddOnClickedEvent(self,  self.ButtonMask, self.OnButtonMaskClick)
	UIUtil.AddOnClickedEvent(self,  self.Btn_Video, self.OnVideoPlayClick)
end

function OpsActivityHorizontalCenterPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OpsActivityNodeGetReward, self.OpsNodeRewardGet)
end

function OpsActivityHorizontalCenterPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function OpsActivityHorizontalCenterPanelView:OpsNodeRewardGet()
	self:OnShow()
	local Rewards  = {}
	local LoginDayNodeRewards = self.ViewModel.LoginDayNodeRewards
	if LoginDayNodeRewards then
		for _, Reward in ipairs(LoginDayNodeRewards) do
			table.insert(Rewards, {ResID = Reward.ItemID, Num = Reward.Num})
		end
	end
	if #Rewards > 0 then
		local Params = {}
		Params.ShowBtn = false
		Params.ItemList = Rewards
		_G.UIViewMgr:ShowView(_G.UIViewID.CommonRewardPanel, Params)
	end
end

function OpsActivityHorizontalCenterPanelView:OnCommBtnGotoClick()
	if self.ViewModel.IsLoginDay then
		if self.ViewModel.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
			OpsActivityMgr:SendActivityNodeGetReward(self.ViewModel.LoginDayNodeID)
		elseif self.ViewModel.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
			MsgTipsUtil.ShowTipsByID(351004)
		end
	else
		DataReportUtil.ReportActivityFlowData("ActivityPicClickFlow", self.Params.ActivityID, 1)
		OpsActivityMgr:Jump(self.ViewModel.JumpType, self.ViewModel.JumpParam)
	end
end

function OpsActivityHorizontalCenterPanelView:OnButtonMaskClick()
	if not self.ViewModel.bShowCommBtnGoto then
		DataReportUtil.ReportActivityFlowData("ActivityPicClickFlow", self.Params.ActivityID, 1)
		OpsActivityMgr:Jump(self.ViewModel.JumpType, self.ViewModel.JumpParam)
	end
end

function OpsActivityHorizontalCenterPanelView:OnClickedSelectMemberItem(Index, ItemData, ItemView)
	if ItemData == nil or ItemData.ItemID == nil then
		return
	end
	ItemTipsUtil.ShowTipsByResID(ItemData.ItemID, ItemView, nil, nil, 30)
end

function OpsActivityHorizontalCenterPanelView:OnVideoPlayClick()
	if self.ViewModel.VideoPath == nil then
		return
	end
	_G.UIViewMgr:ShowView(_G.UIViewID.CommonVideoPlayerView, {VideoPath = self.ViewModel.VideoPath})
end

function OpsActivityHorizontalCenterPanelView:SetTextColor()
	if self.Params.Activity == nil then
		return
	end
	local FColor = _G.UE.FLinearColor
	local Activity = self.Params.Activity
	if Activity.TitleColor and Activity.TitleColor ~= "" then
		self.TextTitle:SetColorAndOpacity(FColor.FromHex(Activity.TitleColor))
	end
	if Activity.SubTitleColor and Activity.SubTitleColor ~= "" then
		self.TextSubTitle:SetColorAndOpacity(FColor.FromHex(Activity.SubTitleColor))
	end
	if Activity.InfoColor and Activity.InfoColor ~= "" then
		self.TextInfo:SetColorAndOpacity(FColor.FromHex(Activity.InfoColor))
	end
end

return OpsActivityHorizontalCenterPanelView