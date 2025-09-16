---
--- Author: Administrator
--- DateTime: 2024-01-23 09:37
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ChocoboLevelUpTipsVM = require("Game/Chocobo/Life/VM/ChocoboLevelUpTipsVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class ChocoboLevelUpTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewAttri UTableView
---@field AnimMission UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboLevelUpTipsView = LuaClass(UIView, true)

function ChocoboLevelUpTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewAttri = nil
	--self.AnimMission = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboLevelUpTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboLevelUpTipsView:OnInit()
    self.ViewModel = ChocoboLevelUpTipsVM.New()
    self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewAttri, nil, nil)
end

function ChocoboLevelUpTipsView:OnDestroy()

end

function ChocoboLevelUpTipsView:OnShow()
    self:PlayAnimation(self.AnimMission)
end

function ChocoboLevelUpTipsView:OnHide()

end

function ChocoboLevelUpTipsView:OnRegisterUIEvent()

end

function ChocoboLevelUpTipsView:OnRegisterGameEvent()

end

function ChocoboLevelUpTipsView:OnAnimationFinished(Anim)
    if Anim == self.AnimMission then
        UIViewMgr:HideView(UIViewID.ChocoboLevelUpTipsView)
    end
end

function ChocoboLevelUpTipsView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end
    
    self.ViewModel:UpdateVM(Params)
    local Binders = {
        { "TableViewList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
    }
    self:RegisterBinders(self.ViewModel, Binders)
end

return ChocoboLevelUpTipsView