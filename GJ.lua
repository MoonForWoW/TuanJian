local AddonName, ns = ...

local LibBG = ns.LibBG
local L = ns.L

local Size = ns.Size
local RGB = ns.RGB
local AddTexture = ns.AddTexture
local SendSystemMessage = ns.SendSystemMessage

local pt = print
local After = C_Timer.After
local BG = TJ

local realmID = GetRealmID()
local player = UnitName("player")
local GetAddOnMetadata = GetAddOnMetadata or C_AddOns.GetAddOnMetadata
local IsAddOnLoaded = IsAddOnLoaded or C_AddOns.IsAddOnLoaded

local logo = "TuanJian: "

if not TJ.IsMOP then return end
TJ.Init(function()
    local mainFrame = TJ.gjMainFrame
    local FB = "GJ"
    local bossIndex = 1
    TJ[FB] = {}
    TJ.frame[FB] = {}
    TJ.frame[FB][bossIndex] = mainFrame
    TuanJian[FB] = TuanJian[FB] or {}
    TuanJian[FB][bossIndex] = TuanJian[FB][bossIndex] or {}

    -- 警戒
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "dps", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["优先安排输出战士，然后是防战。"]
        local f = TJ.CreateTitle(FB, 1, AutoFuc, "ability_warrior_vigilance", L["警戒"],
            text, { "WARRIOR" }, nil, nil, nil,
            nil)
        f:ClearAllPoints()
        f:SetPoint("TOPLEFT", TJ.MainFrame, "TOPLEFT", 20, -50)
        TJ.CreateEdit(FB, bossIndex, L["1警戒"])
        TJ.CreateEdit(FB, bossIndex, L["2警戒"])
        TJ.CreateEdit(FB, bossIndex, L["3警戒"])
        TJ.CreateEdit(FB, bossIndex, L["4警戒"])
        TJ.CreateEdit(FB, bossIndex, L["5警戒"])
        TJ.CreateEdit(FB, bossIndex, L["6警戒"])
    end

    -- 牺牲之手
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "dps", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["优先安排惩戒骑，然后是奶骑，最后防骑。"]
        local f = TJ.CreateTitle(FB, 1, AutoFuc, "spell_holy_sealofsacrifice", L["牺牲之手"],
            text, { "PALADIN" }, nil, nil, nil,
            nil)
        TJ.CreateEdit(FB, bossIndex, L["1小牺"])
        TJ.CreateEdit(FB, bossIndex, L["2小牺"])
        TJ.CreateEdit(FB, bossIndex, L["3小牺"])
        TJ.CreateEdit(FB, bossIndex, L["4小牺"])
        TJ.CreateEdit(FB, bossIndex, L["5小牺"])
        TJ.CreateEdit(FB, bossIndex, L["6小牺"])
    end

    -- 重置
    do
        local bt = CreateFrame("Button", nil, mainFrame)
        bt:SetSize(18, 18)
        bt:SetPoint("BOTTOMRIGHT", TJ.MainFrame, "BOTTOMRIGHT", -20, 23)
        bt:SetNormalTexture("interface/raidframe/readycheck-notready")
        bt:SetHighlightTexture("interface/raidframe/readycheck-notready")
        bt:RegisterForClicks("AnyUp")
        bt:SetScript("OnClick", function(self)
            TJ.PlaySound(1)
            TJ.ClearGJ()
        end)
        bt:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(L["重置"], 1, 1, 1, true)
            GameTooltip:Show()
        end)
        bt:SetScript("OnLeave", GameTooltip_Hide)
    end

    function TJ.ClearGJ()
        for _, v in ipairs(TJ.frame[FB][bossIndex].all) do
            for _, vv in ipairs(v.edits) do
                vv.edit:ClearAll()
            end
        end
    end
end)
