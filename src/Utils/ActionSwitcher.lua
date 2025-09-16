local LuaClass = require("Core/LuaClass")

local M = LuaClass()

function M:Ctor(Dict, ActiveAction, PassiveAction, StartKey)
    self._Dict = Dict
    self._ActiveAction = ActiveAction
    self._PasstiveAction = PassiveAction

    if nil ~= StartKey then
        self:Switch(StartKey)
    end
end

function M:_Cancel()
    for key, value in pairs(self._Dict) do
        if key ~= self._CurKey then
            self._PasstiveAction(value)
        end
    end
end

function M:Switch(Key, ...)
    if Key == self._CurKey then
        return
    end
    if nil == self._Dict[Key] then
        return
    end

    self._CurKey = Key
    local Hit = self._Dict[Key]

    self:_Cancel()
    if self._ActiveAction then
        self._ActiveAction(Hit, ...)
    end
end

function M:Clear()
    self._CurKey = nil
    self:_Cancel()
end

return M
