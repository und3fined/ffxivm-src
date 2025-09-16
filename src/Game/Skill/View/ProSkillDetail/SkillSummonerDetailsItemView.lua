---
--- Author: chaooren
--- DateTime: 2023-07-17 09:18
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class SkillSummonerDetailsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextCall URichTextBox
---@field RichTextLearn URichTextBox
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillSummonerDetailsItemView = LuaClass(UIView, true)

function SkillSummonerDetailsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextCall = nil
	--self.RichTextLearn = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillSummonerDetailsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillSummonerDetailsItemView:OnInit()
	local LSTR = _G.LSTR
	self.RichTextCall:SetText(LSTR(140055))
	self.RichTextLearn:SetText(LSTR(140056))
	self.TextTitle:SetText(LSTR(140057))
end

function SkillSummonerDetailsItemView:OnDestroy()

end

function SkillSummonerDetailsItemView:OnShow()

end

function SkillSummonerDetailsItemView:OnHide()

end

function SkillSummonerDetailsItemView:OnRegisterUIEvent()

end

function SkillSummonerDetailsItemView:OnRegisterGameEvent()

end

function SkillSummonerDetailsItemView:OnRegisterBinder()

end

return SkillSummonerDetailsItemView