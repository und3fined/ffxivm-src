---
--- Author: shuangteng
--- DateTime: 2024-03-28 18:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local EquipmentMgr = require("Game/Equipment/EquipmentMgr")
local ActorMgr = require("Game/Actor/ActorMgr")
local LoginRoleRaceGenderVM = require("Game/LoginRole/LoginRoleRaceGenderVM")

---@class LoginFantasiaFinishWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BagSlot BagSlotView
---@field BtnNormal CommBtnLView
---@field BtnRecommend CommBtnLView
---@field Comm2FrameS Comm2FrameSView
---@field PanelConsume UFHorizontalBox
---@field TextContent URichTextBox
---@field TextContent2 URichTextBox
---@field TextNum URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginFantasiaFinishWinView = LuaClass(UIView, true)

function LoginFantasiaFinishWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BagSlot = nil
	--self.BtnNormal = nil
	--self.BtnRecommend = nil
	--self.Comm2FrameS = nil
	--self.PanelConsume = nil
	--self.TextContent = nil
	--self.TextContent2 = nil
	--self.TextNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginFantasiaFinishWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BagSlot)
	self:AddSubView(self.BtnNormal)
	self:AddSubView(self.BtnRecommend)
	self:AddSubView(self.Comm2FrameS)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginFantasiaFinishWinView:OnInit()

end

function LoginFantasiaFinishWinView:OnDestroy()

end

function LoginFantasiaFinishWinView:InitText()
	self.Comm2FrameS.FText_Title:SetText(_G.LSTR(980081))	--完成编辑
	self.BtnNormal:SetText(_G.LSTR(980087))	--取 消
	self.BtnRecommend:SetText(_G.LSTR(980088))	--确 认
	self.TextContent:SetText(_G.LSTR(980094))--确认要完成角色编辑吗？
	self.TextContent2:SetText(_G.LSTR(980095))--*编辑后无法穿戴的装备将通过邮件返还
	self.TextConsume:SetText(_G.LSTR(980096))--消耗：
end

function LoginFantasiaFinishWinView:OnShow()
	self:InitText()
	self.BagSlotVM = self.BagSlotVM or BagSlotVM.New()
	--幻想药道具ID
	local ItemID = 66700163
	local Item = ItemUtil.CreateItem(ItemID, 0)
	self.BagSlotVM:UpdateVM(Item, {IsShowNum = false})
	local HasNum = _G.BagMgr:GetItemNum(ItemID)
	local NeedNum = 1
	local ItemRichText = RichTextUtil.GetText(string.format("%d", HasNum), "d5d5d5", 0, nil)
	self.ItemNumberText = string.format("%s/%d", ItemRichText, NeedNum)
	self.TextNum:SetText(self.ItemNumberText)
	self.BagSlot:SetParams({Data = self.BagSlotVM})
	--根据装备是否还能穿决定要不要显示提示文字
	if self:CheckEquipmentCanWear() then
		UIUtil.SetIsVisible(self.TextContent2, false, false, false)
	else
		UIUtil.SetIsVisible(self.TextContent2, true, false, false)
	end
end

function LoginFantasiaFinishWinView:OnHide()

end

function LoginFantasiaFinishWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnNormal, self.OnCancelBtnClick)
	UIUtil.AddOnClickedEvent(self, self.BtnRecommend, self.OnConfirmBtnClick)
	UIUtil.AddOnClickedEvent(self, self.BagSlot.BtnSlot, self.OnBtnSlotClick)
end

function LoginFantasiaFinishWinView:OnRegisterGameEvent()

end

function LoginFantasiaFinishWinView:OnRegisterBinder()

end

--检查幻想药改变种族后，原有装备是否还能使用
---@return boolean
function LoginFantasiaFinishWinView:CheckEquipmentCanWear()
	local RoleDetail = ActorMgr:GetMajorRoleDetail()
	if not RoleDetail or not RoleDetail.Simple then
		return true
	end
	if not LoginRoleRaceGenderVM.CurrentRaceCfg then
		return true
	end
	--检查前，需要本地修改种族和性别信息
	local CachedGender = RoleDetail.Simple.Gender
	local CachedRace = RoleDetail.Simple.Race
	local CachedTribe = RoleDetail.Simple.Tribe

	local CurrentRaceCfg = LoginRoleRaceGenderVM.CurrentRaceCfg
	RoleDetail.Simple.Gender = CurrentRaceCfg.Gender
	RoleDetail.Simple.Race = CurrentRaceCfg.RaceID
	RoleDetail.Simple.Tribe = CurrentRaceCfg.Tribe

	--检查装备列表的装备是否可以穿
	local CanWear = true
    if RoleDetail.Equip and RoleDetail.Equip.EquipList then
		for _, Item in pairs(RoleDetail.Equip.EquipList) do
			local CanEquip = EquipmentMgr:CanEquiped(Item.ResID, false, RoleDetail.Simple.Prof, RoleDetail.Simple.Level)
			if not CanEquip then
				CanWear = false
				break
			end
		end
	end
	--检查后，需要还原
	RoleDetail.Simple.Gender = CachedGender
	RoleDetail.Simple.Race = CachedRace
	RoleDetail.Simple.Tribe = CachedTribe

	return CanWear
end

function LoginFantasiaFinishWinView:OnBtnSlotClick()	
	--幻想药道具ID
	local ItemID = 66700163
	ItemTipsUtil.ShowTipsByResID(ItemID, self.BagSlot)
end

function LoginFantasiaFinishWinView:OnCancelBtnClick()
	self:Hide()
end

function LoginFantasiaFinishWinView:OnConfirmBtnClick()
	_G.LoginUIMgr:OnConfirmFantasiaProfileUpdate()
end

return LoginFantasiaFinishWinView