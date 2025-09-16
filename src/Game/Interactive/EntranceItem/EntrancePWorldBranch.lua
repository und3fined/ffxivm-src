
local LuaClass = require("Core/LuaClass")
local EntranceBase = require("Game/Interactive/EntranceItem/EntranceBase")


local EntrancePWorldBranch = LuaClass(EntranceBase)

function EntrancePWorldBranch:Ctor()
    self.TargetType = _G.LuaEntranceType.PWorldBranch
end

function EntrancePWorldBranch:OnInit()
    self.DisplayName = _G.LSTR(90013)
    self.IconPath = "PaperSprite'/Game/UI/Atlas/MapIconSnap/Frames/060453_png.060453_png'"
end

function EntrancePWorldBranch:OnUpdateDistance()
    self.Distance = 1
end

function EntrancePWorldBranch:CheckInterative(EnableCheckLog)
    return true
end

function EntrancePWorldBranch:OnClick()
    _G.UIViewMgr:ShowView(_G.UIViewID.PWorldBranchPanel)
end

function EntrancePWorldBranch:OnGenFunctionList()
    local FunctionList = {}

    return FunctionList
end

return EntrancePWorldBranch