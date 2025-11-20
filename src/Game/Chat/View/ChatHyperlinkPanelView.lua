---
--- Author: xingcaicao
--- DateTime: 2024-11-27 20:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local ChatVM = require("Game/Chat/ChatVM")
local ChatMgr = require("Game/Chat/ChatMgr")
local ChatDefine = require("Game/Chat/ChatDefine")
local UIBindableList = require("UI/UIBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local ChatEmojiCfg = require("TableCfg/ChatEmojiCfg")
local ChatGifTypeCfg = require("TableCfg/ChatGifTypeCfg")
local ChatGifCfg = require("TableCfg/ChatGifCfg")
local ItemVM = require("Game/Item/ItemVM")
local ItemUtil = require("Utils/ItemUtil")
local ChatHyperlinkLocationItemVM = require("Game/Chat/VM/ChatHyperlinkLocationItemVM")
local ChatUtil = require("Game/Chat/ChatUtil")
local TipsUtil = require("Utils/TipsUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

local LSTR = _G.LSTR
local HyperlinkLocationType = ChatDefine.HyperlinkLocationType

local BagMgr = _G.BagMgr
local FLOG_INFO = _G.FLOG_INFO

local HyperlinkCategory = {
	Expression = 0,	-- 表情
	Bag = 1, -- 背包
	History = 2, -- 历史记录
}

local TabType = {
	Emoji 		= 1000, -- 系统表情
	Equip 		= 1001, -- 装备
	Item 		= 1002, -- 道具
	Location 	= 1003, -- 位置 
	HistoryText = 1004, -- 历史文字 
	HistoryExpression = 1005, -- 历史表情
}

local LocationConfig = {
	{
		Type 		= HyperlinkLocationType.MyLocation,
		MapDescUkey = nil,
		TipsUkey 	= 50018, -- "我的位置"
		NormalIcon 	= "PaperSprite'/Game/UI/Atlas/NewChat/Frames/UI_Chat_Img_Loction_png.UI_Chat_Img_Loction_png'",
	},
	{
		Type 		= HyperlinkLocationType.OpenMap,
		MapDescUkey = 50019, -- "打开地图"
		TipsUkey 	= 50020, -- "标记位置"
		NormalIcon 	= "PaperSprite'/Game/UI/Atlas/NewChat/Frames/UI_Chat_Img_Map_png.UI_Chat_Img_Map_png'",
	}
}

---@class ChatHyperlinkPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnHideHyperlinkPanel UFButton
---@field ComRedDotExpression CommonRedDotView
---@field EmojiPanel UFCanvasPanel
---@field EmptyTipsPanel CommBackpackEmptyView
---@field GifPanel UFCanvasPanel
---@field GoodsPanel UFCanvasPanel
---@field HistoryExpressionPanel UFCanvasPanel
---@field HistoryTextPanel UFCanvasPanel
---@field LocationPanel UFCanvasPanel
---@field TableViewEmoji UTableView
---@field TableViewGif UTableView
---@field TableViewGoods UTableView
---@field TableViewHistoryExpression UTableView
---@field TableViewHistoryText UTableView
---@field TableViewLocation UTableView
---@field TableViewTab UTableView
---@field ToggleGroupCategory UToggleGroup
---@field AnimChangeContent UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimToggleButtonEmojiChecked UWidgetAnimation
---@field AnimToggleButtonHistoryChecked UWidgetAnimation
---@field AnimToggleButtonPropChecked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatHyperlinkPanelView = LuaClass(UIView, true)

function ChatHyperlinkPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnHideHyperlinkPanel = nil
	--self.ComRedDotExpression = nil
	--self.EmojiPanel = nil
	--self.EmptyTipsPanel = nil
	--self.GifPanel = nil
	--self.GoodsPanel = nil
	--self.HistoryExpressionPanel = nil
	--self.HistoryTextPanel = nil
	--self.LocationPanel = nil
	--self.TableViewEmoji = nil
	--self.TableViewGif = nil
	--self.TableViewGoods = nil
	--self.TableViewHistoryExpression = nil
	--self.TableViewHistoryText = nil
	--self.TableViewLocation = nil
	--self.TableViewTab = nil
	--self.ToggleGroupCategory = nil
	--self.AnimChangeContent = nil
	--self.AnimIn = nil
	--self.AnimToggleButtonEmojiChecked = nil
	--self.AnimToggleButtonHistoryChecked = nil
	--self.AnimToggleButtonPropChecked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatHyperlinkPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ComRedDotExpression)
	self:AddSubView(self.EmptyTipsPanel)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatHyperlinkPanelView:OnInit()
	self.BagItemVMList = UIBindableList.New(ItemVM)
	self.BagEquipVMList = UIBindableList.New(ItemVM)
    self.LocationVMList = UIBindableList.New(ChatHyperlinkLocationItemVM)
	self.ItemVMTip = ItemVM.New()

	self.TableAdapterTab = UIAdapterTableView.CreateAdapter(self, self.TableViewTab, self.OnSelectChangedTab)

	self.TableAdapterEmoji 				= UIAdapterTableView.CreateAdapter(self, self.TableViewEmoji)
	self.TableAdapterGif 	 			= UIAdapterTableView.CreateAdapter(self, self.TableViewGif)
	self.TableAdapterGoods 	 			= UIAdapterTableView.CreateAdapter(self, self.TableViewGoods)
	self.TableAdapterLocation 			= UIAdapterTableView.CreateAdapter(self, self.TableViewLocation)
	self.TableAdapterHistoryText		= UIAdapterTableView.CreateAdapter(self, self.TableViewHistoryText)
	self.TableAdapterHistoryExpression 	= UIAdapterTableView.CreateAdapter(self, self.TableViewHistoryExpression)

	self.TableAdapterTab:SetOnClickedCallback(self.OnItemClickedTab)
	self.TableAdapterEmoji:SetOnClickedCallback(self.OnItemClickedEmoji)
	self.TableAdapterGif:SetOnClickedCallback(self.OnItemClickedGif)
	self.TableAdapterGoods:SetOnClickedCallback(self.OnItemClickedGoods)
	self.TableAdapterHistoryExpression:SetOnClickedCallback(self.OnItemClickedGif)
end

function ChatHyperlinkPanelView:OnDestroy()

end

function ChatHyperlinkPanelView:OnShow()
	self.IsUpdateEquipList = true
	self.IsUpdateItemList = true

	self.ToggleGroupCategory:SetCheckedIndex(ChatVM.CurHyperlinkCategoryIdx or 0)
end

function ChatHyperlinkPanelView:OnHide()
	self:SetEmptyTips(false)
	self.TableAdapterGoods:CancelSelected()

	self.BagItemVMList:Clear()
	self.BagEquipVMList:Clear()
	self.LocationVMList:Clear()

	-- 清理数据
	self:ReleaseTableViewAllItems(self.CurTabType)
	self.CurCategory = nil 
	self.CurTabType = nil
end

function ChatHyperlinkPanelView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleGroupCategory, self.OnGroupStateChangedCategory)
	UIUtil.AddOnClickedEvent(self, self.BtnHideHyperlinkPanel, self.OnClickButtonHideHyperlinkPanel)
