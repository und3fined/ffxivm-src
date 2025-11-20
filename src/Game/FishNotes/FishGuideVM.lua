---
---@author Lucas
---DateTime: 2023-03-20 17:47:13
---Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local ProtoRes = require ("Protocol/ProtoRes")
local FishNotesGridVM = require("Game/FishNotes/ItemVM/FishNotesGridVM")
local FishNotesMgr = require("Game/FishNotes/FishNotesMgr")
local FishNotesDefine = require("Game/FishNotes/FishNotesDefine")
local BoardType = require("Define/BoardType")
local TimeUtil = require("Utils/TimeUtil")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local ChatUtil = require("Game/Chat/ChatUtil")
local ProtoCS = require("Protocol/ProtoCS")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MajorUtil = require("Utils/MajorUtil")

---@type FishGuideVM : UIViewModel
---@field FishGridList table @鱼列表
---@field SelectFishPlaceList table @选中的鱼出没地点列表
---
---@field SelectFishName string @选中的鱼名字
---@field SelectFishNameColor string @选中的鱼名字颜色
---@field SelectFishLevel string @选中的鱼等级
---@field SelectFishSeaboard string @选中的鱼出没地点
---@field SelectFishNumberID string @选中的鱼编号
---@field SelectFishDetail string @选中的鱼详情
---@field SelectFishNumber string @选中的鱼累计钓到数量
---@field SelectFishObtainPower string @选中的鱼的获得力要求
---@field SelectFishSize string @选中的鱼钓到的最大尺寸
---@field bSelectFishDetailVisible boolean @选中的鱼详情是否显示
---
---@field TotalFishUnLock string @已解锁的鱼类数量
---@field TotalFish string @可解锁的鱼类数量
---@field FishKingUnlock string @已解锁的鱼王数量
---@field TotalFishKing string @可解锁的鱼王数量
---@field FishQueenUnlock string @已解锁的鱼皇数量
---@field TotalFishQueen string @已解锁的鱼皇数量
---@field bInheritVisible boolean @是否是传承
---@field bFishDetailVisible boolean @是否显示详情
---@field bFishUnlockVisible boolean @未解锁提示
---@field FishUnlockText string @未解锁提示文字
---@field bCommentViewVisible boolean @评论视窗开关控制变量
---@field bFishSearchEmptyVisible boolean @搜索列表为空提示
---@field FishSearchEmptyText string @搜索列表为空提示文字
---@field bInheritTipsVisible boolean @传承提示是否显示
---@field InheritTipsText string @传承提示文字
---
---@type LocalElement 本地参数
---@field TotalFishNum number @本地计算的鱼类总数
---@field TotalUnlockNum number @本地计算的已解锁鱼类总数
---@field TotalKingFishNum number @本地计算的鱼王总数
---@field TotalKingUnlockNum number @本地计算的已解锁鱼王总数
---@field TotalQueenFishNum number @本地计算的鱼皇总数
---@field TotalQueenUnlockNum number @本地计算的已解锁鱼皇总数
---
---@field LastDropDownIndex number @当前选中的下拉框Index
---@field SelectedFishGridIndex number @当前选中的鱼下标
---
---@field bSearchShow boolean @是否开始搜索显示
---@field SearchDataList table @搜索后的鱼列表
---
---@field SelectFishItemID number @选中的鱼物品ID
---@field FishSwitchState boolean @图标/拓印切换按纽，true为图标
---
---@field bShowRankingVisible boolean @详情界面排名信息显示
---@field bSizeKing boolean @详情界面皇冠显示
local FishGuideVM = LuaClass(UIViewModel)

function FishGuideVM:Ctor()
end

