local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
--local ProtoCommon = require("Protocol/ProtoCommon")
--local MajorUtil = require("Utils/MajorUtil")

--local HaircutMgr = _G.HaircutMgr
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local HairUnlockCfg = require("TableCfg/HairUnlockCfg")
local GlobalCfg = require("TableCfg/GlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")
local GameGlobalCfg = require("TableCfg/GameGlobalCfg")

local LSTR = _G.LSTR
local BagMgr = nil
local ScoreMgr = nil
local HaircutMgr = nil

---@class HaircutWinVM : UIViewModel
local HaircutWinVM = LuaClass(UIViewModel)


function HaircutWinVM:Ctor()

    BagMgr = _G.BagMgr
    ScoreMgr = _G.ScoreMgr
    HaircutMgr = _G.HaircutMgr
    
    self.WinType =  0
    self.ItemID = nil
    self.TileText = ""
	self.SubText = ""
	self.ItemText = ""
    self.bShowItem = false
    

    self.bCheckMoney = false
	self.bShowMoney = false
    self.bMoneyEnough = false
	self.MoneyText = ""
    self.CheckBoxText = ""

    self.ItemIcon = nil
    self.MoneyIcon = nil

	self.bShowCancleBtn = true
	self.bEnableSureBtn = true
    self.ConsumeText = ""
    self.MoneneyName = ""

end
-- 部分数据初始化
function HaircutWinVM:InitViewData(WinType, ItemID)
    self.bShowItem = false
    self.bCheckMoney = false
	self.bShowMoney = false
    self.bMoneyEnough = false
    
    self.WinType = WinType
    self.ItemID = ItemID
    if WinType == HaircutMgr.HaircutWinType.HairUnlock then
        self:InitHairUnlock()
    elseif WinType == HaircutMgr.HaircutWinType.HairNotOwn then
        self:InitHairNotOwn()
    elseif WinType == HaircutMgr.HaircutWinType.UnModify then
        self:InitUnModify()
    elseif WinType == HaircutMgr.HaircutWinType.Save then
        self:InitSave()
    elseif WinType == HaircutMgr.HaircutWinType.Exist then
        self:InitExist()
    end
end

-- 解锁发型
function HaircutWinVM:InitHairUnlock()
    self.bShowItem = true
    self.bShowCancleBtn = true
    self.bShowMoney = false
    self.bEnableSureBtn = true
    self.TileText = LSTR(1250022) --"解锁发型"
    self.SubText = LSTR(1250023) --"确认要解锁该发型吗？"
    self.ConsumeText = LSTR(1250024) --"消耗"
    
    local NeedNum = 1 -- TODO 目前全为1
    local HasNum = BagMgr:GetItemNum(self.ItemID)
    self.ItemText = string.format("%d/%d", HasNum, NeedNum)
    
    local IconID = ItemUtil.GetItemIcon(self.ItemID)
	if IconID then
		self.ItemIcon = UIUtil.GetIconPath(IconID)
	end
end

-- 未解锁发型修改
function HaircutWinVM:InitHairNotOwn()
    self.bShowItem = true
    self.bShowCancleBtn = false
    self.bShowMoney = false
    self.bEnableSureBtn = true
    self.TileText = LSTR(1250025) --"提示"
    self.SubText = LSTR(1250026) --"所选发型未解锁，无法生效"
    self.ConsumeText = LSTR(1250027) --"解锁消耗"

    local NeedNum = 1 -- TODO 目前全为1
    local HasNum = BagMgr:GetItemNum(self.ItemID)
    --self.ItemText = string.format("<span color=\"#f80003ff\">%d</>/%d", HasNum, NeedNum)

    local IconID = ItemUtil.GetItemIcon(self.ItemID)
	if IconID then
		self.ItemIcon = UIUtil.GetIconPath(IconID)
	end
    if HasNum >= NeedNum then
        self.ItemText = string.format("%d/%d", HasNum, NeedNum)
    else
        self.ItemText = string.format("<span color=\"#f80003ff\">%d</>/%d", HasNum, NeedNum)
    end
