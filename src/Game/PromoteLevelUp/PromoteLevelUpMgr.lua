local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local UIViewID = require("Define/UIViewID")
local ProtoRes = require("Protocol/ProtoRes")
local ViewVM = require("Game/PromoteLevelUp/PromoteLevelUpVM")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ActorMgr = require("Game/Actor/ActorMgr")
local PromoteDefine = require("Game/PromoteLevelUp/PromoteLevelUpDefine")
local ItemUtil = require("Utils/ItemUtil")
local ItemGetaccesstypeCfg = require("TableCfg/ItemGetaccesstypeCfg")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local EventID = require("Define/EventID")

local LSTR = nil
local UIViewMgr = nil

---@class PromoteLevelUpMgr : MgrBase
local PromoteLevelUpMgr = LuaClass(MgrBase)

function PromoteLevelUpMgr:OnInit()

    LSTR = _G.LSTR
    UIViewMgr = _G.UIViewMgr
    if not ViewVM then
        ViewVM = _G.PromoteLevelUpVM
    end

end

function PromoteLevelUpMgr:OnBegin()

end

function PromoteLevelUpMgr:OnHide()

end

function PromoteLevelUpMgr:OnEnd()

end

function PromoteLevelUpMgr:OnRegisterNetMsg()

end

function PromoteLevelUpMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ShowPromoteMainPanel, self.OnShowPromoteMainPanel)
end

---【入口】
function PromoteLevelUpMgr:OnShowPromoteMainPanel(Params)
    self:ShowPromoteMainPanel(Params) 
end

--- 打开提升聚合界面
---@param Params.TypeNum 提升类型 1战斗职业,2生产职业,3装备
---@param Params.ProfID  职业 （选填，默认当前职业）
function PromoteLevelUpMgr:ShowPromoteMainPanel(Params)
    if Params == nil then return end
    local TypeNum = 1
    TypeNum = table.is_nil_empty(Params) and Params or Params.TypeNum
    if not ViewVM then return end
    ViewVM.PromoteType = TypeNum    --设置类型
    local IconPath = nil
    local Level = 0
    local ProfName = ""
    local ProfClass = nil
    local RoleDetail = ActorMgr:GetMajorRoleDetail()
    local DetailProf = RoleDetail and RoleDetail.Prof
    local ProfList = DetailProf and DetailProf.ProfList or {}
    
    if TypeNum == ProtoRes.promote_type.PROMOTE_TYPE_COMBAT then  --战斗职业等级
        local ProfID = 1
        if table.is_array(Params) and nil ~= Params.Prof then
            ProfID = Params.Prof
        elseif MajorUtil.GetMajorAttributeComponent() then
            ProfID = MajorUtil.GetMajorAttributeComponent().ProfID
        end
        local ProfInfo = RoleInitCfg:FindCfgByKey(ProfID)
        if ProfInfo then
            IconPath = ProfInfo.SimpleIcon3
            ProfName = ProfInfo.ProfName
            ProfClass = ProfInfo.Class
        end

        Level = ProfList[ProfID] and ProfList[ProfID].Level
        if nil == Level then
            print("[PromoteLevelUpMgr] ShowPromoteMainPanel Level is nil")
            Level = 0
        end
        Level = string.format("<span color=\"#b56728\">%d%s</>", Level, LSTR("1540007"))
        ViewVM.TextTitle = LSTR("1540001")      --"职业等级提升"
        ViewVM.RichTextJobLevel = ProfName .. "  " .. Level
        ViewVM.RichTextHint = LSTR("1540004")   --"当前职业等级不足，可参与下方内容快速提升"
        ViewVM.IconJob = IconPath
        ViewVM.ProfID = ProfID
        ViewVM.ProfClass = ProfClass

    elseif TypeNum == ProtoRes.promote_type.PROMOTE_TYPE_PRODUCTION then  --生产职业等级
        local ProfID = 1
        if table.is_array(Params) and nil ~= Params.Prof then
            ProfID = Params.Prof
        elseif MajorUtil.GetMajorAttributeComponent() then
            ProfID = MajorUtil.GetMajorAttributeComponent().ProfID
        end
        local Specialization = RoleInitCfg:FindProfSpecialization(ProfID)
	    local bCrafterProf = Specialization ~= ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION
	    if bCrafterProf then   -- 若当前非生产职业，则默认首个生产职业
            ProfID = ProtoCommon.prof_type.PROF_TYPE_BLACKSMITH
        end
        local ProfInfo = RoleInitCfg:FindCfgByKey(ProfID)
        if ProfInfo then
            IconPath = ProfInfo.SimpleIcon3
            ProfName = ProfInfo.ProfName
            ProfClass = ProfInfo.Class
        end
        
        Level = ProfList[ProfID] and ProfList[ProfID].Level or 1
        Level = string.format("<span color=\"#b56728\">%d%s</>", Level, LSTR("1540007"))
        ViewVM.TextTitle = LSTR("1540001")      --"职业等级提升"
        ViewVM.RichTextJobLevel = ProfName .. "  " .. Level
        ViewVM.RichTextHint = LSTR("1540004")   --"当前职业等级不足，可参与下方内容快速提升"
        ViewVM.IconJob = IconPath
        ViewVM.ProfID = ProfID
        ViewVM.ProfClass = ProfClass

    elseif TypeNum == ProtoRes.promote_type.PROMOTE_TYPE_EQUIP then  --装备品级
        local MajorVM = MajorUtil.GetMajorRoleVM(true)
        if MajorVM then
            Level = MajorVM.EquipScore
        end
        
        Level = string.format("<span color=\"#b56728\">%d%s</>", Level, LSTR("1540007"))
        ViewVM.TextTitle = LSTR("1540002")      --"装备品级提升"
        ViewVM.RichTextJobLevel = LSTR("1540003") .. Level             --"当前装备品级  "
        ViewVM.RichTextHint = LSTR("1540005")   --"当前装备品级不足，可参与下方内容快速提升"
        ViewVM.IconJob = PromoteDefine.EquipIconPath

    end

    if UIViewMgr:IsViewVisible(UIViewID.PromoteLevelUpMainPanel) then
        --若已打开界面 需要关闭后再开 否则不会置顶
        UIViewMgr:HideView(UIViewID.PromoteLevelUpMainPanel)
        _G.TimerMgr:AddTimer(self, function()
            UIViewMgr:ShowView(UIViewID.PromoteLevelUpMainPanel)
		end, 0.2)
        return
    end

    --打开UI界面： PWorldPromoteWinView.lua
    UIViewMgr:ShowView(UIViewID.PromoteLevelUpMainPanel)
