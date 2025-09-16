local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ItemCfg = require("TableCfg/ItemCfg")
local FuncCfg = require("TableCfg/FuncCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local ClosetSuitCfg = require("TableCfg/ClosetSuitCfg")
local CondCfg = require("TableCfg/CondCfg")
local MajorUtil = require("Utils/MajorUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local EventID = require("Define/EventID")
local ObjectGCType = require("Define/ObjectGCType")

local UIViewID = _G.UIViewID
local UIViewMgr = _G.UIViewMgr
local PreviewMgr = LuaClass(MgrBase)

function PreviewMgr:Ctor()
	self.IsPreLoadViewBgmBp = false
	self.CompanionSceneActorPath = "Class'/Game/UI/Render2D/Companion/BP_Render2DPreviewCompanion.BP_Render2DPreviewCompanion_C'"
	self.MountSceneActorPath = "Class'/Game/UI/Render2D/Mount/Bp_Reder2DForPreviewMount.Bp_Reder2DForPreviewMount_C'"
end

function PreviewMgr:OnInit()
end

function PreviewMgr:OnBegin()

end

function PreviewMgr:OnEnd()
end

function PreviewMgr:OnShutdown()
	self.IsPreLoadViewBgmBp = false
end

function PreviewMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventEnterWorld)
end

function PreviewMgr:OnRegisterNetMsg()
end

function PreviewMgr:OnGameEventEnterWorld(Params)
    if self.IsPreLoadViewBgmBp then
		return
	end

	local DelayShowTime = 0.2 -- 延时一帧预加载预览背景(穿帮问题)，防止进地图峰值卡顿
	self:RegisterTimer(function()
		self.IsPreLoadViewBgmBp = true
		_G.ObjectMgr:LoadClassAsync(self.CompanionSceneActorPath,nil, ObjectGCType.LRU, nil)
		_G.ObjectMgr:LoadClassAsync(self.MountSceneActorPath,nil, ObjectGCType.LRU, nil)
	end, DelayShowTime)
end

--打开预览界面
---@param ItemResID number 物品ID/套装表ID(散件是物品表ID、套装则是[衣橱表]中的套装表ID)
function PreviewMgr:OpenPreviewView(ItemResID)
	if ItemResID == nil then 
		FLOG_INFO("PreviewMgr:OpenPreviewView ItemResID=nil");
		return 
	end

	FLOG_INFO("PreviewMgr:OpenPreviewView ItemResID=%d", ItemResID);
	local FindItemCfg = ItemCfg:FindCfgByKey(ItemResID)
	local TempSuitCfg = ClosetSuitCfg:FindCfgByKey(ItemResID)

	--套装
	if (FindItemCfg == nil and TempSuitCfg ~= nil) then
		self:OnShowRoleApperanceViewForSuit(TempSuitCfg)
		return
	end

	if FindItemCfg == nil then
		FLOG_INFO("PreviewMgr:OpenPreviewView FindItemCfg is nil, ItemResID=%d", ItemResID);
		return
	end

	--预览坐骑、宠物
	if FindItemCfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_MOUNT or 
	FindItemCfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_MINION then
		local FindFuncCfg = FuncCfg:FindCfgByKey(FindItemCfg.UseFunc)
		if FindFuncCfg == nil then return end
		local ResID = FindFuncCfg.Func[1].Value[1]
		if ResID == nil then return end

		if FindItemCfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_MOUNT then
			UIViewMgr:ShowView(UIViewID.PreviewMountView,{ MountId = ResID })
			--预览埋点
			DataReportUtil.ReportPreviewFlowData("PreviewFlow", 1, ItemResID, 1)
		elseif FindItemCfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_MINION then
			UIViewMgr:ShowView(UIViewID.PreviewCompanionView, { CompanionId = ResID })
			--预览埋点
			DataReportUtil.ReportPreviewFlowData("PreviewFlow", 1, ItemResID, 2)
		end
		return
	end

	--- 预览时装散件、装备
	if (FindItemCfg.ItemMainType == ProtoCommon.ItemMainType.ItemArmor) or 
	(FindItemCfg.ItemMainType == ProtoCommon.ItemMainType.ItemAccessory) or 
	(FindItemCfg.ItemMainType == ProtoCommon.ItemMainType.ItemArm) or 
	(FindItemCfg.ItemMainType == ProtoCommon.ItemMainType.ItemTool) or 
	(FindItemCfg.ItemMainType == ProtoCommon.ItemMainType.ItemCollage and FindItemCfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_FASHION) or 
	(FindItemCfg.ItemMainType == ProtoCommon.ItemMainType.ItemCollage and FindItemCfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_COIFFURE) then 
		self:OnShowRoleApperanceViewEquip(ItemResID)
		return
	end

	FLOG_INFO("PreviewMgr:OpenPreviewView not a preview item type, ItemResID=%d", ItemResID);
end

--- 显示时装预览界面--套装
function PreviewMgr:OnShowRoleApperanceViewForSuit(TempSuitCfg)
	FLOG_INFO("PreviewMgr:OnShowRoleAppearancePanelByType TempSuitCfg.id=%d", TempSuitCfg.ID);
	local EquipData = {}
	--- 套装
	local MajorGender = MajorUtil:GetMajorGender() -- 主角性别
	local Items = {}
	--- 套装表中配的是[装备表]中的装备ID，获取装备的ItemData
	for _, value in ipairs(TempSuitCfg.AppItems) do
		-- local TempID = WardrobeUtil.GetWeaponEquipIDByAppearanceID(value)
		local TempItemCfg = self:GetItemCfgByEquipmentID(value)
		if value ~= 0 then
			table.insert(Items, TempItemCfg)
		end
	end
	if table.is_nil_empty(Items) then
		return
	end
	EquipData.IsPreviewSuit = true
	EquipData.Name = TempSuitCfg.SuitName
	EquipData.Items = Items
	EquipData.IsMajorSameGender = true
	if TempSuitCfg.GenderLimit ~= 0 then
		if TempSuitCfg.GenderLimit ~= MajorGender then
			EquipData.IsMajorSameGender = false
		end
	end
	_G.PreviewRoleAppearanceVM:UpdateViewDataByPreView(EquipData)
	UIViewMgr:ShowView(UIViewID.PreviewRoleAppearanceView)

	--预览埋点
	DataReportUtil.ReportPreviewFlowData("PreviewFlow", 1, TempSuitCfg.ID, (EquipData.IsPreviewSuit and 3 or 4))
end

--- 显示时装预览界面--散件、装备
---@param ItemResID number 物品ID/套装表ID(散件是物品表ID、套装则是[衣橱表]中的套装表ID)
function PreviewMgr:OnShowRoleApperanceViewEquip(ItemResID)
	FLOG_INFO("PreviewMgr:OnShowRoleApperanceViewEquip, ItemResID=%d", ItemResID);
	local EquipData = {}
	--- 套装
	local MajorGender = MajorUtil:GetMajorGender() -- 主角性别
	local Items = {}
	local TempItemCfg = self:GetItemCfg(ItemResID)
	if TempItemCfg == nil then
		FLOG_INFO("PreviewMgr:OnShowRoleAppearancePanelByType TempItemCfg is nil, TempItemCfg.id=%d", ItemResID);
		return
	end

	EquipData.IsPreviewSuit = false
	EquipData.Name = TempItemCfg.Name
	table.insert(Items, TempItemCfg)
	EquipData.Items = Items
	--是否与主角同性别
	EquipData.IsMajorSameGender = true
	if TempItemCfg.UseCond ~= 0 then
		local TempCondCfg = CondCfg:FindCfgByKey(TempItemCfg.UseCond)
		if TempCondCfg ~= nil and #TempCondCfg.Cond > 0 then
			local CondData1 = TempCondCfg.Cond[1]
			if #CondData1.Value > 0 then
				local EquipGender = CondData1.Value[1]
				if MajorGender ~= EquipGender then
					EquipData.IsMajorSameGender = false
				end
			end
		end
	end
	_G.PreviewRoleAppearanceVM:UpdateViewDataByPreView(EquipData)
	UIViewMgr:ShowView(UIViewID.PreviewRoleAppearanceView)

	--预览埋点
	DataReportUtil.ReportPreviewFlowData("PreviewFlow", 1, ItemResID, (EquipData.IsPreviewSuit and 3 or 4))
end

function PreviewMgr:GetItemCfg(ID)
	local TempItemCfg = ItemCfg:FindCfgByKey(ID)
	if TempItemCfg == nil then
		FLOG_ERROR("PreviewMgr GetItemCfg ID is nil"..ID)
		return
	end

	local ItemData = {
		Name = TempItemCfg.ItemName,
		IconID = TempItemCfg.IconID,
		Classify = TempItemCfg.Classify,
		ItemColor = TempItemCfg.ItemColor,
		ItemID = TempItemCfg.ItemID,
		ItemType = TempItemCfg.ItemType,
		EquipmentID = TempItemCfg.EquipmentID,
		UseCond = TempItemCfg.UseCond,
	}

	--装备传过来的就是EquipmentID(非时装)
	if (TempItemCfg.ItemMainType == ProtoCommon.ItemMainType.ItemArmor) or 
	(TempItemCfg.ItemMainType == ProtoCommon.ItemMainType.ItemAccessory) or 
	(TempItemCfg.ItemMainType == ProtoCommon.ItemMainType.ItemArm) or 
	(TempItemCfg.ItemMainType == ProtoCommon.ItemMainType.ItemTool) then
		ItemData.EquipmentID = ID
	end
	return ItemData
end

function PreviewMgr:GetItemCfgByEquipmentID(EquipmentID)
	local SearchConditions = string.format("EquipmentID = %d", EquipmentID)
	local Cfg = ItemCfg:FindCfg(SearchConditions)
	return Cfg
end

return PreviewMgr