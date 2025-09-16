---
--- Author: Administrator
--- DateTime: 2024-10-10 15:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local DiscoverNoteMgr = require("Game/SightSeeingLog/DiscoverNoteMgr")
local DiscoverNoteVM = require("Game/SightSeeingLog/DiscoverNoteVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local LSTR = _G.LSTR

---@class SightSeeingLogActChoosePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field PanelDescribe UFCanvasPanel
---@field TableViewLeft UTableView
---@field TableViewRight UTableView
---@field TextDescribe UFTextBlock
---@field TextTitle UFTextBlock
---@field TextTopTips UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SightSeeingLogActChoosePanelView = LuaClass(UIView, true)

function SightSeeingLogActChoosePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.PanelDescribe = nil
	--self.TableViewLeft = nil
	--self.TableViewRight = nil
	--self.TextDescribe = nil
	--self.TextTitle = nil
	--self.TextTopTips = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SightSeeingLogActChoosePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SightSeeingLogActChoosePanelView:InitConstStringInfo()
	self.TextTopTips:SetText(LSTR(330010))
	self.TextTitle:SetText(LSTR(330003))
end

function SightSeeingLogActChoosePanelView:OnInit()
	self.bEmotionSelecting = false -- 统一控制左右表情选择列表，防止同时点击
	self.AdapterTableViewLeft = UIAdapterTableView.CreateAdapter(self, self.TableViewLeft, self.OnLeftEmotionSelected)
	self.AdapterTableViewRight = UIAdapterTableView.CreateAdapter(self, self.TableViewRight, self.OnRightEmotionSelected)
	self.Binders = {
		{"LeftEmotionList", UIBinderUpdateBindableList.New(self, self.AdapterTableViewLeft)},
		{"RightEmotionList", UIBinderUpdateBindableList.New(self, self.AdapterTableViewRight)},
		{"ActNoteContentText", UIBinderSetText.New(self, self.TextDescribe)},
		{"ForceClosePanelByPointChange", UIBinderValueChangedCallback.New(self, nil, self.OnForceClosePanelByPointChange)},
	}
	self:InitConstStringInfo()
end

function SightSeeingLogActChoosePanelView:OnDestroy()

end

function SightSeeingLogActChoosePanelView:OnShow()

end

function SightSeeingLogActChoosePanelView:OnHide()

end

function SightSeeingLogActChoosePanelView:OnRegisterUIEvent()
	self.BtnClose:SetCallback(self, self.OnBtnCloseClicked)
end

function SightSeeingLogActChoosePanelView:OnRegisterGameEvent()

end

function SightSeeingLogActChoosePanelView:OnRegisterBinder()
	if not DiscoverNoteVM then
		return
	end

	self:RegisterBinders(DiscoverNoteVM, self.Binders)
end

function SightSeeingLogActChoosePanelView.OnBtnCloseClicked(View)
	if not View then
		return
	end

	_G.InteractiveMgr:ShowMainPanel()
	View:Hide()
end

function SightSeeingLogActChoosePanelView:OnLeftEmotionSelected(_, ItemData, _, _)
	self:OnEmotionItemSelected(ItemData)
end

function SightSeeingLogActChoosePanelView:OnRightEmotionSelected(_, ItemData, _, _)
	self:OnEmotionItemSelected(ItemData)
end

function SightSeeingLogActChoosePanelView:OnEmotionItemSelected(ItemData)
	if self.bEmotionSelecting then
		return
	end

	self.bEmotionSelecting = true

	if not ItemData then
		self.bEmotionSelecting = false
		return
	end

	local bLock = not ItemData.bGot
	if bLock then
		MsgTipsUtil.ShowTips(LSTR(330008))
		self.bEmotionSelecting = false
		return
	end

	local EmotionID = ItemData.EmotionID
	if not EmotionID then
		self.bEmotionSelecting = false
		return
	end

	DiscoverNoteMgr:PerfectEmotionInteractReq(DiscoverNoteVM.ActChooseNoteID, EmotionID)
	self.bEmotionSelecting = false
	self.OnBtnCloseClicked(self)
end

function SightSeeingLogActChoosePanelView:OnForceClosePanelByPointChange(NewValue, OldValue)
	if not NewValue then
		return
	end

	if NewValue == OldValue then
		return
	end


	MsgTipsUtil.ShowTips(LSTR(330021))

	self:Hide()
end

return SightSeeingLogActChoosePanelView