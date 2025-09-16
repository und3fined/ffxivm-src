---
--- Author: Administrator
--- DateTime: 2024-05-30 10:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local SidePopUpMainBagVM = require("Game/SidePopUp/VM/SidePopUpMainBagVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIViewID = require("Define/UIViewID")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local ProtoRes = require("Protocol/ProtoRes")
local SidepopupCfg = require("TableCfg/SidepopupCfg")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ProtoCommon = require("Protocol/ProtoCommon")
local ItemCfg = require("TableCfg/ItemCfg")
local TimeUtil = require("Utils/TimeUtil")

local SidePopUpMgr = _G.SidePopUpMgr

---@class SidePopUpMainBagWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BagSlot_UIBP BagSlotView
---@field BtnClose UFButton
---@field EFF_ProBarLight UFImage
---@field EquipInfo UFHorizontalBox
---@field FTextBlock_146 UFTextBlock
---@field IconLock UFImage
---@field ImgArrow UFImage
---@field ImgBg UFImage
---@field ProBarCD UProgressBar
---@field SidePopUpBtn SidePopUpBtnItemView
---@field SizeBox USizeBox
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimProBar UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SidePopUpMainBagWinView = LuaClass(UIView, true)

function SidePopUpMainBagWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BagSlot_UIBP = nil
	--self.BtnClose = nil
	--self.EFF_ProBarLight = nil
	--self.EquipInfo = nil
	--self.FTextBlock_146 = nil
	--self.IconLock = nil
	--self.ImgArrow = nil
	--self.ImgBg = nil
	--self.ProBarCD = nil
	--self.SidePopUpBtn = nil
	--self.SizeBox = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimProBar = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SidePopUpMainBagWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BagSlot_UIBP)
	self:AddSubView(self.SidePopUpBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SidePopUpMainBagWinView:OnInit()
	self.Binders = {
		{ "CDProgressPercent", UIBinderSetPercent.New(self, self.ProBarCD) },
		{ "ItemName", UIBinderSetText.New(self, self.TextTitle)},
		{ "bShowEquipInfo", UIBinderSetIsVisible.New(self, self.EquipInfo)},
		{ "bLock", UIBinderSetIsVisible.New(self, self.IconLock)},
		{ "PromoteValue", UIBinderSetTextFormat.New(self, self.FTextBlock_146, "%d" ) },
		{ "ActionName", UIBinderSetText.New(self, self.SidePopUpBtn.TextContent)},
		{ "CanntEquip", UIBinderSetIsVisible.New(self, self.SidePopUpBtn.ImgAsh)},
	
	}
end

function SidePopUpMainBagWinView:OnDestroy()

end

function SidePopUpMainBagWinView:OnShow()
	local Params = self.Params
	if Params == nil then
		return
	end
	self.IsClickedWear = false
	--UIUtil.SetIsVisible(self.EFF_ProBarLight, false)
	self:PlayAnimationTimeRange(self.AnimProBar, 0 , 0.1, 1, nil, 0.1, false)
	SidePopUpMainBagVM:UpdateVM(Params)
end

function SidePopUpMainBagWinView:OnHide()
	_G.UIViewMgr:HideView(UIViewID.ItemTips)
	_G.UIViewMgr:HideView(UIViewID.CommGetWayTipsView)
	_G.UIViewMgr:HideView(UIViewID.ItemTipsStatus)
end

function SidePopUpMainBagWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClose, self.OnClickButtonClose)
	UIUtil.AddOnClickedEvent(self, self.BagSlot_UIBP.BtnSlot, self.OnClickedItem)
	UIUtil.AddOnClickedEvent(self, self.SidePopUpBtn.Btn, self.OnClickedAction)
end

function SidePopUpMainBagWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.SidePopUpUpdateTime, self.OnEventSidePopUpUpdateTime)
	self:RegisterGameEvent(EventID.MajorProfSwitch, self.OnMajorProfSwitch)
	self:RegisterGameEvent(EventID.EquipUpdate, self.OnEquipUpdate)
	self:RegisterGameEvent(EventID.BagUseItemSucc, self.OnBagUseItemSucc)
end

function SidePopUpMainBagWinView:OnRegisterBinder()
	self:RegisterBinders(SidePopUpMainBagVM, self.Binders)
	self.BagSlot_UIBP:SetParams({Data = SidePopUpMainBagVM.BagSlotVM})
end


