---
--- Author: guanjiewu
--- DateTime: 2024-01-11 14:50
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local MainVM = require("Game/LegendaryWeapon/VM/LegendaryWeaponMainPanelVM")
local LegendaryWeaponChapterCfg = require("TableCfg/LegendaryWeaponChapterCfg")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local EquipmentMgr = require("Game/Equipment/EquipmentMgr")
local ProtoCommon = require("Protocol/ProtoCommon")
local EventMgr = require("Event/EventMgr")
local BagMgr = _G.BagMgr
local UIViewMgr
local UIViewID
local ViewVM

---@class LegendaryWeaponMaterialPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field BtnInfor CommInforBtnView
---@field EquipTips LegendaryWeaponEquipTipsView
---@field ItemTips LegendaryWeaponItemTipsView
---@field PanelAtma UFCanvasPanel
---@field RootPanel UFCanvasPanel
---@field TableViewAtma UTableView
---@field TableViewMaterial UTableView
---@field TextAtma UFTextBlock
---@field TextMaterial UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LegendaryWeaponMaterialPageView = LuaClass(UIView, true)

function LegendaryWeaponMaterialPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.BtnInfor = nil
	--self.EquipTips = nil
	--self.ItemTips = nil
	--self.PanelAtma = nil
	--self.RootPanel = nil
	--self.TableViewAtma = nil
	--self.TableViewMaterial = nil
	--self.TextAtma = nil
	--self.TextMaterial = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LegendaryWeaponMaterialPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.BtnInfor)
	self:AddSubView(self.EquipTips)
	self:AddSubView(self.ItemTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LegendaryWeaponMaterialPageView:OnInit()
	UIViewMgr = _G.UIViewMgr
	UIViewID = _G.UIViewID
	ViewVM = _G.LegendaryWeaponMainPanelVM

	self.AdapterAtmaList = UIAdapterTableView.CreateAdapter(self, self.TableViewAtma)
	self.AdapterMaterialList = UIAdapterTableView.CreateAdapter(self, self.TableViewMaterial)

	if self.BtnInfor then
		self.BtnInfor.HelpInfoID = -1
		self.BtnInfor.Type = 4
	end
end

function LegendaryWeaponMaterialPageView:OnShow()
	self.TextAtma:SetText(LSTR(220009))	--"魂晶收集"
	self.TextMaterial:SetText(LSTR(220010))--"武器材料"
--	self:PlayAnimation(self.AnimIn)
end

function LegendaryWeaponMaterialPageView:OnHide()
	self:PlayAnimation(self.AnimOut)
end

function LegendaryWeaponMaterialPageView:Setup(bIsSpecial, ItemID)
	UIUtil.SetIsVisible(self.PanelAtma, self.ParentView.bHaveSpecial)
	self:UpdateAtmaList()
	self:UpdateNormalList()
	_G.EventMgr:SendEvent(EventID.LegendaryInnerMatClick, ItemID)
end

function LegendaryWeaponMaterialPageView:UpdateAtmaList()
	if self.ParentView.bHaveSpecial and nil ~= MainVM.ProfInfo then
		local WeaponCfg = MainVM.ProfInfo.WeaponCfg
		self.AtmaList = {}
		local TempList = WeaponCfg.SpecialItems
		for k,v in pairs(TempList) do
			if v.ResID ~= 0 then
				table.insert(self.AtmaList, v)
			end
		end
		self.AdapterAtmaList:UpdateAll(self.AtmaList)
	end
end

function LegendaryWeaponMaterialPageView:UpdateNormalList()
	if nil == MainVM.ProfInfo then
		return
	end
	local WeaponCfg = MainVM.ProfInfo.WeaponCfg
	self.ItemList = {}
	local TempList = WeaponCfg.ConsumeItems
	for k,v in pairs(TempList) do
		if v.ResID ~= 0 then
			table.insert(self.ItemList, v)
		end
	end
	self.AdapterMaterialList:UpdateAll(self.ItemList)
end

-- function LegendaryWeaponMaterialPageView:Show(flag)
-- 	UIUtil.SetIsVisible(self.RootPanel, flag)
-- end

function LegendaryWeaponMaterialPageView:OnRegisterUIEvent()
	if self.BtnInfor then
		self.BtnInfor:SetCallback(self.BtnInfor, self.OnClickedBtnInfor)
	end
	
	if self.BtnBack then
		self.BtnBack:AddBackClick(self, self.OnClickedBtnBack)
	end
end

function LegendaryWeaponMaterialPageView:OnClickedBtnInfor()
	if not MainVM then
		return
	end
	local ChapterID = MainVM.ChapterID
	for k, v in pairs(MainVM.ChapterList) do
		if v.ID == ChapterID then
			local SpecialItemsHelp = v.SpecialItemsHelp
			if string.isnilorempty(SpecialItemsHelp) then
				break
			end
			local MsgTipsUtil = require("Utils/MsgTipsUtil")
			MsgTipsUtil.ShowTips(SpecialItemsHelp)
			return
		end
	end
end

function LegendaryWeaponMaterialPageView:OnClickedBtnBack()
	self.ParentView:CloseMatPanel()
end

function LegendaryWeaponMaterialPageView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.LegendaryInnerMatClick, self.OnInnerMatClick)
--	self:RegisterGameEvent(EventID.LegendaryUpdateEquipTips, self.OnUpdateEquipTips)
end

function LegendaryWeaponMaterialPageView:OnRegisterBinder()

end

function LegendaryWeaponMaterialPageView:OnInnerMatClick(ResID)
	local EquipCfg = EquipmentCfg:FindCfgByEquipID(ResID)
	if EquipCfg ~= nil then
		UIUtil.SetIsVisible(self.ItemTips, false)
		UIUtil.SetIsVisible(self.EquipTips, true)
		-- 这里需要取到具体的那件装备
		local Equip = nil
		local Temp = EquipmentMgr:GetEquipedItemByPart((ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND))
		if Temp ~= nil and ResID == Temp.ResID then
			Equip = Temp
		end
		if Equip == nil then
			Temp = EquipmentMgr:GetEquipedItemByPart((ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND))
			if Temp ~= nil and ResID == Temp.ResID then
				Equip = Temp
			end
		end
		if Equip == nil then
			Temp = BagMgr:GetItemByResID(ResID)
			if ResID ~= nil then
				Equip = Temp
			end
		end
		if Equip == nil then
			Equip = {
				GID = -1,
				ResID = ResID,
			}
		end
		self.EquipTips:Setup(Equip)
	else
		UIUtil.SetIsVisible(self.ItemTips, true)
		UIUtil.SetIsVisible(self.EquipTips, false)
		self.ItemTips:Setup(ResID)
	end
end

return LegendaryWeaponMaterialPageView