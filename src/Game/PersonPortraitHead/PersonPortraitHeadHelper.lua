



local Helper = {}
local HeadPortraitCfg = require("TableCfg/HeadPortraitCfg")
local MajorUtil = require("Utils/MajorUtil")
local PersonPortraitHeadDefine = require("Game/PersonPortraitHead/PersonPortraitHeadDefine")
local UIUtil = require("Utils/UIUtil")
local HeadFrameCfg = require("TableCfg/HeadFrameCfg")
local RaceCfg = require("TableCfg/RaceCfg")

function Helper.SetMajorFrame(Widget)
    local MajorVM = MajorUtil.GetMajorRoleVM()
    local FrameID = MajorVM.HeadFrameID or 1
    Helper.SetFrame(Widget, FrameID)
end

function Helper.SetFrame(Widget, FrameID)
    local Cfg = HeadFrameCfg:FindCfgByKey(FrameID or 1)

    if Cfg then
        UIUtil.ImageSetBrushFromAssetPath(Widget, Cfg.FrameIcon)
    end
end

function Helper.SetMajorHead(Widget)
    local MajorVM = MajorUtil.GetMajorRoleVM()
    
    Helper.SetHeadByRoleVM(Widget, MajorVM)
end

function Helper.SetHeadByRoleVM(Widget, RoleVM)
    if not RoleVM then
        return
    end

    Helper.SetHeadByHeadInfo(Widget, RoleVM.HeadInfo)
end

function Helper.SetHeadByHeadInfo(Widget, HeadInfo)

    if not HeadInfo then
        return
		_G.FLOG_WARNING('[PersonHead][PersonPortraitHeadHelper][SetHeadByHeadInfo] Info = ' .. table.tostring(HeadInfo))
    end
    local Race
    local Type, Idx, Url
 
    if (not HeadInfo.HeadType) or (not HeadInfo.HeadIdx) or (not HeadInfo.Race) or (not Widget) then
		_G.FLOG_WARNING('[PersonHead][PersonPortraitHeadHelper][SetHeadByHeadInfo] Info = ' .. table.tostring(HeadInfo))
		return
	end
    
    HeadInfo = HeadInfo or {}
    Type = HeadInfo.HeadType or PersonPortraitHeadDefine.HeadType.Default
    Idx = HeadInfo.HeadIdx or 1
    Url = HeadInfo.HeadUrl or ""
    Race = HeadInfo.Race or 1

    Helper.SetHead(Widget, Type, Idx, Url, Race)
end

function Helper.SetHead(Widget, Type, Idx, Url, RaceID)
    -- _G.FLOG_INFO(string.format('[PersonHead][PersonPortraitHeadHelper][SetHead] Type = %s, Idx = %s, Url = %s, RaceID = %s', 
    --     tostring(Type),
    --     tostring(Idx),
    --     tostring(Url),
    --     tostring(RaceID)
    -- ))

    if Type == PersonPortraitHeadDefine.HeadType.Default then
        local Icon = HeadPortraitCfg:GetHeadIconByRaceID(RaceID, Idx)
        -- UIUtil.ImageSetBrushFromAssetPath(Widget, Icon)
        UIUtil.ImageSetMaterialTextureFromAssetPathSync(Widget, Icon, 'Texture')
    elseif Type == PersonPortraitHeadDefine.HeadType.Custom then
        Helper.SetHeadByUrl(Widget, Url)
    end
end

local UuidIdx = 0
function Helper.GenHeadUuid()
    UuidIdx = UuidIdx + 1
    local Time = os.clock()

    return string.format('%s%s', tostring(Time),tostring(UuidIdx))
end

---@param Key 调试Key
function Helper.SetHeadByUrl(Widget, Url, Key)
    -- _G.FLOG_INFO(string.format('[PersonHead][PersonPortraitHeadHelper][SetHeadByUrl] Widget = %s, Url = %s, Key = %s', tostring(Widget), tostring(Url), tostring(Key)))

    if (not Widget) or string.isnilorempty(Url) then
        return
    end

    UIUtil.SetIsVisible(Widget, false)

    local ImageDownloader = _G.UE.UImageDownloader.MakeDownloader("HeadImage" .. tostring(Key), true, 200)
    ImageDownloader.OnSuccess:Add(ImageDownloader,
		function(_, texture)
			if texture then
				-- _G.FLOG_INFO('[PersonHead][PersonPortraitHeadHelper][SetHeadByUrl] Download image success Key = ' .. tostring(Key))
				-- UIUtil.ImageSetBrushResourceObject(Widget, texture)
                UIUtil.SetIsVisible(Widget, true)
                UIUtil.ImageSetMaterialTextureParameterValue(Widget, 'Texture', texture)
			end
		end
    )

    ImageDownloader.OnFail:Add(ImageDownloader,
		function()
            UIUtil.SetIsVisible(Widget, true)
			_G.FLOG_ERROR('[PersonHead][PersonPortraitHeadHelper][SetHeadByUrl] Download image failed Key = ' .. tostring(Key))
		end
	)
	
    ImageDownloader:Start(Url, "", false)
end

function Helper.GetHeadRace(Race, Gender, Tribe)

    local Cfg = RaceCfg:FindCfgByRaceIDGenderAndTribe(Race, Gender, Tribe)
    if Cfg then
        return Cfg.ID
    else
        return 1
    end
end

return Helper