end

function ChatHyperlinkPanelView:OnRegisterGameEvent()

end

function ChatHyperlinkPanelView:OnRegisterBinder()
end

function ChatHyperlinkPanelView:ReleaseTableViewAllItems(Type)
	if Type == TabType.Emoji then
		self.TableAdapterEmoji:ReleaseAllItem(true)

	elseif Type == TabType.Equip then
		self.TableAdapterGoods:ReleaseAllItem(true)

	elseif Type == TabType.Item then
		self.TableAdapterGoods:ReleaseAllItem(true)

	elseif Type == TabType.Location then
		self.TableAdapterLocation:ReleaseAllItem(true)

	elseif Type == TabType.HistoryText then
		self.TableAdapterHistoryText:ReleaseAllItem(true)

	elseif Type == TabType.HistoryExpression then
		self.TableAdapterHistoryExpression:ReleaseAllItem(true)

	else
		self.TableAdapterGif:ReleaseAllItem(true)
	end	

	_G.ObjectMgr:CollectGarbage(false)
end

function ChatHyperlinkPanelView:OnGroupStateChangedCategory(ToggleGroup, ToggleButton, Index, State)
	if not self.IsShowView then
		return
	end

	local LastCategory = self.CurCategory
	if LastCategory == Index then
		return
	end

	if not UIUtil.IsToggleButtonChecked(State) then
		return
	end

	self.CurCategory = Index

	-- Tab
	self.TableAdapterTab:ReleaseAllItem(true)
	self.TableAdapterTab:CancelSelected()
	local TabDataList = self:GetTabDataList(Index) or {}
	self.TableAdapterTab:SetEntryWidth(#TabDataList > 2 and 285.0 or 427.5) -- 调整Tab的宽度
	self.TableAdapterTab:UpdateAll(TabDataList)

	--播放动效
	if Index == HyperlinkCategory.Expression then
		self:PlayAnimation(self.AnimToggleButtonEmojiChecked)

	elseif Index == HyperlinkCategory.Bag then
		self:PlayAnimation(self.AnimToggleButtonPropChecked)

	elseif Index == HyperlinkCategory.History then
		self:PlayAnimation(self.AnimToggleButtonHistoryChecked)
	end

	if ChatVM.CurHyperlinkCategoryIdx ~= Index then
		ChatVM.CurHyperlinkTabIdx = 1
		ChatVM.CurHyperlinkCategoryIdx = Index

		self.TableAdapterTab:SetSelectedIndex(1)
	else
		self.TableAdapterTab:SetSelectedIndex(ChatVM.CurHyperlinkTabIdx or 1)
	end

end

function ChatHyperlinkPanelView:GetTabDataList(Category)
	local Ret
	if Category == HyperlinkCategory.Expression then
		Ret = self.ExpressionTabs
		if nil == Ret then
			Ret = {}

			--系统表情
			if ChatUtil.IsOpenEmojiModule() then
				table.insert(Ret, {Type = TabType.Emoji, Name = LSTR(50030)}) -- "系统表情"
			end

			local Cfg = ChatGifTypeCfg:FindAllCfg()

			for _, v in ipairs(Cfg) do
				table.insert(Ret, {Type = v.ID, Name = v.Name, RedDotID = v.RedDotID})
			end
		end

		self.ExpressionTabs = Ret

	elseif Category == HyperlinkCategory.Bag then
		Ret = self.BagTabs
		if nil == Ret then
			Ret = {
				{ Type = TabType.Equip, Name = LSTR(50084) }, -- "装备"
				{ Type = TabType.Item, Name = LSTR(50085) }, -- "道具"
				{ Type = TabType.Location, Name = LSTR(50086) }, -- "位置"
			} 

			self.BagTabs = Ret
		end

	elseif Category == HyperlinkCategory.History then
		Ret = self.LocationTabs
		if nil == Ret then
			Ret = {
				{ Type = TabType.HistoryText, Name = LSTR(50052) }, -- "历史文字"
				{ Type = TabType.HistoryExpression, Name = LSTR(50053) }, -- "历史表情"
			} 

			self.LocationTabs = Ret
		end

		return Ret
	end

	return Ret
end

function ChatHyperlinkPanelView:OnItemClickedTab(Index, ItemData, ItemView)
	if nil == ItemData or nil == ItemData.Type then
		return
	end
end

function ChatHyperlinkPanelView:SetEmptyTips( IsVisible, TipsTextUkey )
	if IsVisible then 
		self.EmptyTipsPanel:SetTipsContent(LSTR(TipsTextUkey))
	end

	UIUtil.SetIsVisible(self.EmptyTipsPanel, IsVisible)
end

function ChatHyperlinkPanelView:OnSelectChangedTab(Index, ItemData, ItemView)
	if nil == ItemData or nil == ItemData.Type then
		return
	end

	ChatVM.CurHyperlinkTabIdx = Index

	UIUtil.SetIsVisible(self.EmojiPanel, false)
	UIUtil.SetIsVisible(self.GoodsPanel, false)
	UIUtil.SetIsVisible(self.GifPanel, false)
	UIUtil.SetIsVisible(self.LocationPanel, false)
	UIUtil.SetIsVisible(self.HistoryTextPanel, false)
	UIUtil.SetIsVisible(self.HistoryExpressionPanel, false)

	--清理上一个tableview数据
	self:ReleaseTableViewAllItems(self.CurTabType)

	local Type = ItemData.Type
	self.CurTabType = Type

	if Type == TabType.Emoji then -- 系统表情(emoji)
		self:ShowEmoji()

	elseif Type == TabType.Equip then
		self:ShowEquips()

	elseif Type == TabType.Item then
		self:ShowItems()

	elseif Type == TabType.Location then
		self:ShowLocation()

	elseif Type == TabType.HistoryText then
		self:ShowHistoryText()

	elseif Type == TabType.HistoryExpression then
		self:ShowHistoryExpression()

	else -- Gif
		self:ShowGif(Type)
	end
end


-------------------------------------------------------------------------------------------------
--- 表情 

function ChatHyperlinkPanelView:ShowEmoji( )
	local DataList = ChatEmojiCfg:FindAllCfg()
	self.TableAdapterEmoji:UpdateAll(DataList)

	local IsEmpty = #DataList <= 0
	self:SetEmptyTips(IsEmpty, 50048) -- "暂无表情"
	UIUtil.SetIsVisible(self.EmojiPanel, not IsEmpty)
end

function ChatHyperlinkPanelView:ShowGif(Type)
	local DataList = {}
	local CfgList = ChatGifCfg:GetCfgListByTypeID(Type) or {}

	-- 过滤掉未解锁Gif
	for _, Cfg in ipairs(CfgList) do
		local v = table.clone(Cfg)
		local ID = v.ID
		local bNeedUnlock = (v.NeedUnlock == 1 and v.UnlockItemID and v.UnlockItemID ~= 0)
		if v.NeedUnlock == 1 then
			v.IsLock = not ChatVM:IsGiftUnlocked(ID)
			if v.IsLock then
				v.bNotUse = BagMgr:GetItemByResID(v.UnlockItemID) ~= nil
			end
		end

		-- FLOG_INFO("[ChatHyperlinkPanelView:ShowGif] ID:%d, NeedUnlock:%d, IsLock:%s", v.ID, v.NeedUnlock, tostring(v.IsLock))
		if v.IsHidden == 1 then
			-- 企鹅表情，未解锁时需要隐藏
			-- if v.IsUnlock then
			if bNeedUnlock then
				table.insert(DataList, v)
			end
		else
			table.insert(DataList, v)
		end
	end

	table.sort(DataList, function(a, b)
		if a.IsLock ~= b.IsLock then
			return a.IsLock ~= true
		end
		if a.bNotUse ~= b.bNotUse then
			return a.bNotUse
		end
		local aRedDotValue = _G.RedDotMgr:GetNodeValueByID(a.RedDotID) or 0
		local bRedDotValue = _G.RedDotMgr:GetNodeValueByID(b.RedDotID) or 0
		if aRedDotValue ~= bRedDotValue then
			return aRedDotValue < bRedDotValue
		end
		return (a.ID or 0) < (b.ID or 0) -- ID小的排在前面
	end)

	self.TableAdapterGif:UpdateAll(DataList)

	local IsEmpty = #DataList <= 0
	self:SetEmptyTips(IsEmpty, 50048) -- "暂无表情"
	UIUtil.SetIsVisible(self.GifPanel, not IsEmpty)
end

function ChatHyperlinkPanelView:OnItemClickedEmoji(Index, ItemData, ItemView)
	if nil == ItemData or nil == ItemData.ID then
		return
	end
	
	local ID = tostring(ItemData.ID)
	if string.isnilorempty(ID) then
		return
	end

	EventMgr:SendEvent(EventID.ChatInsertInputText, "&" .. ID)
end

function ChatHyperlinkPanelView:OnItemClickedGif(Index, ItemData, ItemView)
	if nil == ItemData then
		return
	end

	-- FLOG_INFO("[ChatHyperlinkPanelView:OnItemClickedGif] ID:%d, NeedUnlock:%d, IsLock:%s", ItemData.ID, ItemData.NeedUnlock, tostring(ItemData.IsLock))
	if ItemData.NeedUnlock and ItemData.IsLock then
		-- 未解锁
		-- 检测背包是否存在表情道具，存在则弹出快捷使用弹窗，否则显示来源弹窗
		--local ResID = 61900023
		local ResID = ItemData.UnlockItemID
		local Item = BagMgr:GetItemByResID(ResID)
		if Item then
			-- 弹出快捷使用弹窗
			BagMgr:PopUpEasyUse(Item)
		else
			-- 显示来源弹窗
			self.ItemVMTip.ResID = ResID
			local Params = { ViewModel = self.ItemVMTip, InTagetView = ItemView, Offset = _G.UE.FVector2D(-24, -8), ParentViewID=_G.UIViewID.ChatHyperlinkPanel}
			local ModValue = Index % 7
			if ModValue == 0 or ModValue > 5 then
				Params.Extras = { OffsetXViewCount = -1 }
				Params.Offset = _G.UE.FVector2D(24, -8)
			end
			ItemTipsUtil.OnClickedToGetBtn(Params)
		end
		return
	end

	if ChatMgr:SendGif(ItemData.ID) then
		-- 红点设置为已读
		ChatVM:AddGifReadRedDotIDs({ItemData.RedDotID})
		self:Hide()
	end
end

-------------------------------------------------------------------------------------------------
--- 背包 

function ChatHyperlinkPanelView:ShowEquips( )
	local VMList = self.BagEquipVMList 
	if nil == VMList then
		return
	end

	if self.IsUpdateEquipList then
		self.IsUpdateEquipList = false 
		local EquipList = _G.BagMgr:FilterItemByCondition(function(Item)
			return ItemUtil.CheckIsEquipmentByResID(Item.ResID)
		end)

		VMList:UpdateByValues(EquipList, nil, true)
	end

	self.TableAdapterGoods:UpdateAll(VMList)

	local IsEmpty = VMList:Length() <= 0
	self:SetEmptyTips(IsEmpty, 50049) -- "暂无装备"
	UIUtil.SetIsVisible(self.GoodsPanel, not IsEmpty)

	if not IsEmpty then
		self.TableAdapterGoods:ScrollToTop()
	end
end

function ChatHyperlinkPanelView:ShowItems( )
	local VMList = self.BagItemVMList
	if nil == VMList then
		return
	end

	if self.IsUpdateItemList then
		self.IsUpdateItemList = false 
		local ItemList = _G.BagMgr:FilterItemByCondition(function(Item)
			return not ItemUtil.CheckIsEquipmentByResID(Item.ResID)
		end)

		VMList:UpdateByValues(ItemList, nil, true)
	end

	self.TableAdapterGoods:UpdateAll(VMList)

	local IsEmpty = VMList:Length() <= 0
	self:SetEmptyTips(IsEmpty, 50050) -- "暂无道具"
	UIUtil.SetIsVisible(self.GoodsPanel, not IsEmpty)

	if not IsEmpty then
		self.TableAdapterGoods:ScrollToTop()
	end
end

function ChatHyperlinkPanelView:ShowLocation( )
	local VMList = self.LocationVMList	
	if VMList:Length() <= 0 then
		VMList:UpdateByValues(LocationConfig)
	end

	-- 当前位置
	local CurLocItemVM = VMList:Find(function(e) return e.Type == HyperlinkLocationType.MyLocation end) 
	if CurLocItemVM then
		CurLocItemVM:UpdateByCurLocation()
	end

	self.TableAdapterLocation:UpdateAll(VMList)
	self:SetEmptyTips(false)
	UIUtil.SetIsVisible(self.LocationPanel, true)
end

function ChatHyperlinkPanelView:OnItemClickedGoods(Index, ItemData, ItemView)
	if nil == ItemData then
		return
	end

	EventMgr:SendEvent(EventID.ChatHyperLinkSelectGoods, ItemData)
end


-------------------------------------------------------------------------------------------------
--- 历史记录 

-- 历史文字

function ChatHyperlinkPanelView:ShowHistoryText()
	local IsEmpty = true
	local VMList = ChatVM.HistoryTextVMList
	if VMList then
		self.TableAdapterHistoryText:UpdateAll(VMList)
		IsEmpty = VMList:Length() <= 0
	end

	self:SetEmptyTips(IsEmpty, 50051) -- "暂无历史记录"
	UIUtil.SetIsVisible(self.HistoryTextPanel, not IsEmpty)
end

-- 历史表情(Gif)
function ChatHyperlinkPanelView:ShowHistoryExpression()
	local IsEmpty = true
	local VMList = ChatVM.HistoryGifVMList
	if VMList then
		self.TableAdapterHistoryExpression:UpdateAll(VMList)
		IsEmpty = VMList:Length() <= 0
	end

	self:SetEmptyTips(IsEmpty, 50051) -- "暂无历史记录"
	UIUtil.SetIsVisible(self.HistoryExpressionPanel, not IsEmpty)
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function ChatHyperlinkPanelView:OnClickButtonHideHyperlinkPanel()
	self:Hide()
end

return ChatHyperlinkPanelView