---
--- Author: sammrli
--- DateTime: 2024-07-17 23:50
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local LSTR = _G.LSTR

---@class ChocoboTransportQuestView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ToggleBtnRemove UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboTransportQuestView = LuaClass(UIView, true)

function ChocoboTransportQuestView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ToggleBtnRemove = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboTransportQuestView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboTransportQuestView:OnInit()

end

function ChocoboTransportQuestView:OnDestroy()

end

function ChocoboTransportQuestView:OnShow()

end

function ChocoboTransportQuestView:OnHide()

end

function ChocoboTransportQuestView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnRemove, self.OnToggleBtnRemoveClick)
end

function ChocoboTransportQuestView:OnRegisterGameEvent()

end

function ChocoboTransportQuestView:OnRegisterBinder()

end

function ChocoboTransportQuestView:OnToggleBtnRemoveClick()
	local function SureCallBack()
		_G.ChocoboTransportMgr:QuestCancelTrasport()
	end
	MsgBoxUtil.MessageBox(LSTR(580002), LSTR(10002), LSTR(10003), SureCallBack) --580002=是否确定下鸟？剩余路程需要自行前往哦~
end

return ChocoboTransportQuestView