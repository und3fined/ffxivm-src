---
---@Author: ZhengJanChuan
---@Date: 2023-06-05 16:32:48
---@Description: 
 ---


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TutorialGuideListSearchItemVM = LuaClass(UIViewModel)
local LSTR = _G.LSTR

---Ctor
function TutorialGuideListSearchItemVM:Ctor()
    self.GuideID = nil --指南ID
    self.Index = nil  --排序位置
    self.TextName = ""
    self.TextContain = ""
    self.TextContainVisible = false
    self.IsSelected = false
    self.TextNewVisible = false
end

function TutorialGuideListSearchItemVM:OnInit()
end

function TutorialGuideListSearchItemVM:OnBegin()
end

function TutorialGuideListSearchItemVM:OnEnd()
end 

function TutorialGuideListSearchItemVM:OnShutdown()
end

function TutorialGuideListSearchItemVM:UpdateItemInfo(Data)
    self.TextName = Data.Title
    self.Index = Data.Index
    self.GuideID = Data.GuideID
    self.IsNew = Data.IsNew
end

function TutorialGuideListSearchItemVM:UpdateChangeState(IsSelected)
    self.IsSelected = IsSelected
end

function TutorialGuideListSearchItemVM:UpdateNew(IsNew)
    self.IsNew = false
end

function TutorialGuideListSearchItemVM:AdapterOnGetWidgetIndex()
    return self.ID
end


return TutorialGuideListSearchItemVM
