---
--- Author: Administrator
--- DateTime: 2024-06-04 15:00
--- Description:
---特效获取item

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local ArmyDefine = require("Game/Army/ArmyDefine")
local ArmyBonusStateGetType = ArmyDefine.ArmyBonusStateGetType
local ArmyTextColor = ArmyDefine.ArmyTextColor
local ArmyMgr
local UIViewMgr
local UIViewID
---@class ArmySpecialEffectsItem04View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBuy CommBtnSView
---@field BtnTips UFButton
---@field BtnUse CommBtnSView
---@field ImgIcon UFImage
---@field ImgPriceIcon UFImage
---@field PanelBtn02 UFCanvasPanel
---@field PanelUnlock UFCanvasPanel
---@field TextGrade UFTextBlock
---@field TextHave UFTextBlock
---@field TextPrice UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmySpecialEffectsItem04View = LuaClass(UIView, true)

function ArmySpecialEffectsItem04View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBuy = nil
	--self.BtnTips = nil
	--self.BtnUse = nil
	--self.ImgIcon = nil
	--self.ImgPriceIcon = nil
	--self.PanelBtn02 = nil
	--self.PanelUnlock = nil
	--self.TextGrade = nil
	--self.TextHave = nil
	--self.TextPrice = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmySpecialEffectsItem04View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBuy)
	self:AddSubView(self.BtnUse)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmySpecialEffectsItem04View:OnInit()
	ArmyMgr = require("Game/Army/ArmyMgr")
	UIViewMgr = _G.UIViewMgr
	UIViewID = _G.UIViewID
    self.Binders = {
        {"IsGrey", UIBinderValueChangedCallback.New(self, nil, self.OnSetGrey)}, 
		{"IsUsed", UIBinderValueChangedCallback.New(self, nil, self.OnSetUsed)}, 
        {"GetType", UIBinderValueChangedCallback.New(self, nil, self.OnSetGetType)}, 
        {"IsPremission", UIBinderValueChangedCallback.New(self, nil, self.OnSetIsPremission)}, 
		{"IsUnlock", UIBinderSetIsVisible.New(self, self.PanelUnlock, true)}, 
		{"IsUnlock", UIBinderSetIsVisible.New(self, self.PanelBtn02)}, 
		{"bUsed", UIBinderSetIsVisible.New(self, self.BtnUse)}, 
		{"Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon)}, 
		{"Grade", UIBinderSetText.New(self, self.TextGrade)}, 
		{"CostStr", UIBinderSetText.New(self, self.TextPrice)}, 
		{"HaveStr", UIBinderSetText.New(self, self.TextHave)}, 
    }
end

function ArmySpecialEffectsItem04View:OnDestroy()

end

function ArmySpecialEffectsItem04View:OnShow()

end

function ArmySpecialEffectsItem04View:OnHide()

end

function ArmySpecialEffectsItem04View:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBuy, self.OnClickedBuy)
    --UIUtil.AddOnClickedEvent(self, self.BtnGet, self.OnClickedLookTrends)
	UIUtil.AddOnClickedEvent(self, self.BtnUse, self.OnClickedUse)
	UIUtil.AddOnClickedEvent(self, self.BtnTips, self.OnClickedTips)
end

function ArmySpecialEffectsItem04View:OnRegisterGameEvent()

end

function ArmySpecialEffectsItem04View:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	self:RegisterBinders(self.ViewModel, self.Binders)
end

---设置灰态
function ArmySpecialEffectsItem04View:OnSetGrey(IsGrey)
	local Color
	if not IsGrey then
		Color = "FFFFFFFF"
	else
		Color = "AEAEAEFF"
	end
	UIUtil.SetColorAndOpacityHex(self.ImgIcon, Color)
end

---设置已使用
function ArmySpecialEffectsItem04View:OnSetUsed(IsUsed)
	if IsUsed then
		-- LSTR string:停止使用
		self.BtnUse:SetText(LSTR(910047))
	else
		-- LSTR string:使用
		self.BtnUse:SetText(LSTR(910040))
	end
end


function ArmySpecialEffectsItem04View:OnSetGetType(GetType)
	if GetType == ArmyBonusStateGetType.Buy then
		UIUtil.SetIsVisible(self.ImgPriceIcon, true)
		-- LSTR string:购买
		self.BtnBuy:SetText(LSTR(910235))
	elseif GetType == ArmyBonusStateGetType.AetherWheel then
		UIUtil.SetIsVisible(self.ImgPriceIcon, false)
		-- LSTR string:获取
		self.BtnBuy:SetText(LSTR(910211))
	end
