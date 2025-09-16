---
--- Author: xingcaicao
--- DateTime: 2023-08-18 20:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CommDropDownExtendItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field ImgIcon UFImage
---@field TextContent UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommDropDownExtendItemView = LuaClass(UIView, true)

function CommDropDownExtendItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClick = nil
	--self.ImgIcon = nil
	--self.TextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommDropDownExtendItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommDropDownExtendItemView:OnInit()

end

function CommDropDownExtendItemView:OnDestroy()

end

function CommDropDownExtendItemView:OnShow()

end

function CommDropDownExtendItemView:OnHide()

end

function CommDropDownExtendItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnClickButtonCLick)
end

function CommDropDownExtendItemView:OnRegisterGameEvent()

end

function CommDropDownExtendItemView:OnRegisterBinder()

end

---@param ClickCBFunc function @扩展项被点击回调函数
---@param IsVisible boolean @扩展项是否可见
function CommDropDownExtendItemView:SetData( Name, ClickCBFunc )
	-- 名称
	self.TextContent:SetText(Name or "")

	-- 回调函数
	self.ClickCBFunc = ClickCBFunc
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function CommDropDownExtendItemView:OnClickButtonCLick()
	if self.ClickCBFunc then
		self.ClickCBFunc()
	end
end

function CommDropDownExtendItemView:SetStyle(ExtendImgIcon)
	self.ImgIcon:SetBrush(ExtendImgIcon)
end

return CommDropDownExtendItemView