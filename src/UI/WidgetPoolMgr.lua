--
-- Author: anypkvcai
-- Date: 2022-11-14 17:26
-- Description:
--
local LinkedList = require("Core/LinkedList")
local WidgetPool = require("UI/WidgetPool")
local TimeUtil = require("Utils/TimeUtil")
local CommonUtil = require("Utils/CommonUtil")
local UIViewConfig = require("Define/UIViewConfig")
local ObjectMgr = require("Object/ObjectMgr")
local ObjectGCType = require("Define/ObjectGCType")
local UWidgetBlueprintLibrary = _G.UE.UWidgetBlueprintLibrary
local UIDefine = require("Define/UIDefine")
local UILayer = require("UI/UILayer")

local FLOG_INFO = _G.FLOG_INFO
--local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_ERROR = _G.FLOG_ERROR

--缓存的时间 单位：秒
local CacheTime = 60

--缓存的数量
local CacheNum = 5

--回收的数量
local GCNum = 3

---@class WidgetPoolMgr
---@field WidgetPools table
---@field CachedWidgetsByTime LinkedList
---@field CachedWidgetsByNum LinkedList
local WidgetPoolMgr = {
	WidgetPools = {},
	CachedWidgetsByTime = LinkedList.New(),
	CachedWidgetsByNum = LinkedList.New(),
	WidgetsPendingToRecycle = {}
}

---CreateWidgetSync
---@param BPName string
---@param GCType ObjectGCType | nil @nil表示用默认值 ObjectGCType.LRU
---@param IsAutoInitWidget boolean
---@param IsAutoShowWidget boolean
---@param Params any
---@public
function WidgetPoolMgr:CreateWidgetSyncByName(BPName, GCType, IsAutoInitWidget, IsAutoShowWidget, Params)
	return self:CreateWidgetSyncInternal(BPName, GCType, nil, nil, IsAutoInitWidget, IsAutoShowWidget, Params)
end

---CreateWidgetSyncByViewID
---@param ViewID UIViewID
---@param IsAutoInitWidget boolean
---@param IsAutoShowWidget boolean
---@param Params any
---@public
function WidgetPoolMgr:CreateWidgetSyncByViewID(ViewID, IsAutoInitWidget, IsAutoShowWidget, Params)
	local Config = self:FindConfig(ViewID)
	if nil == Config then
		FLOG_ERROR("WidgetPoolMgr:CreateWidgetSyncByViewID ViewConfig is nil, ViewID=%d", ViewID)
		return
	end

	return self:CreateWidgetSyncInternal(Config.BPName, Config.GCType, ViewID, Config, IsAutoInitWidget, IsAutoShowWidget, Params)
end

---CreateWidgetAsync
---@param BPName string
---@param GCType ObjectGCType | nil @nil表示用默认值 ObjectGCType.LRU
---@param Callback function
---@param IsAutoInitWidget boolean
---@param IsAutoShowWidget boolean
---@param Params any
---@public
function WidgetPoolMgr:CreateWidgetAsyncByName(BPName, GCType, Callback, IsAutoInitWidget, IsAutoShowWidget, Params)
	return self:CreateWidgetAsyncInternal(BPName, GCType, nil, nil, Callback, IsAutoInitWidget, IsAutoShowWidget, Params)
end

---CreateWidgetAsyncByViewID
---@param ViewID UIViewID
---@param Callback function
---@param IsAutoInitWidget boolean
---@param IsAutoShowWidget boolean
---@param Params any
---@public
function WidgetPoolMgr:CreateWidgetAsyncByViewID(ViewID, Callback, IsAutoInitWidget, IsAutoShowWidget, Params)
	local Config = self:FindConfig(ViewID)
	if nil == Config then
		FLOG_ERROR("WidgetPoolMgr:CreateWidgetAsyncByViewID ViewConfig is nil, ViewID=%d", ViewID)

		if nil ~= Callback then
			Callback()
		end
		return
	end

	return self:CreateWidgetAsyncInternal(Config.BPName, Config.GCType, ViewID, Config, Callback, IsAutoInitWidget, IsAutoShowWidget, Params)
end

---PrepareRecycleWidget
---@param Widget UIView
function WidgetPoolMgr:PrepareRecycleWidget(Widget)
	--print("WidgetPoolMgr:PrepareRecycleWidget", Widget.ObjectName, Widget.AncestorName)
	table.insert(self.WidgetsPendingToRecycle, Widget)
end

