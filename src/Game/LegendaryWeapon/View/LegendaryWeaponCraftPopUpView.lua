---
--- Author: YanYuSheng
--- DateTime: 2024-04-18 19:31
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local LegendaryWeaponTopicCfg = require("TableCfg/LegendaryWeaponTopicCfg") --传奇武器主题表
local LSTR = _G.LSTR

---@class LegendaryWeaponCraftPopUpView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EFFGroup UCanvasPanel
---@field TextWords UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LegendaryWeaponCraftPopUpView = LuaClass(UIView, true)

function LegendaryWeaponCraftPopUpView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EFFGroup = nil
	--self.TextWords = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LegendaryWeaponCraftPopUpView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LegendaryWeaponCraftPopUpView:OnInit()
	self.WeaponName = ""
	self.ChapText = ""
end

function LegendaryWeaponCraftPopUpView:OnShow()
	if nil == self.Params then
		return
	end
	UIUtil.SetIsVisible(self.EFFGroup, true)
	self:PlayAnimation(self.AnimIn)
	if self.Params.WeaponID and self.Params.WeaponID > 0 then
		self.WeaponName = ItemCfg:GetItemName(self.Params.WeaponID)
	end
	
	local TopicCfg = LegendaryWeaponTopicCfg:FindCfgByKey(self.Params.TopicID)
	if TopicCfg then
		self.ChapText = TopicCfg.Chap1Text
	end

	local TextContent = string.format(self.ChapText, self.WeaponName )
	self.TextWords:SetText(TextContent)
end

function LegendaryWeaponCraftPopUpView:OnRegisterTimer()
	self.Super:OnRegisterTimer()
	
	local Delay = 1
	if self.AnimIn then
		Delay = self.AnimIn:GetEndTime()
	end
	
	-- UI动画播放完就销毁此UI
	self:RegisterTimer(self.OnTimer, Delay, 0, 1)
end

function LegendaryWeaponCraftPopUpView:OnTimer()
	_G.UIViewMgr:HideView(_G.UIViewID.LegendaryWeaponCraftPopUp)
end

return LegendaryWeaponCraftPopUpView