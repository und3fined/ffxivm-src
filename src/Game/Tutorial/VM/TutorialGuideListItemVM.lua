---
---@Author: ZhengJanChuan
---@Date: 2023-06-05 16:32:48
---@Description: 
 ---


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TutorialGuideListItemVM = LuaClass(UIViewModel)

---Ctor
function TutorialGuideListItemVM:Ctor()
    self.WidgetIndex = 0

    self.Index = nil
    self.RealIndex = nil
    self.GuideID = nil
    self.Type = nil
    self.TextPlace = ""

    self.TextName = ""
    self.TextContain = ""
    self.TextNewVisible = false
    self.TextContainVisible = false
    self.IsSelected = false
    self.IsAutoExpand = false
end

function TutorialGuideListItemVM:OnInit()
end

function TutorialGuideListItemVM:OnBegin()
end

function TutorialGuideListItemVM:OnEnd()
end 

function TutorialGuideListItemVM:OnShutdown()
end

function TutorialGuideListItemVM:InitVM(Value)
    self.WidgetIndex = Value.WidgetIndex
    if self.WidgetIndex == 0 then
        self.TextPlace = Value.Title
    elseif self.WidgetIndex == 1 then
        self.TextName = Value.Title
    end

    self.Type = Value.Type
    self.Index = Value.Index
    self.RealIndex = Value.RealIndex
    self.GuideID = Value.GuideID
    self.TextNewVisible = Value.TextNewVisible
    self.ChildrenVM = {}
 
    if Value.Items and #Value.Items > 0 then
        for i = 1, #Value.Items do
            local ChildVM = TutorialGuideListItemVM.New()
            ChildVM:InitVM(Value.Items[i])
            table.insert(self.ChildrenVM, ChildVM)
        end
        self.IsAutoExpand = true
    end

end

function TutorialGuideListItemVM:AdapterOnGetWidgetIndex()
	return self.WidgetIndex
end

function TutorialGuideListItemVM:UpdateChangeState(IsSelected)
    self.IsSelected = IsSelected
end

function TutorialGuideListItemVM:OnSelectChanged(bSelected)
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	ViewModel.IsSelected = bSelected
end

function TutorialGuideListItemVM:AdapterOnGetChildren()
	return self.ChildrenVM
end

function TutorialGuideListItemVM:ChangedNewStatus()
    self.TextNewVisible = false
    _G.TutorialGuideMgr:DelRedDot(self.GuideID)
end

function TutorialGuideListItemVM:AdapterOnExpansionChanged(IsExpanded)
	self.IsAutoExpand = IsExpanded
end

function TutorialGuideListItemVM:GetKey()
	return self.GuideID
end

return TutorialGuideListItemVM