---RecycleWidget
---@param Widget UIView
---@Params bCacheByNum @超过缓存数量会释放
---@public
function WidgetPoolMgr:RecycleWidget(Widget, bCacheByNum)
	if nil == Widget then
		FLOG_ERROR("WidgetPoolMgr:RecycleWidget Widget is nil")
		return
	end

	--print("WidgetPoolMgr:RecycleWidget", Widget.ObjectName, Widget.AncestorName)

	Widget:RemoveFromParentView()

	table.remove_item(self.WidgetsPendingToRecycle, Widget)

	local Pool = self:GetWidgetPool(Widget.BPName)
	if Widget:IsForceGC() or UIDefine.bForceGC then
		--print("WidgetPoolMgr:ForceReleaseWidget", Widget.BPName)
		Pool:ForceReleaseWidget(Widget)
		self:UnLoadClass(Pool)
		ObjectMgr:CollectGarbage(false)
		return
	end

	Pool:RecycleWidget(Widget)

	if Widget:GetGCType() ~= ObjectGCType.LRU then
		return
	end

	local Time = TimeUtil.GetGameTime()
	local CachedItem = { Pool = Pool, Widget = Widget, Time = Time }

	local CachedWidgetsByTime = self.CachedWidgetsByTime
	CachedWidgetsByTime:AddTail(CachedItem)

	if bCacheByNum then
		local CachedWidgetsByNum = self.CachedWidgetsByNum
		CachedWidgetsByNum:AddTail(CachedItem)

		if CachedWidgetsByNum:GetNum() >= CacheNum then
			for _ = 1, GCNum do
				local Item = CachedWidgetsByNum:RemoveHead()
				CachedWidgetsByTime:Remove(Item)
				--FLOG_INFO("WidgetPoolMgr:RecycleWidget Name=%s", Item.Widget.BPName)
				Item.Pool:ReleaseExpiredWidgets(Item.Widget)
				self:UnLoadClass(Item.Pool)
			end

			ObjectMgr:CollectGarbage(false)
		end
	end
end

---ReleaseAllWidgets
function WidgetPoolMgr:ReleaseAllWidgets()
	self.CachedWidgetsByNum:Empty()
	self.CachedWidgetsByTime:Empty()
	self.WidgetsPendingToRecycle = {}

	for _, v in pairs(self.WidgetPools) do
		v:ReleaseAllWidgets()
		self:UnLoadClass(v)
	end
end

---ReleaseAllWidgetsExceptHold
function WidgetPoolMgr:ReleaseAllWidgetsExceptHold()
	self.CachedWidgetsByNum:Empty()
	self.CachedWidgetsByTime:Empty()

	for k, v in pairs(self.WidgetPools) do
		v:ReleaseAllWidgetsExceptHold()
		self:UnLoadClass(v)
		if v:GetWidgetCount() <= 0 then
			self.WidgetPools[k] = nil
		end
	end
end

---ReleaseExpiredWidgetsPredicate
---@param Item table
---@private
function WidgetPoolMgr.ReleaseExpiredWidgetsPredicate(Item)
	return TimeUtil.GetGameTime() >= Item.Time + CacheTime
end

---ReleaseExpiredWidgets
function WidgetPoolMgr:ReleaseExpiredWidgets()
	local WidgetsPendingToRecycle = self.WidgetsPendingToRecycle
	local Num = #WidgetsPendingToRecycle
	if Num > 0 then
		--FLOG_INFO("WidgetPoolMgr:ReleaseExpiredWidgets WidgetsPendingToRecycle")
		for i = Num, 1, -1 do
			--local View = WidgetsPendingToRecycle[i]
			--if nil ~= View and View:IsValid() then
			--	self:RecycleWidget(View)
			--end
			self:RecycleWidget(WidgetsPendingToRecycle[i])
		end

		self.WidgetsPendingToRecycle = {}
	end

	local List = self.CachedWidgetsByTime:RemoveAll(WidgetPoolMgr.ReleaseExpiredWidgetsPredicate)
	if nil == List then
		return
	end

	for i = 1, #List do
		local Item = List[i]
		Item.Pool:ReleaseExpiredWidgets(Item.Widget)
		WidgetPoolMgr.CachedWidgetsByNum:Remove(Item)
	end
end

