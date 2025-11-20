local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local PhotoActionItemVM = require("Game/Photo/VM/Item/PhotoActionItemVM")
local PhotoDefine = require("Game/Photo/PhotoDefine")
local PhotoTemplateUtil = require("Game/Photo/Util/PhotoTemplateUtil")

local PhotoEmojiVM = LuaClass(UIViewModel)
local PhotoMgr
local PhotoRoleStatVM

PhotoEmojiVM.EmojiType = {Face = 1,  Mouth = 2} -- 表情，口型

function PhotoEmojiVM:Ctor()
    PhotoMgr = _G.PhotoMgr
    PhotoRoleStatVM = _G.PhotoRoleStatVM
    self.Type = PhotoEmojiVM.EmojiType.Face
    self.EmojiItemVMList = UIBindableList.New(PhotoActionItemVM)
    self.CurSeltItemIdx = nil
    self.ItemIdxMap = {}
    self.CurID = nil
    self.EmojiProbarIsVisibility = false
    self.IsPauseEmojiAnim = false
    self.CurAnimPct = 0
end

function PhotoEmojiVM:UpdateVM()
    self:UpdateListVM()
    self.ItemIdxMap = {}
    self.CurSeltItemIdx = nil
end

function PhotoEmojiVM:MakeDataList(InType)
    local EmojiVList = {}
    if InType == PhotoEmojiVM.EmojiType.Face then
        local AllEmotion = PhotoMgr:GetEmojCfgList()
        for k, v in ipairs(AllEmotion) do
            local IsUseMouth = PhotoMgr:GetEmotionIsUseMouth(v.ID)
            table.insert(EmojiVList, {
                ID = v.ID,
                NameText = v.EmotionName,
                ImgIcon = v.IconPath,
                Type = PhotoDefine.AnimType.Face,
                IsUseMouth = IsUseMouth,
            })
        end
    elseif InType == PhotoEmojiVM.EmojiType.Mouth then
        local AllEmotion = PhotoMgr:GetMoveOrMouthList(PhotoDefine.MoveMouthType.Mouth)
        for k, v in ipairs(AllEmotion) do
            table.insert(EmojiVList, {
                ID = v.ID,
                NameText = v.Name,
                ImgIcon = v.Path,
                Type = PhotoDefine.AnimType.Mouth
            })
        end
    end
    return EmojiVList
end

function PhotoEmojiVM:GetItemListByType(InType)
    if InType == PhotoEmojiVM.EmojiType.Face then
        if table.is_nil_empty(self.FaceItemList) then
            self.FaceItemList = self:MakeDataList(InType)
        end
        return self.FaceItemList
    elseif InType == PhotoEmojiVM.EmojiType.Mouth then
        if table.is_nil_empty(self.MouthItemList) then
            self.MouthItemList = self:MakeDataList(InType)
        end
        return self.MouthItemList
    else
        return {}
    end
end

function PhotoEmojiVM:ClearVMData()
    self.FaceItemList = nil
    self.MouthItemList = nil
end

function PhotoEmojiVM:UpdateListVM()
    local EmojiVList = self:GetItemListByType(self.Type)
    self.EmojiItemVMList:UpdateByValues(EmojiVList)
end

function PhotoEmojiVM:SetSelectedEmojiItem(Idx, ID)
    if not Idx or not ID  then
        self.EmojiProbarIsVisibility = false
    end
    self:SetSelectedEmojiItemInner(Idx, ID)
    PhotoRoleStatVM:TryRptStat()
end

function PhotoEmojiVM:SetSelectedEmojiItemInner(Idx, ID)
    self.ItemIdxMap[self.Type] = Idx
    self:UpdateCurIdx()
end

function PhotoEmojiVM:SetEmojiType(Index)
    PhotoEmojiVM.EmojiProbarIsVisibility = Index == 1 and PhotoMgr.MouthID
    if Index == 0 then
        self.Type = PhotoEmojiVM.EmojiType.Face
    elseif Index == 1 then
        self.Type = PhotoEmojiVM.EmojiType.Mouth
    end
    self:UpdateListVM()
    self:UpdateCurIdx()
end

function PhotoEmojiVM:UpdateCurIdx()
    self.CurSeltItemIdx = self.ItemIdxMap[self.Type]

    local ID = nil
    self.CurID = nil
    for i = 1, self.EmojiItemVMList:Length() do
        local ItemVM = self.EmojiItemVMList:Get(i)
        if i == self.CurSeltItemIdx then
            ID = ItemVM.ID
            self.CurID = ID
        end
		ItemVM:UpdateIconState(ID)
	end
end

function PhotoEmojiVM:ResetRoleActAni(isEmoji)
    self.EmojiProbarIsVisibility = false
    self:SetSelectedEmojiItemInner()
    if isEmoji == true then
        PhotoMgr:SetEmojiID(nil)
    elseif isEmoji == false then
        PhotoMgr:SetMouthID(nil)
    else
        PhotoMgr:SetEmojiID(nil)
        PhotoMgr:SetMouthID(nil)
    end
end

function PhotoEmojiVM:SetAmimIsPause(IsPause)
    if self.IsPauseEmojiAnim == IsPause then
        return
    end

    self.IsPauseEmojiAnim = IsPause
    if not PhotoMgr:GetIsDirectPause() then
        PhotoMgr:PauseMouthMontage(IsPause)
    end
end

-------------------------------------------------------------------------------------------------------
---@region template setting

function PhotoEmojiVM:TemplateSave(InTemplate)
    local MouthFrames = PhotoMgr.MouthID and self.CurAnimPct
    PhotoTemplateUtil.SetEmojAndMouth(InTemplate, self.ItemIdxMap[self.EmojiType.Face], self.ItemIdxMap[self.EmojiType.Mouth], MouthFrames)
end

function PhotoEmojiVM:TemplateApply(InTemplate)
    self:SetAmimIsPause(false)
    self:ResetRoleActAni()
    self:SetSelectedEmojiItem()
    local Info = PhotoTemplateUtil.GetEmojAndMouth(InTemplate)
    -- _G.FLOG_INFO('[Photo][PhotoCamVM][TemplateApply] Info = ' .. table.tostring(Info))
    if Info then
        local EmojIdx = Info.EmojIdx
        local MouthIdx = Info.MouthIdx
        if EmojIdx then
            self.ItemIdxMap[self.EmojiType.Face] = EmojIdx
            local List = self:GetItemListByType(self.EmojiType.Face)
            local Item = List[EmojIdx]
            if Item then
                local ID = Item.ID
		        PhotoMgr:SetEmojiID(ID)
            end
        end
        if MouthIdx then
            self.ItemIdxMap[self.EmojiType.Mouth] = MouthIdx
            local List = self:GetItemListByType(self.EmojiType.Mouth)
            local Item = List[MouthIdx]
            if Item then
                local ID = Item.ID
		        PhotoMgr:SetMouthID(ID)
                local MouthFrames = Info.MouthFrames
                if MouthFrames then
                    local function NextFrame()
                        self:SetAmimIsPause(true)
                        self.CurAnimPct = MouthFrames
                        PhotoMgr:SetPlayingEmojiMontagePct(MouthFrames)
                    end
                    _G.TimerMgr:AddTimer(nil, NextFrame, 0.01, 0, 1)
                end
            end
        end
    end
end


return PhotoEmojiVM