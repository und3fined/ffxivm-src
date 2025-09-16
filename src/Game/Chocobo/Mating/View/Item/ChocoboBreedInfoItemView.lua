---
--- Author: Administrator
--- DateTime: 2024-01-15 12:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class ChocoboBreedInfoItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field TableViewBlueStar UTableView
---@field TableViewRedStar UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboBreedInfoItemView = LuaClass(UIView, true)

function ChocoboBreedInfoItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.TableViewBlueStar = nil
	--self.TableViewRedStar = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboBreedInfoItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboBreedInfoItemView:OnInit()
    self.BlueStarTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewBlueStar, nil, nil)
    self.RedStarTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewRedStar, nil, nil)
end

function ChocoboBreedInfoItemView:OnDestroy()

end

function ChocoboBreedInfoItemView:OnShow()

end

function ChocoboBreedInfoItemView:OnHide()
end

function ChocoboBreedInfoItemView:OnRegisterUIEvent()

end

function ChocoboBreedInfoItemView:OnRegisterGameEvent()

end

function ChocoboBreedInfoItemView:OnRegisterBinder()
 local Params = self.Params
    if nil == Params then
        return
    end

    local Data = Params.Data
    if nil == Data then
        return
    end

    local ViewModel = Data
    self.ViewModel = ViewModel

    local Binders = {
        { "AttrIconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
        { "BlueStarTableView", UIBinderUpdateBindableList.New(self, self.BlueStarTableView) },
        { "RedStarTableView", UIBinderUpdateBindableList.New(self, self.RedStarTableView) },
    }
    self:RegisterBinders(ViewModel, Binders)
end

return ChocoboBreedInfoItemView