---
--- Author: yutingzhan
--- DateTime: 2024-10-26 11:00
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

---@class OpsActivityUpandDownPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn_Video UFButton
---@field ButtonMask UButton
---@field CommBtnGoto OpsCommBtnLView
---@field IconVideco UFImage
---@field ImgLine UFImage
---@field PanelPreview UFCanvasPanel
---@field PanelVideo UFCanvasPanel
---@field ShareTips OpsActivityShareTipsItemView
---@field TableViewSlot UTableView
---@field TextInfo UFTextBlock
---@field TextPreview UFTextBlock
---@field TextSubTitle UFTextBlock
---@field TextTitle UFTextBlock
---@field Time OpsActivityTimeItemView
---@field UMGVideoPlayer_UIBP UMGVideoPlayerView
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsActivityUpandDownPanelView = LuaClass(UIView, true)
local LSTR = _G.LSTR
function OpsActivityUpandDownPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn_Video = nil
	--self.ButtonMask = nil
	--self.CommBtnGoto = nil
	--self.IconVideco = nil
	--self.ImgLine = nil
	--self.PanelPreview = nil
	--self.PanelVideo = nil
	--self.ShareTips = nil
	--self.TableViewSlot = nil
	--self.TextInfo = nil
	--self.TextPreview = nil
	--self.TextSubTitle = nil
	--self.TextTitle = nil
	--self.Time = nil
	--self.UMGVideoPlayer_UIBP = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsActivityUpandDownPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBtnGoto)
	self:AddSubView(self.ShareTips)
	self:AddSubView(self.Time)
	self:AddSubView(self.UMGVideoPlayer_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsActivityUpandDownPanelView:OnInit()
	self.CommBtnGoto.Money = false
	self.CommBtnGoto.NotUnlock = false
	self.ViewModel = OpsActivityLeftandRightPanelVM.New()
	self.AwardTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot, self.OnClickedSelectMemberItem, true)
	self.Binders = {
        {"TextIntroduction", UIBinderSetText.New(self, self.TextInfo)},
		{"bShowTextIntroduction", UIBinderSetIsVisible.New(self, self.TextInfo)},
		{"bShowImgline", UIBinderSetIsVisible.New(self, self.ImgLine)},
        {"TextTitle", UIBinderSetText.New(self, self.TextTitle)},
		{"TextSubTitle", UIBinderSetText.New(self, self.TextSubTitle)},
		{"bShowSubTitle", UIBinderSetIsVisible.New(self, self.TextSubTitle)},
        {"AwardVMList", UIBinderUpdateBindableList.New(self, self.AwardTableViewAdapter)},
		{"bShowCommBtnGoto", UIBinderSetIsVisible.New(self, self.CommBtnGoto)},
		{"bShowTableViewSlot", UIBinderSetIsVisible.New(self, self.TableViewSlot)},
		{"bShowTableViewSlot", UIBinderSetIsVisible.New(self, self.PanelPreview)},
    }
	UIUtil.SetIsVisible(self.PanelVideo, false)
	self.UMGVideoPlayer_UIBP:HideAllUI()
end

function OpsActivityUpandDownPanelView:OnDestroy()
	
end

function OpsActivityUpandDownPanelView:OnShow()
	self.TextPreview:SetText(LSTR(100008))
	self.CommBtnGoto.TextNotUnlock:SetText(LSTR(100009))
	if self.Params == nil then
		return
	end
	if self.Params.ActivityID == nil then
		return
	end
	self:SetTextColor()
	self.ViewModel:Update(self.Params)
	if self.ViewModel.bShowCommBtnGoto then
		if self.ViewModel.IsLoginDay then
			self:SetBtnState()
		else
			self.CommBtnGoto.CommBtnL:SetIsRecommendState(true)
			self.CommBtnGoto.BtnText = self.ViewModel.BtnContent
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

function OpsActivityUpandDownPanelView:SetBtnState()
	if self.ViewModel.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
		self.CommBtnGoto.CommBtnL:SetIsRecommendState(true)
		self.CommBtnGoto.BtnText = LSTR(100132)
	elseif self.ViewModel.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
		self.CommBtnGoto.CommBtnL:SetIsDoneState(true)
		self.CommBtnGoto.BtnText = LSTR(100037)
		self.CommBtnGoto.CommBtnL:SetText(LSTR(100037))
	elseif self.ViewModel.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
		self.CommBtnGoto.CommBtnL:SetIsDisabledState(true, true)
		self.CommBtnGoto.BtnText = LSTR(100132)
	end
end


function OpsActivityUpandDownPanelView:OnHide()
	self.UMGVideoPlayer_UIBP:OnClose()
end

function OpsActivityUpandDownPanelView:PlayMovieEnd()
	self.UMGVideoPlayer_UIBP:OnResume()
end

function OpsActivityUpandDownPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.CommBtnGoto.CommBtnL, self.OnCommBtnGotoClick)
	UIUtil.AddOnClickedEvent(self,  self.ButtonMask, self.OnButtonMaskClick)
	UIUtil.AddOnClickedEvent(self,  self.Btn_Video, self.OnVideoPlayClick)
end

function OpsActivityUpandDownPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OpsActivityNodeGetReward, self.OpsNodeRewardGet)
end

function OpsActivityUpandDownPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function OpsActivityUpandDownPanelView:OpsNodeRewardGet()
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

function OpsActivityUpandDownPanelView:OnCommBtnGotoClick()
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

function OpsActivityUpandDownPanelView:OnButtonMaskClick()
	if not self.ViewModel.bShowCommBtnGoto then
		DataReportUtil.ReportActivityFlowData("ActivityPicClickFlow", self.Params.ActivityID, 1)
		OpsActivityMgr:Jump(self.ViewModel.JumpType, self.ViewModel.JumpParam)
	end
end

function OpsActivityUpandDownPanelView:OnClickedSelectMemberItem(Index, ItemData, ItemView)
	if ItemData == nil or ItemData.ItemID == nil then
		return
	end
	ItemTipsUtil.ShowTipsByResID(ItemData.ItemID, ItemView, nil, nil, 30)
end

function OpsActivityUpandDownPanelView:OnVideoPlayClick()
	if self.ViewModel.VideoPath == nil then
		return
	end
	_G.UIViewMgr:ShowView(_G.UIViewID.CommonVideoPlayerView, {VideoPath = self.ViewModel.VideoPath})
end

function OpsActivityUpandDownPanelView:SetTextColor()
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

return OpsActivityUpandDownPanelView