local LuaClass = require("Core/LuaClass")
local HPBarLikeAnimProxy = LuaClass()
local UIUtil = require("Utils/UIUtil")

---@class HPBarLikeAnimProxy
function HPBarLikeAnimProxy:Ctor(Context, ProBar, AnimAdd, AnimSub, AnimObjAdd, AnimObjSub)
	self.Context = Context
	self.ProBar = ProBar
	self.AnimObjAdd = AnimObjAdd
	self.AnimObjSub = AnimObjSub
	self.AnimAdd = AnimAdd
	self.AnimSub = AnimSub
	self.IsAddAnimStop = true
	self.IsSubAnimStop = true
    self.IsInterruptLastAnim = false
end

local function Cross(n, a, b)
	n = math.max(a, n)
	n = math.min(b, n)
	return n
end

function HPBarLikeAnimProxy:Upd(Pct)
    if not Pct then return end
	Pct = Cross(Pct, 0, 1)
	-- if Pct == self.Pct then return end
	if not self.Pct then
		self.Pct = Pct
		return
	end
	local IsAdd = Pct >= self.Pct
	if IsAdd then
		self:UpdAdd(Pct)
	else
		self:UpdSub(Pct)
	end
	self.Pct = Pct
end

function HPBarLikeAnimProxy:UpdAdd(Pct)
	self:StopSubAnim()
    if self.AnimObjAdd then
	    self:OnUpdAdd(Pct)
    end
	self:PlayAddAnim()
end

function HPBarLikeAnimProxy:OnUpdAdd(Pct)
end

function HPBarLikeAnimProxy:UpdSub(Pct)
	self:StopAddAnim()
	if self.AnimObjSub then
	    self:OnUpdSub(Pct)
    end
	self:PlaySubAnim()
end

function HPBarLikeAnimProxy:OnUpdSub(Pct)

end


function HPBarLikeAnimProxy:PlayAddAnim()
    if not self.AnimAdd then return end
    if (not self.IsAddAnimStop) and (not self.IsInterruptLastAnim) then return end
	self:PlayAnim(self.AnimAdd)
end

function HPBarLikeAnimProxy:PlaySubAnim()
	if not self.AnimSub then return end
    if (not self.IsSubAnimStop) and (not self.IsInterruptLastAnim) then return end
	self:PlayAnim(self.AnimSub)
end

function HPBarLikeAnimProxy:PlayAnim(Anim)
    if not Anim then return end
	self.Context:PlayAnimation(Anim)
end




function HPBarLikeAnimProxy:StopAddAnim()
	self:StopAnim(self.AnimAdd)
end

function HPBarLikeAnimProxy:StopSubAnim()
	self:StopAnim(self.AnimSub)
end

function HPBarLikeAnimProxy:StopAnim(Anim)
	if not Anim then return end
	if not self.Context or not self.Context:IsValid() then
		return
	end
	self.Context:StopAnimation(Anim)
end




function HPBarLikeAnimProxy:Reset()
	self.Pct = nil
end

-- C++ 播放动画返回的句柄判断动画播放状态的接口没有导入到Lua，UMG脚本使用的是OnAnimationFinished回调，在每个动画播完会调用
function HPBarLikeAnimProxy:OnContextAnimStop(Anim)
	if Anim == self.AnimAdd then
		self.IsAddAnimStop = true
	elseif Anim == self.AnimSub then
		self.IsSubAnimStop = true
	end
end


local HPBarLikeAnimShapeProxy = LuaClass(HPBarLikeAnimProxy)

function HPBarLikeAnimShapeProxy:Ctor(Context, ProBar, AnimAdd, AnimSub, AnimObjAdd, AnimObjSub)
    self.IsInterruptLastAnim = true

    local Pos = UIUtil.CanvasSlotGetPosition(ProBar)
	local Size = UIUtil.CanvasSlotGetSize(ProBar)

	if AnimObjAdd then
		local AddObjSize = UIUtil.CanvasSlotGetSize(AnimObjAdd)
		local AddObjPos = UIUtil.CanvasSlotGetPosition(AnimObjAdd)
		self.AddObjSizeY = AddObjSize.y
		self.AddObjPosY = AddObjPos.y
	end

	if AnimObjSub then
		local SubObjSize = UIUtil.CanvasSlotGetSize(AnimObjSub)
		local SubObjPos = UIUtil.CanvasSlotGetPosition(AnimObjSub)
		self.SubObjSizeY = SubObjSize.y
		self.SubObjPosY = SubObjPos.y
	end

    self.ProBarSizeX = Size.x
	self.ProBarPosX = Pos.x
	self.ProBarPosY = Pos.y
end

function HPBarLikeAnimShapeProxy:OnUpdAdd(Pct)
    local AnimObj, LX, RX
	AnimObj = self.AnimObjAdd
	LX = self.ProBarPosX + self.Pct * self.ProBarSizeX
	RX = self.ProBarPosX + Pct * self.ProBarSizeX
	local SizeX = RX - LX
	UIUtil.CanvasSlotSetPosition(AnimObj, _G.UE.FVector2D(LX, self.AddObjPosY))
	UIUtil.CanvasSlotSetSize(AnimObj, _G.UE.FVector2D(SizeX, self.AddObjSizeY))
end

