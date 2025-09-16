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
---@field TableViewContent UTableView
---@field TableViewExplan UTableView
---@field TextNote UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EmoActRulesWinView = LuaClass(UIView, true)

function EmoActRulesWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.TableViewContent = nil
	--self.TableViewExplan = nil
	--self.TextNote = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EmoActRulesWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EmoActRulesWinView:OnInit()
	if self.BG then
		self.BG.HideOnClick = false
	end

	--钓鱼动作只有一个，暂时不考虑。
	--目前共4种：站立、坐在地面、座椅、坐骑

	local Color1 = "D5D5D5FF"
	local Color2 = "828282FF"
	local Color3 = "D1BA8EFF"
	local StateName = {
		LSTR(210016),	--"站立"
		LSTR(210017),	--"坐在地面"
		LSTR(210018),	--"座椅"
		LSTR(210019) }	--"坐骑"

	local StateText1 = string.format("<span color=\"#%s\">%s</>", Color1, StateName[1])
	local StateText2 = string.format("<span color=\"#%s\">%s</>", Color1, StateName[2])
	local StateText3 = string.format("<span color=\"#%s\">%s</>", Color1, StateName[3])
	local StateText4 = string.format("<span color=\"#%s\">%s</>", Color1, StateName[4])

	self.CanUse = {
		{CanUseName = StateText1, IconPath = EmotionUtils.GetScenesIconPath("UI_EmoAct_Scenes_Stand_On_png")},
		{CanUseName = StateText2, IconPath = EmotionUtils.GetScenesIconPath("UI_EmoAct_Scenes_Sit_On_png")},
		{CanUseName = StateText3, IconPath = EmotionUtils.GetScenesIconPath("UI_EmoAct_Scenes_Seat_On_png")},
		{CanUseName = StateText4, IconPath = EmotionUtils.GetScenesIconPath("UI_EmoAct_Scenes_Ride_On_png")},
	}

	self.HelpText = {
		LSTR(210020),	--"动作介绍"
		LSTR(210021),	--"1.  利用情感动作可以表达当前心情"
		LSTR(210022),	--"2.  可以选中目标对其使用情感动作"
		LSTR(210023),	--"3.  可以根据时机和场合做出合适的动作，更加有趣"
	}
	
	self.HelpText = {
		string.format("<span color=\"#%s\">%s</>", Color3, self.HelpText[1]),
		string.format("<span color=\"#%s\">%s</>", Color1, self.HelpText[2]),
		string.format("<span color=\"#%s\">%s</>", Color1, self.HelpText[3]),
		string.format("<span color=\"#%s\">%s</>", Color1, self.HelpText[4]).."\n".."\n".."\n",
	 }

	self.TableViewExplanAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewExplan)
	self.TableViewContentAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewContent)
end

function EmoActRulesWinView:OnShow()
	self.TextNote:SetText(LSTR(210003))	--"适用场景"
	self.BG:SetTitleText(LSTR(210004))	--"规则说明"
	self.TableViewExplanAdapter:UpdateAll(self.CanUse)
	self.TableViewContentAdapter:UpdateAll(self.HelpText)
end

return EmoActRulesWinView