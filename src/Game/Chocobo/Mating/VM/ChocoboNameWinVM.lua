--Author:Easy
--DateTime: 2023/1/10

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local ChocoboNameCfg = require("TableCfg/ChocoboNameCfg")
local UIBindableList = require("UI/UIBindableList")
local ChocoboNameVM = require("Game/Chocobo/Mating/VM/ChocoboNameVM")

local ChocoboNameWinVM = LuaClass(UIViewModel)
function ChocoboNameWinVM:Ctor()
    self.WordList = UIBindableList.New(ChocoboNameVM)
end

function ChocoboNameWinVM:UpdateItem(Index)
    local WordList = {}
    local NameCfg = ChocoboNameCfg:FindAllCfg(string.format("Category=%d", Index))
    if NameCfg ~= nil then 
        for _,V in pairs(NameCfg) do
            if string.len(V.Name) > 0 then
                local Name = {ID = V.ID,Name = V.Name}
                table.insert(WordList,Name)
            end
        end
    end
    self.WordList:UpdateByValues(WordList)
end

return ChocoboNameWinVM
