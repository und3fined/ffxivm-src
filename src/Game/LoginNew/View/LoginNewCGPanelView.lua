---
--- Author: richyczhou
--- DateTime: 2024-06-25 10:00
--- Description:
---

local CommonUtil = require("Utils/CommonUtil")
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local PathMgr = require("Path/PathMgr")
local SaveKey = require("Define/SaveKey")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")

local FLOG_INFO = _G.FLOG_INFO
local FLOG_WARNING = _G.FLOG_WARNING
local LSTR = _G.LSTR

local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local LoginStrID = LoginNewDefine.LoginStrID

---@class LoginNewCGPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field BtnScreen UButton
---@field CoverImage UFImage
---@field MovieImage UImage
---@field CGMoviePath string
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewCGPanelView = LuaClass(UIView, true)

function LoginNewCGPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.BtnScreen = nil
	--self.CoverImage = nil
	--self.MovieImage = nil
	--self.CGMoviePath = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewCGPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewCGPanelView:OnInit()
	FLOG_INFO("[LoginNewCGPanelView:OnInit]")
	self.MovieImage:SetVisibility(_G.UE.ESlateVisibility.Collapsed)
end

function LoginNewCGPanelView:OnDestroy()
	FLOG_INFO("[LoginNewCGPanelView:OnDestroy]")
end

function LoginNewCGPanelView:OnShow()
	FLOG_INFO("[LoginNewCGPanelView:OnShow]")
	self.bBackBtnShowing = false
	self.BtnBack:SetVisible(self.bBackBtnShowing)

	--if self:PlayCGVideo() then
	--	self.MovieImage:SetVisibility(_G.UE.ESlateVisibility.HitTestInvisible)
	--else
	--	self.MovieImage:SetVisibility(_G.UE.ESlateVisibility.Collapsed)
	--end
	self.MovieImage:SetVisibility(_G.UE.ESlateVisibility.Collapsed)

	--if _G.CgMgr:PlayCGVideo(_G.CgMgr:GetCGPath()) then
	--	_G.CgMgr:SetMovieImage(self.MovieImage)
	--end

	self.bIsMute = _G.UE.USaveMgr.GetInt(SaveKey.IsCGMute, 0, false) == 1

	_G.CgMgr:PlayCGVideo(self.MovieImage)
	_G.CgMgr:SetAutoClear(true)
end

function LoginNewCGPanelView:OnHide()
	FLOG_INFO("[LoginNewCGPanelView:OnHide]")
	--if self.MediaPlayerActor and CommonUtil.IsObjectValid(self.MediaPlayerActor) then
	--	self.MediaPlayerActor:ReleasePlayer()
	--	CommonUtil.DestroyActor(self.MediaPlayerActor)
	--end
	--self.MediaPlayerActor = nil

	_G.CgMgr:StopCGVideo()
	_G.EventMgr:SendEvent(_G.EventID.PlayLoginBGM)
end

function LoginNewCGPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBack.Button, self.OnClickBtnBack)
	UIUtil.AddOnClickedEvent(self, self.BtnScreen, self.OnClickBtnScreen)

	--- ********************* TEST ********************* ---
	--UIUtil.AddOnClickedEvent(self, self.BtnTest, self.OnClickBtnTest)
	--UIUtil.AddOnClickedEvent(self, self.BtnCloseTest, self.OnClickBtnCloseTest)
	--UIUtil.AddOnClickedEvent(self, self.BtnClose, self.OnClickBtnClose)
	--UIUtil.AddOnClickedEvent(self, self.BtnLauncherSource, self.OnClickBtnLauncherSource)
	--UIUtil.AddOnClickedEvent(self, self.BtnNormalSource, self.OnClickBtnNormalSource)
	--UIUtil.AddOnClickedEvent(self, self.BtnStart, self.OnClickBtnStart)
	--UIUtil.AddOnClickedEvent(self, self.BtnReset, self.OnClickBtnReset)
end

function LoginNewCGPanelView:OnRegisterGameEvent()

end

function LoginNewCGPanelView:OnRegisterBinder()