function SidePopUpMainBagWinView:OnEventSidePopUpUpdateTime()
	local EndTime = SidePopUpMgr:GetDisplayedEndTime(ProtoRes.side_popup_type.SIDE_POPUP_EASY_USE)
    local CDTime = SidepopupCfg:FindCfgByKey(ProtoRes.side_popup_type.SIDE_POPUP_EASY_USE).ShowTime

    if CDTime == 0 or EndTime == 0 then
        return
    end

	local Percent = (EndTime - TimeUtil.GetServerTime())/CDTime
	if Percent == SidePopUpMainBagVM.CDProgressPercent then
		return
	end
	self:PlayAnimationTimeRange(self.AnimProBar, 1 - Percent, 1 - Percent + 0.1, 1, nil, 0.1, false)
	SidePopUpMainBagVM.CDProgressPercent = Percent
	
end

function SidePopUpMainBagWinView:OnMajorProfSwitch()
	local Params = self.Params
	if nil == Params then return end

	SidePopUpMainBagVM:UpdateCanEquip(Params.ResID)
end

function SidePopUpMainBagWinView:OnClickButtonClose()
	SidePopUpMgr:RemoveSidePopUp(UIViewID.SidePopUpEasyUse)
end

function SidePopUpMainBagWinView:OnClickedItem()
	if self:GetIsHiding() then
		return
	end
	local Params = self.Params
	if nil == Params then return end
	if Params and Params.ResID and Params.ResID > 0 then
		ItemTipsUtil.ShowTipsByItem(Params, self.ImgBg)
	end
end

function SidePopUpMainBagWinView:OnClickedAction()
	local Params = self.Params
	if nil == Params then return end

	local ECfg = EquipmentCfg:FindCfgByKey(Params.ResID)
	if ECfg ~= nil then
		if SidePopUpMainBagVM.CanntEquip == true then
			_G.MsgTipsUtil.ShowTips(_G.LSTR(1020059))
			return
		end
		local MajorUtil = require("Utils/MajorUtil")
		if MajorUtil.IsMajorDead() then
			_G.MsgTipsUtil.ShowTips(_G.LSTR(1020060))
			return
		end
		--检查穿戴条件
		if not _G.EquipmentMgr:CheckCanOperate(LSTR(1050178), true) then
			return
		end

		local ActorUtil = require("Utils/ActorUtil")
		local MajorEntityID = MajorUtil.GetMajorEntityID()
		local bIsCombat = ActorUtil.IsCombatState(MajorEntityID)
		if bIsCombat then
			_G.MsgTipsUtil.ShowTips(_G.LSTR(1020061))
			return
		end

		local Part = ECfg.Part
		if ECfg.Part == ProtoCommon.equip_part.EQUIP_PART_FINGER then
			local EquipedLevel = 0
			local LeftEquipedItem = _G.EquipmentMgr:GetEquipedItemByPart(ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER)
			local RightEquipedItem = _G.EquipmentMgr:GetEquipedItemByPart(ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER)
			Part = ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER
			if LeftEquipedItem then
				local EquipedItemCfg = ItemCfg:FindCfgByKey(LeftEquipedItem.ResID)
				if EquipedItemCfg then
					EquipedLevel = EquipedItemCfg.ItemLevel
				end
			end
	
			if RightEquipedItem then
				local EquipedItemCfg = ItemCfg:FindCfgByKey(RightEquipedItem.ResID)
				if EquipedItemCfg and EquipedLevel > EquipedItemCfg.ItemLevel then
					Part = ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER
				end
			else
				Part = ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER
			end
		end
		local lstEquipInfo = {{Part = Part, GID = Params.GID}}
		if not self.IsClickedWear then
			self.IsClickedWear = true
			_G.EquipmentMgr:SendEquipOn(lstEquipInfo)
		end
		
	else
		_G.BagMgr:UseItemNoCD(Params.GID, nil)
		SidePopUpMgr:RemoveSidePopUp(UIViewID.SidePopUpEasyUse)
	end
end

function SidePopUpMainBagWinView:OnEquipUpdate()
	local Params = self.Params
	if nil == Params then return end

	local Item, Part = _G.EquipmentMgr:GetEquipedItemByGID(Params.GID)
	if Item ~= nil then
		SidePopUpMgr:RemoveSidePopUp(UIViewID.SidePopUpEasyUse)
	end
end

function SidePopUpMainBagWinView:OnBagUseItemSucc(Params)
	if nil == Params then return end

	if self.Params and self.Params.ResID == Params.ResID then
		SidePopUpMgr:RemoveSidePopUp(UIViewID.SidePopUpEasyUse)
	end
end


return SidePopUpMainBagWinView