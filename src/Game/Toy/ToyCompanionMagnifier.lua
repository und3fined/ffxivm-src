-- Author: michaelyang_lightpaw
-- Date: 2025-07-28
-- Description:玩具-宠物放大镜，宠物的体型会发生改变
--

local LuaClass = require("Core/LuaClass")
local ToyBase = require("Game/Toy/ToyBase")
local ProtoRes = require("Protocol/ProtoRes")

local LSTR = _G.LSTR
local FLOG_ERROR = _G.FLOG_ERROR

---@class GoldGameNewBase
local ToyCompanionMagnifier = LuaClass(ToyBase)

function ToyCompanionMagnifier:Ctor()
end

-- 子类继承函数 --
function ToyCompanionMagnifier:OnInit(InToyID)
    self.ToyType = ProtoRes.ToyType.ToyTypePetZoomIn
    return true
end

function ToyCompanionMagnifier:OnToyBegin(InSceneID)
end

function ToyCompanionMagnifier:OnToyExit()
end

function ToyCompanionMagnifier:OnVisionEnter(InEntityType, InEntityID)
end

function ToyCompanionMagnifier:OnVisionLeave(InEntityType, InEntityID)
end
-- END --

return ToyCompanionMagnifier
