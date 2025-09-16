--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-03-28 20:43:46
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-03-31 11:20:03
FilePath: \Script\Game\Ops\View\OpsSkateboard\OpsSkateboardMainPanelView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local UIView = require("Game/Ops/View/OpsActivity/OpsWhaleMonutPanelView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local LSTR = _G.LSTR
local UIViewMgr = require("UI/UIViewMgr")
local DataReportUtil = require("Utils/DataReportUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ActivityNodeType = ProtoRes.Game.ActivityNodeType
local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")

---@class OpsSkateboardMainPanelView : OpsWhaleMonutPanelView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnFullScreen UFButton
---@field BtnNormal CommBtnLView
---@field BtnRecommend OpsCommBtnLView
---@field CommMoney CommMoneySlotView
---@field CommSlot CommBackpack96SlotView
---@field PanelNotPurchased UFCanvasPanel
---@field PanelPurchased UFCanvasPanel
---@field PreviewBtn OpsActivityPreviewBtnView
---@field RichTextInfo URichTextBox
---@field ShareTips OpsActivityShareTipsItemView
---@field TableViewList UTableView
---@field TextPurchaseRewards UFTextBlock
---@field TextSlot UFTextBlock
---@field TextSlot2 UFTextBlock
---@field TextTag UFTextBlock
---@field TextTitle UFTextBlock
---@field TimePurchased OpsActivityTimeItemView
---@field UMGVideoPlayer UMGVideoPlayerView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsSkateboardMainPanelView = LuaClass(UIView, true)

function OpsSkateboardMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnFullScreen = nil
	--self.BtnNormal = nil
	--self.BtnRecommend = nil
	--self.CommMoney = nil
	--self.CommSlot = nil
	--self.PanelNotPurchased = nil
	--self.PanelPurchased = nil
	--self.PreviewBtn = nil
	--self.RichTextInfo = nil
	--self.ShareTips = nil
	--self.TableViewList = nil
	--self.TextPurchaseRewards = nil
	--self.TextSlot = nil
	--self.TextSlot2 = nil
	--self.TextTag = nil
	--self.TextTitle = nil
	--self.TimePurchased = nil
	--self.UMGVideoPlayer = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsSkateboardMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnNormal)
	self:AddSubView(self.BtnRecommend)
	self:AddSubView(self.CommMoney)
	self:AddSubView(self.CommSlot)
	self:AddSubView(self.PreviewBtn)
	self:AddSubView(self.ShareTips)
	self:AddSubView(self.TimePurchased)
	self:AddSubView(self.UMGVideoPlayer)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsSkateboardMainPanelView:OnInit()
	local OpsSkateboardVM = require("Game/Ops/View/OpsSkateboard/VM/OpsSkateBoardMainVM")
	self.ViewModel = OpsSkateboardVM.New()

	self.TaskTableViewAdapter =  UIAdapterTableView.CreateAdapter(self, self.TableViewList)
	self.Binders = {
		{"TaskVMList", UIBinderUpdateBindableList.New(self, self.TaskTableViewAdapter)},
		{"TextTitle", UIBinderSetText.New(self, self.TextTitle)},
		{"TextSubTitle", UIBinderSetText.New(self, self.TextSubTitle)},
		{"StrParamText1", UIBinderSetText.New(self, self.PreviewBtn.Text01)},
		{"StrParamText2", UIBinderSetText.New(self, self.PreviewBtn.Text02)},
    }

	UIUtil.SetIsVisible(self.UMGVideoPlayer, false)
	self.UMGVideoPlayer:HideAllUI()
end

function OpsSkateboardMainPanelView:OnRegisterUIEvent()
	self.Super.OnRegisterUIEvent(self)
	UIUtil.AddOnClickedEvent(self, self.CommSlot.Btn, self.OnClickItemTips)
	UIUtil.AddOnClickedEvent(self, self.BtnFullScreen, self.OnClickedFullScreen)
end

function OpsSkateboardMainPanelView:OnRegisterGameEvent()
	self.Super.OnRegisterGameEvent(self)
	self:RegisterGameEvent(_G.EventID.ShareOpsActivitySuccess, self.OnShareOpsActivitySuccess)
end

function OpsSkateboardMainPanelView:OnShareOpsActivitySuccess(Param)
	if not Param then return end

	if self.Params and Param.ActivityID and self.Params.ActivityID == Param.ActivityID then
		self:RegisterTimer(function()
			OpsActivityMgr:SendQueryActivity(self.Params.ActivityID)
		end, 1, 0, 1)
	end
end

function OpsSkateboardMainPanelView:OnClickItemTips()
	if not self.ViewModel then return end

	local ItemTipsUtil = require("Utils/ItemTipsUtil")
	local RewardResID = self.ViewModel:GetBuyRewardItemID()
	ItemTipsUtil.ShowTipsByResID(RewardResID, self.CommSlot)
end

function OpsSkateboardMainPanelView:OnClickedFullScreen()
	local ViedoPath = self.ViewModel:GetMoviePath()
	if ViedoPath then
		self.UMGVideoPlayer:SetVolume(true)
		UIViewMgr:ShowView(_G.UIViewID.CommonVideoPlayerView, {VideoPath = ViedoPath, SeekValue = self.UMGVideoPlayer:GetSeekValue(), HideCallBack = 
		function ()
			self:PlayMovieEnd()
		end
		})
	end
end

function OpsSkateboardMainPanelView:PlayMovieEnd()
	self.UMGVideoPlayer:SetVolume(false)
	self.UMGVideoPlayer:OnResume()
end

function OpsSkateboardMainPanelView:OnShow()
	self.Super.OnShow(self)
	self.TextPurchaseRewards:SetText(LSTR(100107))
	self.TextSlot:SetText(LSTR(100108))
	self.TextSlot2:SetText(LSTR(100115))
	self.TextTag:SetText(LSTR(100104))
	self:SetBuyRewardShow()
	UIUtil.SetIsVisible(self.UMGVideoPlayer.CloseButton, false)
	local ViedoPath = self.ViewModel:GetMoviePath()
	if ViedoPath and not self.ViewModel:GetActGoodsHasBought() then
		self.UMGVideoPlayer:SetVideoPath(ViedoPath)
		self.UMGVideoPlayer:SetPlayMovieEndCallBack(self, self.PlayMovieEnd)
		self.UMGVideoPlayer:OnRewind()
		self.UMGVideoPlayer:SetNoUIMode(true)
		self.UMGVideoPlayer:SetPreviewMode(true)
		UIUtil.SetIsVisible(self.UMGVideoPlayer, true)
		self:RegisterTimer(function()
			self.UMGVideoPlayer:SetVolume(false)
		end, 0.01, 0, 1)
	else
		self.UMGVideoPlayer:OnClose()
	end
end

function OpsSkateboardMainPanelView:OnHide()
	self.Super.OnHide(self)
	self.UMGVideoPlayer:OnClose()
end

function OpsSkateboardMainPanelView:SetBuyRewardShow()
	UIUtil.SetIsVisible(self.CommSlot, false)
	if not self.ViewModel then return end

	local RewardResID = self.ViewModel:GetBuyRewardItemID()
	if RewardResID then
		UIUtil.SetIsVisible(self.CommSlot, true)
		local ItemCfg = require("TableCfg/ItemCfg")
		local ItemUtil = require("Utils/ItemUtil")
		local Cfg = ItemCfg:FindCfgByKey(RewardResID) or {}
		local ImgPath = Cfg.IconID and ItemCfg.GetIconPath(Cfg.IconID) or ""
		self.CommSlot:SetIconImg(ImgPath)
		self.CommSlot:SetQualityImg(ItemUtil.GetItemColorIcon(RewardResID))
		UIUtil.SetIsVisible(self.CommSlot.IconChoose, false)
		UIUtil.SetIsVisible(self.CommSlot.RichTextLevel, false)
		UIUtil.SetIsVisible(self.CommSlot.RichTextQuantity, false)
	end
end

function OpsSkateboardMainPanelView:UpdateUIShow()
	local Activity = self.Params and self.Params.Activity or {}
	if self.ViewModel:GetActGoodsHasBought() then
		UIUtil.SetIsVisible(self.PanelPurchased, true)
		UIUtil.SetIsVisible(self.PanelNotPurchased, false)
	else
		UIUtil.SetIsVisible(self.PanelPurchased, false)
		UIUtil.SetIsVisible(self.PanelNotPurchased, true)
	end

	self.TextTitle:SetText(Activity.Title or "")
	self.RichTextInfo:SetText(Activity.SubTitle or "")
	local GoodsID = self.ViewModel:GetGoodsID()
	self.BtnRecommend:SetBtnPriceByGoodsID(GoodsID)
end

function OpsSkateboardMainPanelView:OnClickRebateTask()
	DataReportUtil.ReportActivityClickFlowData(self.Params.ActivityID, "3")
	UIViewMgr:ShowView(_G.UIViewID.OpsSkateboardRebatesWin, {ViewModel = self.ViewModel})
end

function OpsSkateboardMainPanelView:HideOtherView()
	if UIViewMgr:IsViewVisible(_G.UIViewID.StoreNewBuyWinPanel) then
		UIViewMgr:HideView(_G.UIViewID.StoreNewBuyWinPanel)
	end

	if UIViewMgr:IsViewVisible(_G.UIViewID.OpsSkateboardRebatesWin) then
		UIViewMgr:HideView(_G.UIViewID.OpsSkateboardRebatesWin)
	end
end

return OpsSkateboardMainPanelView