end

---设置无权限
function ArmySpecialEffectsItem04View:OnSetIsPremission(IsPremission)
	if IsPremission then
		self.BtnUse:SetIsNormalState(true)
		self.BtnBuy:SetIsNormalState(true)
	else
		self.BtnUse:SetIsDisabledState(true, true)
		self.BtnBuy:SetIsDisabledState(true, true)
	end
end

function ArmySpecialEffectsItem04View:OnClickedBuy()
	if self.ViewModel then
		if not self.ViewModel.IsPremission then
			-- LSTR string:无部队特效编辑权限
			MsgTipsUtil.ShowTips(LSTR(910151))
		elseif self.ViewModel.GetType == ArmyBonusStateGetType.Buy then
			local Params = {}
			Params.ID = self.ViewModel.ID
			--Params.BuyCallBack = self.BuyBonusState
			--Params.Owner = self
			Params.Name = self.ViewModel.Name
			Params.Desc = self.ViewModel.Desc
			Params.Cost = self.ViewModel.Cost
			Params.Icon = self.ViewModel.Icon
			--Params.IsPremission = self.ViewModel.IsPremission
			UIViewMgr:ShowView(UIViewID.ArmySEBuyWin, Params)
		elseif self.ViewModel.GetType == ArmyBonusStateGetType.AetherWheel then
			-- LSTR string:尚未拥有以太转轮
			MsgTipsUtil.ShowTips(LSTR(910101))
		end
	end
end

function ArmySpecialEffectsItem04View:OnClickedTips()
	if self.ViewModel then
		if self.ViewModel:GetGetType() == ArmyBonusStateGetType.UnOpen or self.ViewModel.UnLockLv == nil then
			-- LSTR string:敬请期待
			MsgTipsUtil.ShowTips( LSTR(910147))
		elseif self.ViewModel.UnLockLv then
			-- LSTR string:部队等级
			MsgTipsUtil.ShowTips(string.format("%s%d%s", LSTR(910260), self.ViewModel.UnLockLv, LSTR(910199)))
		end
	end
end
-- --- 购买处理
-- function ArmySpecialEffectsItem04View:BuyBonusState(ID, Num)
--     ArmyMgr:SendGroupBonusStateBuy(ID, Num)
-- end

--- 停用处理
function ArmySpecialEffectsItem04View:StopBonusState(ID)
	if self.ViewModel and not self.ViewModel.IsPremission  then
		-- LSTR string:无部队特效编辑权限
		MsgTipsUtil.ShowTips(LSTR(910151))
		return
	end
	local Index = self.ViewModel.UsedIndex
	if Index and Index ~= 0 then
    	ArmyMgr:SendGroupBonusStateStop(ID, Index)
	end
end

--- 使用处理
function ArmySpecialEffectsItem04View:UseBonusState(ID)
	if self.ViewModel and not self.ViewModel.IsPremission  then
		-- LSTR string:无部队特效编辑权限
		MsgTipsUtil.ShowTips(LSTR(910151))
		return
	end
	ArmyMgr:UseGroupBonusState(ID)
end

function ArmySpecialEffectsItem04View:OnClickedUse()
	if self.ViewModel then
		if not self.ViewModel.IsPremission then
			-- LSTR string:无部队特效编辑权限
			MsgTipsUtil.ShowTips(LSTR(910151))
		elseif self.ViewModel.IsUsed then
			local StopStr = RichTextUtil.GetText(self.ViewModel.Name, ArmyTextColor.YellowHex)
			-- LSTR string:是否停用
			StopStr = string.format("%s%s%s",LSTR(910153), StopStr, LSTR(910176))
			MsgBoxUtil.ShowMsgBoxTwoOp(
				self,
				-- LSTR string:停用特效
				LSTR(910050),
				StopStr,
				function()
					self:StopBonusState(self.ViewModel.ID)
				end,
				nil,
				-- LSTR string:取消
				LSTR(910083),
				-- LSTR string:确定
				LSTR(910182)
			)
		else
			self:UseBonusState(self.ViewModel.ID)
		end
	end
end

return ArmySpecialEffectsItem04View