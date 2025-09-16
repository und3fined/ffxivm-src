--
-- Author: ZhengJanChuan
-- Date: 2024-07-30 15:10
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class TutorialGuideShowDropWinItemVM : UIViewModel
local TutorialGuideShowDropWinItemVM = LuaClass(UIViewModel)

---Ctor
function TutorialGuideShowDropWinItemVM:Ctor()
    self.IsSelected = nil
end

function TutorialGuideShowDropWinItemVM:OnInit()
end

function TutorialGuideShowDropWinItemVM:OnBegin()
end

function TutorialGuideShowDropWinItemVM:OnEnd()
end

function TutorialGuideShowDropWinItemVM:OnShutdown()
end

function TutorialGuideShowDropWinItemVM:OnSelectedChange(IsSelected)
    self.IsSelected = IsSelected
end



--要返回当前类
return TutorialGuideShowDropWinItemVM