
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")

---@class CrafterMainPanelVM : UIViewModel
local CrafterMainPanelVM = LuaClass(UIViewModel)


function CrafterMainPanelVM:Ctor()
    self.EventSkillRsp = {}
end

function CrafterMainPanelVM:OnInit()
end

function CrafterMainPanelVM:OnBegin()
end

function CrafterMainPanelVM:OnEnd()
end

function CrafterMainPanelVM:OnShutdown()
end

function CrafterMainPanelVM:Reset()
end

--加工
function CrafterMainPanelVM:OnProcess()
    FLOG_INFO("Crafter OnProcess 加工 skillIdx: 2")
    _G.CrafterMgr:CastLifeSkill(2)
end

--制作
function CrafterMainPanelVM:OnMake()
    FLOG_INFO("Crafter OnProcess 制作 skillIdx: 1")
    _G.CrafterMgr:CastLifeSkill(1)
end

--加热
function CrafterMainPanelVM:OnHeat()
    FLOG_INFO("Crafter OnProcess 加热 skillIdx: 3")
    _G.CrafterMgr:CastLifeSkill(3)
end

--放弃
function CrafterMainPanelVM:QuitMake()
    _G.CrafterMgr:QuitMake()
end

--加催化剂
function CrafterMainPanelVM:OnAddCatalyst(SkillIdx)
    FLOG_INFO("Crafter OnAddCatalyst 加催化剂 skillIdx: %d", SkillIdx)
    _G.CrafterMgr:CastLifeSkill(SkillIdx)
end

--释放随机事件的应对技能
function CrafterMainPanelVM:OnRandomEventSkill(SkillIdx)
    FLOG_INFO("Crafter OnRandomEventSkill 随机事件应对技能 skillIdx: %d", SkillIdx)
    _G.CrafterMgr:CastLifeSkill(SkillIdx)
end

--StartMake的回包，处理界面刷新
--现在onshow直接处理了（临时界面）
function CrafterMainPanelVM:UpdateStartMakeRsp(StartMakeRsp)
    -- 后续属性绑定的方式 todo
end

--技能的回包，处理界面刷新，随机事件
function CrafterMainPanelVM:UpdateSkillRsp(MsgBody)
    self.EventSkillRsp = MsgBody.CrafterSkill
end

return CrafterMainPanelVM