--
-- Author: ZhengJianChuan
-- Date: 2024-03-07 15:21
-- Description:
--


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local WardrobeDefine = require("Game/Wardrobe/WardrobeDefine")
local WardrobeMgr = require("Game/Wardrobe/WardrobeMgr")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local MajorUtil = require("Utils/MajorUtil")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")
local ProfUtil = require("Game/Profession/ProfUtil")
local ProfMgr = require("Game/Profession/ProfMgr")
local ProtoRes = require("Protocol/ProtoRes")
local GlobalCfg = require("TableCfg/GlobalCfg")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local ClosetSuitCfg = require("TableCfg/ClosetSuitCfg")
local UIBindableList = require("UI/UIBindableList")
local WardrobeSuitItemVM = require("Game/Wardrobe/VM/Item/WardrobeSuitItem2VM")
local WardrobeSuitWinListVM  = require("Game/Wardrobe/VM/Item/WardrobeSuitWinListVM")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")
local ItemVM = require("Game/Item/ItemVM")
local LSTR

---@class WardrobeSuitWinVM : UIViewModel
local WardrobeSuitWinVM = LuaClass(UIViewModel)

---Ctor
function WardrobeSuitWinVM:Ctor()
	self.SuitList = UIBindableList.New(WardrobeSuitItemVM)
	self.EquipmentList = UIBindableList.New(WardrobeSuitWinListVM)
	self.IsCurAppUnlock = false
	self.CurEquipID = nil
	self.AppName = ""
	self.IsEmptyGetWay = false
	self.UnlockText = ""
	self.SuitListSelectedIndex = nil
	self.EquipmentListSelectedIndex = nil
	self.RedDotNameList = {}
end

function WardrobeSuitWinVM:OnInit()
end

function WardrobeSuitWinVM:OnBegin()
	LSTR = _G.LSTR
end

function WardrobeSuitWinVM:OnEnd()
end

function WardrobeSuitWinVM:OnShutdown()
	for _, name in ipairs(self.RedDotNameList) do
		_G.RedDotMgr:DelRedDotByName(name)
	end
	self.RedDotNameList = {}
end

function WardrobeSuitWinVM:UpdateSuitList(SuitID)
	self.SuitList:Clear()
	local Cfg = ClosetSuitCfg:FindCfgByKey(SuitID)
	if Cfg == nil then
		return
	end

	local ItemList1 = {}
	for i=1, 10, 1 do
		if Cfg.AppItems and next(Cfg.AppItems) then
			if Cfg.AppItems[i] ~= nil then
				local Data = {}
				local EquipID = Cfg.AppItems[i]
				local Cfg = EquipmentCfg:FindCfgByEquipID(EquipID)
				if Cfg ~= nil and Cfg.AppearanceID and Cfg.AppearanceID ~= 0 then
					Data.Index = i
					Data.AppID = Cfg.AppearanceID
					Data.EquipID = EquipID
					Data.IsEmpty = false
					table.insert(ItemList1, Data)
					if  WardrobeUtil.JudgeUnlockAppearanceWithouItem(Cfg.AppearanceID)  and not WardrobeMgr:GetIsUnlock(Cfg.AppearanceID)  then
						if self.RedDotNameList[Cfg.AppearanceID] == nil then
							Data.RedDotName = _G.RedDotMgr:AddRedDotByParentRedDotID(WardrobeDefine.RedDotList.WinList)
							self.RedDotNameList[Cfg.AppearanceID] = Data.RedDotName
						else
							Data.RedDotName = self.RedDotNameList[Cfg.AppearanceID]
						end
						Data.IsRed = true
					else
						if self.RedDotNameList[Cfg.AppearanceID] ~= nil then
							_G.RedDotMgr:DelRedDotByName( self.RedDotNameList[Cfg.AppearanceID])
							self.RedDotNameList[Cfg.AppearanceID] = nil
						end
						Data.IsRed = false
					end
				end
			else
				local Data = {}
				Data.Index = i
				Data.IsEmpty = true
				Data.EquipID = 0
				Data.IsRed = false
				table.insert(ItemList1, Data)
			end
		end
	end

	self.SuitList:UpdateByValues(ItemList1)
	self.SuitListSelectedIndex = 1
end
   
function WardrobeSuitWinVM:UpdateEquipmentList(AppID)
	self.EquipmentList:Clear()
	local ItemList1 = {}
	local IsSpecial =  WardrobeUtil.GetIsSpecial(AppID)
	if not IsSpecial then
		local List = WardrobeUtil.GetSameAppearanceEquipmentList(AppID)
		for _, equipID in ipairs(List) do
			local Data = {}
			Data.EquipID  = equipID
			table.insert(ItemList1, Data)
		end
	else
		local Data = {}
		Data.EquipID = WardrobeUtil.GetUnlockCostItemID(AppID)
		table.insert(ItemList1, Data)
	end

	self.EquipmentList:UpdateByValues(ItemList1)
	self.EquipmentListSelectedIndex = 1
end

function WardrobeSuitWinVM:UpdateUnlockText(AppID)
	self.UnlockText = WardrobeMgr:GetIsUnlock(AppID) and _G.LSTR(1080057) or _G.LSTR("前往解锁") 
end

function WardrobeSuitWinVM:UpdateGetWayList(ResID)
	local CommGetWayItems = ItemUtil.GetItemGetWayList(ResID) or {}
	if self.Params and self.Params.Alignment then
		for i, v in ipairs(CommGetWayItems) do
			CommGetWayItems[i].Alignment = self.Params.Alignment
			CommGetWayItems[i].Source = self.Source
		end
	end
	
	self.GetWayList:UpdateByValues(CommGetWayItems)
end

--要返回当前类
return WardrobeSuitWinVM