end

-- 未修改
function HaircutWinVM:InitUnModify()
    self.bShowItem = false
    self.bShowCancleBtn = true
    self.bShowMoney = false
    self.bEnableSureBtn = true
    self.TileText =  LSTR(1250028) --"提示"
    self.SubText = LSTR(1250029) --"确定要中止角色容貌的编辑吗？"
end

-- 保存修改
function HaircutWinVM:InitSave()
    self.bShowItem = true
    self.bShowCancleBtn = true
    self.bShowMoney = false
    self.bEnableSureBtn = false
    self.TileText = LSTR(1250030) --"完成美容"
    self.SubText = LSTR(1250031) --"确定要完成角色美容吗？"
    self.ConsumeText = LSTR(1250032) --"消耗"
    -- 在全局配置表获取 1理发消耗物品ID， 2理发消耗物品数量， 3理发消耗金币ID， 4理发消耗金币数量
    local DefaultList = GameGlobalCfg:FindValue(ProtoRes.Game.game_global_cfg_id.GAME_CFG_BARBERSHOP_COST, "Value")
    if DefaultList == nil then
        FLOG_ERROR("DefaultList = GameGlobalCfg:FindValue is nil")
        return
    end
    -- 道具消耗
    local ItemID = DefaultList[1]
    local NeedNum = DefaultList[2]
    local HasNum = BagMgr:GetItemNum(ItemID)
    self.ItemID = ItemID

    local IconID = ItemUtil.GetItemIcon(ItemID)
	if IconID then
		self.ItemIcon = UIUtil.GetIconPath(IconID)
	end
    if HasNum >= NeedNum then
        self.bShowMoney = false
        self.bEnableSureBtn = true
        self.ItemText = string.format("%d/%d", HasNum, NeedNum)
        return
    else
        self.bShowMoney = true
        self.bEnableSureBtn = false
        self.ItemText = string.format("<span color=\"#f80003ff\">%d</>/%d", HasNum, NeedNum)
    end

    -- 代币消耗
    local MonneyID = DefaultList[3]
    local MoneyNeedNum = DefaultList[4]
    local MonneyHasNum = ScoreMgr:GetScoreValueByID(MonneyID)
    self.bMoneyEnough = MonneyHasNum >= MoneyNeedNum
    self.MoneyIcon = ScoreMgr:GetScoreIconName(MonneyID)
    self.MoneneyName = ScoreMgr:GetScoreNameText(MonneyID)
    self.CheckBoxText = string.format(LSTR(1250033), self.MoneneyName) --"材料不足消耗%s(金币)不足"
    --self.MoneyText = string.format("%d/%d", tostring(MonneyHasNum), tostring(MoneyNeedNum))
    if not self.bMoneyEnough then
        self.MoneyText = string.format(LSTR("<span color=\"#f80003ff\">%d</>"), MoneyNeedNum)..LSTR(1250034) --"<span color=\"#f80003ff\">%d</>补足"
    else
        self.MoneyText = string.format(LSTR(1250035), MoneyNeedNum) --"%d补足"
    end

end

-- 直接退出
function HaircutWinVM:InitExist()
    self.bShowItem = false
    self.bShowCancleBtn = true
    self.bShowMoney = false
    self.bEnableSureBtn = true
    self.TileText = LSTR(1250036) --"退出美容"
    self.SubText = LSTR(1250037) --"确定要退出美容吗？"
end

function HaircutWinVM:OnCheckBoxChange(bChecked)
    self.bCheckMoney = bChecked
    if bChecked == true then
        self.CheckBoxText = LSTR(1250038) --"花费"
        self.bEnableSureBtn = self.bMoneyEnough
    else
        self.CheckBoxText = LSTR(1250039)..self.MoneneyName --"材料不足消耗金币"
        self.bEnableSureBtn = false
    end
end

return HaircutWinVM