end

function LoginNewCGPanelView:OnClickBtnBack()
	local function Callback()
		self:Hide();
	end
	_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(LoginStrID.QuitPlayer), LSTR(LoginStrID.ConfirmQuitPlayer), Callback, nil, LSTR(LoginStrID.CancelBtnStr), LSTR(LoginStrID.ConfirmBtnStr))
end

function LoginNewCGPanelView:OnClickBtnScreen()
	self.bBackBtnShowing = not self.bBackBtnShowing
	self.BtnBack:SetVisible(self.bBackBtnShowing)
end

--function LoginNewCGPanelView:PlayCGVideo()
--	local ActorPath = "Blueprint'/Game/UI/BP/LoginNew/MediaPlayerActor_BP.MediaPlayerActor_BP_C'"
--	local ActorCls = _G.ObjectMgr:GetClass(ActorPath)
--	if not ActorCls then
--		FLOG_WARNING("[LoginNewCGPanelView:PlayCGVideo] AMediaPlayerActor GetClass failed...", ActorPath)
--		self.MediaPlayerActor = _G.CommonUtil.SpawnActor(_G.UE.AMediaPlayerActor.StaticClass())
--	else
--		self.MediaPlayerActor = _G.CommonUtil.SpawnActor(ActorCls)
--	end
--
--	if self.MediaPlayerActor and CommonUtil.IsObjectValid(self.MediaPlayerActor) then
--		self.MediaPlayerActor:SetMovieImage(self.MovieImage)
--
--		-- Android/iOS在Movies下，PC在Movies_Launcher下
--		local CGPath = PathMgr.ContentDirRelative() .. "Movies/LauncherMovie.mp4"
--		if not PathMgr.ExistFile(CGPath) then
--			CGPath = PathMgr.ContentDirRelative() .. "Movies_Launcher/LauncherMovie.mp4"
--		end
--		return self.MediaPlayerActor:PlayVideo(CGPath)
--	end
--
--	return false
--end

--- ********************* TEST ********************* ---
--[[
function LoginNewCGPanelView:OnTextIDInputChanged(Text, Len)
	--FLOG_INFO("[LoginNewMainBase:OnTextIDInputChanged] OpenID:%s", Text)
end

function LoginNewCGPanelView:OnClickBtnTest()
	FLOG_INFO("[LoginNewCGPanelView:OnClickBtnTest] ")
	self.PanelTest:SetVisibility(_G.UE.ESlateVisibility.SelfHitTestInvisible)
end

function LoginNewCGPanelView:OnClickBtnCloseTest()
	FLOG_INFO("[LoginNewCGPanelView:OnClickBtnCloseTest] ")
	self.PanelTest:SetVisibility(_G.UE.ESlateVisibility.Collapsed)
end

function LoginNewCGPanelView:OnClickBtnClose()
	FLOG_INFO("[LoginNewCGPanelView:OnClickBtnClose] ")
	self:ReleasePlayer()
end

function LoginNewCGPanelView:OnClickBtnLauncherSource()
	FLOG_INFO("[LoginNewCGPanelView:OnClickBtnLauncherSource] ")
	self:StopVideo()

	self:PlayVideoSource(self.TestLauncherSource)
end

function LoginNewCGPanelView:OnClickBtnNormalSource()
	FLOG_INFO("[LoginNewCGPanelView:OnClickBtnNormalSource] ")
	self:StopVideo()

	self:PlayVideoSource(self.TestNormalSource)
end

function LoginNewCGPanelView:OnClickBtnStart()
	self:StopVideo()

	local filePath = self.InputBox:GetText()
	FLOG_INFO("[LoginNewCGPanelView:OnClickBtnStart] %s", filePath)
	self:PlayVideo(filePath)
end

function LoginNewCGPanelView:OnClickBtnReset()
	FLOG_INFO("[LoginNewCGPanelView:OnClickBtnReset]")
	self:StopVideo()

	self:TryPlayCGVideo()
end
]]--
--- ********************* TEST ********************* ---

return LoginNewCGPanelView