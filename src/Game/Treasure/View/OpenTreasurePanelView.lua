---
--- Author: wallencai
--- DateTime: 2022-12-20 16:12
--- Description: 已弃用
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PWorldMgr = require("Game/PWorld/PWorldMgr")
local ProtoCS = require("Protocol/ProtoCS")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")

local TreasureCtrl = ProtoCS.TreasureCtrl

---@class OpenTreasurePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FButton_124 UFButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpenTreasurePanelView = LuaClass(UIView, true)

function OpenTreasurePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FButton_124 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpenTreasurePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpenTreasurePanelView:OnInit()

end

function OpenTreasurePanelView:OnDestroy()

end

function OpenTreasurePanelView:OnShow()

end

function OpenTreasurePanelView:OnHide()

end

function OpenTreasurePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FButton_124, self.OnBtnClick)
end

function OpenTreasurePanelView:OnBtnClick()
end

function OpenTreasurePanelView:OnRegisterGameEvent()

end

function OpenTreasurePanelView:OnRegisterBinder()

end

return OpenTreasurePanelView