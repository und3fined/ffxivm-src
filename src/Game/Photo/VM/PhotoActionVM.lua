local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local PhotoActionItemVM = require("Game/Photo/VM/Item/PhotoActionItemVM")
local PhotoDefine = require("Game/Photo/PhotoDefine")
local PhotoTemplateUtil = require("Game/Photo/Util/PhotoTemplateUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local PhotoUtil = require("Game/Photo/PhotoUtil")

local PhotoActionVM = LuaClass(UIViewModel)
local AnimType = PhotoDefine.AnimType
local ShowTips = MsgTipsUtil.ShowTips
local LSTR = _G.LSTR
local PhotoMgr = _G.PhotoMgr
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

function PhotoActionVM:ChangedSelecteActor()
    self.IsShowSlider = false
    self:UpdateListVM()
end

function PhotoActionVM:MakeDataList(InType)
    local ActionList = {}
    if InType == PhotoActionVM.ActionType.Motion then
        local AllEmotion = PhotoMgr:GetActionCfgList()
        for k,v in ipairs(AllEmotion) do
            local IsUseMouth = PhotoMgr:GetEmotionIsUseMouth(v.ID)
			table.insert(ActionList, {
                ID = v.ID,
                NameText = v.EmotionName,
                ImgIcon = v.IconPath,
                Type = AnimType.Motion,
                IsUseMouth = IsUseMouth,
            })
		end
    elseif InType == PhotoActionVM.ActionType.Movement then
        local AllEmotion = PhotoMgr:GetMoveOrMouthList(PhotoDefine.MoveMouthType.Movement)
        for k,v in ipairs(AllEmotion) do
			table.insert(ActionList, {
                ID = v.ID,
                NameText = v.Name,
                ImgIcon = v.Path,
                Type = AnimType.Movement
            })
		end
    end
    return ActionList
end

function PhotoActionVM:UpdateListVM()
    local ActionList = {}
    if self.Type == PhotoActionVM.ActionType.Motion then
        if table.is_nil_empty(self.MotionItemList) then
            self.MotionItemList = self:MakeDataList(self.Type)
        end
        ActionList = self.MotionItemList
    elseif self.Type == PhotoActionVM.ActionType.Movement then
        if table.is_nil_empty(self.MovementItemList) then
            self.MovementItemList = self:MakeDataList(self.Type)
        end
        ActionList = self.MovementItemList
    end
    self.ActionItemVMList:UpdateByValues(ActionList)
end

function PhotoActionVM:ClearVMData()
    self.MotionItemList = nil
    self.MovementItemList = nil
end

function PhotoActionVM:UpdateCurIdx(bIgSync)
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

    if not bIgSync then
        self:OnActChg(self.CurItem)
    end
end

function PhotoActionVM:OnActChg(ItemData)
	if not ItemData then
        self.CurAniPct = nil
		return
	end
    local GiveType = _G.PhotoVM.GiveType
	if ItemData.Type == AnimType.Motion then
		if GiveType == PhotoDefine.PhotoGiveType.Movement then
			ShowTips(LSTR(630047))
		end
        if not self.IsPauseAnim then
		    PhotoMgr:SetActionID(ItemData.ID)
        end
	elseif ItemData.Type == AnimType.Movement then
		if GiveType == PhotoDefine.PhotoGiveType.Action then
			ShowTips(LSTR(630046))
		end
        if not self.IsPauseAnim then
		    PhotoMgr:SetMoveID(ItemData.ID)
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
    PhotoMgr:SetActionID(nil)
    PhotoMgr:SetMoveID(nil)
end

function PhotoActionVM:SetAmimIsPause(IsPause)
    if self.IsPauseAnim == IsPause then
        return
    end

    self.IsPauseAnim = IsPause
    if not PhotoMgr:GetIsDirectPause() then
        PhotoMgr:PauseAllMontage(self.IsPauseAnim)
    end
end

-------------------------------------------------------------------------------------------------------
---@region template setting

function PhotoActionVM:TemplateSave(InTemplate)
    PhotoTemplateUtil.SetActOrMove(InTemplate, self.TypeIdx, self.CurSeltItemIdx, self.CurAniPct, self.CurID)
end

function PhotoActionVM:TemplateApply(InTemplate)
    local Info = PhotoTemplateUtil.GetActOrMove(InTemplate)
    -- _G.FLOG_INFO('[Photo][PhotoCamVM][TemplateApply] Info = ' .. table.tostring(Info))
    if Info then
        local TypeIdx = Info.Type
        local Idx = Info.Idx
        local ID = Info.ID
        local SeltEntID = PhotoMgr.SeltEntID
        if not ID or not _G.EmotionMgr:IsEnableID(ID, SeltEntID) then
            PhotoUtil.ShowAnimTips(AnimType.Motion, ID)
            return
        end

        self:SetActionType(TypeIdx)
        self:SetSelectedActionItem(Idx)
        local Pct = Info.Pct

        if Pct then
            self.CurAniPct = Pct
	        PhotoMgr:SetPlayingActionMontagePct(Pct)
        end
    else
        self:ResetRoleActAni()
        self:SetSelectedActionItem(nil)
    end
end

return PhotoActionVM