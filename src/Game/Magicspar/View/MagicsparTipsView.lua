---
--- Author: jamiyang
--- DateTime: 2025-02-25 11:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local ItemUtil = require("Utils/ItemUtil")
local MagicsparRuleCfg = require("TableCfg/MagicsparRuleCfg")
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local ItemGetaccesstypeCfg = require("TableCfg/ItemGetaccesstypeCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local MagicsparDefine = require("Game/Magicspar/MagicsparDefine")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MajorUtil = require("Utils/MajorUtil")

---@class MagicsparTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewList UTableView
---@field TextContent UFTextBlock
---@field TextContent2 UFTextBlock
---@field TextGetWay UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MagicsparTipsView = LuaClass(UIView, true)

function MagicsparTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewList = nil
	--self.TextContent = nil
	--self.TextContent2 = nil
	--self.TextGetWay = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MagicsparTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MagicsparTipsView:OnInit()
	self.MagicsparGetWayAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnMagicsparGetWaySelect, true, false)
end

function MagicsparTipsView:OnDestroy()

end

function MagicsparTipsView:OnShow()
	self.MateID = nil
	self.TextGetWay:SetText(_G.LSTR(1060020))
	self.TextContent:SetText(_G.LSTR(1060031))
end

function MagicsparTipsView:OnHide()

end

function MagicsparTipsView:OnRegisterUIEvent()

end

function MagicsparTipsView:OnRegisterGameEvent()

end

function MagicsparTipsView:OnRegisterBinder()

end

function MagicsparTipsView:OnMagicsparGetWaySelect(Index, ItemData, ItemView)
	if nil == ItemData then
		return
	end

	if not ItemData.IsUnLock then
		MsgTipsUtil.ShowTips(_G.LSTR(1060043))
		return
	end

	if ItemData.IsRedirect == 0 then --跳转状态为0不跳转
		return
	end
	ItemUtil.JumpGetWayByItemData(ItemData)
end

function MagicsparTipsView:UpdateTipsData(MateID, bNomal)
	if bNomal == false then
		self.TextGetWay:SetText(_G.LSTR(1060046))
	else
		self.TextGetWay:SetText(_G.LSTR(1060020))
	end
	if MateID == self.MateID then
		return
	end
	local GetwayContent = ""
	local RuleCfg = MagicsparRuleCfg:FindCfgByKey(MateID)
	if RuleCfg then
		local lstAttr = RuleCfg.Attr
		for index, value in ipairs(lstAttr) do
			local Name = MagicsparDefine.MagicsparAttrName[value]
			if index >1 then
				Name = _G.LSTR(1060042) .. Name
			end
			GetwayContent = GetwayContent .. Name
		end
		self.TextContent2:SetText(GetwayContent)
		-- 获取方式
		local EquipProperty = RuleCfg.EquipProperty
		local ClassLimit = RuleCfg.ClassLimit
		local ClientGlobal = nil
		if EquipProperty == ProtoCommon.equip_property.EQUIP_PROPERTY_BATTLE then
			-- 战斗职业装备
			ClientGlobal = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_BATTLE_PROF_MAGICSPAR_GETWAY)
		elseif EquipProperty == ProtoCommon.equip_property.EQUIP_PROPERTY_PRODUCT and
		       ClassLimit == ProtoCommon.class_type.CLASS_TYPE_EARTHMESSENGER then
			-- 采集职业装备
			ClientGlobal = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_GATHER_PROF_MAGICSPAR_GETWAY)
		else
			-- 生产职业装备
			ClientGlobal = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CRAFTER_PROF_MAGICSPAR_GETWAY)
		end
		if ClientGlobal then
			local CommGetWayItems = {}
			local UnLockIndex = 1
			local GetwayList = ClientGlobal.Value
			local CurMajorLevel = MajorUtil ~= nil and MajorUtil.GetMajorLevel() or 0
			for _, value in ipairs(GetwayList) do
				local Cfg = ItemGetaccesstypeCfg:FindCfgByKey(value)
				if Cfg ~= nil then
					local ViewParams = {ID = Cfg.ID, FunDesc = Cfg.FunDesc, ItemID = nil, MajorLevel = CurMajorLevel, FunIcon = Cfg.FunIcon, ItemAccessFunType = Cfg.FunType, UnLockLevel = Cfg.UnLockLevel, IsRedirect = Cfg.IsRedirect, FunValue = Cfg.FunValue, RepeatJumpTipsID = Cfg.RepeatJumpTipsID, UnLockTipsID = Cfg.UnLockTipsID}
					if (ViewParams.UnLockLevel == nil or ViewParams.MajorLevel == nil or ViewParams.UnLockLevel <= ViewParams.MajorLevel) and ItemUtil.QueryIsUnLock(ViewParams.ItemAccessFunType, ViewParams.FunValue, ViewParams.ItemID) then --等级限制
						ViewParams.IsUnLock = true
					else
						ViewParams.IsUnLock = false
					end
					if ViewParams.IsUnLock and Cfg.SpoilerCondition and Cfg.SpoilerCondition ~= 0 then
						ViewParams.CanRevealPlot = ItemUtil.QueryIsCanRevealPlot(ViewParams.ItemAccessFunType, Cfg.SpoilerCondition)
						ViewParams.SpoilerTipsDesc = Cfg.SpoilerTipsDesc
					else
						ViewParams.CanRevealPlot = true
					end
					if ViewParams.IsUnLock then
						table.insert(CommGetWayItems, UnLockIndex, ViewParams)
						UnLockIndex = UnLockIndex + 1
					else
						if Cfg.NotRedirectHide == 0 then
							table.insert(CommGetWayItems,ViewParams)
						end
					end
				end
			end
			self.MagicsparGetWayAdapter:UpdateAll(CommGetWayItems)
		end
	end
	self.MateID = MateID
end

return MagicsparTipsView