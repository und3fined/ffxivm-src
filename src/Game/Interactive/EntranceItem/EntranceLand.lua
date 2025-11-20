
local LuaClass = require("Core/LuaClass")
local EntranceBase = require("Game/Interactive/EntranceItem/EntranceBase")


local EntranceLand = LuaClass(EntranceBase)

function EntranceLand:Ctor()
    self.TargetType = _G.LuaEntranceType.Land
end

function EntranceLand:OnInit()
    self.DisplayName = _G.LSTR(90034)
    self.IconPath = "Texture2D'/Game/UI/Texture/NPCTalk/UI_NPC_Icon_Mount_House.UI_NPC_Icon_Mount_House'"
end

function EntranceLand:OnUpdateDistance()
    self.Distance = 1
end

function EntranceLand:CheckInterative(EnableCheckLog, IsFromQuestUpdate)
    local ResidenceNumber = self.EntranceParams.IntParam2 or 0
    local AreaNumber = self.EntranceParams.IntParam3 or 0
    local LandNumber = self.EntranceParams.IntParam4 or 0
    return _G.HousingMgr:IsHouseBuildInBlock(ResidenceNumber,AreaNumber,LandNumber) == 0
end

function EntranceLand:OnClick()
    local Params = {}
    Params.ResidenceNumber = self.EntranceParams.IntParam2 or 0
    Params.AreaNumber = self.EntranceParams.IntParam3 or 0
    Params.LandNumber = self.EntranceParams.IntParam4 or 0
    _G.UIViewMgr:ShowView(_G.UIViewID.HouseStyleWinView, Params)
end

function EntranceLand:OnGenFunctionList()
    local FunctionList = {}

    return FunctionList
end

return EntranceLand