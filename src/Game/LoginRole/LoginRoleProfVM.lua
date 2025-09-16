local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
-- local MajorUtil = require("Utils/MajorUtil")

-- local ProfUtil = require("Game/Profession/ProfUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")

local ProtoCommon = require("Protocol/ProtoCommon")
local FUNCTION_TYPE = ProtoCommon.function_type
local CLASS_TYPE = ProtoCommon.class_type

local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR
---@class LoginRoleProfVM : UIViewModel
local LoginRoleProfVM = LuaClass(UIViewModel)

local ClassTypeOrder = 
{
    CLASS_TYPE.CLASS_TYPE_TANK,	-- 防护
    CLASS_TYPE.CLASS_TYPE_HEALTH,	-- 治疗
    CLASS_TYPE.CLASS_TYPE_NEAR,	-- 近战
    CLASS_TYPE.CLASS_TYPE_FAR,	-- 远程
    CLASS_TYPE.CLASS_TYPE_MAGIC,	-- 魔法
}

function LoginRoleProfVM:Ctor()
    self.ProfName = ""
    self.ProfDesc = ""
    self.ProfFuncDesc = ""
    self.JobCfgList = {}
    self.ProfHint = ""
    self.TextTips = ""
    self.bShowTextTips = false
    self.SelectProf = nil   --传入ProfCfg   --todel
    self.ProfBGLogo = ""

	self:SetNoCheckValueChange("SelectProf", true)--todel

    --该阶段的数据
    self.CurrentProf = nil          --记录当前选择的
    self.SelectProfMap = {}         --记录各个类别选择的职业    --todel
    self.IsMore = false --todel
    self.CurSelectIndex = 1
    --该阶段的数据

    --xls中配置了概率>0 并且IsCanCreate=1 的那些
    self.RandomProfList = nil   --todel
    --xls中配置了IsCanCreate=1或者IsShowWhenMore=1那些，忽略概率那个字段
    self.MoreProfList = nil --todel
    self.TotalProbabilityMap = {}   --todel
    --最下面第一排IsCanCreate=1的那些，包括概率为0的
    self.BottomFullProfList = nil --todel

    self.CanCrateProfList = {}
    self.TotalProbability = 0

    self.bBackFromPreview = false
end

function LoginRoleProfVM:OnInit()
    self.TotalProbability = 0
end

function LoginRoleProfVM:OnBegin()
end

function LoginRoleProfVM:OnEnd()
end

function LoginRoleProfVM:OnShutdown()
end

function LoginRoleProfVM:DiscardData()
    FLOG_INFO("LoginRoleProfVM:DiscardData")
    
    self.CurrentProf = nil          --记录当前选择的
    _G.LoginUIMgr:RecordProfSuit(self.CurrentProf)
    self.SelectProfMap = {}         --记录各个类别选择的职业
    self.IsMore = false
    self.CurSelectIndex = 1
end

function LoginRoleProfVM:Restore()
    self:InitProfInfoNew()

	local SaveData = _G.LoginUIMgr.LoginReConnectMgr.SaveData
    local ProfID = SaveData.ProfID
    if self.JobCfgList then
        for index = 1, #self.JobCfgList do
            local Cfg = self.JobCfgList[index]
            if Cfg and Cfg.Prof == ProfID then
                self.CurrentProf = Cfg          --记录当前选择的
                _G.LoginUIMgr:RecordProfSuit(Cfg)

                self:DoSelectProf(Cfg, index)
            end
        end
    end
end

function LoginRoleProfVM:ClearSelectProf()
    self.CurrentProf = nil          --记录当前选择的
    _G.LoginUIMgr:RecordProfSuit(self.CurrentProf)
end

------------------------------ new -------------------------------------

