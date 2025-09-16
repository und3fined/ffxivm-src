local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local PhotoTemplateVM = LuaClass(UIViewModel)
local UIBindableList = require("UI/UIBindableList")
local PhotoTemplateUtil = require("Game/Photo/Util/PhotoTemplateUtil")

-- local ItemVM = require("Game/Item/ItemVM")
local PhotoTemplateItemVM = require("Game/Photo/ItemVM/PhotoTemplateItemVM")

local LSTR = _G.LSTR

local PhotoMgr


function PhotoTemplateVM:Ctor()
    self.Templates = UIBindableList.New(PhotoTemplateItemVM)
    self.BtnImage = ""
    self.CurItemVM = nil
end

function PhotoTemplateVM:OnInit()
end

function PhotoTemplateVM:OnBegin()
    -- PWorldQuestMgr = _G.PWorldQuestMgr
    -- PWorldTeamMgr = _G.PWorldTeamMgr

    PhotoMgr = _G.PhotoMgr
end

function PhotoTemplateVM:OnEnd()
end

function PhotoTemplateVM:OnShutdown()
end

function PhotoTemplateVM:Clear()
    self.CurItemVM = nil
end

function PhotoTemplateVM:UpdateVM()
    self:UpdTemplates()
end

function PhotoTemplateVM:UpdTemplates()
    -- self.CurItemVM = nil
    self.TemplateData = {}

    local CustList = PhotoMgr.CustTemplateList
    local CfgList = PhotoMgr.CfgTemplateList

    for Idx, Temp in pairs(CustList) do
        local BaseInfo = PhotoTemplateUtil.GetBaseInfo(Temp)
        if BaseInfo then
            local Item = {
                IsCust = true,
                ID = BaseInfo.ID
            }
            table.insert(self.TemplateData, Item)
        end
    end

    for Idx, Temp in pairs(CfgList) do
        local BaseInfo = PhotoTemplateUtil.GetBaseInfo(Temp)
        if BaseInfo then
            local Item = {
                IsCust = false,
                ID = BaseInfo.ID
            }

            table.insert(self.TemplateData, Item)
        end
    end

    self.BtnImage = #CustList >= 5 and "PaperSprite'/Game/UI/Atlas/Button/Frames/UI_Comm_Btn_Plus_Disab_png.UI_Comm_Btn_Plus_Disab_png'" or "PaperSprite'/Game/UI/Atlas/Button/Frames/UI_Comm_Btn_Plus_png.UI_Comm_Btn_Plus_png'"

    self.Templates:UpdateByValues(self.TemplateData)
end

-- function PhotoTemplateVM:OnTimer()
-- end

return PhotoTemplateVM