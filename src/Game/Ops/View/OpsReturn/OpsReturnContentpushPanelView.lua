---
--- Author: Administrator
--- DateTime: 2025-07-10 14:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local OpsReturnContentpushPanelVM = require("Game/Ops/VM/OpsReturn/OpsReturnContentpushPanelVM")
local OpsReturnDefine = require("Game/Ops/View/OpsReturn/OpsReturnDefine")
local OpsReturnCfg = require("TableCfg/OpsReturnCfg")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ProtoRes = require("Protocol/ProtoRes")
local UKismetInputLibrary = UE.UKismetInputLibrary
local LSTR = _G.LSTR

---@class OpsReturnContentpushPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBulletin UFButton
---@field BtnGoto CommBtnMView
---@field BtnReplace CommBtnXSView
---@field BtnVideo UFButton
---@field PanelBanner UFCanvasPanel
---@field TableViewBanner UTableView
---@field TableViewMainBanner UTableView
---@field TableViewPoint UTableView
---@field TextBubbleTItle UFTextBlock
---@field TextBubbleTItle_1 UFTextBlock
---@field TextInfo UFTextBlock
---@field TextRecommend UFTextBlock
---@field TextSort UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsReturnContentpushPanelView = LuaClass(UIView, true)

function OpsReturnContentpushPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBulletin = nil
	--self.BtnGoto = nil
	--self.BtnReplace = nil
	--self.BtnVideo = nil
	--self.PanelBanner = nil
	--self.TableViewBanner = nil
	--self.TableViewMainBanner = nil
	--self.TableViewPoint = nil
	--self.TextBubbleTItle = nil
	--self.TextBubbleTItle_1 = nil
	--self.TextInfo = nil
	--self.TextRecommend = nil
	--self.TextSort = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsReturnContentpushPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnGoto)
	self:AddSubView(self.BtnReplace)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsReturnContentpushPanelView:OnInit()
	self.ViewModel = OpsReturnContentpushPanelVM.New()
	
	self.PointListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewPoint,  self.OnSelectedChanged, true)
	self.BannerImgListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewMainBanner, nil, true)
	self.BannerListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewBanner, self.OnClickedBanner, true)

	self.Binders = {
		{"TagName", UIBinderSetText.New(self, self.TextSort)},
		{"PointList", UIBinderUpdateBindableList.New(self, self.PointListAdapter)},
		{"BannerList", UIBinderUpdateBindableList.New(self, self.BannerListAdapter)},
		{"BannerImgList", UIBinderUpdateBindableList.New(self, self.BannerImgListAdapter)},
		{"DropListSelectIndex", UIBinderSetSelectedIndex.New(self, self.PointListAdapter)},
	}
end

function OpsReturnContentpushPanelView:OnDestroy()
end

function OpsReturnContentpushPanelView:OnShow()
	self.BannerCurIndex = 1
	self.TargetOffset = 1
	self.BannerID = 0
	self.IsDrag = false
	self.IsAnimating = false
	self:InitText()
	-- self.ViewModel:UpdateSystemVersion(1)
	self.ViewModel:UpdateTagName()
	-- 左边
	self.ViewModel:UpdateVersionList()
	-- 右边
	self.ViewModel:UpdateContentList()

	self.BannerLen = self.BannerImgListAdapter:GetNum() 
	if self.BannerLen > 1 then
		self.BannerCurIndex = 1
		self.BannerTimerID = self:RegisterTimer(function ()
			self:StartMoveToAnimation()
			self:ResetBannerTimer()
		end, 5, 0, 1)
	end
end

function OpsReturnContentpushPanelView:OnHide()
	self:ResetAnimationTimer()
	self:ResetBannerTimer()
	self.ViewModel.DropListSelectIndex = 0
	self.BannerID = 0
end

function OpsReturnContentpushPanelView:StartMoveToAnimation()
	if self.IsAnimating then
        return
    end
    
    self.IsAnimating = true
    self.AnimationProgress = 0
	self.AnimationStartTime  =  _G.TimeUtil.GetLocalTimeMS()

	-- 记录起始偏移量
	self.StartOffset = self.TableViewMainBanner:GetScrollOffset()
	
	-- 计算目标偏移量（下一个Banner的位置）
    self.TargetOffset = self.StartOffset + 1
    if self.TargetOffset >= self.BannerLen then
        self.TargetOffset = 0  -- 循环回到第一个
    end

	-- 计算总位移量
	self.TotalDistance =  self.TargetOffset - self.StartOffset

	self.AnimationDuration = 1000 -- 动画总时长毫秒
	self.AnimationInterval = 0.016 -- 动画更新间隔（秒)
    
    -- 注册动画定时器，每10毫秒更新一次
    self.AnimationTimerID = self:RegisterTimer(function()
        self:UpdateAnimation()
    end, 0, self.AnimationInterval, -1)
end

local function pow(t)
	return t*t*t
end  