function FishGuideVM:OnInit()
    self.FishGridList = UIBindableList.New(FishNotesGridVM)
    --self.SelectFishPlaceList = UIBindableList.New(FishNotesPlaceVM)

    self.SelectFishName = ""
    --self.SelectFishNameColor = ""
    self.SelectFishLevel = ""
    self.SelectFishSeaboard = ""
    self.SelectFishNumberID = ""
    self.SelectFishDetail = ""
    self.SelectFishNumber = ""
    self.SelectFishObtainPower = ""
    self.SelectFishSize = ""
    self.SelectFishSizeTime = ""
    self.FishIcon = ""
    self.PrintingPicture = ""
    self.ItemDataIconID = nil
    self.ParchmentIcon = nil
    self.InchIcon = nil
    self.FishSwitchState = true
    --self.QualityIcon = ""
    self.bSelectFishDetailVisible = false
    self.HauntList = nil

    self.TotalFishUnLock = ""
    self.TotalFish = ""
    self.FishKingUnlock = ""
    self.TotalFishKing = ""
    self.FishQueenUnlock = ""
    self.TotalFishQueen = ""
    self.bInheritVisible = false
    self.bFishDetailVisible = false
    self.bFishUnlockVisible = false
    self.FishUnlockText = ""
    self.bCommentViewVisible = false
    self.bFishSearchEmptyVisible = false
    self.FishSearchEmptyText = _G.LSTR(FishNotesDefine.SearchEmptyText)
    self.bInheritTipsVisible = false
    self.InheritTipsText = string.format(_G.LSTR(FishNotesDefine.InheritTipsText), _G.LSTR(FishNotesDefine.UnkonwText))

    self.NowData = nil
    self.LastDropDownIndex = 1 --1全部 2鱼王 3普通
    self.SelectedFishGridIndex = nil
    self.FilterDataList = nil
    self.SelectFishItemID = 0

    self.bSearchShow = false
    self.SearchDataList = nil

    --排名
    self.bShowRankingVisible = false
    self.HistoryRanking = _G.LSTR(70008)--"无"
    self.CurRanking = _G.LSTR(70008)--"无"
    self.HistoryRankingColor = ""
    self.CurRankingColor = ""
    self.bSizeKing = false
    self.bLargeFontSize = true
end

function FishGuideVM:OnShutdown()
    self.FishGridList:Clear()
    self.FilterDataList = nil
    self.SearchDataList = nil
end

local function SortGrid(A, B)
    if A == nil or B == nil then
        return false
    end

    if A.ID == nil or B.ID == nil then
        return false
    end

    return A.ID < B.ID
end

local function SortItemDataByUnLockandID(Left, Right)
    local bLockStateLeft = Left.bLockState or FishNotesMgr:CheckFishbUnLock(Left.ID) or false
    local bLockStateRight = Right.bLockState or FishNotesMgr:CheckFishbUnLock(Right.ID) or false
    if bLockStateLeft ~= bLockStateRight then
        return bLockStateLeft == true
    else
        return Left.ID < Right.ID
    end
end

---@type 刷新鱼类计数信息
function FishGuideVM:UpdateCountInfo()
    local bLockState
    local FishRartyEnum = FishNotesDefine.FishRartyEnum
    local KingRarity = FishRartyEnum.King
    local QueenRarity = FishRartyEnum.Queen
    local TotalFishNum, TotalUnlockNum, TotalKingFishNum, TotalKingUnlockNum, TotalQueenFishNum, TotalQueenUnlockNum = 0, 0, 0, 0, 0, 0
    local FishDataList = FishNotesMgr:GetFishDataListByVersion()
    for _, Fish in pairs(FishDataList) do
        TotalFishNum = TotalFishNum + 1
        if Fish.Rarity == KingRarity then
            TotalKingFishNum = TotalKingFishNum + 1
        elseif Fish.Rarity == QueenRarity then
            TotalQueenFishNum = TotalQueenFishNum + 1
        end

        bLockState = FishNotesMgr:CheckFishbUnLock(Fish.ID)
        if bLockState == true then
            TotalUnlockNum = TotalUnlockNum + 1
            if Fish.Rarity == KingRarity then
                TotalKingUnlockNum = TotalKingUnlockNum + 1
            elseif Fish.Rarity == QueenRarity then
                TotalQueenUnlockNum = TotalQueenUnlockNum + 1
            end
        end
    end
    self.TotalFishUnLock = tostring(TotalUnlockNum)
    self.TotalFish = tostring(TotalFishNum)
    self.FishKingUnlock = tostring(TotalKingUnlockNum)
    self.TotalFishKing = tostring(TotalKingFishNum)
    self.FishQueenUnlock = tostring(TotalQueenUnlockNum)
    self.TotalFishQueen = tostring(TotalQueenFishNum)
end

