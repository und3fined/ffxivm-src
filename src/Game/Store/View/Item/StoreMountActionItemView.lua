
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class StoreMountActionItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field ImgSelect UFImage
---@field ToggleBtnAction UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreMountActionItemView = LuaClass(UIView, true)

function StoreMountActionItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.ImgSelect = nil
	--self.ToggleBtnAction = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreMountActionItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreMountActionItemView:OnInit()
	self.Binders = {
		{"Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon)}
	}
end

function StoreMountActionItemView:OnDestroy()

end

function StoreMountActionItemView:OnShow()

end

function StoreMountActionItemView:OnHide()

end

function StoreMountActionItemView:OnRegisterUIEvent()

end

function StoreMountActionItemView:OnRegisterGameEvent()

end

function StoreMountActionItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end
	local Viewmodel = Params.Data
	if Viewmodel == nil then
		return
	end
	self:RegisterBinders(Viewmodel, self.Binders)
end

return StoreMountActionItemView