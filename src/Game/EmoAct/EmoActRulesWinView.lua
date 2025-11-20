---
--- Author: Administrator
--- DateTime: 2023-09-13 14:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local EmotionUtils = require("Game/Emotion/Common/EmotionUtils")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

local LSTR = _G.LSTR

---@class EmoActRulesWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field CommWinSlotQuality CommWinSlotQualityView
---@field TableViewContent UTableView
---@field TableViewExplan UTableView
---@field TextNote UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EmoActRulesWinView = LuaClass(UIView, true)

function EmoActRulesWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.CommWinSlotQuality = nil
	--self.TableViewContent = nil
	--self.TableViewExplan = nil
	--self.TextNote = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EmoActRulesWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.CommWinSlotQuality)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EmoActRulesWinView:OnInit()
	if self.BG then
		self.BG.HideOnClick = false
	end

	self.MainTitle = LSTR(210004)
	self.SubTitle = {
		LSTR(210003),	--"图标说明"
		LSTR(210020),	--"操作说明"
		LSTR(210037),	--"可见性设置"
	}
	self.StateText = {		--图标说明的内容
		LSTR(210016),	--"站立"
		LSTR(210017),	--"坐在地面"
		LSTR(210018),	--"座椅"
		LSTR(210019),	--"坐骑"
		"%s时可用",
	}
	self.HelpContent = {	--操作说明的内容
		LSTR(210038),
	}
	self.HelpText = {		--可见性设置的内容
		LSTR(210039),
		LSTR(210021),	--"1.利用情感动作可以表达当前心情"
		LSTR(210022),	--"2.可以选中目标对其使用情感动作"
		LSTR(210023),	--"3.可以根据时机和场合做出合适的动作，更加有趣"
	}

	local Color1 = "#D5D5D5FF"
	local Color2 = "#FA9563"
	local Color3 = "#D1BA8EFF"
	local StateText1 = string.format("<span color=\"%s\">%s</>", Color2, self.StateText[1])
	local StateText2 = string.format("<span color=\"%s\">%s</>", Color2, self.StateText[2])
	local StateText3 = string.format("<span color=\"%s\">%s</>", Color2, self.StateText[3])
	local StateText4 = string.format("<span color=\"%s\">%s</>", Color2, self.StateText[4])
	StateText1 = string.format(self.StateText[5], StateText1)
	StateText2 = string.format(self.StateText[5], StateText2)
	StateText3 = string.format(self.StateText[5], StateText3)
	StateText4 = string.format(self.StateText[5], StateText4)

	self.CanUse = {
		{CanUseName = StateText1, IconPath = EmotionUtils.GetScenesIconPath("UI_EmoAct_Scenes_Stand_On_png")},
		{CanUseName = StateText2, IconPath = EmotionUtils.GetScenesIconPath("UI_EmoAct_Scenes_Sit_On_png")},
		{CanUseName = StateText3, IconPath = EmotionUtils.GetScenesIconPath("UI_EmoAct_Scenes_Seat_On_png")},
		{CanUseName = StateText4, IconPath = EmotionUtils.GetScenesIconPath("UI_EmoAct_Scenes_Ride_On_png")},
	}

	-- self.HelpText = {
	-- 	string.format("<span color=\"%s\">%s</>", Color1, self.HelpText[1]),
	-- 	string.format("<span color=\"%s\">%s</>", Color1, self.HelpText[2]),
	-- 	string.format("<span color=\"%s\">%s</>", Color1, self.HelpText[3]).."\n".."\n".."\n",
	-- }

	self.HelpListData = {
		{Title = self.SubTitle[2], Content = self.HelpContent[1],},
		{Title = self.SubTitle[3], Content = self.HelpText[1],},
	}

	self.TableViewExplanAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewExplan)
	self.TableViewContentAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewContent)
end

function EmoActRulesWinView:OnShow()
	self.BG:SetTitleText(self.MainTitle)
	self.TextNote:SetText(self.SubTitle[1])

	self.TableViewExplanAdapter:UpdateAll(self.CanUse)
	self.TableViewContentAdapter:UpdateAll(self.HelpListData)
end

return EmoActRulesWinView