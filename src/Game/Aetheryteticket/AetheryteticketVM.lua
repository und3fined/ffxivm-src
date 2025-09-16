local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local AetheryteticketItemVM = require("Game/Aetheryteticket/ItemVM/AetheryteticketItemVM")

local AetheryteticketVM = LuaClass(UIViewModel)

function AetheryteticketVM:Ctor()

end

function AetheryteticketVM:OnInit()
    self.AetheryteticketList = UIBindableList.New(AetheryteticketItemVM)
end

function AetheryteticketVM:OnBegin()

end

function AetheryteticketVM:UpdateVM(Value)

end

function AetheryteticketVM:OnShutdown()

end

function AetheryteticketVM:OnEnd()

end

--- @type 更新列表
--- @param
function AetheryteticketVM:UpdateAetheryteticketList(Data)
    local List = self.AetheryteticketList
    if List == nil then
        return
    end

    if Data[1] == nil then
        List:Clear()
        return
    end

    if nil ~= List and List:Length() > 0 then
        List:Clear()
    end

    List:UpdateByValues(Data)
end

return AetheryteticketVM