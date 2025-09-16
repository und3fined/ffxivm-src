local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ScoreSummaryCfg = require("TableCfg/ScoreSummaryCfg")
local ScoreCfg = require("TableCfg/ScoreCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemDefine = require("Game/Item/ItemDefine")

------ 已弃用
---@class EquipmentCurrencyListItemVM : UIViewModel
local EquipmentCurrencyListItemVM = LuaClass(UIViewModel)

function EquipmentCurrencyListItemVM:Ctor()
    self.ScoreID = 0
    self.ShopID = 0
	self.ItemIcon = ""						-- Icon路径
    self.TextItemName = ""
    self.TextItemNum = 0
    self.CurrencyTitle = ""
    self.TextCountDown = ""             -- 转化倒计时
    self.TargetIcon = ""                -- 目标Icon路径
    self.JumpIconPath = ""
	self.BtnShopIsVisible = false
	self.IsLock = false					-- 军票锁
	self.QualityIcon = ""				--- 品质色
	self.TargetImgQuanlity = ""			--- 品质色
	self.NumVisible = false
	self.IconChooseVisible = false
	self.IsShowTextLevel = false
	self.IsDuringConvertimeCD = false		--- 是否正在倒计时
    self.WeekUpperVisible = false      ---是否显示周获取上限
end

function EquipmentCurrencyListItemVM:UpdateVM(Value)
    local ScoreID = Value.ScoreID
	self.JumpIconPath = Value.JumpIconPath
    local Cfg = ScoreSummaryCfg:FindCfgByKey(ScoreID)
    if Cfg == nil then
        _G.FLOG_ERROR("ScoreSummaryCfg:FindCfgByKey Is Nil ScoreID=%d", ScoreID)
        return
    end
    self.ScoreTableCfg = ScoreCfg:FindCfgByKey(ScoreID)
    if self.ScoreTableCfg == nil then
        _G.FLOG_ERROR("ScoreCfg:FindCfgByKey Is Nil ScoreID=%d", ScoreID)
        return
    end
    local Desc = self.ScoreTableCfg.Desc
    self.ScoreID = ScoreID
    self.ShopID = Cfg.ShopID
	self.IsLock = Value.IsLock				-- 军票锁
	self.TextItemName = Cfg.NameText
	if ScoreID == ProtoRes.SCORE_TYPE.SCORE_TYPE_STAMPS or ScoreID == ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE then
		self.BtnShopIsVisible = true
	else
		self.BtnShopIsVisible = Cfg.ShopID ~= 0
	end
	self.QualityIcon = ""
	self.TargetImgQuanlity = ""
	
	local TempItemCfg = ItemCfg:FindCfgByKey(ScoreID)
	if TempItemCfg ~= nil then
		self.QualityIcon = ItemDefine.ItemIconColorType[TempItemCfg.ItemColor]
	end

    self.ItemIcon = self.ScoreTableCfg.IconName
    self.Desc = Desc
	--- 军票才有SealLevel参数
	if Value.SealLevel and Value.SealLevel > 0 then
		self.ImgInfoIsVisible = self.IsLock
		local SealID = Value.SealID
		local SealScoreMaxValue = _G.CompanySealMgr.CompanyRankList[SealID][Value.SealLevel].CompanySealMax
		self.TextItemNum = string.format("%s%s%s", self:ConvertCurrencyToDollar(Value.ScoreNum), "/", self:ConvertCurrencyToDollar(SealScoreMaxValue))
	else
		if Cfg.IsUpperLimit > 0 then
			self.TextItemNum = string.format("%s%s%s", self:ConvertCurrencyToDollar(Value.ScoreNum), "/", self:ConvertCurrencyToDollar(self.ScoreTableCfg.MaxValue))
		else
			self.TextItemNum = self:ConvertCurrencyToDollar(Value.ScoreNum)
		end
		self.ImgInfoIsVisible = Desc > 0
	end

    if self.ScoreTableCfg.TargetScore == 0 then -- 转化目标ID为零不做转化处理
        return
	else
		local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
        local year, month, day, hour, min, sec = self.ScoreTableCfg.NextConvertTime:match(pattern)
        local timestamp = os.time({ year = year, month = month, day = day, hour = hour, min = min, sec = sec})
        local servertime = _G.TimeUtil.GetServerTime()
        local TampTime =  timestamp - servertime
		self.IsDuringConvertimeCD = TampTime <= self.ScoreTableCfg.TimeInterval and TampTime > 0
    end

	local TargetScoreID = self.ScoreTableCfg.TargetScore
    local TargetScoreCfg = ScoreCfg:FindCfgByKey(TargetScoreID)

    if TargetScoreCfg ~= nil then
        self.TargetIcon = TargetScoreCfg.IconName
    end
    if TargetScoreCfg == nil then
        _G.FLOG_ERROR("ScoreCfg:FindCfgByKey Is Nil ScoreID=%d", TargetScoreID)
        return
    end
	local TempTargetItemCfg = ItemCfg:FindCfgByKey(TargetScoreID)
	if TempTargetItemCfg ~= nil then
		self.TargetImgQuanlity = ItemDefine.ItemIconColorType[TempTargetItemCfg.ItemColor]
	end
	
    --- 目前只有创世石有周上限
    self.WeekUpperVisible = self.ScoreID == ProtoRes.SCORE_TYPE.SCORE_TYPE_CREATE_WORLD
    if nil~= self.ScoreTableCfg.WeekUpper then
        self.WeekUpperFloatNum = self.ScoreTableCfg.WeekUpper.Float
        self.WeekUpperFixedNum = self.ScoreTableCfg.WeekUpper.Fixed
        --- 目前的判断条件只有一个
        if(_G.BattlePassMgr:GetBattlePassGrade() == self.ScoreTableCfg.WeekUpper.CondValues[1]) then
            self.WeekUpperNum = self.WeekUpperFloatNum
        else
            self.WeekUpperNum = self.WeekUpperFixedNum
        end
		---  									每周上限：
        self.WeekUpperText = string.format(LSTR(490008), 0, self.WeekUpperNum)
    end
    ---根据战令等级设置Icon
    if _G.BattlePassMgr:GetBattlePassGrade() == 3 then
        self.IconBPIconPath = "Texture2D'/Game/UI/Texture/Equipment/UI_Equipment_Icon_BP1.UI_Equipment_Icon_BP1"
    else
        self.IconBPIconPath = "Texture2D'/Game/UI/Texture/Equipment/UI_Equipment_Icon_BP2.UI_Equipment_Icon_BP2"
    end
end

function EquipmentCurrencyListItemVM:IsEqualVM(Value)
	return Value
end

function EquipmentCurrencyListItemVM:AdapterOnGetWidgetIndex()
    return 1
end

function EquipmentCurrencyListItemVM:ConvertCurrencyToDollar(CurrencyNum)
    local Result = tostring(CurrencyNum)
    Result = string.reverse(Result)
    local NewStr = ""
    local SubStepLen = 3
    local Index = 1
    local Len = string.len(Result)
    for _ = 1, Len do
        if Index > Len then
            break
        end
        if Index > SubStepLen then
            NewStr = string.format("%s%s", NewStr, ",")
        end
        NewStr = string.format("%s%s", NewStr, string.char(string.byte(Result, Index)))
        if Index + 1 > Len then
            break
        end
        NewStr = string.format("%s%s", NewStr, string.char(string.byte(Result, Index + 1)))
        if Index + 2 > Len then
            break
        end
        NewStr = string.format("%s%s", NewStr, string.char(string.byte(Result, Index + 2)))
        Index = Index + SubStepLen
    end
    return string.reverse(NewStr)
end

function EquipmentCurrencyListItemVM:Convert(Result, CurrencyNum)
    if CurrencyNum / 1000 >= 1 then
        Result = string.format("%s%s", Result, self:Convert(Result, CurrencyNum))
        _G.FLOG_INFO("value assigned to variable 'Result' is unuse : EquipmentCurrencyListItemVM Convert: %s", Result)
    else
        Result = tostring(CurrencyNum % 1000)
        CurrencyNum = CurrencyNum / 1000
        _G.FLOG_INFO("value assigned to variable 'Result' is unuse:EquipmentCurrencyListItemVM Convert: %s", Result)
        _G.FLOG_INFO("value assigned to variable 'CurrencyNum' is unuse:EquipmentCurrencyListItemVM Convert: %s", CurrencyNum)
    end
end

---@param WeekUpperVisible boolean 是否显示周获取上限提示
---@param HasGetNum number 本周已经获取的数量
function EquipmentCurrencyListItemVM:UpdateWeekUpperInfo(HasGetNum)
    self.WeekUpperText = string.format(LSTR(490008), HasGetNum, self.WeekUpperNum)
end
return EquipmentCurrencyListItemVM