function HPBarLikeAnimShapeProxy:OnUpdSub(Pct)
    local AnimObj, LX, RX
	AnimObj = self.AnimObjSub
	RX = self.ProBarPosX + self.Pct * self.ProBarSizeX
	LX = self.ProBarPosX + Pct * self.ProBarSizeX
	local SizeX = RX - LX
	UIUtil.CanvasSlotSetPosition(AnimObj, _G.UE.FVector2D(LX, self.SubObjPosY))
	UIUtil.CanvasSlotSetSize(AnimObj, _G.UE.FVector2D(SizeX, self.SubObjSizeY))
end

local HPBarLikeAnimMatProxy = LuaClass(HPBarLikeAnimProxy)

function HPBarLikeAnimMatProxy:Ctor(Context, ProBar, AnimAdd, AnimSub, AnimObjAdd, AnimObjSub)
    self.AnimAddMat = AnimObjAdd:GetDynamicMaterial()
    self.AnimSubMat = AnimObjSub:GetDynamicMaterial()
end



function HPBarLikeAnimMatProxy:OnUpdAdd(Pct)
    if not self.AnimAddMat then return end
	UIUtil.SetIsVisible(self.AnimObjAdd, true)
	UIUtil.SetIsVisible(self.AnimObjSub, false)
	self.AnimAddMat:SetScalarParameterValue("ProgressStart", self.Pct)
	self.AnimAddMat:SetScalarParameterValue("ProgressEnd", Pct)
end

function HPBarLikeAnimMatProxy:OnUpdSub(Pct)
    if not self.AnimSubMat then return end
	UIUtil.SetIsVisible(self.AnimObjAdd, false)
	UIUtil.SetIsVisible(self.AnimObjSub, true)
	self.AnimSubMat:SetScalarParameterValue("ProgressStart", self.Pct)
	self.AnimSubMat:SetScalarParameterValue("ProgressEnd", Pct)
end

local HPBarLikeAnimExpProxy = LuaClass(HPBarLikeAnimProxy)

local function IsStretchedHorizontal(Anchors)
	return Anchors.Minimum.X ~= Anchors.Maximum.X
end

local function GetWidgetPosXAndSizeX(Widget)
	local Anchors = UIUtil.CanvasSlotGetAnchors(Widget)
	local Margin = UIUtil.CanvasSlotGetOffsets(Widget)
	local ScreenSize = UIUtil.GetScreenSize()

	local PosX = Anchors.Minimum.X * ScreenSize.X + Margin.Left
	local SizeX = 0
	if IsStretchedHorizontal(Anchors) then
		SizeX = (Anchors.Maximum.X - Anchors.Minimum.X) * ScreenSize.X - Margin.Left - Margin.Right
	else
		SizeX = Margin.Right
	end
	return PosX, SizeX
end

local function OnUpdInternal(AnimObj, LeftPos, RightPos)
	local Anchors = UIUtil.CanvasSlotGetAnchors(AnimObj)
	local Margin = UIUtil.CanvasSlotGetOffsets(AnimObj)
	local ScreenSize = UIUtil.GetScreenSize()

	Margin.Left = LeftPos - Anchors.Minimum.X * ScreenSize.X
	if IsStretchedHorizontal(Anchors) then
		Margin.Right = Anchors.Maximum.X * ScreenSize.X - RightPos
	else
		Margin.Right = RightPos - LeftPos
	end

	UIUtil.CanvasSlotSetOffsets(AnimObj, Margin)
end

function HPBarLikeAnimExpProxy:Ctor(Context, ProBar, AnimAdd, AnimSub, AnimObjAdd, AnimObjSub)
    self.IsInterruptLastAnim = true
end

local CommonUtil = require("Utils/CommonUtil")

function HPBarLikeAnimExpProxy:OnUpdAdd(Pct)
	local _ <close> = CommonUtil.MakeProfileTag("HPBarLikeAnimExpProxy:OnUpdAdd")
	local PosX, SizeX = GetWidgetPosXAndSizeX(self.ProBar)
	local Left = PosX + self.Pct * SizeX
	local Right = PosX + Pct * SizeX
	OnUpdInternal(self.AnimObjAdd, Left, Right)
end

function HPBarLikeAnimExpProxy:OnUpdSub(Pct)
	local _ <close> = CommonUtil.MakeProfileTag("HPBarLikeAnimExpProxy:OnUpdSub")
	local PosX, SizeX = GetWidgetPosXAndSizeX(self.ProBar)
	local Left = PosX + Pct * SizeX
	local Right = PosX + self.Pct * SizeX
	OnUpdInternal(self.AnimObjSub, Left, Right)
end


local HPBarLikeAnimProxyFactory = {}

function HPBarLikeAnimProxyFactory.CreateMatProxy(Context, ProBar, AnimAdd, AnimSub, AnimObjAdd, AnimObjSub)
    return HPBarLikeAnimMatProxy.New(Context, ProBar, AnimAdd, AnimSub, AnimObjAdd, AnimObjSub)
end

function HPBarLikeAnimProxyFactory.CreateShapeProxy(Context, ProBar, AnimAdd, AnimSub, AnimObjAdd, AnimObjSub)
    return HPBarLikeAnimShapeProxy.New(Context, ProBar, AnimAdd, AnimSub, AnimObjAdd, AnimObjSub)
end

function HPBarLikeAnimProxyFactory.CreateExpProxy(Context, ProBar, AnimAdd, AnimSub, AnimObjAdd, AnimObjSub)
    return HPBarLikeAnimExpProxy.New(Context, ProBar, AnimAdd, AnimSub, AnimObjAdd, AnimObjSub)
end

function HPBarLikeAnimProxyFactory.GetMatProxyClass()
    return HPBarLikeAnimMatProxy
end

return HPBarLikeAnimProxyFactory













