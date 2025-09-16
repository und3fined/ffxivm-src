local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local PhotoActionItemVM = require("Game/Photo/VM/Item/PhotoActionItemVM")
local PhotoActionVM = LuaClass(UIViewModel)
local EmotionDefines = require("Game/Emotion/Common/EmotionDefines")
local PhotoDefine = require("Game/Photo/PhotoDefine")
local LSTR = _G.LSTR
local PhotoTemplateUtil = require("Game/Photo/Util/PhotoTemplateUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ShowTips = MsgTipsUtil.ShowTips
local PhotoUtil = require("Game/Photo/PhotoUtil")

PhotoActionVM.ActionType = {Motion = 1,  Movement = 2} -- 动作，移动

function PhotoActionVM:Ctor()
    self.Type = PhotoActionVM.ActionType.motion
    self.TypeIdx = nil
    self.ActionItemVMList = UIBindableList.New(PhotoActionItemVM)
    self.IsPauseAnim = false
    self.IsShowSlider = false
    self.CurSeltItemIdx = nil
    self.ItemIdxMap = {}
    self.CurID = nil
    self.CurItem = nil
    self.CurAniPct = 0
end

function PhotoActionVM:UpdateVM()
    self:UpdateListVM()
    self.ItemIdxMap = {}
    self.CurSeltItemIdx = nil
    self.IsShowSlider = false
end

function PhotoActionVM:UpdateListVM()
    local ActionList = {}
    local SeltEntID = _G.PhotoMgr.SeltEntID
    local IsPlayer = _G.PhotoMgr:IsCurSeltPlayer()

    -- print('debug lockscreen [1] IsPlayer = ' .. tostring(IsPlayer))
    -- print('debug lockscreen [2] SeltEntID = ' .. tostring(SeltEntID))

    if self.Type == PhotoActionVM.ActionType.Motion then
        local AllEmotion = _G.PhotoMgr:GetActionCfgList()
        for k,v in ipairs(AllEmotion) do
            local IsEnable = IsPlayer and _G.EmotionMgr:IsEnableID(v.ID, SeltEntID)
            -- local Test = _G.EmotionMgr:IsEnableID(v.ID, SeltEntID)
            -- print('debug lockscreen ID = ' .. tostring(v.ID) .. ' Enable = ' .. tostring(Test))

			table.insert(ActionList, {ID = v.ID, NameText = v.EmotionName, ImgIcon = v.IconPath, IsEnable = IsEnable, Type = PhotoActionItemVM.ItemType.Motion})
		end
    elseif self.Type == PhotoActionVM.ActionType.Movement then
        local AllEmotion = _G.PhotoMgr:GetMoveOrMouthList(PhotoDefine.MoveMouthType.Movement)
        
        for k,v in ipairs(AllEmotion) do
            local IsEnable = IsPlayer and PhotoUtil.IsEnableIDMovement(SeltEntID)
			table.insert(ActionList, {ID = v.ID, NameText = v.Name, ImgIcon = v.Path, IsEnable = IsEnable, Type = PhotoActionItemVM.ItemType.Movement})
		end
    end
    self.ActionItemVMList:UpdateByValues(ActionList)
end

function PhotoActionVM:UpdateCurIdx()
    self.CurSeltItemIdx = self.ItemIdxMap[self.Type]

    local ID = nil
    self.CurItem = nil
    for i = 1, self.ActionItemVMList:Length() do
		local ItemVM = self.ActionItemVMList:Get(i)
        if i == self.CurSeltItemIdx then
            ID = ItemVM.ID
            self.CurItem = ItemVM
        end
		ItemVM:UpdateIconState(ID)	
	end

    self.CurID = ID
    self.IsShowSlider = (ID ~= nil)
    self:OnActChg(self.CurItem)
end

function PhotoActionVM:OnActChg(ItemData)
	if not ItemData then
        self.CurAniPct = nil
		return
	end
    local GiveType = _G.PhotoVM.GiveType
	if ItemData.Type == PhotoActionItemVM.ItemType.Motion then
		if GiveType == PhotoDefine.PhotoGiveType.Movement then
			ShowTips(LSTR(630047))
		end
        if not self.IsPauseAnim then
		    _G.PhotoMgr:SetActionID(ItemData.ID)
        end
	elseif ItemData.Type == PhotoActionItemVM.ItemType.Movement then
		if GiveType == PhotoDefine.PhotoGiveType.Action then
			ShowTips(LSTR(630046))
		end
        if not self.IsPauseAnim then
		    _G.PhotoMgr:SetMoveID(ItemData.ID)
        end
	end
end

function PhotoActionVM:SetSelectedActionItem(Idx, ID)
    self:SetSelectedActionItemInner(Idx, ID)

    _G.PhotoRoleStatVM:TryRptStat()
end

function PhotoActionVM:SetSelectedActionItemInner(Idx, ID)
    if self.Type then
        self.ItemIdxMap[self.Type] = Idx
    end
    self:SetAmimIsPause(false)
    self:UpdateCurIdx()
end

function PhotoActionVM:SetActionType(Index)
    if self.TypeIdx == Index then return end
    self.TypeIdx = Index
    -- self:SetAmimIsPause(false)
    if Index == 0 then
        self.Type = PhotoActionVM.ActionType.Motion
    elseif Index == 1 then
        self.Type = PhotoActionVM.ActionType.Movement
    end
    self:UpdateListVM()
    self:UpdateCurIdx()
end

function PhotoActionVM:CancelIdxMontion()
    self.ItemIdxMap[1] = nil
end

function PhotoActionVM:CancelIdxMovement()
    self.ItemIdxMap[2] = nil
end

function PhotoActionVM:ResetRoleActAni()
    self:SetSelectedActionItemInner()
    if self.Type == PhotoActionVM.ActionType.Motion then
		_G.PhotoMgr:SetActionID(nil)
	elseif self.Type == PhotoActionVM.ActionType.Movement then
		_G.PhotoMgr:SetMoveID(nil)
	end
end

function PhotoActionVM:SetAmimIsPause(IsPause)
    if self.IsPauseAnim == IsPause then
        return
    end

    self.IsPauseAnim = IsPause

    if self.IsPauseAnim then
        _G.PhotoMgr:PauseCurMontage()
    else
        _G.PhotoMgr:ResumeCurMontage()
    end
end

-------------------------------------------------------------------------------------------------------
---@region template setting

function PhotoActionVM:TemplateSave(InTemplate)
    PhotoTemplateUtil.SetActAndMove(InTemplate, self.TypeIdx, self.CurSeltItemIdx, self.CurAniPct)
end

function PhotoActionVM:TemplateApply(InTemplate)
    local Info = PhotoTemplateUtil.GetActAndMove(InTemplate)
    -- _G.FLOG_INFO('[Photo][PhotoCamVM][TemplateApply] Info = ' .. table.tostring(Info))
    if Info then
        local TypeIdx = Info.Type
        local Idx = Info.Idx
        self:SetActionType(TypeIdx)
        self:SetSelectedActionItem(Idx)
        local Pct = Info.Pct

        if Pct then
            self.CurAniPct = Pct
            self:SetAmimIsPause(true)
	        _G.PhotoMgr:SetCurMontagePct(Pct)
        end
    else
        self:ResetRoleActAni()
        self:SetSelectedActionItem(nil)
    end
end

return PhotoActionVM