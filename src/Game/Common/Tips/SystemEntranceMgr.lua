--
-- Author: v_zanchang
-- Date: 2023-6-7 14:01:23
-- Description:
--

local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
local ShopMgr = require("Game/Shop/ShopMgr")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIViewID = _G.UIViewID
local WorldMapMgr = _G.WorldMapMgr
local FishNotesMgr = _G.FishNotesMgr
local SystemEntranceMgr = {}

--副本 1
---@param TypeID 副本类型 1每日随机,2迷宫挑战,3讨伐歼灭战,4大型任务
function SystemEntranceMgr:ShowPwordEntrance(TypeID, PMapWordID)
    -- Util.ShowPWorldEntviewNM(1001003)
    --每日随机
    -- PWorldEntUtil.ShowPWorldEntViewDR(1211008)
    --非
    -- if TypeID == 3 then
    --     -- PWorldEntUtil.ShowPWorldEntView(TypeID, 1202021) -- 讨伐歼灭战 3
    --     -- PWorldEntUtil.ShowPWorldEntViewNM(1202015)
    -- elseif TypeID == 2 then
    --     -- PWorldEntUtil.ShowPWorldEntView(TypeID, 1202021) -- 迷宫挑战 2
    --     -- PWorldEntUtil.ShowPWorldEntViewNM(1211002)
    -- elseif TypeID == 4 then
    --     -- PWorldEntUtil.ShowPWorldEntView(TypeID, 1202021) -- 大型任务 4
    --     -- PWorldEntUtil.ShowPWorldEntViewNM(1206001)
    -- elseif TypeID == 1 then
    --     -- PWorldEntUtil.ShowPWorldEntView(TypeID, 1202021) -- 每日随机 1
    -- end
    PWorldEntUtil.ShowPWorldEntViewNM(PMapWordID)
end

--商店 1
---@param ShopId number@商店ID
---@param ItemId number@物品ID
function SystemEntranceMgr:ShowShopEntrance(ShopID, ItemID, TransferData)
    --ShopMgr:OpenShop(ShopID, ItemID)
    ShopMgr:JumpToShopGoods(ShopID, ItemID, nil, TransferData)
end

function SystemEntranceMgr:ShowArmyShopEntrance(ItemID, TransferData)
    _G.ArmyMgr:JumpToArmyShopGoods(ItemID, TransferData)
end

--商城 1
function SystemEntranceMgr:ShowStoreEntrance(ItemID, TransferData)
    if not _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMall) then
        _G.MsgTipsUtil.ShowTips(LSTR(950088))
        return
    end
	local bOpenBuyWindow = false
	local bIsMysterbox = false
	if nil ~= TransferData then
		bOpenBuyWindow = nil ~= TransferData.NeedBuyNum
		bIsMysterbox = TransferData.FunValue == 1
	end
	_G.StoreMgr:JumpToGoods(ItemID, nil, bOpenBuyWindow, bIsMysterbox)
end

--钓鱼笔记 1
function SystemEntranceMgr:ShowFishIngholeEntrance(ItemData)
    if ItemData.LocationInfo ~= nil then
        _G.EventMgr:SendEvent(_G.EventID.FishNoteSkipLocation, ItemData.LocationInfo)
    else
        FishNotesMgr:ShowCanFishLocation(ItemData.ItemID) --搜索鱼类
    end
end

--制作笔记
---@param ItemId number@物品ID
function SystemEntranceMgr:ShowCraftingLogEntrance(ItemID)
    if _G.UIViewMgr:IsViewVisible(_G.UIViewID.CraftingLog) then
        if _G.UIViewMgr:IsViewVisible(UIViewID.ShopBuyPropsWinView)
        or _G.UIViewMgr:IsViewVisible(UIViewID.MarketMainPanel) then
            _G.MsgTipsUtil.ShowTips(_G.LSTR(1200048))--"无法跳转到已经打开的界面"
            return
        end
    else
        _G.UIViewMgr:ShowView(_G.UIViewID.CraftingLog)
    end
    _G.CraftingLogMgr:OpenCraftingLogWithItemID(ItemID)
end

--采集笔记
function SystemEntranceMgr:ShowGatheringLogEntrance(ItemID)
    _G.GatheringLogMgr:SearchInGatheringLog(ItemID)
end

--地图
function SystemEntranceMgr:ShowMapEntrance(MapID)
    WorldMapMgr:ShowWorldMap(MapID)
end

--危命任务
function SystemEntranceMgr:ShowFateTask(InFuncValue)
    if _G.UIViewMgr:IsViewVisible(UIViewID.TreasureHuntMainPanel) then
        _G.UIViewMgr:HideView(UIViewID.TreasureHuntMainPanel)
    end

    if (InFuncValue == nil or InFuncValue < 0) then
        _G.FLOG_ERROR("SystemEntranceMgr:ShowFateTask ，传入的参数错误，请检查")
        return
    end

    local bShowRewardPanel = InFuncValue % 10 > 0
    local TargetFateID = math.floor(InFuncValue * 0.1)
    _G.FateMgr:ShowFateArchive(TargetFateID, 0, bShowRewardPanel, false)
end

--跳转交易所售卖对应物品的页面
function SystemEntranceMgr:ShowMarketItemEntrance(ItemID)
    if _G.MarketMgr:CanUnLockMarket() == false then
        _G.MsgTipsUtil.ShowTipsByID(358001)
        return
    end
    _G.UIViewMgr:ShowView(UIViewID.MarketMainPanel, {JumpToBuyItemID = ItemID})
end

-- 采集系统
function SystemEntranceMgr:ShowGatherWorldMap(GatherID)
    if _G.UIViewMgr:IsViewVisible(UIViewID.TreasureHuntMainPanel) then
        _G.UIViewMgr:HideView(UIViewID.TreasureHuntMainPanel)
    end

    _G.GatherMgr:NavigateToMap(GatherID)
end

return SystemEntranceMgr
