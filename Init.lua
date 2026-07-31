local AddonName, ns = ...

local L = ns.L
local After = C_Timer.After
local pt = print
local player = UnitName("player")
local realmID = GetRealmID()

local GetAddOnMetadata = GetAddOnMetadata or C_AddOns.GetAddOnMetadata

local LibBG = LibStub:GetLibrary("BiaoGe-LibUIDropDownMenu-4.0") -- 调用库菜单UI
ns.LibBG = LibBG

C_ChatInfo.RegisterAddonMessagePrefix("TuanJian")

TuanJianTooltip = CreateFrame("GameTooltip", "TuanJianTooltip", UIParent, "GameTooltipTemplate") -- 用来获取鼠标提示文本
TuanJianTooltip:SetClampedToScreen(false)
TuanJianTooltip2 = CreateFrame("GameTooltip", "TuanJianTooltip2", UIParent, "GameTooltipTemplate")
TuanJianTooltip2:SetClampedToScreen(false)

-- 游戏按键设置
BINDING_HEADER_TUANJIAN = "TuanJian"
BINDING_NAME_TUANJIAN = L["打开/关闭界面"]

TJ = {}

TJ.IsNewUI = true
local ver = select(4, GetBuildInfo())
if ver < 20000 then
    TJ.IsVanilla = true
end

if TJ.IsVanilla and (C_Engraving and C_Engraving.IsEngravingEnabled()) then
    TJ.IsVanilla_Sod = true
end

if TJ.IsVanilla and not (C_Engraving and C_Engraving.IsEngravingEnabled()) then
    TJ.IsVanilla_60 = true
end

if ver < 40000 then
    TJ.verLess3 = true
else
    TJ.verOver4 = true
end
if ver >= 20000 and ver < 30000 then
    TJ.IsTBC = true
end

if ver >= 30000 and ver < 40000 then
    TJ.IsWLK = true
    if ver >= 38000 then
        TJ.IsTitan = true
    else
        TJ.IsWLK_80 = true
    end
end

if ver >= 40000 and ver < 50000 then
    TJ.IsCTM = true
end

if ver >= 50000 then
    TJ.IsMOP = true
    -- if GetCurrentRegion() ~= 5 then
    --     TJ.IsMOP_TW = true
    -- else
    --     TJ.IsMOP_CN = true
    -- end
    -- TJ.IsMOP_TW = nil
    -- TJ.IsCTM = true
end

if ver >= 110000 then
    TJ.IsRetail = true
end

TJ.options = {}
TJ.iconTexCoord = { .07, .93, .07, .93 }
TJ.borderAlpha = .5
TJ.sendCD = .25
TJ.sendCD2 = .3
TJ.onEnterAlpha = 0.1
TJ.scrollStep = 80
TJ.FBtbl = {}
TJ.FBinfo = {}
TJ.tabFrame = {}
TJ.frame = {}
TJ.Load = {}
TJ.healerClass = { "PALADIN", "SHAMAN", "DRUID", "PRIEST", "MONK" }
TJ.tankClass = { "DEATHKNIGHT", "WARRIOR", "DRUID", "PALADIN", "MONK" }
TJ.dps1Class = { "DEATHKNIGHT", "PALADIN", "WARRIOR", "SHAMAN", "DRUID", "ROGUE", "MONK" }
TJ.dps2Class = { "HUNTER", "SHAMAN", "DRUID", "MAGE", "WARLOCK", "PRIEST" }
TJ.TJClass = { "DEATHKNIGHT", "PALADIN", "WARRIOR", "SHAMAN", "MONK", "DRUID", "ROGUE", "PRIEST", }
TJ.ver = "v" .. GetAddOnMetadata(AddonName, "Version")
TJ.dispelInfo = {}
TJ.dispelFB = {}
TJ.teamList = {}
TJ.DBMCallback = {}
TJ.SSpowerSpell = TJ.IsTitan and 48090

for i = 1, 8 do
    tinsert(TJ.teamList, i .. L["队"])
end

function TJ.Init(func)
    local f = CreateFrame("Frame")
    f:RegisterEvent("ADDON_LOADED")
    f:SetScript("OnEvent", function(self, event, addonName)
        if addonName ~= AddonName then
            return
        end
        self:UnregisterEvent("ADDON_LOADED")
        securecall(func)
    end)
end

function TJ.Init2(func)
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:SetScript("OnEvent", function(self, event, isLogin, isReload)
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        securecall(func)
    end)
end

function TJ.Init3(func)
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_LOGIN")
    f:SetScript("OnEvent", function(self, event)
        self:UnregisterEvent("PLAYER_LOGIN")
        securecall(func)
    end)
end

local events = {}
local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(_, event, ...)
    for _, func in ipairs(events[event]) do
        if event == "COMBAT_LOG_EVENT_UNFILTERED" then
            securecall(func, f, event, CombatLogGetCurrentEventInfo())
        else
            securecall(func, f, event, ...)
        end
    end
end)
function TJ.RegisterEvent(event, func)
    if not events[event] then
        events[event] = {}
        f:RegisterEvent(event)
    end
    tinsert(events[event], func)
end
