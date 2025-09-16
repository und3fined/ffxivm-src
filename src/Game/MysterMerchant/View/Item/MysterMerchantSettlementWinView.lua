---
--- Author: Administrator
--- DateTime: 2024-05-20 15:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local AudioUtil = require("Utils/AudioUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MysterMerchantVM = require("Game/MysterMerchant/VM/MysterMerchantVM")
local MysterMerchantMgr = require("Game/MysterMerchant/MysterMerchantMgr")
local MerchantDefine = require("Game/MysterMerchant/MysterMerchantDefine")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class MysterMerchantSettlementWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonThroughFrameS_UIBP CommonThroughFrameSView
---@field GoodImpression MysterMerchantGoodImpressionItemView
---@field PanelAdd UFCanvasPanel
---@field TableViewProps UTableView
---@field TextAddQuantity UFTextBlock
---@field TextGoodImpression UFTextBlock
---@field TextQuantity UFTextBlock
---@field TextUnlockProps UFTextBlock
---@field AnimFinishExpUp UWidgetAnimation
---@field AnimFinishExpUpUnlock UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MysterMerchantSettlementWinView = LuaClass(UIView, true)

function MysterMerchantSettlementWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonThroughFrameS_UIBP = nil
	--self.GoodImpression = nil
	--self.PanelAdd = nil
	--self.TableViewProps = nil
	--self.TextAddQuantity = nil
	--self.TextGoodImpression = nil
	--self.TextQuantity = nil
	--self.TextUnlockProps = nil
	--self.AnimFinishExpUp = nil
	--self.AnimFinishExpUpUnlock = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MysterMerchantSettlementWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonThroughFrameS_UIBP)
	self:AddSubView(self.GoodImpression)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MysterMerchantSettlementWinView:OnInit()
	self.LevelUpNum = 0 --等级提升数
	
	self.UnlockGoodsListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewProps, self.OnUnlockItemSelected, true, false)
	self.Binders = {
		{"PrevFriendlinessLevel", UIBinderSetText.New(self, self.GoodImpression.TextLv) },
		{"FriendlinessEXPSettlementText", UIBinderSetText.New(self, self.TextQuantity) },
		{"UnlockGoodsVMList", UIBinderUpdateBindableList.New(self, self.UnlockGoodsListAdapter)},
		{"PreEXPPercent", UIBinderValueChangedCallback.New(self, nil, self.OnEXPPercentChanged)},
		{"AddExp", UIBinderSetText.New(self, self.TextAddQuantity) },
		--{"AddExp", UIBinderSetPercent.New(self, self.GoodImpression.ImgProgressFull)},
	}
end

function MysterMerchantSettlementWinView:OnDestroy()

end

function MysterMerchantSettlementWinView:OnShow()
	self:SetLSTR()
	local PrevLevel = MysterMerchantVM:GetPrevFriendlinessLevel()
	local CurLevel = MysterMerchantVM:GetFriendlinessLevel()
	self.LevelUpNum = CurLevel - PrevLevel
	self.IsPerformEnd = false
	self:StartExePerform()
	self:OnCheckLevelMax(PrevLevel)
	self.CommonThroughFrameS_UIBP.PopUpBG:SetHideOnClick(false)
	self:RegisterTimer(self.EnableHide, 2.5)
	AudioUtil.LoadAndPlayUISound(MerchantDefine.SoundPath.Settlement)
end

function MysterMerchantSettlementWinView:OnHide()
	MysterMerchantMgr:EndInteraction()
end

function MysterMerchantSettlementWinView:OnRegisterUIEvent()

end

function MysterMerchantSettlementWinView:OnRegisterGameEvent()

end

function MysterMerchantSettlementWinView:OnRegisterBinder()
	self:RegisterBinders(MysterMerchantVM, self.Binders)
end

function MysterMerchantSettlementWinView:OnEXPPercentChanged(Percent)
	self.GoodImpression.ImgProgressFull:SetPercent(Percent)
	local Angle = Percent * 360
	self.GoodImpression.PanelProgressLight:SetRenderTransformAngle(Angle)
end

function MysterMerchantSettlementWinView:SetLSTR()
	self.CommonThroughFrameS_UIBP.TextTitle:SetText(_G.LSTR(1110047)) -- 1110047("解围成功")
	self.CommonThroughFrameS_UIBP.TextCloseTips:SetText(_G.LSTR(10056)) --("点击空白处关闭")
	self.TextUnlockProps:SetText(_G.LSTR(1110048)) --1110048("解锁新商品")
end

function MysterMerchantSettlementWinView:EnableHide()
	self.CommonThroughFrameS_UIBP.PopUpBG:SetHideOnClick(true)
end