---CreateWidgetSyncInternal
---@private
function WidgetPoolMgr:CreateWidgetSyncInternal(BPName, GCType, ViewID, Config, IsAutoInitWidget, IsAutoShowWidget, Params)
	local Widget = self:GetWidget(BPName)
	if nil ~= Widget then
		return self:CreateWidgetInternal(Widget, BPName, GCType, ViewID, Config, IsAutoInitWidget, IsAutoShowWidget, Params)
	end

	local BPPath = self:GetBPPath(BPName)
	local Class = ObjectMgr:LoadClassSync(BPPath, GCType)
	if nil == Class then
		FLOG_ERROR("WidgetPoolMgr:CreateWidgetSyncInternal LoadClass failed, BPName=%s", BPName)
		return
	end

	local NewWidget = UWidgetBlueprintLibrary.Create(self:GetWorld(), Class)
	if nil == NewWidget then
		FLOG_ERROR("WidgetPoolMgr:CreateWidgetSyncInternal Create failed, BPName=%s", BPName)
		return
	end

	if ObjectGCType.NoCache ~= GCType then
		local Pool = self:GetWidgetPool(BPName)
		Pool:SetBPPath(BPPath)
		Pool:AddWidget(NewWidget, true)
	end

	return self:CreateWidgetInternal(NewWidget, BPName, GCType, ViewID, Config, IsAutoInitWidget, IsAutoShowWidget, Params)
end

---CreateWidgetAsyncInternal
---@private
function WidgetPoolMgr:CreateWidgetAsyncInternal(BPName, GCType, ViewID, Config, Callback, IsAutoInitWidget, IsAutoShowWidget, Params)
	local Widget = self:GetWidget(BPName)
	if nil ~= Widget then
		self:CreateWidgetInternal(Widget, BPName, GCType, ViewID, Config, IsAutoInitWidget, IsAutoShowWidget, Params)

		if nil ~= Callback then
			Callback(Widget)
		end

		return
	end

	local BPPath = self:GetBPPath(BPName)

	local function LoadCallback()
		local Class = ObjectMgr:GetClass(BPPath)
		if nil == Class then
			FLOG_ERROR("WidgetPoolMgr:CreateWidgetAsyncInternal LoadClass failed, BPName=%s", BPName)
			return
		end

		local NewWidget = UWidgetBlueprintLibrary.Create(self:GetWorld(), Class)

		if nil == NewWidget then
			FLOG_ERROR("WidgetPoolMgr:CreateWidgetAsyncInternal Create failed, BPName=%s", BPName)
			return
		end

		if ObjectGCType.NoCache ~= GCType then
			local Pool = self:GetWidgetPool(BPName)
			Pool:SetBPPath(BPPath)
			Pool:AddWidget(NewWidget, true)
		end

		self:CreateWidgetInternal(NewWidget, BPName, GCType, ViewID, Config, IsAutoInitWidget, IsAutoShowWidget, Params)

		if nil ~= Callback then
			Callback(NewWidget)
		end
	end

	ObjectMgr:LoadClassAsync(BPPath, LoadCallback, GCType)
end

---CreateWidgetInternal
---@private
function WidgetPoolMgr:CreateWidgetInternal(Widget, BPName, GCType, ViewID, Config, IsAutoInitWidget, IsAutoShowWidget, Params)
	Widget:SetGCType(GCType)
	Widget:SetLayer(Config and Config.Layer or UILayer.Normal)

	if IsAutoInitWidget then
		do
			local _ <close> = CommonUtil.MakeProfileTag(string.format("WidgetPoolMgr:CreateWidgetInternal_%s", BPName))
			Widget:InitView(ViewID, Config)

			Widget:LoadView()
		end

		if IsAutoShowWidget then
			Widget:ShowView(Params, false)
		end
	end

	Widget:SetBPName(BPName)

	return Widget
end

---PreLoadWidgetByName
---@param BPName string
---@param GCType ObjectGCType 默认用的Hold
---@param Num number
----@return boolean
function WidgetPoolMgr:PreLoadWidgetByName(BPName, GCType, Num)
	local Count = self:GetInactiveWidgetsCount(BPName)
	if Count > 0 then
		return true
	end

	local BPPath = self:GetBPPath(BPName)

	local function LoadCallback()
		local Class = ObjectMgr:GetClass(BPPath)
		if nil == Class then
			FLOG_ERROR("WidgetPoolMgr:PreLoadWidgetByName LoadClass failed, BPName=%s", BPName)
			return
		end

		for _ = 1, Num or 1 do
			local NewWidget = UWidgetBlueprintLibrary.Create(self:GetWorld(), Class)
			if nil == NewWidget then
				FLOG_ERROR("WidgetPoolMgr:PreLoadWidgetByName Create failed, BPName=%s", BPName)
				return
			end

			local Pool = self:GetWidgetPool(BPName)
			Pool:SetBPPath(BPPath)
			Pool:AddWidget(NewWidget, false)

			NewWidget:SetGCType(GCType or ObjectGCType.Hold)
			NewWidget:SetBPName(BPName)
		end
	end

	local ret = ObjectMgr:LoadClassAsync(BPPath, LoadCallback, ObjectGCType.Hold)
	return ret >= 0
end

