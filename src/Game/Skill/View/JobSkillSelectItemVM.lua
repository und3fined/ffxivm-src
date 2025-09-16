local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local WidgetPoolMgr = require("UI/WidgetPoolMgr")
local ObjectGCType = require("Define/ObjectGCType")

---@class JobSkillSelectItemVM : UIViewModel
local JobSkillSelectItemVM = LuaClass(UIViewModel)

function JobSkillSelectItemVM:Ctor()

end

function JobSkillSelectItemVM:OnInit()
    self.JobSkillIcon = ""
    self.bJobSkillShow = false
end

function JobSkillSelectItemVM:OnBegin()
end

function JobSkillSelectItemVM:OnEnd()
end

function JobSkillSelectItemVM:OnShutdown()
end

function JobSkillSelectItemVM:SetProfInfo(Params)
    if Params == nil then
        self.bJobSkillShow = false
        return
    end
    self.ProfID = Params.ProfID or 0
    self.JobSkillIcon = Params.JobSkillIcon and Params.JobSkillIcon:ToString() or ""
    if self.JobSkillIcon == "" then
        self.bJobSkillShow = false
    else
        self.bJobSkillShow = true
    end
    local SkillSystemVM = Params.SkillSystemVM
    if SkillSystemVM then
        local JobSkillDetail = Params.JobSkillDetail
        SkillSystemVM:OnSpectrumSelected(false)
        if JobSkillDetail and _G.UE.UCommonUtil.IsObjectExist(JobSkillDetail) then
            local BPName = JobSkillDetail:ToString()
            BPName = string.gsub(BPName, "/Game/UI/BP/", "")
            self.BPName = string.gsub(BPName, "%..*", "")
            local function CreateCallback(Widget)
                if self.BPName == Widget.BPName and SkillSystemVM then
                    SkillSystemVM:SetSpectrumDetailWidget(Widget)
                end
            end

            WidgetPoolMgr:CreateWidgetAsyncByName(self.BPName, ObjectGCType.NoCache, CreateCallback, true, false)
        else
            SkillSystemVM:SetSpectrumDetailWidget(nil)
        end
    end
end


return JobSkillSelectItemVM