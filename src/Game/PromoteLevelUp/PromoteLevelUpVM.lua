local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local PromoteLevelUpCfg = require("TableCfg/PromoteLevelUpCfg")
local ProfClassCfg = require("TableCfg/ProfClassCfg")

---@class PromoteLevelUpVM: UIViewModel
local PromoteLevelUpVM = LuaClass(UIViewModel)

function PromoteLevelUpVM:Ctor()
    self.PromoteType = 1
    self.ProfID = nil
    self.ProfClass = nil
    self.TextTitle = nil
    self.RichTextJobLevel = nil
    self.RichTextHint = nil
    self.IconJob = nil
    self.PromoteList = {}
end

function PromoteLevelUpVM:OnInit()

end

function PromoteLevelUpVM:OnShow()

end

function PromoteLevelUpVM:OnEnd()

end

function PromoteLevelUpVM:UpdateList()
    local AllList = self:GetPromoteList()
    local ProfPromoteList = {}
    for _, v in pairs(AllList) do
        if v.ProfClass and v.ProfClass ~= 0 then
            local ProfCC = ProfClassCfg:FindCfgByKey(v.ProfClass)
            if ProfCC and ProfCC.Prof and #ProfCC.Prof > 0 then
                for k, ID in pairs(ProfCC.Prof) do
                    if ID and ID == self.ProfID then
                        table.insert(ProfPromoteList, v)
                        break
                    end
                end
            end
            -- if self.ProfClass == v.ProfClass then
            --     table.insert(ProfPromoteList, v)
            -- end
        else
            table.insert(ProfPromoteList, v)
        end
    end
    
    self.PromoteList = ProfPromoteList
end

function PromoteLevelUpVM:GetPromoteList()
    local PromoteList = {}
    if self.PromoteType ~= nil then
        local Cfg = PromoteLevelUpCfg:FindAllCfg(string.format("Type = %d", self.PromoteType))
        if not Cfg then return end
        for _, v in pairs(Cfg) do
            if v ~= nil and v.ID ~= nil then
                table.insert(PromoteList, v)
            end
        end
    end

    return PromoteList
end

return PromoteLevelUpVM
