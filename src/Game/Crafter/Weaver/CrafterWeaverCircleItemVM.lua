local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local CrafterConfig = require("Define/CrafterConfig")

local CircleStateIndex = {
	Normal = 1,
	Green = 2,
	Yellow = 4,
	Red = 8,
	GreenYellow = 6,
    GreenRed = 10,
    YellowRed = 12
}

local WeaverCircleItemIconPath = {
    [CircleStateIndex.Normal] = CrafterConfig.WeaverCircleItemIconPath.NormalItem,
    [CircleStateIndex.Green] = CrafterConfig.WeaverCircleItemIconPath.GreenItem,
    [CircleStateIndex.Yellow] = CrafterConfig.WeaverCircleItemIconPath.YellowItem,
    [CircleStateIndex.Red] = CrafterConfig.WeaverCircleItemIconPath.RedItem,
    [CircleStateIndex.GreenYellow] = CrafterConfig.WeaverCircleItemIconPath.GreenYellowItem,
    [CircleStateIndex.GreenRed] = CrafterConfig.WeaverCircleItemIconPath.GreenRedItem,
    [CircleStateIndex.YellowRed] = CrafterConfig.WeaverCircleItemIconPath.YellowRedItem,
}

---@class CrafterWeaverCircleItemVM : UIViewModel
local CrafterWeaverCircleItemVM = LuaClass(UIViewModel)

function CrafterWeaverCircleItemVM:Ctor()
    self.CircleState = 0
    self.CircleItemPath = nil
end

function CrafterWeaverCircleItemVM:OnInit()
	
end

function CrafterWeaverCircleItemVM:OnBegin()
end

function CrafterWeaverCircleItemVM:OnEnd()
end

function CrafterWeaverCircleItemVM:OnShutdown()
    
end

function CrafterWeaverCircleItemVM:Reset()

end

function CrafterWeaverCircleItemVM:UpdateCircleItemVM(State)
    self.CircleState = State
    self.CircleItemPath = WeaverCircleItemIconPath[State]
end

return CrafterWeaverCircleItemVM