function LoginRoleProfVM:InitProfInfoNew()
    if #self.JobCfgList > 0 then
        -- FLOG_INFO("LoginRoleProfVM ProfInfo already init")
        return 
    end

    local ProfList = RoleInitCfg:FindAllCfg()
    if ProfList then
        local ClassNum = #ClassTypeOrder

        --可以创建的那些职业排在前面
        for Idx = 1, ClassNum do
            for index = 1, #ProfList do
                local Cfg = ProfList[index]
                if Cfg.Class == ClassTypeOrder[Idx] then
                    if Cfg.IsCanCreate == 1 then
                        self.TotalProbability = self.TotalProbability + Cfg.ProfProbability
                        table.insert(self.JobCfgList, Cfg)
        
                        -- FLOG_INFO("LoginRoleProfVM:InitProfInfo %s CanCreate, Probability:%d", Cfg.ProfName, Cfg.ProfProbability)
                    end
                end
            end
        end
        
        --不能创建的那些职业排在后面
        for Idx = 1, ClassNum do
            for index = 1, #ProfList do
                local Cfg = ProfList[index]
                if Cfg.Class == ClassTypeOrder[Idx] then
                    if Cfg.IsShowWhenMore == 1 then
                        table.insert(self.JobCfgList, Cfg)
                        -- FLOG_INFO(" ==== Login %s Cann't Create", Cfg.ProfName)
                    end
                end
            end
        end
    end
end

function LoginRoleProfVM:PreLoadProfIcons()
    self:InitProfInfoNew()
    
    if self.JobCfgList then
        for index = 1, #self.JobCfgList do
            local Cfg = self.JobCfgList[index]
            if Cfg then
                _G.ObjectMgr:LoadObjectAsync(Cfg.SimpleIcon, 0)
            end
        end
    end
end

function LoginRoleProfVM:OnSelectProf(ProfCfg)
    if ProfCfg then
        self.ProfName = ProfCfg.ProfName
        self.ProfDesc = ProfCfg.ProfDesc
        FLOG_INFO("LoginRoleProfVM:OnSelectProf %s", ProfCfg.ProfName)

        --更换选择的，都是先clear的
        if not self.CurrentProf then
            _G.LoginUIMgr:SetProfEquips(ProfCfg.Prof)
        end
        
        self.CurrentProf = ProfCfg
        self.SelectProfMap[ProfCfg.Function] = ProfCfg

        self.SelectProf = ProfCfg

    end
end

function LoginRoleProfVM:RandomProf()
    if self.CurrentProf then
        self:OnSelectProf(self.CurrentProf)
        return 
    end

    if self.JobCfgList then
        local RandomValue = math.random(1, self.TotalProbability)
        FLOG_INFO("======= Login RandonProfFromAll Random[1, %d] = %d ======", self.TotalProbability, RandomValue)

        for index = 1, #self.JobCfgList do
            local Cfg = self.JobCfgList[index]
            RandomValue = RandomValue - Cfg.ProfProbability
            if RandomValue <= 0 then
                self:DoSelectProf(Cfg, index)
                FLOG_INFO("LoginRoleProfVM random %s", Cfg.ProfName)
                return
            end
        end
    end
end

function LoginRoleProfVM:DoSelectProf(ProfCfg, CurIdx)
    if ProfCfg then
        self.ProfName = ProfCfg.ProfName
        self.ProfDesc = ProfCfg.ProfDesc
        self.ProfFuncDesc = ProfCfg.ProfFuncDesc
        self.CurSelectIndex = CurIdx
        self.ProfBGLogo = ProfCfg.LoginCreateProfIcon
        FLOG_INFO("LoginRoleProfVM:OnSelectProf %s", ProfCfg.ProfName)

        --更换选择的，都是先clear的
        if not self.bBackFromPreview then
            if not self.CurrentProf then
                _G.LoginUIMgr:SetProfEquips(ProfCfg.Prof)
            end
        else
            self.bBackFromPreview = false
        end

        if ProfCfg.IsShowWhenMore == 1 then
            self.TextTips = ProfCfg.ProfGrowUpDesc--_G.LSTR(980070)--"需游戏内转职")
            self.bShowTextTips = true
            self.ProfHint = ""
        else
            self.bShowTextTips = false
            self.ProfHint = ProfCfg.ProfGrowUpDesc
        end
        
        _G.LoginUIMgr.LoginReConnectMgr:SaveValue("ProfID", ProfCfg.Prof)
        self.CurrentProf = ProfCfg
        -- self.SelectProfMap[ProfCfg.Function] = ProfCfg

    end
end

return LoginRoleProfVM