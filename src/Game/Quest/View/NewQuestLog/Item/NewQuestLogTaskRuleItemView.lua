---
--- Author: lydianwang
--- DateTime: 2023-05-30 15:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local LSTR = _G.LSTR

---@class NewQuestLogTaskRuleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnTips UFButton
---@field IconRule UFImage
---@field TextRule UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewQuestLogTaskRuleItemView = LuaClass(UIView, true)

function NewQuestLogTaskRuleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnTips = nil
	--self.IconRule = nil
	--self.TextRule = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewQuestLogTaskRuleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewQuestLogTaskRuleItemView:OnInit()
	self.bTipsVisible = false
	self.bPreprocessClosed = false
end

function NewQuestLogTaskRuleItemView:OnDestroy()

end

function NewQuestLogTaskRuleItemView:OnShow()

end

function NewQuestLogTaskRuleItemView:OnHide()

end

function NewQuestLogTaskRuleItemView:OnRegisterUIEvent()

end

function NewQuestLogTaskRuleItemView:OnRegisterGameEvent()

end

function NewQuestLogTaskRuleItemView:OnRegisterBinder()

end

function NewQuestLogTaskRuleItemView:SetProfFixed()
	self.TextRule:SetText(LSTR(390015))
end

return NewQuestLogTaskRuleItemView