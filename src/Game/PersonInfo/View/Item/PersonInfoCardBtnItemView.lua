---
--- Author: Administrator
--- DateTime: 2024-08-15 20:12
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local PersonInfoVM = require("Game/PersonInfo/VM/PersonInfoVM")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local PersonInfoDefine = require("Game/PersonInfo/PersonInfoDefine")
local PopupBtnType = PersonInfoDefine.PopupBtnType

---@class PersonInfoCardBtnItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field TextHomepage UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoCardBtnItemView = LuaClass(UIView, true)

function PersonInfoCardBtnItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.TextHomepage = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoCardBtnItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoCardBtnItemView:OnInit()
	self.Binders = {
		{ "BtnIcon", 		UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "Name", 			UIBinderSetText.New(self, self.TextHomepage) },
	}
end

function PersonInfoCardBtnItemView:OnDestroy()

end

function PersonInfoCardBtnItemView:OnShow()

end

function PersonInfoCardBtnItemView:OnHide()

end

function PersonInfoCardBtnItemView:OnRegisterUIEvent()
	-- UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnClickButtonFunction)
end

function PersonInfoCardBtnItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	local ViewModel = Params.Data
	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

return PersonInfoCardBtnItemView