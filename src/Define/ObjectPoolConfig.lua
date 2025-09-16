--
-- Author: anypkvcai
-- Date: 2022-06-15 15:02
-- Description: 记录需要预加载的LuaClass对象，一般为需要频繁创建的LuaClass
-- WiKi: https://iwiki.woa.com/pages/viewpage.action?pageId=1861039916

local ActorVM = require("Game/Actor/ActorVM")
local ActorBufferVM = require("Game/Actor/ActorBufferVM")
local HUDActorView = require("Game/HUD/HUDActorView")
local HUDActorVM = require("Game/HUD/HUDActorVM")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")
local ItemVM = require("Game/Item/ItemVM")
local DepotPageVM = require("Game/Depot/DepotPageVM")
local TeamMemberVM = require("Game/Team/VM/TeamMemberVM")
local TeamInviteVM = require("Game/Team/VM/TeamInviteVM")
local RollTipsVM = require("Game/Roll/RollTipsVM")
local CommMenuChildVM = require("Game/Common/Menu/CommMenuChildVM")
local CommMenuParentVM = require("Game/Common/Menu/CommMenuParentVM")
local WardrobeEquipmentSlotItemVM = require("Game/Wardrobe/VM/Item/WardrobeEquipmentSlotItemVM")
local ShopGoodsListItemVM = require("Game/Shop/ItemVM/ShopGoodsListItemVM")
local EmoActVM = require("Game/EmoAct/VM/EmoActVM")
local RedDotItemVM = require("Game/CommonRedDot/VM/RedDotItemVM")
local MapMarkerFixedPoint = require("Game/Map/Marker/MapMarkerFixedPoint")
local MapMarkerVM = require("Game/Map/MarkerVM/MapMarkerVM")
local ChatMsgItemVM = require("Game/Chat/VM/ChatMsgItemVM")
local SavageRankViewRankItemVM = require("Game/SavageRank/View/Item/SavageRankViewRankItemVM")



local ObjectPoolConfig = {
	{ ObjectClass = ActorVM, PreLoadNum = 10 },
	{ ObjectClass = ActorBufferVM, PreLoadNum = 30 },
	{ ObjectClass = HUDActorView, PreLoadNum = 20 },
	{ ObjectClass = HUDActorVM, PreLoadNum = 20 },
	{ ObjectClass = BagSlotVM, PreLoadNum = 600 },
	{ ObjectClass = ItemVM, PreLoadNum = 100 },

	{ ObjectClass = DepotPageVM, PreLoadNum = 1 },
	{ ObjectClass = TeamMemberVM, PreLoadNum = 8 },
	{ ObjectClass = TeamInviteVM, PreLoadNum = 3 },
	{ ObjectClass = RollTipsVM, PreLoadNum = 1 },
	{ ObjectClass = CommMenuChildVM, PreLoadNum = 20 },
	{ ObjectClass = CommMenuParentVM, PreLoadNum = 10 },
	{ ObjectClass = WardrobeEquipmentSlotItemVM, PreLoadNum = 10 },
	{ ObjectClass = ShopGoodsListItemVM, PreLoadNum = 30 },
	{ ObjectClass = EmoActVM, PreLoadNum = 30 },
	{ ObjectClass = RedDotItemVM, PreLoadNum = 30 },
	{ ObjectClass = MapMarkerFixedPoint, PreLoadNum = 60 },
	{ ObjectClass = MapMarkerVM, PreLoadNum = 60 },
	{ ObjectClass = SavageRankViewRankItemVM, PreLoadNum = 100 },
	{ ObjectClass = ChatMsgItemVM, PreLoadNum = 500 },
}

return ObjectPoolConfig