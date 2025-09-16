---
--- Author: Leo
--- DateTime: 2023-04-10 09:52
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

---@class GatheringLogConditionItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgForbidden UFImage
---@field ImgServerBg UFImage
---@field ImgZoneBg UFImage
---@field PanelZone UFCanvasPanel
---@field TextCondition URichTextBox
---@field TextContent UFTextBlock
---@field TextServer UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GatheringLogConditionItemView = LuaClass(UIView, true)

function GatheringLogConditionItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgForbidden = nil
	--self.ImgServerBg = nil
	--self.ImgZoneBg = nil
	--self.PanelZone = nil
	--self.TextCondition = nil
	--self.TextContent = nil
	--self.TextServer = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GatheringLogConditionItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GatheringLogConditionItemView:OnInit()

end

function GatheringLogConditionItemView:OnDestroy()

end

function GatheringLogConditionItemView:OnShow()
    self.TextServer:SetText(_G.LSTR(70043)) --艾
end

function GatheringLogConditionItemView:OnHide()

end

function GatheringLogConditionItemView:OnRegisterUIEvent()

end

function GatheringLogConditionItemView:OnRegisterGameEvent()

end

function GatheringLogConditionItemView:OnRegisterBinder()

end

return GatheringLogConditionItemView