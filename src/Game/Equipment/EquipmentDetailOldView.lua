---
--- Author: enqingchen
--- DateTime: 2021-12-27 15:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterToggleGroup = require("UI/Adapter/UIAdapterToggleGroup")
local RichTextUtil = require("Utils/RichTextUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

local EquipmentVM = require("Game/Equipment/VM/EquipmentVM")
local EquipmentMgr = _G.EquipmentMgr
local EquipmentDetailVM = require("Game/Equipment/VM/EquipmentDetailOldVM")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

local MsgBoxUtil = _G.MsgBoxUtil
local MsgBoxTitle = nil

---@class EquipmentDetailView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn_CraftInfo UFButton
---@field Btn_CraftInfo_1 UFButton
---@field Btn_QuickMagicspar UFButton
---@field Btn_QuickRequire UFButton
---@field Button UFCanvasPanel
---@field ClassValue URichTextBox
---@field DetailTableView UTableView
---@field FBtn_More UFButton
---@field FBtn_Right Comm2BtnLView
---@field FImg_Slot01 UFImage
---@field FImg_Slot02 UFImage
---@field FImg_Slot03 UFImage
---@field FImg_Slot04 UFImage
---@field FImg_Slot05 UFImage
---@field Img_Quality UFImage
---@field Img_Tips UFImage
---@field InlayAttri UTableView
---@field JobType URichTextBox
---@field LevelNumber URichTextBox
---@field Magicspar UFCanvasPanel
---@field MoreFilterTips UFCanvasPanel
---@field MsgTips UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field ScrollBox UScrollBox
---@field Text_Attri01 UFTextBlock
---@field Text_Attri02 UFTextBlock
---@field Text_Attri03 UFTextBlock
---@field Text_Attri04 UFTextBlock
---@field Text_Attri05 UFTextBlock
---@field Text_Attri06 UFTextBlock
---@field Text_EquipName UFTextBlock
---@field Text_EquipType UFTextBlock
---@field Text_WeaponAttri UFTextBlock
---@field ToggleGroupDynamicItem UToggleGroupDynamic
---@field UI_Attri_Icon_Bind UFImage
---@field UI_Attri_Icon_Only UFImage
---@field AnimMoreIn UWidgetAnimation
---@field AnimUpdate UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentDetailView = LuaClass(UIView, true)

function EquipmentDetailView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn_CraftInfo = nil
	--self.Btn_CraftInfo_1 = nil
	--self.Btn_QuickMagicspar = nil
	--self.Btn_QuickRequire = nil
	--self.Button = nil
	--self.ClassValue = nil
	--self.DetailTableView = nil
	--self.FBtn_More = nil
	--self.FBtn_Right = nil
	--self.FImg_Slot01 = nil
	--self.FImg_Slot02 = nil
	--self.FImg_Slot03 = nil
	--self.FImg_Slot04 = nil
	--self.FImg_Slot05 = nil
	--self.Img_Quality = nil
	--self.Img_Tips = nil
	--self.InlayAttri = nil
	--self.JobType = nil
	--self.LevelNumber = nil
	--self.Magicspar = nil
	--self.MoreFilterTips = nil
	--self.MsgTips = nil
	--self.PopUpBG = nil
	--self.ScrollBox = nil
	--self.Text_Attri01 = nil
	--self.Text_Attri02 = nil
	--self.Text_Attri03 = nil
	--self.Text_Attri04 = nil
	--self.Text_Attri05 = nil
	--self.Text_Attri06 = nil
	--self.Text_EquipName = nil
	--self.Text_EquipType = nil
	--self.Text_WeaponAttri = nil
	--self.ToggleGroupDynamicItem = nil
	--self.UI_Attri_Icon_Bind = nil
	--self.UI_Attri_Icon_Only = nil
	--self.AnimMoreIn = nil
	--self.AnimUpdate = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentDetailView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.FBtn_Right)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentDetailView:OnInit()
	self.ViewModel = EquipmentDetailVM.New()
	self.MoreToggleGroup = UIAdapterToggleGroup.CreateAdapter(self, self.ToggleGroupDynamicItem)
	self.InlayAttriTableView = UIAdapterTableView.CreateAdapter(self, self.InlayAttri, nil, false)
	self.InlayAttriTableView:SetScrollbarIsVisible(false)
	self.DetailAdapterTableView = UIAdapterTableView.CreateAdapter(self, self.DetailTableView, nil, false)
	self.DetailAdapterTableView:SetScrollbarIsVisible(false)
