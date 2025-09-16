local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local BuddyFeedItemVM = require("Game/Buddy/VM/BuddyFeedItemVM")
local BuddyAIItemVM = require("Game/Buddy/VM/BuddyAIItemVM")
local ActorUtil = require("Utils/ActorUtil")
local BuddyAiCfg = require("TableCfg/BuddyAiCfg")
local BuddyFoodCfg = require("TableCfg/BuddyFoodCfg")
local GroupBonusStateDataCfg = require("TableCfg/GroupBonusStateDataCfg")
local BuddyMgr = require("Game/Buddy/BuddyMgr")
local ItemVM = require("Game/Item/ItemVM")
local ItemUtil = require("Utils/ItemUtil")
local TimeUtil = require("Utils/TimeUtil")

---@class BuddyStatusPageVM : UIViewModel
local BuddyStatusPageVM = LuaClass(UIViewModel)

BuddyStatusPageVM.TabType = {Feed = 1, AI = 2}
---Ctor
function BuddyStatusPageVM:Ctor()
	self.MiddleContentVisible = nil
	self.NoCallVisible = nil
	self.FeedOrderVisible = nil

	self.FeedListVisible = nil
	self.AIListVisible = nil
	
	self.HpText = nil
	self.CallTimeText = nil
		
	self.HPProgressPercent = nil
	self.CallTimePercent = nil

	self.BuffImg = nil
	self.BuffImgVisible = nil

	self.CallBtnEnable = nil
	self.HPProgressEnable = nil
	self.CallTimeEnable = nil
	self.SupplementBtnEnable = nil
		
	self.FeedBtnEnable = nil
	self.UseAIBtnEnable = nil

	self.FeedBtnVisible = nil
	self.UseAIVisible = nil

	self.FeedListVMList = UIBindableList.New(BuddyFeedItemVM)
	self.AIListVMList = UIBindableList.New(BuddyAIItemVM)

	self.TabIndex = nil
    self.CurFeedID = nil
	self.CurAIID = nil

	self.ItemVM = ItemVM.New()
	
	self.OnlyOrderVisible = nil
	self.OrderAndFeedVisible = nil
	self.NameText = nil
	self.TextColor = nil

	self.BuffNodeVisible = nil
	self.LeaveNodeVisible = nil

    self.Supple = nil
end

function BuddyStatusPageVM:UpdateVM()
	self.OnlyOrderVisible = false
	self.OrderAndFeedVisible = true

	local AddTimeItem = ItemUtil.CreateItem(BuddyMgr.CallTimeItemID, 1)
	self.ItemVM:UpdateVM(AddTimeItem, {IsShowNumProgress = true})

	self.NameText = BuddyMgr:GetBuddyName()

	if BuddyMgr:IsBuddyOuting() == false then
		self:ShowCallBuddy()
	else
		self:ShowBuddyStatus()
	end

	self:UpdateBuddyHp()
	self:UpdateFeedList()
	self:UpdateAIList()

	self:SetOnlyOrderVisible()
end

function BuddyStatusPageVM:SetOnlyOrderVisible()
	self.OnlyOrderVisible = true
	self.OrderAndFeedVisible = false
	self:SetTabsSelectionIndex(BuddyStatusPageVM.TabType.AI)
end

function BuddyStatusPageVM:UpdateBuddyHp()
	self.HpText = ""
	self.CallTimeText = ""
	self.HPProgressPercent = 0
	self.CallTimePercent = 0
	self.BuffImgVisible = false

	if BuddyMgr:IsBuddyOuting() == false then
		return
	end

	local AttributeComponent = ActorUtil.GetActorAttributeComponent(BuddyMgr.BuddyEntityID)
    if nil == AttributeComponent then
        return
    end

    local CurHP = AttributeComponent:GetCurHp()
    local MaxHP = AttributeComponent:GetMaxHp()
	self.HpText = string.format("%d/%d", CurHP, MaxHP)
	if MaxHP == 0 then
		self.HPProgressPercent = 0
	else
		self.HPProgressPercent = CurHP / MaxHP
	end

	self:UpdateBuddyTime()
	self:UpdateBuddyState()
end

