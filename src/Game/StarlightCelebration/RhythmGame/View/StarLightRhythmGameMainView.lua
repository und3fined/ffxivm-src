---
--- Author: Administrator
--- DateTime: 2025-07-15 20:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class StarLightRhythmGameMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnPause UFButton
---@field FCanvasPanel_42 UFCanvasPanel
---@field FTextBlock_2 UFTextBlock
---@field HorizontalCombo UFHorizontalBox
---@field ImgLine UFImage
---@field RhythmGameHudPanel StarLightRhythmGameHudPanelView
---@field TableViewProgress UTableView
---@field TextCombo UFTextBlock
---@field TextNumber UFTextBlock
---@field TextTItleGole UFTextBlock
---@field TextTips UFTextBlock
---@field AnimCombo UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StarLightRhythmGameMainView = LuaClass(UIView, true)

function StarLightRhythmGameMainView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnPause = nil
	--self.FCanvasPanel_42 = nil
	--self.FTextBlock_2 = nil
	--self.HorizontalCombo = nil
	--self.ImgLine = nil
	--self.RhythmGameHudPanel = nil
	--self.TableViewProgress = nil
	--self.TextCombo = nil
	--self.TextNumber = nil
	--self.TextTItleGole = nil
	--self.TextTips = nil
	--self.AnimCombo = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StarLightRhythmGameMainView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RhythmGameHudPanel)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StarLightRhythmGameMainView:OnInit()
	self.SatisfactionAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewProgress, nil, nil)
end

function StarLightRhythmGameMainView:OnDestroy()

end

function StarLightRhythmGameMainView:OnShow()
	self.TextTItleGole:SetText(_G.LSTR(1710001)) --  "得分"
	self.TextTips:SetText(_G.LSTR(1710002))  --连击
	
	self.FCanvasSize = UIUtil.GetWidgetSize(self.FCanvasPanel_42)
	UIUtil.SetIsVisible(self.RhythmGameHudPanel, false)
	UIUtil.SetIsVisible(self.FTextBlock_2, _G.RhythmGameMgr.DebugMode)
	UIUtil.SetIsVisible(self.ImgLine, _G.RhythmGameMgr.DebugMode)
	
	self.NodePool = {
		ActiveNodes = {},    -- 正在使用的节点
		InactiveNodes = {},  -- 可重用的节点
	}
	self.CurActiveNodes = {} -- 用于存储当前活动的音符节点，key为音符ID，value为节点对象
	-- 预先创建6个节点
	for i = 1, 10 do
		local NodeView = _G.UIViewMgr:CloneView(self.RhythmGameHudPanel, self, true, true)
		self.FCanvasPanel_42:AddChildToCanvas(NodeView)
		local Anchor = _G.UE.FAnchors()
		Anchor.Minimum = _G.UE.FVector2D(0.5, 0.5)
		Anchor.Maximum = _G.UE.FVector2D(0.5, 0.5)
		UIUtil.CanvasSlotSetAnchors(NodeView, Anchor)
		UIUtil.CanvasSlotSetAlignment(NodeView, _G.UE.FVector2D(0.5, 0.5))
		UIUtil.CanvasSlotSetPosition(NodeView, _G.UE.FVector2D(0, 0))
		UIUtil.SetIsVisible(NodeView, false)
		
		-- 添加到空闲池
		table.insert(self.NodePool.InactiveNodes, NodeView)
	end

	_G.RhythmGameMgr:StartGame()
end

function StarLightRhythmGameMainView:OnHide()
	self:ClearNodePool()
end

function StarLightRhythmGameMainView:OnRegisterUIEvent()

end

function StarLightRhythmGameMainView:OnRegisterGameEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnPause, function()
		_G.RhythmGameMgr:ShowPauseMsgBox()
	end)
end

function StarLightRhythmGameMainView:OnRegisterBinder()
	local Binder = {
		{ "SScore", UIBinderSetText.New(self, self.TextNumber) },
		{ "DebugText", UIBinderSetText.New(self, self.FTextBlock_2) },
		{ "Combo", UIBinderValueChangedCallback.New(self, nil, self.OnComboValueUpdated)},
		{ "SatisfactionVMList", UIBinderUpdateBindableList.New(self, self.SatisfactionAdapter) },
	}

	self:RegisterBinders(_G.RhythmGameMgr:GetRhythmGameVM(), Binder)
end

function StarLightRhythmGameMainView:OnComboValueUpdated(Value)
	if Value >= 2 then
		self.TextCombo:SetText(tostring(Value))
		if not self:IsAnimationPlaying(self.AnimCombo) then
			self:PlayAnimation(self.AnimCombo)
		end
	else
		if not self:IsAnimationPlaying(self.AnimCombo) then
			self.TextCombo:SetText(tostring(Value))
		end
	end
