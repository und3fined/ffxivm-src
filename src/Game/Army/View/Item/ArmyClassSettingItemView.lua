---
--- Author: daniel
--- DateTime: 2023-03-22 14:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ArmyDefine = require("Game/Army/ArmyDefine")
local DefineCategorys = ArmyDefine.DefineCategorys
local GlobalCfgType = ArmyDefine.GlobalCfgType
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local GroupMemberCategoryCfg = require("TableCfg/GroupMemberCategoryCfg")

---@deprecated
---@class ArmyClassSettingItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CheckBox CommCheckBoxView
---@field ImgClassIcon_1 UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyClassSettingItemView = LuaClass(UIView, true)

function ArmyClassSettingItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CheckBox = nil
	--self.ImgClassIcon_1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyClassSettingItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CheckBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyClassSettingItemView:OnInit()

end

function ArmyClassSettingItemView:OnDestroy()

end

function ArmyClassSettingItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	if Params.Data == nil then
		return
	end
	---见习调整置灰
	if Params.Data.IsGray then
		self.CheckBox:SetVisibility(_G.UE.ESlateVisibility.HitTestInvisible)
		self.CheckBox:SetRenderOpacity(0.4)
		self.ImgClassIcon_1:SetRenderOpacity(0.4)
	else
		self.CheckBox:SetVisibility(_G.UE.ESlateVisibility.Visible)
		self.CheckBox:SetRenderOpacity(1.0)
		self.ImgClassIcon_1:SetRenderOpacity(1.0)
	end

	local CategoryID = Params.Data.ID
	local Name = Params.Data.Name
	if string.isnilorempty(Name) then
		local CfgCategoryName
		if CategoryID == ArmyDefine.LeaderCID then
			CfgCategoryName = GroupGlobalCfg:GetStrValueByType(GlobalCfgType.DefaultMajorCategoryName)
            Name = CfgCategoryName or DefineCategorys.LeaderName
        else
			CfgCategoryName = GroupGlobalCfg:GetStrValueByType(GlobalCfgType.DefaultMinorCategoryName)
            Name = CfgCategoryName or DefineCategorys.MemName
        end
    end
	local SIndex = Params.Data.ShowIndex + 1
	self.CheckBox:SetText(string.format("            %d %s", SIndex, Name))
	local Icon = GroupMemberCategoryCfg:GetCategoryIconByID(Params.Data.IconID)
	UIUtil.ImageSetBrushFromAssetPathSync(self.ImgClassIcon_1, Icon)
end

function ArmyClassSettingItemView:OnHide()

end

function ArmyClassSettingItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CheckBox.ToggleButton, self.OnClickedItem)
end

function ArmyClassSettingItemView:OnRegisterGameEvent()

end

function ArmyClassSettingItemView:OnRegisterBinder()

end

---@field IsSelected boolean
function ArmyClassSettingItemView:OnSelectChanged(IsSelected)
	self.CheckBox:SetChecked(IsSelected, false)
end

function ArmyClassSettingItemView:OnClickedItem()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end
	Adapter:OnItemClicked(self, Params.Index)
end

return ArmyClassSettingItemView