end

function EquipmentDetailView:OnDestroy()

end

function EquipmentDetailView:OnShow()
	if nil ~= self.Params and nil ~= self.Params.ContainerView then
		UIUtil.AdjustTipsPosition(self.MsgTips, self.Params.ContainerView, self.Params.ViewOffset)
		self.PopUpBG.HideOnClick = true
	else
		self.PopUpBG.HideOnClick = false
	end

	self.bMoreFilterTipsShow = false
	UIUtil.SetIsVisible(self.MoreFilterTips, false)
	self.ViewModel:GenMoreBtnList()
end

function EquipmentDetailView:OnHide()
	
end

function EquipmentDetailView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FBtn_Right.Button, self.OnRightBtnClick)
	UIUtil.AddOnClickedEvent(self, self.FBtn_More, self.OnMoreBtnClick)
	UIUtil.AddOnClickedEvent(self, self.Btn_QuickMagicspar, self.OnMagicsparClick)
	UIUtil.AddOnClickedEvent(self, self.Btn_QuickRequire, self.OnRequireClick)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleGroupDynamicItem, self.OnMoreToggleGroupClick)
end

function EquipmentDetailView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.EquipRepairSucc, self.OnEquipRepairSucc)
	self:RegisterGameEvent(_G.EventID.MagicsparInlaySucc, self.OnInlaySucc)
	self:RegisterGameEvent(_G.EventID.MagicsparUnInlaySucc, self.OnUnInlaySucc)
end