end

-- 从缓存池获取节点
function StarLightRhythmGameMainView:GetNodeFromPool()
	-- 尝试从空闲池获取
	if #self.NodePool.InactiveNodes > 0 then
		local NodeView = table.remove(self.NodePool.InactiveNodes)
		self.NodePool.ActiveNodes[NodeView] = true
		return NodeView
	end

	-- 空闲池为空，创建新节点
	local NodeView = _G.UIViewMgr:CloneView(self.RhythmGameHudPanel, self, true, true)
	self.FCanvasPanel_42:AddChildToCanvas(NodeView)
	local Anchor = _G.UE.FAnchors()
	Anchor.Minimum = _G.UE.FVector2D(0.5, 0.5)
	Anchor.Maximum = _G.UE.FVector2D(0.5, 0.5)
	UIUtil.CanvasSlotSetAnchors(NodeView, Anchor)
	UIUtil.CanvasSlotSetAlignment(NodeView, _G.UE.FVector2D(0.5, 0.5))
	UIUtil.CanvasSlotSetPosition(NodeView, _G.UE.FVector2D(0, 0))
	UIUtil.SetIsVisible(NodeView, false)

	-- 添加到活动池
	self.NodePool.ActiveNodes[NodeView] = true

	return NodeView
end

-- 回收节点到缓存池
function StarLightRhythmGameMainView:ReturnNodeToPool(NodeView)
	if not NodeView or not self.NodePool or not self.NodePool.ActiveNodes[NodeView] then
		return
	end

	-- 从活动池移除
	self.NodePool.ActiveNodes[NodeView] = nil

	-- 重置节点状态
	UIUtil.SetIsVisible(NodeView, false)

	-- 添加到空闲池
	table.insert(self.NodePool.InactiveNodes, NodeView)
end

-- 清理所有节点
function StarLightRhythmGameMainView:ClearNodePool()
	if not self.NodePool then return end

	-- 销毁所有节点
	for _, NodeView in ipairs(self.NodePool.InactiveNodes) do
		self.FCanvasPanel_42:RemoveChild(NodeView)
		_G.UIViewMgr:RecycleView(NodeView)
	end

	for NodeView, _ in pairs(self.NodePool.ActiveNodes) do
		self.FCanvasPanel_42:RemoveChild(NodeView)
		_G.UIViewMgr:RecycleView(NodeView)
	end

	self.NodePool = nil
end

function StarLightRhythmGameMainView:SpawnNotes(NoteTable)
	if not NoteTable or #NoteTable == 0 then return end
	
	for _, NoteData in ipairs(NoteTable) do
		-- 从缓存池获取一个节点
		local NodeView = self:GetNodeFromPool()
		if NodeView then
			-- 设置节点可见
			UIUtil.SetIsVisible(NodeView, true)
			NodeView:UpdateNote(NoteData)
			self.CurActiveNodes[NoteData.ID] = NodeView
		end
	end
end

-- 清理所有激活的节点
function StarLightRhythmGameMainView:RemoveActiveNodes()
	for ID, NodeView in pairs(self.CurActiveNodes) do
		self:ReturnNodeToPool(NodeView)
		self.CurActiveNodes[ID] = nil
	end
end

function StarLightRhythmGameMainView:RemoveNote(ID)
	local NodeView = self.CurActiveNodes[ID]
	if not NodeView then return end
	
	self:ReturnNodeToPool(NodeView)
	self.CurActiveNodes[ID] = nil
end

function StarLightRhythmGameMainView:GetNote(ID)
	local NodeView = self.CurActiveNodes[ID]
	return NodeView
end

function StarLightRhythmGameMainView:UpdateScanLinePosition(Progress)
	if not self.FCanvasSize then
		return
	end

	local NodeHalfWidth = 182   -- 182是StarLightRhythmGameHudPanelView.NodeHalfWidth
	local ScanLineYPos = NodeHalfWidth + (self.FCanvasSize.Y - NodeHalfWidth - NodeHalfWidth) * Progress
	UIUtil.CanvasSlotSetPosition(self.ImgLine, _G.UE.FVector2D(0, -ScanLineYPos))
end

function StarLightRhythmGameMainView:PauseGame()
	for __, NodeView in pairs(self.CurActiveNodes) do
		NodeView:PauseGame()
	end
end

function StarLightRhythmGameMainView:ResumeGame()
	for __, NodeView in pairs(self.CurActiveNodes) do
		NodeView:ResumeGame()
	end
end

return StarLightRhythmGameMainView