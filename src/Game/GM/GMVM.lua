---
--- Author: v_zanchang
--- DateTime: 2021-09-28 10:35
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local GMVM2 = require("Game/GM/GMVM2")
---@class GMVM : UIViewModel
local GMVM = LuaClass(UIViewModel)

---Ctor
function GMVM:Ctor()
    self.buttonType = "按钮"
    self.sliderType = "进度条"
    self.switchType = "开关"
    self.viewType = "面板"
	self.BindableVM = UIBindableList.New()
end

---UpdateVM
function GMVM:UpdateVM(Value)
	local TableItems = {}
	for index, value in ipairs(Value) do
        if value.ShowType == self.sliderType then
            local VM = GMVM2.New()
            VM.Params = value
            VM.Desc  = "进度条index=" .. tostring(index)
            VM.ID = value.ID
            VM.WidgetIndex = 1
            local EmptyVM2 = GMVM2.New()
            EmptyVM2.Params = value
            EmptyVM2.Desc  = "index=" .. tostring(index)
            EmptyVM2.WidgetIndex = 0
            EmptyVM2.IsVisible = false
            local EmptyVM1 = GMVM2.New()
            EmptyVM1.Params = value
            EmptyVM1.Desc  = "index=" .. tostring(index)
            EmptyVM1.WidgetIndex = 0
            EmptyVM1.IsVisible = false
            -- table.insert(TableItems, 1, VM)
            table.insert(TableItems, VM)
            table.insert(TableItems, EmptyVM2)
            table.insert(TableItems, EmptyVM1)

        end
    end
	for _, value in ipairs(Value) do
        if value.ShowType == self.buttonType then
            local VM = GMVM2.New()
            VM.Params = value
            VM.Desc = value.Desc
            VM.WidgetIndex = 0
            table.insert(TableItems, VM)
        elseif value.ShowType == self.switchType then
            local VM = GMVM2.New()
            VM.Params = value
            VM.ID = value.ID
            VM.WidgetIndex = 2
            table.insert(TableItems, VM)
        end
    end

    for _, value in ipairs(Value) do
        if value.ShowType == self.viewType then
            local VM = GMVM2.New()
            VM.Params = value
            VM.Desc = value.Desc
            VM.WidgetIndex = 3
            table.insert(TableItems, VM)
        end
    end

	self.BindableVM:Update(TableItems)
end

function GMVM:GetViewByVMIndex(index)
    local Item = self.BindableVM:Get(index)
    if Item ~= nil then
        return Item.View
    end
end

return GMVM