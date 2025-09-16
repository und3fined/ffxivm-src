local EmotionUtils = {}

--检测路径有效性
function EmotionUtils.IsValidPath(Path)
	local SoftPath = _G.UE.FSoftObjectPath()
	SoftPath:SetPath(Path)

	if _G.UE.UCommonUtil.IsObjectExist(SoftPath) then
		return true
	end
end

--获取表情动作的图片路径
function EmotionUtils.GetEmoActIconPath(IconPath)
	if string.find(IconPath, "Game/Assets/") then
		return IconPath
	end
	return string.format("Texture2D'/Game/Assets/Icon/064000/%s.%s'", IconPath, IconPath)
end

--获取动作详情的图片路径
function EmotionUtils.GetScenesIconPath(IconPath)
	return string.format("PaperSprite'/Game/UI/Atlas/EmoAct/Frames/%s.%s'", IconPath, IconPath)
end

return EmotionUtils