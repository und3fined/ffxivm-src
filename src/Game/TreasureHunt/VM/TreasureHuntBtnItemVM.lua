local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MajorUtil = require("Utils/MajorUtil")

local TreasureHuntBtnItemVM = LuaClass(UIViewModel)
function TreasureHuntBtnItemVM:Ctor()
    self.SkillPanelVisible = false 
    self.TreasureMarkVisible = false
end

function TreasureHuntBtnItemVM:OnInit()
end

function TreasureHuntBtnItemVM:OnShutdown()
end

function TreasureHuntBtnItemVM:UpdateBtnItem()
    local CurMapData =  _G.TreasureHuntSkillPanelVM:GetCurMapData()
    if CurMapData ~= nil then 
        if MajorUtil.IsMajorByRoleID(CurMapData.RoleID) then
            if UIViewMgr:IsViewVisible(UIViewID.TreasureHuntSkillPanel) then 
                _G.EventMgr:SendEvent(_G.EventID.TreasureHuntShowSkillBtn) 
                self.SkillPanelVisible = true 
                self.TreasureMarkVisible = false
            end 
        else
            local bMarkPoint = CurMapData.MarkPoint     
            self.SkillPanelVisible = false 
            self.TreasureMarkVisible = not bMarkPoint
        end
    end
end

return TreasureHuntBtnItemVM
