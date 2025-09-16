--[[
Author: jususchen jususchen@tencent.com
Date: 2024-12-13 17:29
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-12-25 15:33:47
FilePath: \Script\Game\Share\View\Item\ShareActivityTitleRightItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ShareActivityTitleRightItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm74Slot CommBackpack74SlotView
---@field CommSlot96 CommBackpack96SlotView
---@field PanelBlackColor UFVerticalBox
---@field PanelCoolColor UFVerticalBox
---@field PanelSlot UFHorizontalBox
---@field PanelWarmColor UFVerticalBox
---@field TextContentBlackColor UFTextBlock
---@field TextContentCoolColor UFTextBlock
---@field TextContentWarmColor UFTextBlock
---@field TextSubTitleBlackColor UFTextBlock
---@field TextSubTitleCoolColor UFTextBlock
---@field TextSubTitleWarmColor UFTextBlock
---@field TextTitleBlackColor UFTextBlock
---@field TextTitleCoolColor UFTextBlock
---@field TextTitleWarmColor UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShareActivityTitleRightItemView = LuaClass(UIView, true)

function ShareActivityTitleRightItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm74Slot = nil
	--self.CommSlot96 = nil
	--self.PanelBlackColor = nil
	--self.PanelCoolColor = nil
	--self.PanelSlot = nil
	--self.PanelWarmColor = nil
	--self.TextContentBlackColor = nil
	--self.TextContentCoolColor = nil
	--self.TextContentWarmColor = nil
	--self.TextSubTitleBlackColor = nil
	--self.TextSubTitleCoolColor = nil
	--self.TextSubTitleWarmColor = nil
	--self.TextTitleBlackColor = nil
	--self.TextTitleCoolColor = nil
	--self.TextTitleWarmColor = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShareActivityTitleRightItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm74Slot)
	self:AddSubView(self.CommSlot96)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

---@param Cfg ShareActivityCfg
function ShareActivityTitleRightItemView:UpdateData(Cfg)
	local Title = Cfg.TitleBig
	local TextSubTitle = Cfg.TitleMedium
	local TextContent = Cfg.TitleSmall
	
	local bWarmType = Cfg.ThemeType == nil or Cfg.ThemeType == 0
	if bWarmType then
		self.TextTitleWarmColor:SetText(Title)
		self.TextSubTitleWarmColor:SetText(TextSubTitle)
		self.TextContentWarmColor:SetText(TextContent)
	end
	UIUtil.SetIsVisible(self.PanelWarmColor, bWarmType)

	local bBlackType = Cfg.ThemeType == 1
	if bBlackType then
		self.TextTitleBlackColor:SetText(Title)
		self.TextSubTitleBlackColor:SetText(TextSubTitle)
		self.TextContentBlackColor:SetText(TextContent)
	end
	UIUtil.SetIsVisible(self.PanelBlackColor, bBlackType)

	local bCoolType = Cfg.ThemeType == 2
	if bCoolType then
		self.TextTitleCoolColor:SetText(Title)
		self.TextSubTitleCoolColor:SetText(TextSubTitle)
		self.TextContentCoolColor:SetText(TextContent)
	end
	UIUtil.SetIsVisible(self.PanelCoolColor, bCoolType)

	_G.ShareMgr:UpdateActivityShareRewards(Cfg, self.PanelSlot)
	local Items = _G.ShareMgr:GetShareVM().ShareActivityRewardVMList:GetItems()
	UIUtil.SetIsVisible(self.PanelSlot, #Items > 1)
	if #Items == 1 then
		self.CommSlot96:SetParams({Data = Items[1]})
	end
	UIUtil.SetIsVisible(self.CommSlot96, #Items == 1)
end

return ShareActivityTitleRightItemView