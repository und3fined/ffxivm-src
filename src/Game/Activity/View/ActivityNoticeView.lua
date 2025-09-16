---
--- Author: fish
--- DateTime: 2023-02-02 16:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local ActivityDefine = require("Game/Activity/ActivityDefine")

---@class ActivityNoticeView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextBox_82 URichTextBox
---@field TextTitleActivity UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ActivityNoticeView = LuaClass(UIView, true)

function ActivityNoticeView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextBox_82 = nil
	--self.TextTitleActivity = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ActivityNoticeView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ActivityNoticeView:OnInit()

end

function ActivityNoticeView:OnDestroy()

end

function ActivityNoticeView:OnShow()
	self.TextTitleActivity:SetText(ActivityDefine.ActivityNotice.Title)
	self.RichTextBox_82:SetText(ActivityDefine.ActivityNotice.Content)
end

function ActivityNoticeView:OnHide()

end

function ActivityNoticeView:OnRegisterUIEvent()

end

function ActivityNoticeView:OnRegisterGameEvent()

end

function ActivityNoticeView:OnRegisterBinder()

end

return ActivityNoticeView