end

--- 跳转界面
---@param JumpID 获取途径ID
function PromoteLevelUpMgr:JumpPanelByGetWayID(JumpID)
    if not JumpID then return end
    local Cfg = ItemGetaccesstypeCfg:FindCfgByKey(JumpID)
	if Cfg == nil then return end

	local MajorLevel = MajorUtil.GetMajorLevel()	--主角当前职业等级
	local UnLockIndex = 1
	local CommGetWayItems = {}

	local ViewParams = {ID = Cfg.ID, FunDesc = Cfg.FunDesc, MajorLevel = MajorLevel, FunIcon = Cfg.FunIcon, ItemAccessFunType = Cfg.FunType, 
						UnLockLevel = Cfg.UnLockLevel, IsRedirect = Cfg.IsRedirect, FunValue = Cfg.FunValue, RepeatJumpTipsID = Cfg.RepeatJumpTipsID, 
						UnLockTipsID = Cfg.UnLockTipsID}

	if (ViewParams.UnLockLevel == nil or ViewParams.MajorLevel == nil or ViewParams.UnLockLevel <= ViewParams.MajorLevel) and 
		ItemUtil.QueryIsUnLock(ViewParams.ItemAccessFunType, ViewParams.FunValue, nil) then --等级限制
		ViewParams.IsUnLock = true
	else
		ViewParams.IsUnLock = false
	end
	
	if ViewParams.IsUnLock then
		table.insert(CommGetWayItems, UnLockIndex, ViewParams)
		-- UnLockIndex = UnLockIndex + 1
	else
		if Cfg.NotRedirectHide == 0 then
			table.insert(CommGetWayItems,ViewParams)
		end
	end

	if nil == CommGetWayItems[1] then
		return
	end

    --跳转时关闭本系统界面： PWorldPromoteWinView.lua
    if UIViewMgr:IsViewVisible(UIViewID.PromoteLevelUpMainPanel) then
        UIViewMgr:HideView(UIViewID.PromoteLevelUpMainPanel)
    end

    local ItemData = CommGetWayItems[1]
    if Cfg.FunType == ProtoRes.ItemAccessFunType.Fun_Mazechallenge then   --迷宫挑战
		if _G.UIViewMgr:IsViewVisible(UIViewID.PWorldEntranceSelectPanel) then
            UIViewMgr:HideView(UIViewID.PWorldEntranceSelectPanel)
            ItemUtil.JumpGetWayByItemData(ItemData)                       --重新跳转
			return
		end
    elseif Cfg.FunType == ProtoRes.ItemAccessFunType.Fun_Making then      --制作笔记
		if _G.UIViewMgr:IsViewVisible(UIViewID.CraftingLog) then
            if 0 == ItemData.RepeatJumpTipsID then
                MsgTipsUtil.ShowTipsByID(260610)
                return
            end
			MsgTipsUtil.ShowTipsByID(ItemData.RepeatJumpTipsID)           --弹窗提示
			return
		end
    elseif Cfg.FunType == ProtoRes.ItemAccessFunType.Fun_DailyRandom then --每日随机
        if _G.UIViewMgr:IsViewVisible(UIViewID.PWorldEntranceSelectPanel) then
            UIViewMgr:HideView(UIViewID.PWorldEntranceSelectPanel)
            ItemUtil.JumpGetWayByItemData(ItemData)
			return
		end
    end

    ItemUtil.JumpGetWayByItemData(ItemData)
end

return PromoteLevelUpMgr