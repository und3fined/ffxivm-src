---
--- Author: chriswang
--- DateTime: 2021-11-02 15:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local GatherNoteCfg = require("TableCfg/GatherNoteCfg")
local ColorUtil = require("Utils/ColorUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIViewID = require("Define/UIViewID")
local FLOG_INFO = _G.FLOG_INFO

---@class FunctionGatherItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FBtn_Function UFButton
---@field FImg_Func UFImage
---@field FImg_Normal UFImage
---@field FImg_Select UFImage
---@field Text_GetRate UFTextBlock
---@field Text_HQGetRate UFTextBlock
---@field Text_Level UFTextBlock
---@field Text_Name UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FunctionGatherItemView = LuaClass(UIView, true)

function FunctionGatherItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FBtn_Function = nil
	--self.FImg_Func = nil
	--self.FImg_Normal = nil
	--self.FImg_Select = nil
	--self.Text_GetRate = nil
	--self.Text_HQGetRate = nil
	--self.Text_Level = nil
	--self.Text_Name = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FunctionGatherItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FunctionGatherItemView:OnInit()
	self:SetActive(false)	--是否激活
	-- UIUtil.SetIsVisible(self.FImg_Select, false)

end

function FunctionGatherItemView:OnDestroy()

end

function FunctionGatherItemView:OnShow()
	if nil == self.Params then return end

	local Data = self.Params.Data
	if nil == Data then return end

	self:FillFunction(Data)
end

function FunctionGatherItemView:OnHide()

end

function FunctionGatherItemView:OnRegisterUIEvent()
	-- UIUtil.AddOnHoveredEvent(self, self.FBtn_Function, self.OnHovered, nil)
	-- UIUtil.AddOnUnhoveredEvent(self, self.FBtn_Function, self.OnUnhovered, nil)
end

function FunctionGatherItemView:OnRegisterGameEvent()
    -- self:RegisterGameEvent(EventID.HideFunctionItemView, self.OnHideFunctionItemView)
	self:RegisterGameEvent(_G.EventID.Major_Attr_Change, self.OnMajorAttrChange)

end

function FunctionGatherItemView:OnRegisterBinder()

end

-- function FunctionGatherItemView:OnHideFunctionItemView(EntityID)
-- 	if EntityID == self.FunctionItem.EntityID then
-- 		UIUtil.SetIsVisible(self, false)
-- 	end
-- end

-- function FunctionGatherItemView:OnHovered()
-- 	UIUtil.SetIsVisible(self.FImg_Select, true)
-- 	UIUtil.SetIsVisible(self.FImg_Normal, false)
-- end

-- function FunctionGatherItemView:OnUnhovered()
-- 	UIUtil.SetIsVisible(self.FImg_Select, false)
-- 	UIUtil.SetIsVisible(self.FImg_Normal, true)
-- end

function FunctionGatherItemView:FillFunction(FunctionItem)
	if nil ~= self.UIEventRegister then
		self.UIEventRegister:UnRegisterAll()
	end

	UIUtil.AddOnClickedEvent(self, self.FBtn_Function, self.OnClicked, FunctionItem)
	local NoteCfg = GatherNoteCfg:FindCfgByItemID(FunctionItem.ResID)

	self.FunctionItem = FunctionItem

	-- FLOG_INFO("Interactive FillFunction EntityID: " .. self.FunctionItem.EntityID .. " ItemView:" .. tostring(self))

	local GatherItemCfg = ItemCfg:FindCfgByKey(FunctionItem.ResID)
	if NoteCfg and GatherItemCfg then
		local LinearColor = ColorUtil.GetLinearColor(GatherItemCfg.ItemColor)
		ColorUtil.SetQualityByLinearColor(LinearColor, self.Text_Name)
		ColorUtil.SetQualityByLinearColor(LinearColor, self.FImg_Quality)

		local ItemNoteInfo = FunctionItem.FuncParams.ItemNoteInfo

		self.Text_Name:SetText(ItemCfg:GetItemName(FunctionItem.ResID))
		self.Text_Level:SetText(string.format(_G.LSTR(90024), NoteCfg.GatheringGrade))

		local CurAcquisitionAttr = _G.UE.UMajorUtil.GetAttrValue(ProtoCommon.attr_type.attr_gathering)
		local CurInsightAttr = _G.UE.UMajorUtil.GetAttrValue(ProtoCommon.attr_type.attr_perception)
		if CurAcquisitionAttr >= NoteCfg.MinAcquisition and CurInsightAttr >= NoteCfg.MinInsight then
			if ItemNoteInfo.CommonGatherRate > 0 then
				self.Text_GetRate:SetText(string.format("%d%%", math.floor(ItemNoteInfo.CommonGatherRate / 100)))
			else
				self.Text_GetRate:SetText("-%")
			end

			if ItemNoteInfo.HQGatherRate > 0 then
				self.Text_HQGetRate:SetText(string.format("%d%%", math.floor(ItemNoteInfo.HQGatherRate / 100)))
			else
				self.Text_HQGetRate:SetText("-%")
			end
		else
			self.Text_GetRate:SetText("-%")
			self.Text_HQGetRate:SetText("-%")
		end

		-- if Cfg.IsCollection and Cfg.IsCollection == 1 then
		if ItemNoteInfo.FirstGather then
			UIUtil.SetIsVisible(self.Tag_Collect, true)
			-- UIUtil.ImageSetBrushFromAssetPath(self.FImg_Normal, "Texture2D'/Game/UI/Texture/Collect/UI_Collect_Img_Blue.UI_Collect_Img_Blue'")
		else
			UIUtil.SetIsVisible(self.Tag_Collect, false)
			-- UIUtil.ImageSetBrushFromAssetPath(self.FImg_Normal, "Texture2D'/Game/UI/Texture/Collect/UI_Collect_Img_Normal.UI_Collect_Img_Normal'")
		end

		if ItemNoteInfo.FirstGather then
			FLOG_INFO("Gather %s is FirstGather", GatherItemCfg.ItemName)
		else
			FLOG_INFO("Gather %s is not FirstGather", GatherItemCfg.ItemName)
		end

		if ItemNoteInfo.CommonSkillUp then
			UIUtil.SetIsVisible(self.Icon_SuccessRate, true)
		else
			UIUtil.SetIsVisible(self.Icon_SuccessRate, false)
		end

		if ItemNoteInfo.HQSkillUp then
			UIUtil.SetIsVisible(self.Icon_UpRate, true)
		else
			UIUtil.SetIsVisible(self.Icon_UpRate, false)
		end

		UIUtil.ImageSetBrushFromAssetPath(self.Icon_Gather, UIUtil.GetIconPath(GatherItemCfg.IconID), true)
	end
end

function FunctionGatherItemView:OnMajorAttrChange(Params)
	if _G.UIViewMgr:IsViewVisible(UIViewID.EquipmentMainPanel)
		or _G.UIViewMgr:IsViewVisible(UIViewID.BagMain) then
		_G.InteractiveMgr:ShowEntrances()
		_G.InteractiveMgr:ExitInteractive()
		_G.GatherMgr:SendExitGatherState()
	end
	-- local NoteCfg = GatherNoteCfg:FindCfgByItemID(self.FunctionItem.ResID)
	-- if NoteCfg then
	-- 	local CurAcquisitionAttr = _G.UE.UMajorUtil.GetAttrValue(ProtoCommon.attr_type.attr_gathering)
	-- 	local CurInsightAttr = _G.UE.UMajorUtil.GetAttrValue(ProtoCommon.attr_type.attr_perception)
	-- 	if CurAcquisitionAttr >= NoteCfg.MinAcquisition and CurInsightAttr >= NoteCfg.MinInsight then
	-- 		local ItemNoteInfo = self.FunctionItem.FuncParams.ItemNoteInfo
	-- 		if ItemNoteInfo.CommonGatherRate > 0 then
	-- 			self.Text_GetRate:SetText(string.format("%d%%", math.floor(ItemNoteInfo.CommonGatherRate / 100)))
	-- 		else
	-- 			self.Text_GetRate:SetText("-%")
	-- 		end

	-- 		if ItemNoteInfo.HQGatherRate > 0 then
	-- 			self.Text_HQGetRate:SetText(string.format("%d%%", math.floor(ItemNoteInfo.HQGatherRate / 100)))
	-- 		else
	-- 			self.Text_HQGetRate:SetText("-%")
	-- 		end
	-- 	else
	-- 		self.Text_GetRate:SetText("-%")
	-- 		self.Text_HQGetRate:SetText("-%")
	-- 	end
	-- end
end

function FunctionGatherItemView:SetActive(BActive)
	-- self.BActive = BActive
	-- FLOG_INFO("Interactive SetActive self: " .. tostring(self) .. " BActive: " .. tostring(BActive))
	self.ToggleButton:SetChecked(BActive)--是否激活
end

function FunctionGatherItemView:OnClicked(FunctionItem)
	--FLOG_INFO("Interactive ActiveGatherItem Click" .. FunctionItem.EntityID)
	_G.CollectionMgr:SetGatherItem(FunctionItem)
	FunctionItem:Click()
end

return FunctionGatherItemView