function OpsReturnContentpushPanelView:UpdateAnimation()

	local currentTime = _G.TimeUtil.GetLocalTimeMS()
    
    -- 使用缓动函数计算当前位移比例（这里使用线性插值）
	local elapsedTime = currentTime - self.AnimationStartTime
    self.AnimationProgress = math.min(elapsedTime / self.AnimationDuration, 1.0)

	-- 使用easeOutCubic缓动函数实现先快后慢的效果
    local easedProgress = 1 - pow(1 - self.AnimationProgress, 3)
    
    -- 计算当前偏移量
    local NewOffset = self.StartOffset + (self.TotalDistance * easedProgress)
    
    -- 设置新的偏移量
    self.TableViewMainBanner:SetScrollOffset(NewOffset)

    -- 打印当前进度和item索引（调试用）
	-- _G.FLOG_INFO(string.format("动画进度: %.2f, 缓动进度: %.2f, 当前Offset: %.2f", 
    --     self.AnimationProgress * 100, easedProgress * 100, NewOffset))

    if self.AnimationProgress >= 1.0 then
        self:CompleteAnimation()
    end
end

function OpsReturnContentpushPanelView:CompleteAnimation()
	self.IsAnimating = false
	self.BannerCurIndex = self.BannerCurIndex + 1
	self.AnimationProgress = 0

    if self.BannerCurIndex >= self.BannerLen then
        self.BannerCurIndex = 1  -- 循环回到第一个
		self.TableViewMainBanner:SetScrollOffset(0)
    end
    
    -- 停止动画定时器
    if self.AnimationTimerID then
       self:ResetAnimationTimer()
    end

	local ItemData = self.BannerImgListAdapter:GetItemDataByIndex(self.BannerCurIndex)
	if ItemData ~= nil then
		self.ViewModel.DropListSelectIndex = ItemData.IndexPos
	end
    
    -- 记录当前item
	-- _G.FLOG_INFO(string.format("动画完成，当前item索引: %d", self.BannerCurIndex))
	
	self.BannerTimerID = self:RegisterTimer(function ()
				self:StartMoveToAnimation()
				self:ResetBannerTimer()
	end, 5, 0, 1)
end


function OpsReturnContentpushPanelView:ResetBannerTimer()
	self:UnRegisterTimer(self.BannerTimerID)
	self.BannerTimerID = nil
end

function OpsReturnContentpushPanelView:ResetAnimationTimer()
	self:UnRegisterTimer(self.AnimationTimerID)
	self.BannerTimerID = nil
	self.AnimationTimerID = nil
end

function OpsReturnContentpushPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGoto, self.OnClickedBtnGoto)
	UIUtil.AddOnClickedEvent(self, self.BtnBulletin, self.OnClickedBulletin)
	UIUtil.AddOnClickedEvent(self, self.BtnVideo, self.OnClickedBtnVideo)
	UIUtil.AddOnClickedEvent(self, self.BtnReplace, self.OnClickedNextTag)

	UIUtil.AddOnScrolledEvent(self, self.TableViewMainBanner, self.OnTableViewMainBannerScolled)
	UIUtil.AddOnScrolledToEndEvent(self, self.TableViewMainBanner, self.OnTableViewMainBannerScolledEnd)

end

function OpsReturnContentpushPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.UpdateOpsReturn, self.OnUpdateOpsReturn) -- 更新标签
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonUp, self.OnPreprocessedMouseButtonUp)
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseMove, self.OnPreprocessedMouseMove)
end

function OpsReturnContentpushPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function OpsReturnContentpushPanelView:OnTableViewMainBannerScolled(TableView, ItemOffset)
	local CurScrollValue = self.TableViewMainBanner:GetScrollOffset()
	_G.FLOG_INFO("OpsReturnContentpushPanelView:OnTableViewMainBannerScolled(): " .. CurScrollValue)
	if not self.IsAnimating then
		local Offset = math.ceil(self.TableViewMainBanner:GetScrollOffset() + 0.5) 
		--就是第几个
		self.BannerCurIndex = Offset
		local ItemData = self.BannerImgListAdapter:GetItemDataByIndex(Offset)
		if ItemData ~= nil then
			self.ViewModel.DropListSelectIndex = ItemData.IndexPos
		end
	else
		if self.IsDrag then
			local Offset = math.ceil(self.TableViewMainBanner:GetScrollOffset()) 
			--就是第几个
			self.BannerCurIndex = Offset
			local ItemData = self.BannerImgListAdapter:GetItemDataByIndex(Offset)
			if ItemData ~= nil then
				self.ViewModel.DropListSelectIndex = ItemData.IndexPos
			end
		end
	end
end

function OpsReturnContentpushPanelView:OnTableViewMainBannerScolledEnd()
	-- local Offset = math.ceil(self.TableViewMainBanner:GetScrollOffset() + 0.5) 
	-- --就是第几个
	-- self.BannerCurIndex = Offset + 1
	-- local ItemData = self.BannerImgListAdapter:GetItemDataByIndex(Offset)
	-- if ItemData ~= nil then
	-- 	self.ViewModel.DropListSelectIndex = ItemData.IndexPos
	-- end
end

