local AddonName, ns = ...

local GetAddOnMetadata = GetAddOnMetadata or C_AddOns.GetAddOnMetadata
ns.ver = "v" .. GetAddOnMetadata(AddonName, "Version")

local L = setmetatable({}, {
    __index = function(table, key)
        return tostring(key)
    end
})
ns.L = L

local c1 = "|cff" .. "ffff66"
ns.c1 = c1

do --简体说明书
    ns.instructionsText = {
        "|cff00BFFF< 说明书 >（本插件支持MOP/CTM/WLK/时光服）",
        " ",
        "|cffFFFFFF-作者：|r苍穹之霜",
        "|cffFFFFFF-打开命令：|r/TuanJian或/TJ，或游戏设置里绑定按键。小地图图标： " .. "|TInterface\\AddOns\\TuanJian\\Media\\icon\\icon.tga:0|t",
        "|cffFFFFFF-快捷操作：|r右键输入框可以清除内容",
        -- " ",
    }
    ns.updateText_now = {
        -- "|cff00FF00" .. "",
        -- [[]],
        -- [[]],
        -- " ",
    }
    ns.updateText_before = {
    }
end

local l = GetLocale()
if (l == "zhTW" or l == "enUS") then return end

local L = {}

do
end
