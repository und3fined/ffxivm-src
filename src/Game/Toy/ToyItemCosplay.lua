-- Author: MichaelYang_LightPaw
-- Date: 2025-07-28 20:45
-- Description:玩具-物品变身，变身成为地图中的一个物品，自身的所有HUD隐藏，其他玩家无法选中，靠近可以交互
--

local LuaClass = require("Core/LuaClass")
local ToyBase = require("Game/Toy/ToyBase")
local ProtoRes = require("Protocol/ProtoRes")
local CommonUtil = require("Utils/CommonUtil")

local LSTR = _G.LSTR
local FLOG_ERROR = _G.FLOG_ERROR

---@class GoldGameNewBase
local ToyItemCosplay = LuaClass(ToyBase)

function ToyItemCosplay:Ctor()
end

-- 子类继承函数 --
function ToyItemCosplay:OnInit(InToyID)
    self.ToyType = ProtoRes.ToyType.ToyTypeCosObj
    return true
end

function ToyItemCosplay:OnToyBegin(InSceneID)
    -- 禁用移动
    CommonUtil.HideJoyStick()
    CommonUtil.DisableShowJoyStick(true)
end

function ToyItemCosplay:OnToyExit()
    -- 启用移动
    CommonUtil.ShowJoyStick()
    CommonUtil.DisableShowJoyStick(true)
end

function ToyItemCosplay:OnVisionEnter(InEntityType, InEntityID)
end

function ToyItemCosplay:OnVisionLeave(InEntityType, InEntityID)
end
-- END --

return ToyItemCosplay
