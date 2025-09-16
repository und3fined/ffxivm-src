---
--- Author: Administrator
--- DateTime: 2023-09-07 19:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local DepotExpandWinVM = require("Game/NewBag/VM/DepotExpandWinVM")
local UIAdapterToggleGroup = require("UI/Adapter/UIAdapterToggleGroup")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetCheckedIndex = require("Binder/UIBinderSetCheckedIndex")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local MAX_NAME_LENGTH = 8

local ScoreMgr = _G.ScoreMgr
local DepotMgr = _G.DepotMgr
local EventID = _G.EventID
local LSTR = _G.LSTR
---@class NewBagExpandSetWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field BtnCreate CommBtnLView
---@field FHorizontalConsume UFHorizontalBox
---@field ImgIcon UFImage
---@field InputBox CommInputBoxView
---@field Money1 CommMoneySlotView
---@field TextDefault UFTextBlock
---@field TextNew UFTextBlock
---@field TextNumber1 UFTextBlock
---@field ToggleGroupDynamic UToggleGroupDynamic
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewBagExpandSetWinView = LuaClass(UIView, true)

function NewBagExpandSetWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnCreate = nil
	--self.FHorizontalConsume = nil
	--self.ImgIcon = nil
	--self.InputBox = nil
	--self.Money1 = nil
	--self.TextDefault = nil
	--self.TextNew = nil
	--self.TextNumber1 = nil
	--self.ToggleGroupDynamic = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewBagExpandSetWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnCreate)
	self:AddSubView(self.InputBox)
	self:AddSubView(self.Money1)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewBagExpandSetWinView:OnInit()
	self.AdapterTabToggleGroup = UIAdapterToggleGroup.CreateAdapter(self, self.ToggleGroupDynamic)
	DepotExpandWinVM:UpdateIconList()
	self.InputBox:SetCallback(self, self.OnTextChangedName)
	self.InputBox:SetMaxNum(MAX_NAME_LENGTH)

	self.Binders = {

		{ "CostScoreText", UIBinderSetTextFormatForMoney.New(self, self.TextNumber1) },
		{ "CostScoreColor", UIBinderSetColorAndOpacityHex.New(self, self.TextNumber1) },
		{ "ScoreIconImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },

		{ "DepotIconBindableList", UIBinderUpdateBindableList.New(self, self.AdapterTabToggleGroup) },
		{ "CurrentIndex", UIBinderSetCheckedIndex.New(self, self.ToggleGroupDynamic) },
	}
	
end

function NewBagExpandSetWinView:OnDestroy()

end

function NewBagExpandSetWinView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.InputBox:SetText(string.format("%s%s", LSTR(990036), tostring(_G.DepotVM:GetCurDepotNum() + 1 )))
	DepotExpandWinVM:UpdateVM(Params.EnlargeID)
	
	self.Money1:UpdateView(DepotExpandWinVM.ScoreID, false, nil, true)
end

function NewBagExpandSetWinView:OnHide()

end

function NewBagExpandSetWinView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleGroupDynamic, self.OnToggleGroupStateChanged)
	UIUtil.AddOnClickedEvent(self, self.BtnCreate.Button, self.OnClickedExpand)
end

function NewBagExpandSetWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ScoreUpdate, self.OnMoneyUpdate)
end

function NewBagExpandSetWinView:OnRegisterBinder()
	self:RegisterBinders(DepotExpandWinVM, self.Binders)

	self.TextNew:SetText(LSTR(990064))
	self.TextDefault:SetText(LSTR(990065))
	self.BG:SetTitleText(LSTR(990071))
	self.BtnCreate:SetButtonText(LSTR(990075))
	self.InputBox:SetHintText(LSTR(990067))
end


function NewBagExpandSetWinView:OnToggleGroupStateChanged(ToggleGroup, ToggleButton, Index, State)
	DepotExpandWinVM:SetSelectedIcon(Index + 1)
end


function NewBagExpandSetWinView:OnClickedExpand()

	_G.JudgeSearchMgr:QueryTextIsLegal(self.InputBox:GetText(), function( IsLegal )
		if not IsLegal then
			_G.MsgTipsUtil.ShowTips(LSTR(10057)) 
			self.InputBox:SetText("")
		else
			local NeedCost = DepotExpandWinVM.CostScoreText
			local ScoreID = DepotExpandWinVM.ScoreID
			if NeedCost > ScoreMgr:GetScoreValueByID(ScoreID) then
				
				local CostName = ScoreMgr:GetScoreNameText(ScoreID) or ""
				_G.MsgBoxUtil.ShowMsgBoxTwoOp(
						self,
						LSTR(10004),
						string.format(LSTR(990037), CostName),
						function()
							-- 打开充值界面
							_G.RechargingMgr:ShowMainPanel()
							_G.RechargingMgr:OnChangedMainPanelCloseBtnToBack(true)
						end,
						nil,
						LSTR(10003),
						LSTR(10019)
				)
				return
			end
		
			local Type = DepotExpandWinVM.CurrentIndex
			local DepotName  = self.InputBox:GetText()
			DepotMgr:SendMsgDepotEnlarge(Type, DepotName)
			self:Hide()
		end
	end)

	
end

function NewBagExpandSetWinView:OnMoneyUpdate()
	local Params = self.Params
	if nil == Params then
		return
	end
	DepotExpandWinVM:UpdateVM(Params.EnlargeID)
end


return NewBagExpandSetWinView