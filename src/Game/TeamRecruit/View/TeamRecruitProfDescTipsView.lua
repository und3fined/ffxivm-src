---
--- Author: jususchen
--- DateTime: 2025-03-07 16:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class TeamRecruitProfDescTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PopUpBG CommonPopUpBGView
---@field ProfDescTips UFCanvasPanel
---@field TableViewTips1 UTableView
---@field TableViewTips2 UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamRecruitProfDescTipsView = LuaClass(UIView, true)

function TeamRecruitProfDescTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PopUpBG = nil
	--self.ProfDescTips = nil
	--self.TableViewTips1 = nil
	--self.TableViewTips2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamRecruitProfDescTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamRecruitProfDescTipsView:OnInit()

end

function TeamRecruitProfDescTipsView:OnDestroy()

end

function TeamRecruitProfDescTipsView:OnShow()

end

function TeamRecruitProfDescTipsView:OnHide()

end

function TeamRecruitProfDescTipsView:OnRegisterUIEvent()

end

function TeamRecruitProfDescTipsView:OnRegisterGameEvent()

end

function TeamRecruitProfDescTipsView:OnRegisterBinder()

end

return TeamRecruitProfDescTipsView