function BuddyStatusPageVM:UpdateBuddyTime()
	if BuddyMgr:IsBuddyOuting() == false then
		self.CallTimeText = ""
		self.CallTimePercent = 0
		self.BuffNodeVisible = false
		self.LeaveNodeVisible = false
		return
	end

	local RemainTime = BuddyMgr:GetBuddyRemainTime()
    local MaxCD = BuddyMgr:GetBuddyTotalTime()
	if self.Supple then
		self.CallTimeText = string.format("<span color=\"#D1BA8EFF\">%s</>/%s", TimeUtil.GetFmtTime_MS(RemainTime), TimeUtil.GetFmtTime_MS(MaxCD))
		self.Supple = false
	else
		self.CallTimeText = string.format("%s/%s", TimeUtil.GetFmtTime_MS(RemainTime), TimeUtil.GetFmtTime_MS(MaxCD))
	end
	if MaxCD == 0 then
		self.CallTimePercent = 0
	else
		self.CallTimePercent = RemainTime / MaxCD
	end

	local BuddyActivity = BuddyMgr:CanBuddyActivity()
	self.HPProgressEnable = BuddyActivity
	self.CallTimeEnable = BuddyActivity

	self.BuffNodeVisible = BuddyActivity
	self.LeaveNodeVisible = not BuddyActivity
end

function BuddyStatusPageVM:UpdateBuddyState()
	local State = BuddyMgr:GetBuddyBuff()
	if State == nil then
		self.BuffImgVisible = false
		return
	end

	local StateShowCfg = GroupBonusStateDataCfg:FindCfgByKey(State)
    if StateShowCfg ~= nil then
		self.BuffImgVisible = true
        self.BuffImg = StateShowCfg.EffectIcon
    end
end

function BuddyStatusPageVM:ShowCallBuddy()
	self.NoCallVisible = true
	self.MiddleContentVisible = false
	self.FeedOrderVisible = false
	self.TextColor = "828282"
	self.CallBtnEnable = BuddyMgr:CanBuddyActivity() and _G.BagMgr:GetItemNum(BuddyMgr.CallTimeItemID) > 0
end

function BuddyStatusPageVM:ShowBuddyStatus()
	self.NoCallVisible = false
	self.MiddleContentVisible = true
	self.FeedOrderVisible = true
	self.TextColor = "d5d5d5"
	self.SupplementBtnEnable = BuddyMgr:CanBuddyActivity() and _G.BagMgr:GetItemNum(BuddyMgr.CallTimeItemID) > 0
end

function BuddyStatusPageVM:UpdateFeedList()
	local AllFoodCfg = BuddyFoodCfg:FindAllCfg() or {}

	table.sort(AllFoodCfg, function(A, B)
		return A.ID < B.ID
	end )

	self.FeedListVMList:UpdateByValues(AllFoodCfg)
end

function BuddyStatusPageVM:UpdateAIList()
	self.AIListVMList:UpdateByValues(BuddyAiCfg:FindAllCfg())
end

function BuddyStatusPageVM:SetTabsSelectionIndex(Index, CurFeedID, CurAIID)
	self.TabIndex = Index
	if Index == BuddyStatusPageVM.TabType.Feed then
		self.FeedListVisible = true
		self.AIListVisible = false
		self.FeedBtnVisible = true
		self.FeedBtnEnable = false
		self.UseAIVisible = false
		self:SelectedFeedItem(CurFeedID)
	elseif Index == BuddyStatusPageVM.TabType.AI then
		self.FeedListVisible = false
		self.AIListVisible = true
		self.UseAIVisible = true
		self.UseAIBtnEnable = false
		self.FeedBtnVisible = false
		self:SelectedAIItem(CurAIID)
	end
end

function BuddyStatusPageVM:SelectedFeedItem(ID)
	self.CurFeedID = ID
	for i = 1, self.FeedListVMList:Length() do
		local FeedListVM = self.FeedListVMList:Get(i)
		FeedListVM:UpdateIconState(ID)
		if ID == FeedListVM.ID then
			self.FeedBtnEnable = FeedListVM.Item.Num > 0 and BuddyMgr:CanBuddyActivity()
			if ID == self.BreakThroughItemID then
				if BuddyMgr:CanBreakThrough() == false or BuddyMgr:IsMaxLevel() then
					self.FeedBtnEnable = false
				end
			end
		end
	end
end

function BuddyStatusPageVM:SelectedAIItem(ID)
	self.CurAIID = ID
	for i = 1, self.AIListVMList:Length() do
		local AIListVM = self.AIListVMList:Get(i)
		AIListVM:UpdateIconState(ID)
		if ID == AIListVM.ID then
			self.UseAIBtnEnable = AIListVM.UseImgVisible == false and BuddyMgr:CanBuddyActivity()
		end
	end
end

--要返回当前类
return BuddyStatusPageVM