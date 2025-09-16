---
--- Author: Administrator
--- DateTime: 2023-03-24 16:38
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

local FishGuideVM = require("Game/FishNotes/FishGuideVM")

---@class FishGuideMsgPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CloseBtn CommonCloseBtnView
---@field TableViewMsgList UTableView
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishGuideMsgPanelView = LuaClass(UIView, true)

function FishGuideMsgPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CloseBtn = nil
	--self.TableViewMsgList = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishGuideMsgPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishGuideMsgPanelView:OnInit()
	self.CloseBtn:SetCallback(self, nil, nil, self.OnClickButtonClose)
	-- UIUtil.AddOnClickedEvent(self, self.CloseBtn, self.OnClickButtonClose)
end

function FishGuideMsgPanelView:OnDestroy()

end

function FishGuideMsgPanelView:OnShow()

end

function FishGuideMsgPanelView:OnHide()

end

function FishGuideMsgPanelView:OnRegisterUIEvent()

end

function FishGuideMsgPanelView:OnRegisterGameEvent()

end

function FishGuideMsgPanelView:OnRegisterBinder()

end

function FishGuideMsgPanelView:OnClickButtonClose()
	FishGuideVM:CommentViewChanged(false)
end

return FishGuideMsgPanelView