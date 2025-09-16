---
--- Author: henghaoli
--- DateTime: 2024-03-14 10:52
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

---@class SkillMinerDetailsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgLine UFImage
---@field ImgLine02 UFImage
---@field ImgLine03 UFImage
---@field ImgSkill1 UFImage
---@field ImgSkill2 UFImage
---@field ImgSkill3 UFImage
---@field ImgSkill4 UFImage
---@field RichText01 URichTextBox
---@field RichText02 URichTextBox
---@field RichText02_1 URichTextBox
---@field Scroll UScrollBox
---@field SkillPanel2 UFCanvasPanel
---@field TextSkill1 UFTextBlock
---@field TextSkill2 UFTextBlock
---@field TextSkill3 UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillMinerDetailsItemView = LuaClass(UIView, true)

function SkillMinerDetailsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgLine = nil
	--self.ImgLine02 = nil
	--self.ImgLine03 = nil
	--self.ImgSkill1 = nil
	--self.ImgSkill2 = nil
	--self.ImgSkill3 = nil
	--self.ImgSkill4 = nil
	--self.RichText01 = nil
	--self.RichText02 = nil
	--self.RichText02_1 = nil
	--self.Scroll = nil
	--self.SkillPanel2 = nil
	--self.TextSkill1 = nil
	--self.TextSkill2 = nil
	--self.TextSkill3 = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillMinerDetailsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillMinerDetailsItemView:OnInit()
	self.TextTitle:SetText(LSTR(160007)) --技能效果
	self.TextSkill1:SetText(LSTR(160004)) --价值提升
	self.RichText01:SetText(LSTR(160001)) --使用任意提纯技能时以下方显示的机率进一步提升收藏价值，鉴别力越高此几率越高，最大40%。
	self.TextSkill2:SetText(LSTR(160005)) --洞察
	self.RichText02:SetText(LSTR(160002)) --大胆提纯价值改变为提纯的<span color="#d1ba8eFF">100%~150%</>，慎重提纯价值改变为提纯的<span color="#d1ba8eFF">100%</>。使用任何提纯技能都有一定几率触发，使用任意提纯技能均会消耗此状态。
	self.TextSkill3:SetText(LSTR(160006)) --沉稳
	self.RichText02_1:SetText(LSTR(160003)) --使用<span color="#d1ba8eFF">慎重提纯</>有一定几率不消耗耐久，获得力越高此几率越高，最大25%。


end

function SkillMinerDetailsItemView:OnDestroy()

end

function SkillMinerDetailsItemView:OnShow()

end

function SkillMinerDetailsItemView:OnHide()

end

function SkillMinerDetailsItemView:OnRegisterUIEvent()

end

function SkillMinerDetailsItemView:OnRegisterGameEvent()

end

function SkillMinerDetailsItemView:OnRegisterBinder()

end

return SkillMinerDetailsItemView