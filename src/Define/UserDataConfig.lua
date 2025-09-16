local UserDataID = require("Define/UserDataID")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoModuleID = ProtoCommon.ModuleID
local ProtoCS = require("Protocol/ProtoCS")

---@class UserDataConfig
local UserDataConfig = {
    [UserDataID.Fate] = { ModuleID = ProtoModuleID.ModuleIDFATE, Key = ProtoCS.FateUserDataKey.FateUserDataKeyDefault, MessageName = "csproto.FateUserData" },
    [UserDataID.TreasureHunt] = { ModuleID = ProtoModuleID.ModuleIDTreasureHunt, Key = ProtoCS.Game.TreasureHunt.TreasurehuntUserDataKey.TreasurehuntUserDataKeyDefault, MessageName = "csproto.game.treasurehunt.TreasurehuntUserData" },
    [UserDataID.TreasureHuntBox] = { ModuleID = ProtoModuleID.ModuleIDTreasureHunt, Key = ProtoCS.Game.TreasureHunt.TreasurehuntUserDataKey.TreasurehuntUserDataKeyBox, MessageName = "csproto.game.treasurehunt.TreasurehuntBoxUserData" },
}

return UserDataConfig