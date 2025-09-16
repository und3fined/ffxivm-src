---
--- Author: Star
--- DateTime: 2024-03-11 11:50
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local EventID = require("Define/EventID")
local RedDotItemVM = require("Game/CommonRedDot/VM/RedDotItemVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")


---@class RedDotItemView : UIView
local RedDotItemView = LuaClass(UIView, true)


function RedDotItemView:Ctor()

end

function RedDotItemView:OnRegisterSubView()

end

function RedDotItemView:OnInit()
    self:InitData()
end

function RedDotItemView:InitData()
    if not self.ItemVM then
        self.ItemVM = RedDotItemVM.New()
    end
    self.ItemVM:UpdateNodeDataByName(self.RedDotName)
end

function RedDotItemView:OnDestroy()

end

function RedDotItemView:OnShow()
    self.ItemVM:UpdateNodeDataByName(self.RedDotName)
end

function RedDotItemView:OnHide()

end

function RedDotItemView:OnRegisterUIEvent()

end

function RedDotItemView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.RedDotUpdate, self.OnUpdateRedDot)
end

--- 动态添加的红点需要自己设置名字
function RedDotItemView:SetRedDotName(RedDotName)
    self.RedDotName = RedDotName
    if self.ItemVM then
        self.ItemVM:UpdateNodeDataByName(self.RedDotName)
    else
        self:InitData()
    end
    
end

---只有叶子节点和非红点树管理的节点可以修改
function RedDotItemView:SetRedDotNum(Num)
    if self.ItemVM  then
        self.ItemVM:SetNum(Num)
    end
    
end

function RedDotItemView:GetRedDotName()
    return self.RedDotName
end

function RedDotItemView:OnUpdateRedDot(RedDotNameList)
    if self.ItemVM and  self.RedDotName then
        for _, UpDateName in ipairs(RedDotNameList) do
            if UpDateName == self.RedDotName then
                self.ItemVM:UpdateNodeDataByName(self.RedDotName)
                return
            end
        end
    end
end

function RedDotItemView:OnRegisterBinder()
    if self.Binders then
		local Binders = {
			{ "IsVisible", UIBinderSetIsVisible.New(self, self)},
		}
		for _, Binder in pairs(Binders) do
			table.insert(self.Binders, Binder)
		end
	else
		self.Binders = {
			{ "IsVisible", UIBinderSetIsVisible.New(self, self)},
		}
	end
	if self.ItemVM then
		self:RegisterBinders(self.ItemVM, self.Binders)
	end
end

function RedDotItemView:HideRedDot()
    if self.ItemVM then
        self.ItemVM:HideRedDot()
    end
end

function RedDotItemView:ShowRedDot()
    if self.ItemVM then
        self.ItemVM:ShowRedDot()
    end
end

return RedDotItemView