---
--- Author: danile
--- DateTime: 2023-03-23 09:43
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

---@class ArmyRankListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgRankIcon UFImage
---@field ImgSelectBg UFImage
---@field TextRankContent UFTextBlock
---@field ToggleBtnRank UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyRankListItemView = LuaClass(UIView, true)

function ArmyRankListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgRankIcon = nil
	--self.ImgSelectBg = nil
	--self.TextRankContent = nil
	--self.ToggleBtnRank = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyRankListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyRankListItemView:OnInit()

end

function ArmyRankListItemView:OnDestroy()

end

function ArmyRankListItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	local CategoryData = Params.Data.CategoryData
	local bSelected = Params.Data.bSelected
	local Name = CategoryData.Name
	if string.isnilorempty(Name) then
		local CfgCategoryName
		if CategoryData.ID == ArmyDefine.LeaderCID then
			CfgCategoryName = GroupGlobalCfg:GetStrValueByType(GlobalCfgType.DefaultMajorCategoryName)
            Name = CfgCategoryName or DefineCategorys.LeaderName
        else
			CfgCategoryName = GroupGlobalCfg:GetStrValueByType(GlobalCfgType.DefaultMinorCategoryName)
            Name = CfgCategoryName or DefineCategorys.MemName
        end
    end
	self.TextRankContent:SetText(string.format("%d %s", CategoryData.ShowIndex + 1, Name))
	local IconPath = GroupMemberCategoryCfg:GetCategoryIconByID(CategoryData.IconID)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgRankIcon, IconPath)
	self.ToggleBtnRank:SetIsChecked(bSelected)
end

function ArmyRankListItemView:OnHide()

end

function ArmyRankListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnRank, self.OnClickedItem)
end

function ArmyRankListItemView:OnRegisterGameEvent()

end

function ArmyRankListItemView:OnRegisterBinder()

end

function ArmyRankListItemView:OnClickedItem()
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

return ArmyRankListItemView