---
--- Author: chunfengluo
--- DateTime: 2021-08-23 12:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class NPCTalkTopInfoItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FImg_Function UFImage
---@field RichText_NPCName URichTextBox
---@field RichText_Post URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NPCTalkTopInfoItemView = LuaClass(UIView, true)

function NPCTalkTopInfoItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	self.FImg_Function = nil
	self.RichText_NPCName = nil
	self.RichText_Post = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NPCTalkTopInfoItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NPCTalkTopInfoItemView:OnInit()

end

function NPCTalkTopInfoItemView:OnDestroy()

end

function NPCTalkTopInfoItemView:OnShow()

end

function NPCTalkTopInfoItemView:OnHide()

end

function NPCTalkTopInfoItemView:OnRegisterUIEvent()

end

function NPCTalkTopInfoItemView:OnRegisterGameEvent()

end

function NPCTalkTopInfoItemView:OnRegisterTimer()

end

function NPCTalkTopInfoItemView:OnRegisterBinder()

end

return NPCTalkTopInfoItemView