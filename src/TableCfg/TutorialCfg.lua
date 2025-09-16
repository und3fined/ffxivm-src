local LogMgr = require("Log/LogMgr")
-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class TutorialCfg : CfgBase
local TutorialCfg = {
	TableName = "c_tutorial_cfg",
    LruKeyType = nil,
	KeyName = "TutorialID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Content',
            },
            {
                Name = 'Offline',
            },
            {
                Name = 'Name',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(TutorialCfg, { __index = CfgBase })

TutorialCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function TutorialCfg:FindCfgByID(ID)
	if nil == ID then
		return
	end

	return self:FindCfgByKey(ID)
end

function TutorialCfg:GetTutorialType(ID)
	local Cfg = self:FindCfgByID(ID)
    if Cfg then
        return Cfg["Type"]
    end

	LogMgr.Info(string.format("找不到对应的Type数据 %d", ID))
	return 
end

function TutorialCfg:GetTutorialContent(ID)
	local Cfg = self:FindCfgByID(ID)
    if Cfg then
        return Cfg["Content"]
    end

	LogMgr.Info(string.format("找不到对应的Content数据 %d", ID))
	return 
end

function TutorialCfg:GetTutorialPreID(ID)
	local Cfg = self:FindCfgByID(ID)
    if Cfg then
        return Cfg["PreID"]
    end

	LogMgr.Info(string.format("找不到对应的PreID数据 %d", ID))
	return 0
end

function TutorialCfg:GetTutorialFinishedID(ID)
	local Cfg = self:FindCfgByID(ID)
    if Cfg then
        return Cfg["FinishedID"]
    end

	LogMgr.Info(string.format("找不到对应的FinishedID数据 %d", ID))
	return 0
end

function TutorialCfg:GetTutorialNextID(ID)
	local Cfg = self:FindCfgByID(ID)
    if Cfg then
        return Cfg["NextID"]
    end

	LogMgr.Info(string.format("找不到对应的NextID数据 %d", ID))
	return 
end

function TutorialCfg:GetTutorialHandleType(ID)
	local Cfg = self:FindCfgByID(ID)
    if Cfg then
        return Cfg["HandleType1"]
    end

	LogMgr.Info(string.format("找不到对应的HandleType数据 %d", ID))
	return 
end

function TutorialCfg:GetTutorialBPName(ID)
	local Cfg = self:FindCfgByID(ID)
    if Cfg then
        return Cfg["BPName"]
    end

	LogMgr.Info(string.format("找不到对应的BPName数据 %d", ID))
	return 
end

function TutorialCfg:GetTutorialWidgetPath(ID)
	local Cfg = self:FindCfgByID(ID)
    if Cfg then
        return Cfg["WidgetPath"]
    end

	LogMgr.Info(string.format("找不到对应的WidgetPath数据 %d", ID))
	return 
end

function TutorialCfg:GetTutorialGuideBPName(ID)
	local Cfg = self:FindCfgByID(ID)
    if Cfg then
        return Cfg["GuideBPName"]
    end

	LogMgr.Info(string.format("找不到对应的GuideBPName数据 %d", ID))
	return 
end

function TutorialCfg:GetTutorialGuideWidgetPath(ID)
	local Cfg = self:FindCfgByID(ID)
    if Cfg then
        return Cfg["GuideWidgetPath"]
    end

	LogMgr.Info(string.format("找不到对应的GuideWidgetPath数据 %d", ID))
	return 
end

function TutorialCfg:GetTutorialAnim(ID)
	local Cfg = self:FindCfgByID(ID)
    if Cfg then
        return Cfg["Anim"]
    end

	LogMgr.Info(string.format("找不到对应的Anim数据 %d", ID))
	return 
end

function TutorialCfg:GetTutorialAutoPlay(ID)
	local Cfg = self:FindCfgByID(ID)
    if Cfg then
        return Cfg["AutoPlay"]
    end

	LogMgr.Info(string.format("找不到对应的AutoPlay数据 %d", ID))
	return 
end

function TutorialCfg:GetTutorialEndAnim(ID)
	local Cfg = self:FindCfgByID(ID)
    if Cfg then
        return Cfg["EndAnim"]
    end

	LogMgr.Info(string.format("找不到对应的EndAnim数据 %d", ID))
	return 
end

function TutorialCfg:GetTutorialOffline(ID)
	local Cfg = self:FindCfgByID(ID)
    if Cfg then
        return Cfg["Offline1"]
    end

	LogMgr.Info(string.format("找不到对应的Offline数据 %d", ID))
	return 
end

function TutorialCfg:GetTutorialTime(ID)
	local Cfg = self:FindCfgByID(ID)
    if Cfg then
        return Cfg["Time"]
    end

	LogMgr.Info(string.format("找不到对应的Time数据 %d", ID))
	return 
end

function TutorialCfg:GetTutorialStartFuncName(ID)
	local Cfg = self:FindCfgByID(ID)
    if Cfg then
        return Cfg["StartFuncName"]
    end

	LogMgr.Info(string.format("找不到对应的StartFuncName数据 %d", ID))
	return 
end

function TutorialCfg:GetTutorialEndFuncName(ID)
	local Cfg = self:FindCfgByID(ID)
    if Cfg then
        return Cfg["EndFuncName"]
    end

	LogMgr.Info(string.format("找不到对应的EndFuncName数据 %d", ID))
	return 
end

function TutorialCfg:GetTutorialStartParam(ID)
	local Cfg = self:FindCfgByID(ID)
    if Cfg then
        return Cfg["StartParam"]
    end

	LogMgr.Info(string.format("找不到对应的StartParam数据 %d", ID))
	return 
end

function TutorialCfg:GetTutorialEndParam(ID)
 	local EndConditon = TutorialCfg:GetTutorialEnd(ID)
	if EndConditon ~= nil then
    	return EndConditon.Param
	end
	LogMgr.Info(string.format("找不到对应的EndParam数据 %d", ID))
	return 
end

function TutorialCfg:GetTutorialLeft(ID)
	local Cfg = self:FindCfgByID(ID)
    if Cfg then
        return Cfg["Left"]
    end

	LogMgr.Info(string.format("找不到对应的Left数据 %d", ID))
	return 0
end

function TutorialCfg:GetTutorialTop(ID)
	local Cfg = self:FindCfgByID(ID)
    if Cfg then
        return Cfg["Top"]
    end

	LogMgr.Info(string.format("找不到对应的Top数据 %d", ID))
	
	return 0
end

function TutorialCfg:GetTutorialCfg()
    return self:FindAllCfg()
end

function TutorialCfg:GetTutorial(ID)
	return self:FindCfgByID(ID)
end

function TutorialCfg:GetTutorialGroupID(ID)
	local Cfg = self:FindCfgByID(ID)
    if Cfg then
        return Cfg["GroupID"]
    end

	LogMgr.Info(string.format("找不到对应的GroupID数据 %d", ID))
	return 
end

function TutorialCfg:GetTutorialDir(ID)
	local Cfg = self:FindCfgByID(ID)

	if Cfg == nil then
		LogMgr.Info(string.format("找不到对应的Dir数据 %d", ID))
        return 
    end

	return Cfg["Dir"]

end

---------------------------新的------------------------
function TutorialCfg:GetTutorialStart(ID)
	local Cfg = self:FindCfgByKey(ID)
	if Cfg == nil then
		LogMgr.Info(string.format("找不到对应的Start数据 %d", ID))
        return 
    end

	return Cfg.Start
end

function TutorialCfg:GetTutorialEnd(ID)
	local Cfg = self:FindCfgByKey(ID)
	if Cfg == nil then
		LogMgr.Info(string.format("找不到对应的End数据 %d", ID))
        return 
    end

	return Cfg.End
end

return TutorialCfg
