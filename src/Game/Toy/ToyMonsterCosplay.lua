-- Author: MichaelYang_LightPaw
-- Date: 2025-07-28 20:45
-- Description:玩具-怪物变身，玩家可以变身成为一个怪物，用BUFF来做的，技能组会替换
--

local LuaClass = require("Core/LuaClass")
local ToyBase = require("Game/Toy/ToyBase")
local ProtoRes = require("Protocol/ProtoRes")

local LSTR = _G.LSTR
local FLOG_ERROR = _G.FLOG_ERROR

---@class GoldGameNewBase
local ToyMonsterCosplay = LuaClass(ToyBase)

function ToyMonsterCosplay:Ctor()
end

-- 子类继承函数 --
function ToyMonsterCosplay:OnInit(InToyID)
    self.ToyType = ProtoRes.ToyType.ToyTypeCosplay
    return true
end

function ToyMonsterCosplay:OnToyBegin(InSceneID)
end

function ToyMonsterCosplay:OnToyExit()
end

function ToyMonsterCosplay:OnVisionEnter(InEntityType, InEntityID)
end

function ToyMonsterCosplay:OnVisionLeave(InEntityType, InEntityID)
end
-- END --

return ToyMonsterCosplay