function OpsReturnContentpushPanelView:OnPreprocessedMouseButtonDown(MouseEvent)
	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.PanelBanner, MousePosition) then
		self:UnRegisterTimer(self.BannerTimerID)
		self:UnRegisterTimer(self.AnimationTimerID)
		self.BannerTimerID = nil 
		self.AnimationTimerID = nil
		self.IsDrag = true
	end
end

function OpsReturnContentpushPanelView:OnPreprocessedMouseButtonUp(MouseEvent)
	if self.IsDrag then
		self:UnRegisterTimer(self.BannerTimerID)
		self.BannerTimerID = nil
		local Offset = math.ceil(self.TableViewMainBanner:GetScrollOffset()) 
		local Value = Offset - self.TableViewMainBanner:GetScrollOffset()
		_G.FLOG_INFO("OpsReturnContentpushPanelView:OnPreprocessedMouseButtonUp ".. Value)
		self.IsAnimating = false
		self.BannerTimerID = self:RegisterTimer(function ()
			self:StartMoveToAnimation()
		end, 5, 0, 1)
	end
	self.IsDrag = false
end

function OpsReturnContentpushPanelView:OnPreprocessedMouseMove(MouseEvent)
	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if not UIUtil.IsUnderLocation(self.PanelBanner, MousePosition) then
		self.IsDrag = false
	end
end

function OpsReturnContentpushPanelView:InitText()
	self.BtnGoto:SetText(LSTR(1680006)) --立即前往
	self.TextRecommend:SetText(LSTR(1680007)) --更多推荐
	self.TextInfo:SetText(LSTR(1680008)) --点击查看更多版本咨询
	self.BtnReplace:SetText(LSTR(1680009))  --换一批
end

-- Todo 根据系统类型 跳转对应系统
function OpsReturnContentpushPanelView:OnClickedBtnGoto()
	local BannerID = self.BannerID
	if BannerID == nil or BannerID == 0 then
		return 
	end

	local Cfg = OpsReturnCfg:FindCfgByKey(BannerID)
    if Cfg ~= nil then
		local JumpType = Cfg.JumpType
		local JumpParam = Cfg.JumpPara
		_G.OpsActivityMgr:Jump(JumpType, JumpParam)
    end
end

-- Todo 前往资讯
function OpsReturnContentpushPanelView:OnClickedBulletin()
	_G.PandoraMgr:OpenAnnouncement()
end

-- Todo 版本视频播放
function OpsReturnContentpushPanelView:OnClickedBtnVideo()
	local NodeID = OpsReturnDefine.ActivityNodeID[OpsReturnDefine.ActivityNodeType.VideoNodeID]
	local Cfg = ActivityNodeCfg:FindCfgByKey(NodeID)
	if Cfg and Cfg.StrParam  ~= "" then
		_G.UIViewMgr:ShowView(_G.UIViewID.CommonVideoPlayerView, {VideoPath = Cfg.StrParam})
	end
end

-- Todo 点击推送内容，前往对应系统
function OpsReturnContentpushPanelView:OnClickedBanner(Index, ItemData, ItemView)
	local BannerID = ItemData.BannerID
	if BannerID == nil then
		return 
	end

	local Cfg = OpsReturnCfg:FindCfgByKey(BannerID)
    if Cfg ~= nil then
		local JumpType = Cfg.JumpType
		local JumpParam = Cfg.JumpPara
		_G.OpsActivityMgr:Jump(JumpType, JumpParam)
    end
end

-- Todo 点击滚动版本内容，前往对应系统
function OpsReturnContentpushPanelView:OnClickedVersion(Index, ItemData, ItemView)
	local BannerID = self.BannerID
	if BannerID == nil or BannerID == 0 then
		return 
	end

	local Cfg = OpsReturnCfg:FindCfgByKey(BannerID)
    if Cfg ~= nil then
		local JumpType = Cfg.JumpType
		local JumpParam = Cfg.JumpPara
		_G.OpsActivityMgr:Jump(JumpType, JumpParam)
    end
end

function OpsReturnContentpushPanelView:OnClickedNextTag()
	-- 更新版本内容，
	if self.ViewModel ~= nil then
		self.ViewModel:UpdateContentList(_G.OpsReturnMgr:GetContentEndIndex() + 1)
		self.BannerListAdapter:ScrollToTop()
	end
end

function OpsReturnContentpushPanelView:OnSelectedChanged(Index, ItemData, ItemView)
	if ItemData == nil then
		return
	end

	local BannerID =ItemData.BannerID
	self.BannerID = BannerID
	local Cfg = OpsReturnCfg:FindCfgByKey(BannerID)
	if Cfg ~= nil then
		self.TextBubbleTItle:SetText(Cfg.Title or "")
		self.TextBubbleTItle_1:SetText(Cfg.Synopsis or "")
	end
end

-- 右边
function OpsReturnContentpushPanelView:OnUpdateOpsReturn()
	self.ViewModel:UpdateTagName()
	-- self.ViewModel:UpdateContentList(self.StartIndex)
end



return OpsReturnContentpushPanelView