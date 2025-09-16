
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")

local AlchemistBottleItemVM = require("Game/Crafter/Alchemist/AlchemistBottleItemVM")

---@class AlchemistMainVM : UIViewModel
local AlchemistMainVM = LuaClass(UIViewModel)


function AlchemistMainVM:Ctor()
    self.bBottleDropEnterPanel = false
    self.bBtnAdjust = false
end

function AlchemistMainVM:OnInit()
	self.BottleDragVM = AlchemistBottleItemVM.New()
end

function AlchemistMainVM:OnBegin()
end

function AlchemistMainVM:OnEnd()
end

function AlchemistMainVM:OnShutdown()
    self.BottleDragVM = nil
end

function AlchemistMainVM:Reset()
end


return AlchemistMainVM