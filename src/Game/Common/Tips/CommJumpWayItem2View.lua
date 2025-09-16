---
--- Author: Administrator
--- DateTime: 2024-07-16 14:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CommJumpWayItem2View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGo UFButton
---@field ImgArrow UFImage
---@field ImgItemBg UFImage
---@field ImgItemBgSelect UFImage
---@field ImgItemIcon UFImage
---@field TextQuestName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommJumpWayItem2View = LuaClass(UIView, true)

function CommJumpWayItem2View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGo = nil
	--self.ImgArrow = nil
	--self.ImgItemBg = nil
	--self.ImgItemBgSelect = nil
	--self.ImgItemIcon = nil
	--self.TextQuestName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommJumpWayItem2View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommJumpWayItem2View:OnInit()
	self.Owner = nil
	self.Callback = nil
end

function CommJumpWayItem2View:OnDestroy()

end

function CommJumpWayItem2View:OnShow()

end

function CommJumpWayItem2View:OnHide()

end

function CommJumpWayItem2View:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGo, self.OnClickBtnGo)

end

function CommJumpWayItem2View:OnRegisterGameEvent()

end

function CommJumpWayItem2View:OnRegisterBinder()

end

function CommJumpWayItem2View:SetIcon(Icon)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgItemIcon,Icon)
end

function CommJumpWayItem2View:SetText(Text)
	self.TextQuestName:SetText(Text)
end

function CommJumpWayItem2View:SetIsShowArrow(IsShow)
	UIUtil.SetIsVisible(self.ImgArrow, IsShow)
end

function CommJumpWayItem2View:SetCallback(Owner, Callback)
	self.Owner = Owner
	self.Callback = Callback
end

function CommJumpWayItem2View:OnClickBtnGo()
	if self.Owner and self.Callback then
		self.Callback(self.Owner)
	end
end

return CommJumpWayItem2View