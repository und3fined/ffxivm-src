---
--- Author: Administrator
--- DateTime: 2023-12-14 15:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class ChocoboStarPanelItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBG UFImage
---@field TableViewBlue UTableView
---@field TableViewRed UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboStarPanelItemView = LuaClass(UIView, true)

function ChocoboStarPanelItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBG = nil
	--self.TableViewBlue = nil
	--self.TableViewRed = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboStarPanelItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboStarPanelItemView:OnInit()
    self.BlueStarTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewBlue, nil, nil)
    self.RedStarTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewRed, nil, nil)
end

function ChocoboStarPanelItemView:OnDestroy()

end

function ChocoboStarPanelItemView:OnShow()

end

function ChocoboStarPanelItemView:OnHide()

end

function ChocoboStarPanelItemView:OnRegisterUIEvent()

end

function ChocoboStarPanelItemView:OnRegisterGameEvent()

end

function ChocoboStarPanelItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end

    local Data = Params.Data
    if nil == Data then
        return
    end

    local ViewModel = Data
    self.VM = ViewModel

    if not self.Binders then
        self.Binders = {
            { "BlueStarTableView", UIBinderUpdateBindableList.New(self, self.BlueStarTableView) },
            { "RedStarTableView", UIBinderUpdateBindableList.New(self, self.RedStarTableView) },
        }
    end
    self:RegisterBinders(ViewModel, self.Binders)
end

return ChocoboStarPanelItemView