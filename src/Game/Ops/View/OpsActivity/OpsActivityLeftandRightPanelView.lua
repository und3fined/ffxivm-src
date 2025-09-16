---
--- Author: yutingzhan
--- DateTime: 2024-10-26 11:01
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

---@class OpsActivityLeftandRightPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnView OpsActivityPreviewBtnView
---@field ButtonMask UButton
---@field CommBtnGoto OpsCommBtnLView
---@field ImgLine UFImage
---@field PanelAward UFCanvasPanel
---@field ShareTips OpsActivityShareTipsItemView
---@field TableViewSlot UTableView
---@field TextInfo UFTextBlock
---@field TextPreview UFTextBlock
---@field TextSubTitle UFTextBlock
---@field TextTitle UFTextBlock
---@field Time OpsActivityTimeItemView
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsActivityLeftandRightPanelView = LuaClass(UIView, true)
local LSTR = _G.LSTR

function OpsActivityLeftandRightPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnView = nil
	--self.ButtonMask = nil
	--self.CommBtnGoto = nil
	--self.ImgLine = nil
	--self.PanelAward = nil
	--self.ShareTips = nil
	--self.TableViewSlot = nil
	--self.TextInfo = nil
	--self.TextPreview = nil
	--self.TextSubTitle = nil
	--self.TextTitle = nil
	--self.Time = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsActivityLeftandRightPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnView)
	self:AddSubView(self.CommBtnGoto)
	self:AddSubView(self.ShareTips)
	self:AddSubView(self.Time)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsActivityLeftandRightPanelView:OnInit()
	self.CommBtnGoto.Money = false
	self.CommBtnGoto.NotUnlock = false
	self.ViewModel = OpsActivityLeftandRightPanelVM.New()
	self.AwardTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot, self.OnClickedSelectMemberItem, true)
	self.Binders = {
        {"TextIntroduction", UIBinderSetText.New(self, self.TextInfo)},
		{"bShowTextIntroduction", UIBinderSetIsVisible.New(self, self.TextInfo)},
		{"bShowTextIntroduction", UIBinderSetIsVisible.New(self, self.ImgLine)},
        {"TextTitle", UIBinderSetText.New(self, self.TextTitle)},
		{"TextSubTitle", UIBinderSetText.New(self, self.TextSubTitle)},
		{"bShowSubTitle", UIBinderSetIsVisible.New(self, self.TextSubTitle)},
        {"AwardVMList", UIBinderUpdateBindableList.New(self, self.AwardTableViewAdapter)},
		{"bShowCommBtnGoto", UIBinderSetIsVisible.New(self, self.CommBtnGoto)},
		{"bShowTableViewSlot", UIBinderSetIsVisible.New(self, self.PanelAward)},
    }
end

function OpsActivityLeftandRightPanelView:OnDestroy()

end

function OpsActivityLeftandRightPanelView:OnShow()
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
		self.CommBtnGoto.BtnText = self.ViewModel.BtnContent
	end
end


function OpsActivityLeftandRightPanelView:OnHide()
end

function OpsActivityLeftandRightPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.CommBtnGoto.CommBtnL, self.OnCommBtnGotoClick)
	UIUtil.AddOnClickedEvent(self,  self.ButtonMask, self.OnButtonMaskClick)
end

function OpsActivityLeftandRightPanelView:OnRegisterGameEvent()

end

function OpsActivityLeftandRightPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function OpsActivityLeftandRightPanelView:OnCommBtnGotoClick()
	DataReportUtil.ReportActivityFlowData("ActivityPicClickFlow", self.Params.ActivityID, 1)
	OpsActivityMgr:Jump(self.ViewModel.JumpType, self.ViewModel.JumpParam)
end

function OpsActivityLeftandRightPanelView:OnButtonMaskClick()
	if not self.ViewModel.bShowCommBtnGoto then
		DataReportUtil.ReportActivityFlowData("ActivityPicClickFlow", self.Params.ActivityID, 1)
		OpsActivityMgr:Jump(self.ViewModel.JumpType, self.ViewModel.JumpParam)
	end
end

function OpsActivityLeftandRightPanelView:OnClickedSelectMemberItem(Index, ItemData, ItemView)
	if ItemData == nil or ItemData.ItemID == nil then
		return
	end
	ItemTipsUtil.ShowTipsByResID(ItemData.ItemID, ItemView, nil, nil, 30)
end

function OpsActivityLeftandRightPanelView:SetTextColor()
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


return OpsActivityLeftandRightPanelView