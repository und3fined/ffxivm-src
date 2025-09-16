--
-- Author: Star
-- Date: 2024-03-11 11:23
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")


---@class RedDotItemVM : UIViewModel
---@field RedDotName string @Path 读取蓝图配置，View设置
---@field Num number @红点数量
---@field IsVisible number @红点是否可见
---@field RedDotNode RedDotNode @红点节点
---@field IsAutoUpdateState boolean @Num 数量变化的时候是否自动隐藏删除/显示添加红点 默认开
local RedDotItemVM = LuaClass(UIViewModel)

---Ctor
function RedDotItemVM:Ctor()
	self:Reset()
end

function RedDotItemVM:Reset()
	self.RedDotName = nil
	self.Num = 0
	self.IsVisible = false
	self.IsAutoUpdateState = true
	self.RedDotStyle = nil
	self.Text = nil
	self.IsShowMax = nil
	self.RedDotNode = nil
end

function RedDotItemVM:FindNode(RedDotName)
	---红点名变更时清理之前在Mgr的ItemVM缓存
	local IsChange = self.RedDotName ~= RedDotName
	if self.RedDotName and  IsChange then
		RedDotMgr:RemoveRedDotItemVM(self)
	end
	self.RedDotName = RedDotName
	self.RedDotNode = RedDotMgr:FindRedDotNodeByName(RedDotName)
	-- VM不判断加入
	-- if IsChange then
	-- 	RedDotMgr:AddRedDotItemVM(self)
	-- end
	self:UpdateShowData()
end

function RedDotItemVM:UpdateShowData()
	if not self.RedDotNode then
		self.IsVisible = false
	else
		---叶子节点值就是显示数量，父节点节点值是子节点数，额外用TotalNum表示子节点节点值总和，
		if self.RedDotNode.IsLeafNode then
			self:UpdateNum(self.RedDotNode.NodeValue)
		else
			local ShowNum = self.RedDotNode.TotalNum or 0
			self:UpdateNum(ShowNum)
		end
	end
end

--- 更新数据，VM会缓存对应节点，相同节点更新不重新获取
function RedDotItemVM:UpdateNodeDataByName(RedDotName)
	if self.RedDotNode and self.RedDotNode.RedDotName == RedDotName then
		if self.RedDotNode.NodeValue == nil then
			self:FindNode(RedDotName)
		else
			self:UpdateShowData()
		end
	else
		self:FindNode(RedDotName)
	end
end

--- 更新数据，VM会缓存对应节点，相同节点更新不重新获取
function RedDotItemVM:UpdateNodeDataByID(ID)
	local RedDotName = RedDotMgr:GetRedDotNameByID(ID)
	self:UpdateNodeDataByName(RedDotName)
end

---UpdateNum
---@param Num number
function RedDotItemVM:UpdateNum(Num)
	self.Num = Num
	if self.Num > 99 then
		self.Num = 99
		if self.RedDotStyle == RedDotDefine.RedDotStyle.NumStyle then
			self.IsShowMax = true
		else
			self.IsShowMax = false
		end
	else
		self.IsShowMax = false
	end
	if self.IsAutoUpdateState then
		self:SetIsVisible(Num and Num > 0)
	end
end

---只有叶子节点和非红点树管理的节点可以修改
function RedDotItemVM:SetNum(Num)
	if nil == self.RedDotName then
		self:UpdateNum(Num)
	else
		if nil == self.RedDotNode then
			self.RedDotNode = RedDotMgr:FindRedDotNodeByName(self.RedDotName)
		end
		--- 如果配置了红点名，还手动修改数量>0，默认是子节点进行添加
		if self.RedDotNode == nil then
			if Num > 0 and self.IsAutoUpdateState then
				self:ShowRedDot(Num)
			end
		end
		if self.RedDotNode and self.RedDotNode.IsLeafNode  then
			---非叶子节点不允许修改,叶子节点的节点值红点树不关心
			self.RedDotNode.NodeValue = Num
			if self.IsAutoUpdateState and Num < 0 then
				self:HideRedDot()
			end
		end
		self:UpdateNum(Num)
	end
end

function RedDotItemVM:SetIsVisible(InIsVisible)
	self.IsVisible = InIsVisible
end

function RedDotItemVM:GetIsVisible()
	return self.IsVisible
end

function RedDotItemVM:SetIsAutoUpdateState(InIsAutoUpdateState)
	self.IsAutoUpdateState = InIsAutoUpdateState
end

function RedDotItemVM:SetRedDotName(InRedDotName)
	if self.RedDotName ~= InRedDotName then
		self:FindNode(InRedDotName)
	end
end

function RedDotItemVM:GetRedDotName()
	return self.RedDotName
end

function RedDotItemVM:HideRedDot()
    RedDotMgr:DelRedDotByName(self.RedDotName)
end

function RedDotItemVM:ShowRedDot(NodeValue)
	RedDotMgr:AddRedDotByName(self.RedDotName, NodeValue)
end

function RedDotItemVM:SetRedDotStyle(RedDotStyle)
	self.RedDotStyle = RedDotStyle
end

function RedDotItemVM:GetRedDotStyle()
	return self.RedDotStyle
end

function RedDotItemVM:SetRedDotText(InText)
	self.Text = InText
end

return RedDotItemVM