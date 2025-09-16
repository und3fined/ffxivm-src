local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local PhotoActionItemVM = require("Game/Photo/VM/Item/PhotoActionItemVM")
local EmotionDefines = require("Game/Emotion/Common/EmotionDefines")
local PhotoDefine = require("Game/Photo/PhotoDefine")
local PhotoTemplateUtil = require("Game/Photo/Util/PhotoTemplateUtil")

local PhotoEmojiVM = LuaClass(UIViewModel)

local LSTR = _G.LSTR

PhotoEmojiVM.EmojiType = {Face = 1,  Mouth = 2} -- 表情，口型

function PhotoEmojiVM:Ctor()
    self.Type = PhotoEmojiVM.EmojiType.Face
    self.EmojiItemVMList = UIBindableList.New(PhotoActionItemVM)
    self.CurSeltItemIdx = nil
    self.ItemIdxMap = {}
    self.CurID = nil
end

function PhotoEmojiVM:UpdateVM()
    self:UpdateListVM()
    self.ItemIdxMap = {}
    self.CurSeltItemIdx = nil
end

function PhotoEmojiVM:MakeDataList(InType, bIgCheck)
    local EmojiVList = {}

    if bIgCheck then
        if InType == PhotoEmojiVM.EmojiType.Face then
            local AllEmotion = _G.PhotoMgr:GetEmojCfgList()
            for k,v in ipairs(AllEmotion) do
                table.insert(EmojiVList, {ID = v.ID, NameText = v.EmotionName, ImgIcon = v.IconPath, Type = PhotoActionItemVM.ItemType.Face})
            end
        elseif InType == PhotoEmojiVM.EmojiType.Mouth then
            local AllEmotion = _G.PhotoMgr:GetMoveOrMouthList(PhotoDefine.MoveMouthType.Mouth)
            for k,v in ipairs(AllEmotion) do
                table.insert(EmojiVList, {ID = v.ID, NameText = v.Name, ImgIcon = v.Path, Type = PhotoActionItemVM.ItemType.Mouth})
            end
        end
    else
        local SeltEntID = _G.PhotoMgr.SeltEntID
        local IsPlayer = _G.PhotoMgr:IsCurSeltPlayer()

        if InType == PhotoEmojiVM.EmojiType.Face then
            local AllEmotion = _G.PhotoMgr:GetEmojCfgList()
            for k,v in ipairs(AllEmotion) do
                local IsEnable = IsPlayer and _G.EmotionMgr:IsEnableID(v.ID, SeltEntID)
                table.insert(EmojiVList, {ID = v.ID, NameText = v.EmotionName, ImgIcon = v.IconPath, IsEnable = IsEnable, Type = PhotoActionItemVM.ItemType.Face})
            end
        elseif InType == PhotoEmojiVM.EmojiType.Mouth then
            local AllEmotion = _G.PhotoMgr:GetMoveOrMouthList(PhotoDefine.MoveMouthType.Mouth)
            for k,v in ipairs(AllEmotion) do
                local IsEnable = IsPlayer and _G.EmotionMgr:IsEnableID(v.ID, SeltEntID)
                table.insert(EmojiVList, {ID = v.ID, NameText = v.Name, ImgIcon = v.Path, IsEnable = IsEnable, Type = PhotoActionItemVM.ItemType.Mouth})
            end
        end
    end

    return EmojiVList
end

function PhotoEmojiVM:UpdateListVM()
    local EmojiVList = self:MakeDataList(self.Type)
    self.EmojiItemVMList:UpdateByValues(EmojiVList)
end

function PhotoEmojiVM:SetSelectedEmojiItem(Idx, ID)
    self:SetSelectedEmojiItemInner(Idx, ID)
    _G.PhotoRoleStatVM:TryRptStat()
end

function PhotoEmojiVM:SetSelectedEmojiItemInner(Idx, ID)
    self.ItemIdxMap[self.Type] = Idx
    self:UpdateCurIdx()	
end

function PhotoEmojiVM:SetEmojiType(Index)
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
    for i = 1, self.EmojiItemVMList:Length() do
		local ItemVM = self.EmojiItemVMList:Get(i)
        if i == self.CurSeltItemIdx then
            ID = ItemVM.ID
            self.CurID = ID
        end
		ItemVM:UpdateIconState(ID)	
	end
end

function PhotoEmojiVM:ResetRoleActAni()
    self:SetSelectedEmojiItemInner()
    if self.Type == PhotoEmojiVM.EmojiType.Face then
		_G.PhotoMgr:SetEmojiID(nil)
	elseif self.Type == PhotoEmojiVM.EmojiType.Mouth then	
		_G.PhotoMgr:SetMouthID(nil)
	end
end

-------------------------------------------------------------------------------------------------------
---@region template setting

function PhotoEmojiVM:TemplateSave(InTemplate)
    PhotoTemplateUtil.SetEmojAndMouth(InTemplate, self.ItemIdxMap[self.EmojiType.Face], self.ItemIdxMap[self.EmojiType.Mouth])
end

function PhotoEmojiVM:TemplateApply(InTemplate)
    local Info = PhotoTemplateUtil.GetEmojAndMouth(InTemplate)
    -- _G.FLOG_INFO('[Photo][PhotoCamVM][TemplateApply] Info = ' .. table.tostring(Info))
    if Info then
        local EmojIdx = Info.EmojIdx
        local MouthIdx = Info.MouthIdx

        if EmojIdx then
            self.ItemIdxMap[self.EmojiType.Face] = EmojIdx
            local List = self:MakeDataList(self.EmojiType.Face, true)
            local Item = List[EmojIdx]
            if Item then
                local ID = Item.ID
		        _G.PhotoMgr:SetEmojiID(ID)

            end
        end

        if MouthIdx then
            self.ItemIdxMap[self.EmojiType.Mouth] = MouthIdx
            local List = self:MakeDataList(self.EmojiType.Mouth, true)
            local Item = List[MouthIdx]
            if Item then
                local ID = Item.ID
		        _G.PhotoMgr:SetMouthID(ID)
            end
        end
    else
        self:ResetRoleActAni()
        self:SetSelectedEmojiItem()
    end
end


return PhotoEmojiVM