---PreLoadWidgetByViewID
---@public
---@param ViewID UIViewID
---@param GCType ObjectGCType 默认用的Hold
---@param Num number
----@return boolean
function WidgetPoolMgr:PreLoadWidgetByViewID(ViewID, GCType, Num)
	local Config = self:FindConfig(ViewID)
	if nil == Config then
		FLOG_ERROR("WidgetPoolMgr:PreLoadWidgetByViewID ViewConfig is nil, ViewID=%d", ViewID)
		return false
	end

	return self:PreLoadWidgetByName(Config.BPName, GCType, Num)
end

---GetWorld
---@private
function WidgetPoolMgr:GetWorld()
	return _G.UE.UFGameInstance.Get():GetWorld()
end

---GetWidgetPool
---@param BPName string
---@private
function WidgetPoolMgr:GetWidgetPool(BPName)
	local Pool = self.WidgetPools[BPName]
	if nil == Pool then
		Pool = WidgetPool.New()
		self.WidgetPools[BPName] = Pool
	end

	return Pool
end

---GetWidget
---@param BPName string
---@private
function WidgetPoolMgr:GetWidget(BPName)
	local Pool = self:GetWidgetPool(BPName)
	if nil ~= Pool then
		local Widget = Pool:GetWidget()
		self.CachedWidgetsByNum:RemoveByName("Widget", Widget)
		self.CachedWidgetsByTime:RemoveByName("Widget", Widget)
		return Widget
	end
end

---GetActiveWidgetsCount
function WidgetPoolMgr:GetActiveWidgetsCount(BPName)
	local Pool = self:GetWidgetPool(BPName)
	return Pool and Pool:GetActiveWidgetsCount() or 0
end

---GetInactiveWidgetsCount
function WidgetPoolMgr:GetInactiveWidgetsCount(BPName)
	local Pool = self:GetWidgetPool(BPName)
	return Pool and Pool:GetInactiveWidgetsCount() or 0
end

---FindConfig
---@param ViewID UIViewID
---@private
function WidgetPoolMgr:FindConfig(ViewID)
	return UIViewConfig[ViewID]
end

---GetBPPath
---@param BPName string
---@private
function WidgetPoolMgr:GetBPPath(BPName)
	-- local Name = string.match(BPName, "(%w+)$")
	local Name = string.match(BPName, "([%w_]+)$")

	return string.format("Class'/Game/UI/BP/%s.%s_C'", BPName, Name)
end

---UnLoadClass 避免ObjectMgr还有缓存
---@param Pool WidgetPool
function WidgetPoolMgr:UnLoadClass(Pool)
	if Pool and Pool:GetWidgetCount() <= 0 then
		local Path = Pool:GetBPPath()
		--print("WidgetPoolMgr:UnLoadClass", Path)
		ObjectMgr:UnLoadClass(Path, false)
	end
end

function WidgetPoolMgr:DumpWidgets()
	_G.FLOG_INFO("WidgetPoolMgr:DumpWidgets Begin ----------------------------------------------------------------")

	local ActiveWidgetsNum = 0
	local InactiveWidgets = 0
	for k, v in pairs(self.WidgetPools) do
		ActiveWidgetsNum = ActiveWidgetsNum + v:GetActiveWidgetsCount()
		InactiveWidgets = InactiveWidgets + v:GetInactiveWidgetsCount()
		_G.FLOG_INFO(string.format("BPName=%s ActiveCount=%d InactiveCount=%d", k, v:GetActiveWidgetsCount(), v:GetInactiveWidgetsCount()))
	end

	_G.FLOG_INFO("WidgetPoolMgr:DumpWidgets ActiveWidgetsNum=%d InactiveWidgets=%d Total=%d", ActiveWidgetsNum, InactiveWidgets, ActiveWidgetsNum + InactiveWidgets)

	_G.FLOG_INFO("WidgetPoolMgr:DumpWidgets CachedWidgetsByTime=%d CachedWidgetsByNum=%d", self.CachedWidgetsByTime:GetNum(), self.CachedWidgetsByNum:GetNum())

	local ChildUserWidgets = _G.UE.UUIMgr.Get().ChildUserWidgets:ToTable()
	_G.FLOG_INFO("WidgetPoolMgr:DumpWidgets ChildUserWidgets=%d", #ChildUserWidgets)

	for i = 1, #ChildUserWidgets do
		_G.FLOG_INFO(string.format("ChildUserWidgets Widget=%s", ChildUserWidgets[i]:GetName()))
	end

	_G.FLOG_INFO("WidgetPoolMgr:DumpWidgets End ----------------------------------------------------------------")
end

return WidgetPoolMgr
