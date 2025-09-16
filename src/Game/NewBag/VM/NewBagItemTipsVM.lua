local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local MenuBtnVM = require("Game/NewBag/VM/MenuBtnVM")
local BagMoreMenuConfig = require("Game/NewBag/VM/BagMoreMenuConfig")
local ItemUtil = require("Utils/ItemUtil")
local ProfUtil = require("Game/Profession/ProfUtil")
local MajorUtil = require("Utils/MajorUtil")
local EmotionMgr = require("Game/Emotion/EmotionMgr")
local EmotionDefines = require("Game/Emotion/Common/EmotionDefines")
local AnimationUtil = require("Utils/AnimationUtil")

local ProtoCommon = require("Protocol/ProtoCommon")
local ItemCfg = require("TableCfg/ItemCfg")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local ItemDefine = require("Game/Item/ItemDefine")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local BagTipsMoreMenu = ItemDefine.BagTipsMoreMenu
local ITEM_TYPE_DETAIL = ProtoCommon.ITEM_TYPE_DETAIL
local BtnState = {
	Done = 1,
	Disable = 2,
	Recommend = 3,
	Normal = 4,
}
---@class NewBagItemTipsVM : UIViewModel
local NewBagItemTipsVM = LuaClass(UIViewModel)

---Ctor
function NewBagItemTipsVM:Ctor()
	self.MoreBtnVisible = nil
	self.MorePanelVisible = nil
	self.GoBtnVisible = nil


	self.UseBtnVisible = nil
	self.EquipmentBtnEnabled = nil
	self.UseBtnEnabled = nil
	self.MenuBindableListItem = UIBindableList.New(MenuBtnVM)

	self.BtnReadVisible = false
	self.BtnReadEnabled = false

	self.BtnDropVisible = false
	self.BtnDropEnabled = false

	self.Value = nil
end

