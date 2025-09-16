local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")

local RideCfg = require("TableCfg/RideCfg")
local MountVM = require("Game/Mount/VM/MountVM")
local StoreDefine = require("Game/Store/StoreDefine")
local BindableVector2D = require("UI/BindableObject/BindableVector2D")

local MountMgr = _G.MountMgr
---@class MountGuidelineItemVM : UIViewModel
local MountGuidelineItemVM = LuaClass(UIViewModel)


function MountGuidelineItemVM:Ctor()
    self.Text = nil
    self.Offset = BindableVector2D.New()
    self.Direction = nil
end

return MountGuidelineItemVM