function EquipmentDetailView:OnRegisterBinder()
	if nil ~= self.Params and nil ~= self.Params.ViewModel then
		self.ViewModel = self.Params.ViewModel
	end

	local Binders = {
		{ "EquipmentName", UIBinderSetText.New(self, self.Text_EquipName) },
		{ "EquipmentTypeName", UIBinderSetText.New(self, self.Text_EquipType) },
		{ "ItemLevel", UIBinderValueChangedCallback.New(self, nil, self.OnItemLevelChange) },
		{ "RightBtnText", UIBinderValueChangedCallback.New(self, nil, self.OnRightBtnTextChange) },
		{ "IsBind", UIBinderSetIsVisible.New(self, self.UI_Attri_Icon_Bind) },
		{ "IsOnly", UIBinderSetIsVisible.New(self, self.UI_Attri_Icon_Only) },
		{ "bEnableRightBtn", UIBinderValueChangedCallback.New(self, nil, self.OnEnableRightBtnChange)},
		{ "lstEquipmentMoreFilterItemVM", UIBinderUpdateBindableList.New(self, self.MoreToggleGroup) },
		{ "ProfText", UIBinderSetText.New(self, self.JobType) },
		{ "Grade", UIBinderSetTextFormat.New(self, self.LevelNumber, _G.LSTR(1050002)) },
		{ "GradeColor", UIBinderSetColorAndOpacityHex.New(self, self.LevelNumber) },
		{ "lstAttrMsg", UIBinderValueChangedCallback.New(self, nil, self.OnAttrMsgChange) },
		{ "lstMagicsparInlayStatusItemVM", UIBinderUpdateBindableList.New(self, self.InlayAttriTableView) },
		{ "lstEquipmentAttrItemVM", UIBinderUpdateBindableList.New(self, self.DetailAdapterTableView) },
		{ "bDetailUpdated", UIBinderValueChangedCallback.New(self, nil, self.OnDetailUpdatedChanged) },

		{ "bCanInlayMagicspar", UIBinderSetIsVisible.New(self, self.InlayAttri) },
		{ "bCanInlayMagicspar", UIBinderSetIsVisible.New(self, self.Magicspar) },
		{ "bCanInlayMagicspar", UIBinderSetIsVisible.New(self, self.Btn_QuickMagicspar, false, true) },

		{ "bIsMajor", UIBinderSetIsVisible.New(self, self.Button)},
		{ "bIsMajor", UIBinderSetIsVisible.New(self, self.Btn_QuickMagicspar, false, true)},
		{ "bIsMajor", UIBinderSetIsVisible.New(self, self.Btn_QuickRequire, false, true)},
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function EquipmentDetailView:SetRightBtnEnable(bEnable)
	if bEnable then
		self.FBtn_Right.TextButton:SetColorAndOpacity(self.FBtn_Right.TextRawColorAndOpacity)
		UIUtil.SetIsVisible(self.FBtn_Right.Eff,true,false)
		self.FBtn_Right:PlayColorAnimation()
	else
		UIUtil.SetIsVisible(self.FBtn_Right.Eff,false,false)
		self.FBtn_Right:StopAllAnimations()
		UIUtil.TextBlockSetColorAndOpacityHex(self.FBtn_Right.TextButton,"#a1a1a1")
		UIUtil.ImageSetColorAndOpacity(self.FBtn_Right.FImg_Btn,1,1,1,1)
	end
end

function EquipmentDetailView:OnEnableRightBtnChange(bEnable)
	-- self.FBtn_Right:SetIsEnable(bEnable)
	self:SetRightBtnEnable(bEnable)
end

function EquipmentDetailView:OnRightBtnClick()
	local bCanEquip = self.ViewModel.bCanEquip
	if bCanEquip == false then
		MsgTipsUtil.ShowTips(LSTR(1050064))
		return
	end

	local bEquiped = self.ViewModel.bEquiped
	local lstEquipInfo = {{Part = self.ViewModel.Part, GID = self.ViewModel.GID}}

	if bEquiped then
		--卸载
		if not self.ViewModel.bEnableRightBtn then
			MsgTipsUtil.ShowTips(LSTR(1050015))
			return
		end
		EquipmentMgr:SendEquipOff(lstEquipInfo)
	else
		local func = function ()
			EquipmentMgr:SendEquipOn(lstEquipInfo)
		end

		local ProtoRes = require("Protocol/ProtoRes")
		if _G.LoginMgr:IsModuleSwitchOn(ProtoRes.module_type.MODULE_VERIFY) then -- 提审版本不做二次确认
			func()
			return
		end
		local ConditionA = self.ViewModel.IsBind	--判断条件A：B装备是否绑定， 绑定=true
		
		--装备或者替换
		--若A为空装备，则只需要判断装备B是否是绑定的，二次确认如下：【B装备为可交易装备，替换后将永久绑定，请问是否替换？】
		if self.ViewModel:HasEquipedItem() == false then
			if ConditionA == false then
				MsgBoxUtil.ShowMsgBoxTwoOp(self, MsgBoxTitle, _G.LSTR(1050009), func)
			else
				func()
			end
			return
		end

		local ConditionC = self.ViewModel.CompareLevel >= 0	--判断条件C：B装等是否大于A B>=A = true

-- 		若A装备没有魔晶石，则只需要判断B是否是绑定的以及B的装等，	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　
-- 　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　
-- 　	　	B非绑定，B装等小于A：	【B装备为可交易装备（品级低于当前），替换后将永久绑定，请问是否替换？】	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　
-- 　	　	B非绑定，B装等大于等于A：	【B装备为可交易装备，替换后将永久绑定，请问是否替换？】	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　
-- 　	　	B绑定，B装等小于A：	【当前新装备品级低于原装备，请问是否继续替换？】	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　	　
-- 　	　	B绑定，B装等大于等于A：	无提示，直接替换
		if self.ViewModel:EquipedItemHasMagicsparInlayed() == false then
			if ConditionA == false and ConditionC == false then
				MsgBoxUtil.ShowMsgBoxTwoOp(self, MsgBoxTitle, _G.LSTR(1050008), func)
				return
			end

			if ConditionA == false and ConditionC == true then
				MsgBoxUtil.ShowMsgBoxTwoOp(self, MsgBoxTitle, _G.LSTR(1050009), func)
				return
			end

			if ConditionA == true and ConditionC == false then
				MsgBoxUtil.ShowMsgBoxTwoOp(self, MsgBoxTitle, _G.LSTR(1050067), func)
				return
			end

			if ConditionA == true and ConditionC == true then
				func()
				return
			end

			func()
			return
		end

		local ConditionB = self.ViewModel.bHasMagicspar	--判断条件B：B装备是否镶嵌魔晶石，已镶嵌=true
		local ConditionD = true

		if ConditionA == true and ConditionB == true and ConditionC == true and ConditionD == true then
			MsgBoxUtil.ShowMsgBoxTwoOp(self, MsgBoxTitle, _G.LSTR(1050089), func)
			return
		end

		if ConditionA == true and ConditionB == true and ConditionC == true and ConditionD == false then
			MsgBoxUtil.ShowMsgBoxTwoOp(self, MsgBoxTitle, _G.LSTR(1050093), func)
			return
		end

		if ConditionA == true and ConditionB == true and ConditionC == false and ConditionD == true then
			MsgBoxUtil.ShowMsgBoxTwoOp(self, MsgBoxTitle, _G.LSTR(1050088), func)
			return
		end

		if ConditionA == true and ConditionB == true and ConditionC == false and ConditionD == false then
			MsgBoxUtil.ShowMsgBoxTwoOp(self, MsgBoxTitle, _G.LSTR(1050093), func)
			return
		end

		if ConditionA == true and ConditionB == false and ConditionC == true and ConditionD == true then
			func()
			return
		end

		if ConditionA == true and ConditionB == false and ConditionC == false and ConditionD == true then
			MsgBoxUtil.ShowMsgBoxTwoOp(self, MsgBoxTitle, _G.LSTR(1050067), func)
			return
		end

		if ConditionA == false and ConditionB == true and ConditionC == true and ConditionD == true then
			MsgBoxUtil.ShowMsgBoxTwoOp(self, MsgBoxTitle, _G.LSTR(1050011), func)
			return
		end

		if ConditionA == false and ConditionB == true and ConditionC == true and ConditionD == false then
			MsgBoxUtil.ShowMsgBoxTwoOp(self, MsgBoxTitle, _G.LSTR(1050010), func)
			return
		end

		if ConditionA == false and ConditionB == true and ConditionC == false and ConditionD == true then
			MsgBoxUtil.ShowMsgBoxTwoOp(self, MsgBoxTitle, _G.LSTR(1050011), func)
			return
		end

		if ConditionA == false and ConditionB == true and ConditionC == false and ConditionD == false then
			MsgBoxUtil.ShowMsgBoxTwoOp(self, MsgBoxTitle, _G.LSTR(1050010), func)
			return
		end

		if ConditionA == false and ConditionB == false and ConditionC == true and ConditionD == true then
			MsgBoxUtil.ShowMsgBoxTwoOp(self, MsgBoxTitle, _G.LSTR(1050011), func)
			return
		end

		if ConditionA == false and ConditionB == false and ConditionC == true and ConditionD == false then
			MsgBoxUtil.ShowMsgBoxTwoOp(self, MsgBoxTitle, _G.LSTR(1050010), func)
			return
		end

		if ConditionA == false and ConditionB == false and ConditionC == false and ConditionD == true then
			MsgBoxUtil.ShowMsgBoxTwoOp(self, MsgBoxTitle, _G.LSTR(1050011), func)
			return
		end

		if ConditionA == false and ConditionB == false and ConditionC == false and ConditionD == false then
			MsgBoxUtil.ShowMsgBoxTwoOp(self, MsgBoxTitle, _G.LSTR(1050010), func)
			return
		end

		func()
	end
end

function EquipmentDetailView:ToOriginState()
	self.ScrollBox:ScrollToStart()
end

function EquipmentDetailView:OnItemLevelChange()
	if self.ViewModel.CompareLevel == 0 then
		self.ClassValue:SetText(string.format("%d", self.ViewModel.ItemLevel))
	elseif self.ViewModel.CompareLevel > 0 then
		local CompareText = RichTextUtil.GetText(string.format("%d", math.abs(self.ViewModel.CompareLevel)), "00FD2BFF")
		self.ClassValue:SetText(string.format("%d(+%s)", self.ViewModel.ItemLevel, CompareText))
	else
		local CompareText = RichTextUtil.GetText(string.format("%d", math.abs(self.ViewModel.CompareLevel)), "f80003ff")
		self.ClassValue:SetText(string.format("%d(-%s)", self.ViewModel.ItemLevel, CompareText))
	end
end

function EquipmentDetailView:OnRightBtnTextChange()
	self.FBtn_Right:SetText(self.ViewModel.RightBtnText)
end

function EquipmentDetailView:OnAttrMsgChange()
	if self.ViewModel.lstAttrMsg == nil then
		return
	end
	--属性
	local bArmRatio = self.ViewModel.bHasWeaponArmRatio == true
	UIUtil.SetIsVisible(self.Text_WeaponAttri, bArmRatio)
	UIUtil.SetIsVisible(self.Text_Attri05, not bArmRatio)
	UIUtil.SetIsVisible(self.Text_Attri06, not bArmRatio)
	if bArmRatio then
		self.Text_WeaponAttri:SetText(self.ViewModel.lstAttrMsg[1])
	end
	local Offset = bArmRatio and 1 or 0
	for i = 1, 6 do
		local Text_Attri = self["Text_Attri0"..i]
		if Text_Attri ~= nil then
			if self.ViewModel.lstAttrMsg[i+Offset] ~= nil then
				Text_Attri:SetText(self.ViewModel.lstAttrMsg[i+Offset])
			else
				Text_Attri:SetText("")
			end
		end
	end
end

function EquipmentDetailView:OnDetailUpdatedChanged(bDetailUpdated)
	if bDetailUpdated then
		self:PlayAnimation(self.AnimUpdate)
		self.ViewModel.bDetailUpdated = false
	end
end

function EquipmentDetailView:OnMoreBtnClick()
	if self.bMoreFilterTipsShow == true then
		UIUtil.SetIsVisible(self.MoreFilterTips, false)
		self.bMoreFilterTipsShow = false
	else
		UIUtil.SetIsVisible(self.MoreFilterTips, true)
		self:PlayAnimation(self.AnimMoreIn)
		self.bMoreFilterTipsShow = true
	end
end

function EquipmentDetailView:OnEquipRepairSucc(Params)
	for _,GID in pairs(Params) do
		if GID == self.ViewModel.GID then
			self.ViewModel:UpdateDetail()
		end
	end
end

function EquipmentDetailView:OnMoreToggleGroupClick(ToggleGroupServer, ToggleButton, Index, State)
	if self.bMoreFilterTipsShow == false then
		return
	end

	UIUtil.SetIsVisible(self.MoreFilterTips, false)
	self.bMoreFilterTipsShow = false
	if Index == 0 then
		--UIViewMgr:ShowView(UIViewID.MagicsparInlay, {GID = self.ViewModel.GID})
		--UIViewMgr:ShowView(UIViewID.MagicsparInlayMainPanel, {GID = self.ViewModel.GID})
		local Param = {GID = self.ViewModel.GID, ResID =self.ViewModel.ResID}
	    _G.EquipmentMgr:TryInlayMagicspar(Param)
	elseif Index == 1 then
		EquipmentMgr:OpenEquipmentRepair(self.ViewModel.GID)
	end
end

function EquipmentDetailView:OnRequireClick()
	EquipmentMgr:OpenEquipmentRepair(self.ViewModel.GID)
end

function EquipmentDetailView:OnMagicsparClick()
	--UIViewMgr:ShowView(UIViewID.MagicsparInlay, {GID = self.ViewModel.GID})
	--UIViewMgr:ShowView(UIViewID.MagicsparInlayMainPanel, {GID = self.ViewModel.GID})
	local Param = {GID = self.ViewModel.GID, ResID =self.ViewModel.ResID}
	_G.EquipmentMgr:TryInlayMagicspar(Param)
end

function EquipmentDetailView:OnInlaySucc(Params)
	if (Params.GID == self.ViewModel.GID) then
		self.ViewModel:UpdateMagicsparInfo()
	end
end

function EquipmentDetailView:OnUnInlaySucc(Params)
	if (Params.GID == self.ViewModel.GID) then
		self.ViewModel:UpdateMagicsparInfo()
	end
end

return EquipmentDetailView