function NewBagItemTipsVM:UpdateVM(Value)
	self.Value = Value
	local ItemResID = Value.ResID
	local Cfg = ItemCfg:FindCfgByKey(ItemResID)
	if Cfg == nil then
		return
	end
	local MoreMenuList = {}
	self.BtnDropVisible = false
	self.MorePanelVisible = false
	if _G.BagMgr:TimeLimitItemExpired(Value) then
		self.BtnReadVisible = false
		self.GoBtnVisible = false
		self.UseBtnVisible = false
		self.BtnDropVisible = true
		self.BtnDropEnabled = true 
	elseif ItemUtil.CheckIsEquipment(Cfg.Classify) then
		self.GoBtnVisible = true
		self.UseBtnVisible = false
		self.BtnReadVisible = false
		self.EquipmentBtnEnabled = _G.EquipmentMgr:CanEquiped(ItemResID, false)
		local EquipCfg = EquipmentCfg:FindCfgByEquipID(ItemResID)
		if EquipCfg and EquipCfg.MateID > 0 then
			table.insert(MoreMenuList, BagMoreMenuConfig[BagTipsMoreMenu.Inlay])
		end
		local AppearanceID = WardrobeUtil.IsAppearanceByItemID(ItemResID)
		if AppearanceID and AppearanceID > 0 then
			if not _G.WardrobeMgr:GetIsUnlock(AppearanceID) or  _G.WardrobeMgr:IsLessReduceConditionEquipment(AppearanceID)then
				table.insert(MoreMenuList, BagMoreMenuConfig[BagTipsMoreMenu.Wardrobe])
			end
		end

		if _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDCompanySeal) then
			local IsImprove = _G.CompanySealMgr:EquipIsImprove(ItemResID)
			local IsInScheme = Value.Attr.Equip.IsInScheme
			local CarryList = Value.Attr.Equip.GemInfo.CarryList
			local HasCarry = false
			for _, value in pairs(CarryList) do
				if value then
					HasCarry = true
					break
				end
			end

			if EquipCfg then
				if EquipCfg.ExchangeCompanySealNum > 0 and not IsInScheme and not HasCarry and not IsImprove then
					table.insert(MoreMenuList, BagMoreMenuConfig[BagTipsMoreMenu.RareTask])
				end
			end
		end
	elseif ItemUtil.CheckIsTreasureMap(Cfg.ItemType) then --宝图
		if Cfg.UseFunc > 0 then  --未解读的宝图
			self.BtnReadVisible = true
			self.GoBtnVisible = false
			self.UseBtnVisible = false
			local mapID = _G.TreasureHuntMainVM:GetDecodeMapID(ItemResID)
			if mapID == nil then
                self.BtnReadEnabled = true 
			else 
                self.BtnReadEnabled = false 
			end
		else
			self.BtnReadVisible = false
			self.GoBtnVisible = false
			self.UseBtnVisible = true
			self.UseBtnEnabled = true
		end
	elseif ItemUtil.CheckIsAetherCurrentMachine(ItemResID) then
		self.BtnReadVisible = false
		self.GoBtnVisible = false
		self.UseBtnVisible = true
		self.UseBtnEnabled = true

	elseif Value.FreezeGroup == 6 then
		local MajorEntityID = MajorUtil.GetMajorEntityID()
		local PlayerAnimInst = AnimationUtil.GetPlayerAnimInst(MajorEntityID)
		if EmotionMgr.MajorCanUseType == EmotionDefines.CanUseTypes.SIT_GROUND or
			EmotionMgr.MajorCanUseType == EmotionDefines.CanUseTypes.RIDE or
			EmotionMgr.MajorCanUseType == EmotionDefines.CanUseTypes.SIT_CHAIR or
			(PlayerAnimInst and PlayerAnimInst.bUseBed) then
			self.BtnReadVisible = false
			self.GoBtnVisible = false
			self.UseBtnVisible = true
			self.UseBtnEnabled = false
		else
			self.BtnReadVisible = false
			self.GoBtnVisible = false
			self.UseBtnVisible = true
			self.UseBtnEnabled = true
		end
	elseif ItemResID == _G.UpgradeMgr:GetUpgradeItemID() then
		local Prof = MajorUtil.GetMajorProfID()
		if ProfUtil.IsCombatProf(Prof) then
			self.BtnReadVisible = false
			self.GoBtnVisible = false
			self.UseBtnVisible = true
			self.UseBtnEnabled = true
		else
			self.BtnReadVisible = false
			self.GoBtnVisible = false
			self.UseBtnVisible = true
			self.UseBtnEnabled = false
		end
	elseif ItemUtil.CheckIsMateria(Cfg.ItemType) then
		self.BtnReadVisible = false
		self.GoBtnVisible = false
		self.UseBtnVisible = true
		self.UseBtnEnabled = true
	else
		self.BtnReadVisible = false
		self.GoBtnVisible = false
		self.UseBtnVisible = true
		self.UseBtnEnabled = Cfg.ItemType ~= ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY and Cfg.UseFunc > 0
	end

	if ItemUtil.CheckIsAetheryteticket(Cfg.ItemType) then
		if not _G.BagMgr:ItemUseCondition({ResID = ItemResID}, nil, nil, true) 
		or MajorUtil.IsMajorDead() then
			self.UseBtnEnabled = false
		end
	end

	--这里红点有点不好塞，暂时拆开塞进去
	if _G.EquipmentMgr:CheckCanImprove(ItemResID) then	
		local MenuConfig = BagMoreMenuConfig[BagTipsMoreMenu.Improve]
		MenuConfig.bShowRedPoint = _G.EquipmentMgr:GetImproveMaterialEnough(ItemResID)
		table.insert(MoreMenuList, MenuConfig)
	end
	
	if Cfg.IsCanDrop == 1 then
		table.insert(MoreMenuList, BagMoreMenuConfig[BagTipsMoreMenu.Drop])
	end

	if Cfg.IsHQ == 1 then
		table.insert(MoreMenuList, BagMoreMenuConfig[BagTipsMoreMenu.Degradation])
	end

	self.MoreBtnVisible = #MoreMenuList > 0 and _G.BagMgr:TimeLimitItemExpired(Value) == false
	self.MenuBindableListItem:UpdateByValues(MoreMenuList)
end

--要返回当前类
return NewBagItemTipsVM