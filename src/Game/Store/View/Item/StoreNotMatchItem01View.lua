
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

---@class StoreNotMatchItem01View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextContent URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreNotMatchItem01View = LuaClass(UIView, true)

function StoreNotMatchItem01View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreNotMatchItem01View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreNotMatchItem01View:OnInit()
end

function StoreNotMatchItem01View:OnDestroy()

end

function StoreNotMatchItem01View:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	local Data = Params.Data
	if nil == Data then
		return
	end
	self.RichTextContent:SetText(Data.Des)
end

function StoreNotMatchItem01View:OnHide()
end

function StoreNotMatchItem01View:OnRegisterUIEvent()

end

function StoreNotMatchItem01View:OnRegisterGameEvent()

end

function StoreNotMatchItem01View:OnRegisterBinder()
	
end

return StoreNotMatchItem01View