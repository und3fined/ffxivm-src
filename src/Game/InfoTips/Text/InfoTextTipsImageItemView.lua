---
--- Author: Administrator
--- DateTime: 2024-08-27 15:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class InfoTextTipsImageItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelCards UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local InfoTextTipsImageItemView = LuaClass(UIView, true)

function InfoTextTipsImageItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelCards = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function InfoTextTipsImageItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function InfoTextTipsImageItemView:OnInit()

end

function InfoTextTipsImageItemView:OnDestroy()

end

function InfoTextTipsImageItemView:OnShow()

end

function InfoTextTipsImageItemView:OnHide()

end

function InfoTextTipsImageItemView:OnRegisterUIEvent()

end

function InfoTextTipsImageItemView:OnRegisterGameEvent()

end

function InfoTextTipsImageItemView:OnRegisterBinder()

end

---SetImagePanel 设置显示面板
---@param ImagePanel string  @显示面板名字
function InfoTextTipsImageItemView:SetImagePanel(ImagePanel)
	if ImagePanel == nil then
		return
	end
	UIUtil.SetIsVisible(self.PanelCards, self[ImagePanel] == self.PanelCards)
end

return InfoTextTipsImageItemView