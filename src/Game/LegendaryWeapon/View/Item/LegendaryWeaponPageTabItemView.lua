---
--- Author: guanjiewu
--- DateTime: 2024-01-15 14:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local LegendaryWeaponMainPanelVM = require("Game/LegendaryWeapon/VM/LegendaryWeaponMainPanelVM")
local LegendaryWeaponDefine = require("Game/LegendaryWeapon/LegendaryWeaponDefine")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local LSTR = _G.LSTR

-- 字色
local NormalColor = "#878075"
local SelectedColor = "#FFF4D0"

--描边
local OutlineNormalColor = "#2121217F"
local OutlineSelectedColor = "#8066447F"

---@class LegendaryWeaponPageTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field EFF_1 UFCanvasPanel
---@field HorizontalName UFHorizontalBox
---@field ImgLock UFImage
---@field ImgSelect UFImage
---@field RedDot CommonRedDotView
---@field TextTabName UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimSelect UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LegendaryWeaponPageTabItemView = LuaClass(UIView, true)

function LegendaryWeaponPageTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.EFF_1 = nil
	--self.HorizontalName = nil
	--self.ImgLock = nil
	--self.ImgSelect = nil
	--self.RedDot = nil
	--self.TextTabName = nil
	--self.AnimIn = nil
	--self.AnimSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LegendaryWeaponPageTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LegendaryWeaponPageTabItemView:OnInit()
	self.viewModel = LegendaryWeaponMainPanelVM

	-- 章节序号
	self.ChapterNumber =
	{
		[1] = LSTR(220047),		--'一'
		[2] = LSTR(220048),		--"二"
		[3] = LSTR(220049),		--'三'
		[4] = "四",
		[5] = "五",
	}
	
end

function LegendaryWeaponPageTabItemView:OnDestroy()

end

function LegendaryWeaponPageTabItemView:OnShow()
	if nil == self.Params then return end
	if nil == self.Params.Data then return end
	self.Data = self.Params.Data
	self.TextTabName:SetText(string.format(LSTR(220014), self.ChapterNumber[self.Data.ID]))	--"第%s章"
	
	local IsUnLock = self.Data.IsUnLock
	UIUtil.SetIsVisible(self.ImgLock, not IsUnLock)

	self:SetRedDotID()
	self:OnChapterItemClick(self.viewModel.ChapterID)
	self:PlayAnimation(self.AnimIn)
end

function LegendaryWeaponPageTabItemView:OnHide()

end

function LegendaryWeaponPageTabItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnBtnClicked)
end

function LegendaryWeaponPageTabItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.LegendaryChapterItemClick, self.OnChapterItemClick)
end

function LegendaryWeaponPageTabItemView:OnRegisterBinder()

end

function LegendaryWeaponPageTabItemView:OnChapterItemClick(ID)
	local ChapterID = self.Data.ID
    if ChapterID and ChapterID == ID then
		UIUtil.SetIsVisible(self.ImgSelect, true)
		UIUtil.SetIsVisible(self.EFF_1, true)
		UIUtil.SetColorAndOpacityHex(self.TextTabName, SelectedColor)
		UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextTabName, OutlineSelectedColor)
		self:PlayAnimation(self.AnimSelect)
    else
        UIUtil.SetIsVisible(self.ImgSelect, false)
		UIUtil.SetIsVisible(self.EFF_1, false)
		UIUtil.SetColorAndOpacityHex(self.TextTabName, NormalColor)
		UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextTabName, OutlineNormalColor)
    end
end

function LegendaryWeaponPageTabItemView:OnBtnClicked()
	if not self.Data.IsUnLock then
		MsgTipsUtil.ShowTips(LSTR(220015))	--"章节尚未解锁，敬请期待"
		return
	end
	_G.EventMgr:SendEvent(EventID.LegendaryChapterItemClick, self.Data.ID)
	
	--_G.LegendaryWeaponMgr:SetRedDot(self.RedDotID, false)
end

--- 设置自身的红点ID
function LegendaryWeaponPageTabItemView:SetRedDotID()	
	self.RedDotID = LegendaryWeaponDefine.GetTopicOrChapterRedDotID(self.viewModel.TopicID, self.Data.ID)
	self.RedDot:SetRedDotIDByID(self.RedDotID)
end

return LegendaryWeaponPageTabItemView