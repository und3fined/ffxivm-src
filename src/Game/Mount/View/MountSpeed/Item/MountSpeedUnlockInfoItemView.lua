---
--- Author: janezli
--- DateTime: 2024-10-11 14:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIViewID = require("Define/UIViewID")

---@class MountSpeedUnlockInfoItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelFlightSpeed UFHorizontalBox
---@field PanelGroundSpeed UFHorizontalBox
---@field RichText URichTextBox
---@field RichTextFlightSpeed URichTextBox
---@field RichTextGroundSpeed URichTextBox
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MountSpeedUnlockInfoItemView = LuaClass(UIView, true)

function MountSpeedUnlockInfoItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelFlightSpeed = nil
	--self.PanelGroundSpeed = nil
	--self.RichText = nil
	--self.RichTextFlightSpeed = nil
	--self.RichTextGroundSpeed = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MountSpeedUnlockInfoItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MountSpeedUnlockInfoItemView:OnInit()
	self.Binders = {
		{ "QuestTitle", UIBinderSetText.New(self, self.TextTitle)},
		{ "QuestRichText", UIBinderSetText.New(self, self.RichText) },
		{ "PanelFlightSpeedVisible", UIBinderSetIsVisible.New(self, self.PanelFlightSpeed) },
	}
end

function MountSpeedUnlockInfoItemView:OnDestroy()

end

function MountSpeedUnlockInfoItemView:OnShow()
	self.RichTextGroundSpeed:SetText(LSTR(200015))
	self.RichTextFlightSpeed:SetText(LSTR(200016))
end

function MountSpeedUnlockInfoItemView:OnHide()

end

function MountSpeedUnlockInfoItemView:OnRegisterUIEvent()
	UIUtil.AddOnHyperlinkClickedEvent(self, self.RichText, self.OnHyperlinkClicked)
end

function MountSpeedUnlockInfoItemView:OnRegisterGameEvent()

end

function MountSpeedUnlockInfoItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function MountSpeedUnlockInfoItemView:OnHyperlinkClicked(_, LinkID)
	local SplitList = string.split(LinkID, ",")
	-- 道具ID
	if #SplitList == 1 then
		local ItemID = tonumber(SplitList[1])
		if ItemID and ItemID > 0 then
			ItemTipsUtil.ShowTipsByResID(ItemID, self.RichText)
		end
	-- 地图ID, NPCResID
	elseif #SplitList == 2 then
		local MapID = tonumber(SplitList[1])
		local NPCResID = tonumber(SplitList[2])
		if MapID and MapID > 0 and NPCResID and NPCResID > 0 then
			UIViewMgr:HideView(UIViewID.MountSpeedPanel)
			if UIViewMgr:IsViewVisible(UIViewID.WorldMapPanel) then
				UIViewMgr:HideView(UIViewID.WorldMapPanel,true)
			end
			_G.WorldMapMgr:ShowWorldMapLocationNpc(MapID, NPCResID)
		end
	end
end

return MountSpeedUnlockInfoItemView