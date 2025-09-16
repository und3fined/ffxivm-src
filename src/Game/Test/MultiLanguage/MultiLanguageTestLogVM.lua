---
--- Author: sammrli
--- DateTime: 2023-05-22 15:46
--- Description:野外测试工具列表item ViewModel
---


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class MultiLanguageTestLogVM : UIViewModel
local MultiLanguageTestLogVM = LuaClass(UIViewModel)

function MultiLanguageTestLogVM:Ctor()
    self.Text = ""
end


function MultiLanguageTestLogVM:UpdateVM(Value)
    -- FLOG_INFO(string.format("koff MultiLanguageTestLogVM:UpdateVM"))

    self.Text = tostring(Value.Text)
end

function MultiLanguageTestLogVM:AdapterOnGetCanBeSelected()
	return true
end

function MultiLanguageTestLogVM:AdapterOnGetWidgetIndex()
    return 0
end

return MultiLanguageTestLogVM
