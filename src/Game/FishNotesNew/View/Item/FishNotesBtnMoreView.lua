---
--- Author: v_vvxinchen
--- DateTime: 2025-06-03 11:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class FishNotesBtnMoreView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Common_PopUpBG CommonPopUpBGView
---@field PanelMore UFCanvasPanel
---@field TableViewMore UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishNotesBtnMoreView = LuaClass(UIView, true)

function FishNotesBtnMoreView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Common_PopUpBG = nil
	--self.PanelMore = nil
	--self.TableViewMore = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishNotesBtnMoreView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Common_PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishNotesBtnMoreView:OnInit()

end

function FishNotesBtnMoreView:OnDestroy()

end

function FishNotesBtnMoreView:OnShow()

end

function FishNotesBtnMoreView:OnHide()

end

function FishNotesBtnMoreView:OnRegisterUIEvent()

end

function FishNotesBtnMoreView:OnRegisterGameEvent()

end

function FishNotesBtnMoreView:OnRegisterBinder()

end

return FishNotesBtnMoreView