function MysterMerchantSettlementWinView:StartExePerform()
	local IsLevelUp = MysterMerchantVM:IsLevelUp()
	if IsLevelUp then
		self:OnLevelUp()
	else
		self:OnOnlyExpUp()
	end
end

---@type 只有经验增长无升级
function MysterMerchantSettlementWinView:OnOnlyExpUp()
	self.IsPerformEnd = true
	local CurEXPPercent = MysterMerchantVM:GetEXPPercent()
	local PreEXPPercent = MysterMerchantVM:GetPreEXPPercent()
	local StartPercent = PreEXPPercent
	local EndPercent = CurEXPPercent
	self:PlayAnimExpUp(StartPercent, EndPercent)
	AudioUtil.LoadAndPlayUISound(MerchantDefine.SoundPath.ExpUp)
end

---@type 友好度升级
function MysterMerchantSettlementWinView:OnLevelUp()
	local StartPercent = MysterMerchantVM:GetPreEXPPercent()
	local EndPercent = 1
	self:PlayAnimExpUp(StartPercent, EndPercent)
	self.IsPerformEnd = false
end

---@type 播放经验增长动效
function MysterMerchantSettlementWinView:PlayAnimExpUp(StartPercent, EndPercent)
	self:RegisterTimer(
		function()
			local EndTime = self.GoodImpression:PlayProgressUpAnim(StartPercent, EndPercent)
			self:RegisterTimer(self.OnExpUpAnimFinished, EndTime)
			
		end, 
		0.3
	)
end

---@type 经验增长动效播放完
function MysterMerchantSettlementWinView:OnExpUpAnimFinished()
	if self.IsPerformEnd then
		self:PlayExpUpFinishAnim()
	else
		if self.LevelUpNum > 0 then
			self:PlayLevelUpAnim()
		end
	end
end

---@type 播放经验增长结束动效 显示经验文本
function MysterMerchantSettlementWinView:PlayExpUpFinishAnim()
	local IsLevelUp = MysterMerchantVM:IsLevelUp()
	local Animation = IsLevelUp and self.AnimFinishExpUpUnlock or self.AnimFinishExpUp
	self:PlayAnimation(Animation)
	if IsLevelUp then
		AudioUtil.LoadAndPlayUISound(MerchantDefine.SoundPath.UnlockGoods)
	end
end

---@type 播放友好度升级动效
function MysterMerchantSettlementWinView:PlayLevelUpAnim()
	self:RegisterTimer(
		function()
			local EndTime = self.GoodImpression:PlayLevelUpAnim()
			self:RegisterTimer(self.OnLevelUpAnimFinished, EndTime)
		end, 
		0.5
	)
end

---@type 当升级动效播放完
function MysterMerchantSettlementWinView:OnLevelUpAnimFinished()
	local PrevLevel = MysterMerchantVM:GetPrevFriendlinessLevel()
	local UpLevel = PrevLevel + 1
	self.GoodImpression:UpdateLevel(UpLevel)
	self.LevelUpNum = self.LevelUpNum - 1
	FLOG_INFO("剩余升级数："..self.LevelUpNum)
	self:OnCheckLevelMax(UpLevel)

	if self.LevelUpNum > 0 then
		self:PlayAnimExpUp(0, 1)
	else
		self.IsPerformEnd = true
		local CurLevelLeftExp = MysterMerchantVM:GetCurLevelLeftExp()
		if CurLevelLeftExp > 0 then
			--升级后还需要增长经验时，播放经验增长动效
			local CurEXPPercent = MysterMerchantVM:GetEXPPercent()
			local StartPercent = 0
			local EndPercent = CurEXPPercent
			self:PlayAnimExpUp(StartPercent, EndPercent)
		else
			self:OnExpUpAnimFinished()
			self.GoodImpression:PlayProgressUpAnim(0, 0)
		end
	end
end

---@type 友好度已满
function MysterMerchantSettlementWinView:OnCheckLevelMax(Level)
	if MysterMerchantVM:IsMaxLevel(Level) then
		self.TextGoodImpression:SetText(MerchantDefine.MaxLevelText)--("友好度已满")
		UIUtil.SetIsVisible(self.TextQuantity, false)
		UIUtil.SetIsVisible(self.PanelAdd, false)
	else
		UIUtil.SetIsVisible(self.PanelAdd, true)
		UIUtil.SetIsVisible(self.TextQuantity, true)
		self.TextGoodImpression:SetText(_G.LSTR(1110049))--1110049("友好度")
	end
end


---@type 点击选中解锁商品
function MysterMerchantSettlementWinView:OnUnlockItemSelected(Index, ItemData, ItemView)
	local ItemID = ItemData and ItemData.ItemID or 0
	if ItemID > 0 then
		ItemTipsUtil.ShowTipsByItem({ResID = ItemID}, ItemView, {X = -2, Y = -15})
	end
end

return MysterMerchantSettlementWinView