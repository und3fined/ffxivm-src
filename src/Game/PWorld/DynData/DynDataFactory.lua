--
-- Author: sammrli
-- Date: 2023-9-5
-- Description:动态数据工厂
--

local ProtoRes = require ("Protocol/ProtoRes")
local LuaClass = require("Core/LuaClass")
local DynDataArea = require("Game/PWorld/DynData/DynDataArea")
local DynDataMapArea = require("Game/PWorld/DynData/DynDataMapArea")

---@class DynDataFactory
local DynDataFactory = LuaClass()

function DynDataFactory:Ctor()
end

---@type 创建动态区域
---@param FuncType ProtoRes.area_func_type
---@param ID number
---@return DynDataArea
function DynDataFactory:CreateArea(ID, FuncType)
    local DynData = nil
    if FuncType == ProtoRes.area_func_type.AREA_FUNC_TYPE_MAP then
        DynData = DynDataMapArea.New()
        --加入到MapAreaMgr管理
        ---@see MapAreaMgr
        _G.MapAreaMgr:Add(ID, DynData)
    else
        DynData = DynDataArea.New()
    end
    return DynData
end

return DynDataFactory