---@type 刷新鱼类列表
function FishGuideVM:UpdateFishList(Index)
    if Index == nil then
        Index = self.LastDropDownIndex
    else
        self.LastDropDownIndex = Index
    end
    local FishList = {}
    local AllFish = FishNotesMgr:GetFishDataListByVersion()
    for _, Fish in ipairs(AllFish) do
        Fish.bUnLockState = FishNotesMgr:CheckFishbUnLock(Fish.ID)
        local bKingQueen = Fish.Rarity == FishNotesDefine.FishRartyEnum.King or Fish.Rarity == FishNotesDefine.FishRartyEnum.Queen
        if Index == 1 then
            table.insert(FishList, Fish)
        elseif Index == 2 and bKingQueen then
            table.insert(FishList, Fish)
        elseif Index == 3 and not bKingQueen then
            table.insert(FishList, Fish)
        end
    end
    self.FishGridList:UpdateByValues(FishList, SortGrid)
end

function FishGuideVM:GetSelectIndexByFishID(FishID)
    local FishLish = self.FishGridList:GetItems()
    if not table.is_nil_empty(FishLish) then
        for Index, value in ipairs(FishLish) do
            if value.ID == FishID then
                return Index
            end
        end
    end
    return nil
end

function FishGuideVM:ResetSelectedFishGrid()
    self.SelectedFishGridIndex = FishNotesDefine.SelectDefaultIndex
    --选中激活的第一条
    local FishDataList = self.FishGridList:GetItems()
    local FishCfgList = {}
    for _, Fish in pairs(FishDataList) do
        FishCfgList[#FishCfgList + 1] = Fish
    end
    table.sort(FishCfgList,SortItemDataByUnLockandID)
    if FishCfgList[1] then
        local FishID = FishCfgList[1].ID
        local Index = 0
        for _, Fish in pairs(FishDataList) do
            Index = Index + 1
            if Fish.ID == FishID then
                self.SelectedFishGridIndex = Index
            end
        end
    end
end

---@type 切换选中的鱼_刷新选中的鱼类详情
function FishGuideVM:UpdateFishDetail(Index, Data)
    if self.NowData then
        self.NowData:UpdateSelectXState(false)
    end
    Data:UpdateSelectXState(true)
    self.NowData = Data

    local FishData = FishNotesMgr:GetFishCfg(Data.ID)
    if self.bSearchShow == true then
        self.SearchFishData = FishData
    else
        self.SelectedFishGridIndex = Index
    end

    self.bFishDetailVisible = true
    self.SelectFishName = FishData.Name
    self.SelectFishNumberID = string.format("%s%03d", _G.LSTR(180058), FishData.ID)
    self.SelectFishLevel = string.format(_G.LSTR(180095), FishData.Level) --"等级：%d级"
    self.bInheritVisible = FishData.NeedFolklore
    local Infested = self:SetInfestedInfo(FishData.ID)
    self.SelectFishSeaboard = string.format("%s%s", _G.LSTR(180088), Infested)--"出没场地："

    local bUnLockState = FishNotesMgr:CheckFishbUnLock(FishData.ID)
    local SaveData = FishNotesMgr:GetUnlockFishData(FishData.ID)
    if bUnLockState == false or SaveData == nil then
        self.bSelectFishDetailVisible = false
        self.bFishUnlockVisible = true
        self.FishUnlockText = string.format(_G.LSTR(FishNotesDefine.FishUnlockTipsText), Infested, Infested) 
        return
    end

    self.bFishUnlockVisible = false
    self.bSelectFishDetailVisible = true
    self.SelectFishDetail = FishData.Description
    self.SelectFishNumber = string.format("%s%d", _G.LSTR(180087), SaveData.Count)--钓起数量：
    self.SelectFishObtainPower = string.format("%s%s", _G.LSTR(180113), tostring(FishData.GatheringThreshold or 0))
    local Size = SaveData.Size
    self.InchIcon = self:GetInchIconPath(FishData.Size, Size)
    self.SelectFishSize = string.format("%d%s", Size, _G.LSTR(180061))
    local SizeTime = SaveData.SizeTime ~= 0 and SaveData.SizeTime or TimeUtil.GetServerTime()
    self.SelectFishSizeTime = TimeUtil.GetTimeFormat("%Y/%m/%d", SizeTime)
    self.bSizeKing = SaveData.HistoryPercent == 1
    self:SetRankingInfo(SaveData.HistoryPercent, SaveData.CurrPercent, FishData.Rarity) --排名信息

    self.SelectFishItemID = FishData.ItemID
    local ItemData = ItemCfg:FindCfgByKey(FishData.ItemID)
    if ItemData then
        self.ItemDataIconID = ItemData.IconID
    end
    self.ParchmentIcon = FishData.ParchmentIcon
    if self.ItemDataIconID ~= nil then
        self.FishIcon = UIUtil.GetIconPath(self.ItemDataIconID)
    else
        self.FishIcon = ""
    end
    if not string.isnilorempty(self.ParchmentIcon) then
        self.PrintingPicture = self.ParchmentIcon
    else
        self.PrintingPicture = "Texture2D'/Game/Assets/Icon/FishNotes/UI_Icon_FishNotes_079004.UI_Icon_FishNotes_079004'"
    end
    self.FishSwitchState = true

    --如果当前已经打开了留言板，则申请更新留言信息
    if _G.UIViewMgr:IsViewVisible(_G.UIViewID.MessageBoardPanel) then
        EventMgr:SendEvent(EventID.BoardObjectChange, self.SelectFishItemID)
    end
end

---@type 详情信息_鱼类奖牌
function FishGuideVM:GetInchIconPath(FishCfgSize, SaveSize)
    local MinSize, MaxSize, SizeRatio = 1, 1, 1
    if not table.is_nil_empty(FishCfgSize) then
        MinSize = FishCfgSize[1]
        MaxSize = FishCfgSize[2]
        SizeRatio = (SaveSize - MinSize) / (MaxSize - MinSize)
    end
    if SizeRatio >= 0.7 then
        return "PaperSprite'/Game/UI/Atlas/FishNotesNew/Frames/UI_FishNotes_Img_Inch_png.UI_FishNotes_Img_Inch_png'"
    elseif SizeRatio >= 0.4 then
        return "PaperSprite'/Game/UI/Atlas/FishNotesNew/Frames/UI_FishNotes_Img_Silver_png.UI_FishNotes_Img_Silver_png'"
    else
        return "PaperSprite'/Game/UI/Atlas/FishNotesNew/Frames/UI_FishNotes_Img_Copper_png.UI_FishNotes_Img_Copper_png'"
    end
end

---@type 详情信息_鱼类钓起排名
function FishGuideVM:SetRankingInfo(HistoryPercent, CurrPercent, Rarity)
    local FishRartyEnum = FishNotesDefine.FishRartyEnum
    --鱼王鱼皇才显示排名
    self.bShowRankingVisible = Rarity == FishRartyEnum.King or Rarity == FishRartyEnum.Queen
    if self.bShowRankingVisible then
        if CurrPercent ~= 0 then
            self.HistoryRanking = string.format("%d%%", math.floor(HistoryPercent * 100))
            self.CurRanking = string.format("%d%%", math.floor(CurrPercent * 100))
            self.HistoryRankingColor = self:GetRankingColor(HistoryPercent)
            self.CurRankingColor = self:GetRankingColor(CurrPercent)
            self.bLargeFontSize = true
        else
            --为0时即未上榜
            self.HistoryRanking = _G.LSTR(70008)--"无"
            self.CurRanking = _G.LSTR(70008)--"无"
            self.HistoryRankingColor = self:GetRankingColor(0)
            self.CurRankingColor = self:GetRankingColor(0)
            self.bLargeFontSize = false
        end
    end
end

function FishGuideVM:GetRankingColor(RankPercent, bFishMain)
    if RankPercent == 1 then
        return bFishMain and "#ffd78b" or "#bd8213"
    elseif RankPercent >= 0.99 then
        return bFishMain and "#ff9da9" or "#af4c58"
    elseif RankPercent >= 0.95 then
        return bFishMain and "#fcb77f" or "#b56728"
    elseif RankPercent >= 0.75 then
        return bFishMain and "#c9a2ff" or "#744aad"
    elseif RankPercent >= 0.5 then
        return bFishMain and "#add9ff" or "#4d85b4"
    elseif RankPercent >= 0.25 then
        return bFishMain and "#b3f7b1" or "#449342"
    else
        return bFishMain and "#d5d5d5" or "#6c6964"
    end
end

---@type 详情信息_鱼类出没场地数据
function FishGuideVM:SetInfestedInfo(FishID)
    local HauntList = FishNotesMgr:GetFishHauntList(FishID) or {}
    self.HauntList = HauntList
    local HauntTypeList = {}
    for _, Location in pairs(HauntList) do
        local Type = ProtoEnumAlias.GetAlias(ProtoRes.FISH_LOCATION_TYPE, Location.LocationType) or ""
        HauntTypeList[Type] = 1
    end
    local InfestedText = ""
    for key, _ in pairs(HauntTypeList) do
        if InfestedText == "" then
            InfestedText = key
        else
            InfestedText = InfestedText .. "," .. key
        end
    end
    return InfestedText
end

---@type 搜索列表状态变更
function FishGuideVM:ChangeSearchState(bSearch)
    self.bSearchShow = bSearch

    if bSearch == true then
        self.SearchFishData = nil
    else
        self.bFishDetailVisible = true
        self.bFishSearchEmptyVisible = false
    end
end

---@type 搜索鱼类
function FishGuideVM:Search(Content)
    self.FishGridList:Clear()
    self.SearchDataList = FishNotesMgr:SerachInfoInGuide(Content)

    if self.SearchDataList and #self.SearchDataList > 0 then
        self.bSearchShow = true
        table.sort(self.SearchDataList, SortGrid)
        self.FishGridList:UpdateByValues(self.SearchDataList, nil)
        self.SearchFishData = self.SearchDataList[1]
        self.bFishSearchEmptyVisible = false
        return true
    else
        --如果搜索的内容为空，self.SelectedFishGridIndex,self.SelectFishNumberID不变，还保持为搜索前的选择
        self.SearchFishData = nil
        self.bSelectFishDetailVisible = false
        self.bFishSearchEmptyVisible = true
        self.bFishUnlockVisible = false
        return false
    end
end

---@type 传承录显示状态变更
function FishGuideVM:ChangeInheritDisplayState()
    self.bInheritTipsVisible = not self.bInheritTipsVisible
end

---@type 留言区显示状态
function FishGuideVM:CommentViewChanged(flag)
    local Params = {
		BoardTypeID = BoardType.FishNote, -- 留言板类型ID
		SelectObjectID = self.SelectFishItemID -- 图鉴中的物品ID
	}
    _G.UIViewMgr:ShowView(_G.UIViewID.MessageBoardPanel, Params)
    -- self.bCommentViewVisible = flag
end

---@type 鱼类排名分享信息
function FishGuideVM:GetShareFishInfo()
    local FishData = self.NowData
    local SaveData = FishNotesMgr:GetUnlockFishData(FishData.ID) or {Size = 0, SizeTime = 0, HistoryPercent = 0}
    local LocationType = not table.is_nil_empty(self.HauntList) and self.HauntList[1].LocationType or 0
    return FishData.ID, SaveData.Size, LocationType, SaveData.SizeTime, SaveData.HistoryPercent or 0
end

---@see 鱼类排名分享剪切板
function FishGuideVM:SetClipboard(ID, Size, LocationType, SizeTime, HighestRanking)
    self.FishClipboard = {
        ID = ID,
        Size = Size,
        LocationType = LocationType,
        SizeTime = SizeTime,
        Ranking = HighestRanking,
        RoleID = MajorUtil.GetMajorRoleID()
    }
	MsgTipsUtil.ShowTips(_G.LSTR(1310011))
    _G.UE.UPlatformUtil.ClipboardCopy(ChatUtil.GetFishShareMacro())
end

function FishGuideVM:GenChatFishShareHref()
    local Info = self.FishClipboard
	if nil == Info then
		return
	end

	local ID = Info.ID
	local Size = Info.Size
	local LocationType = Info.LocationType
	local SizeTime = Info.SizeTime
	local Ranking = Info.Ranking

	if nil == ID or nil == Size or nil == LocationType or nil == SizeTime or nil == Ranking then
        _G.FLOG_ERROR("FishGuideVM.GenChatFishShareHref params error")
		return
	end

	local Href = {
		Type = ProtoCS.PARAM_TYPE_DEFINE.PARAM_TYEP_DEFINE_FISH,
		Fish = { ID = ID, Size = Size, LocationType = LocationType, Time = SizeTime, Ranking = Ranking, RoleID = Info.RoleID}
	}

    return Href
end

return FishGuideVM
