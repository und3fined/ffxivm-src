---
--- Author: Administrator
--- DateTime: 2025-03-18 11:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class WorldExploraSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnTips UFButton
---@field ImgIcon UFImage
---@field ImgTypeIcon UFImage
---@field PanelIcon UFCanvasPanel
---@field Slot74 CommBackpack74SlotView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldExploraSlotItemView = LuaClass(UIView, true)

function WorldExploraSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnTips = nil
	--self.ImgIcon = nil
	--self.ImgTypeIcon = nil
	--self.PanelIcon = nil
	--self.Slot74 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldExploraSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Slot74)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldExploraSlotItemView:OnInit()

end

function WorldExploraSlotItemView:OnDestroy()

end

function WorldExploraSlotItemView:OnShow()

end

function WorldExploraSlotItemView:OnHide()

end

function WorldExploraSlotItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnTips, self.OnClickButtonTips)
end

function WorldExploraSlotItemView:OnRegisterGameEvent()

end

function WorldExploraSlotItemView:OnRegisterBinder()

end
 
function WorldExploraSlotItemView:OnClickButtonTips()
	if (self.BtnTipsHelpID ~= nil) then
		_G.WorldExploraMgr:ShowInfoTips(self.BtnTips, self.BtnTipsHelpID)
	else
		_G.FLOG_INFO("BtnTipsHelpID is nil")
	end
end

function WorldExploraSlotItemView:SetButtonTipsHelpID(HelpID)
	self.BtnTipsHelpID = HelpID
end

return WorldExploraSlotItemView