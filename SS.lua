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

TJ.Init(function()
    if not TJ.IsWLK then return end
    local mainFrame = TJ.ssMainFrame
    local FB = "SS"
    local bossIndex = 1
    TJ[FB] = {}
    TJ.frame[FB] = {}
    TJ.frame[FB][bossIndex] = mainFrame
    TuanJian[FB] = TuanJian[FB] or {}
    TuanJian[FB][bossIndex] = TuanJian[FB][bossIndex] or {}

    -- 灵魂石
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local function updateFuc(index)
            for i, v in ipairs(TJ.raidRosterInfo) do
                if v.role ~= "MAINASSIST" and v.class == "WARLOCK" then
                    local name = "|c" .. select(4, GetClassColor(v.class)) .. TJ.GetIconAndName(v) .. "|r"
                    TJ.CreateEdit(FB, bossIndex, name, index)
                end
            end
        end
        local text = L["绑定坦克。"]
        local f = TJ.CreateTitle(FB, bossIndex, AutoFuc, "inv_misc_orb_04", L["灵魂石"],
            text, nil, updateFuc, nil, nil,
            nil, 3)
        f:ClearAllPoints()
        f:SetPoint("TOPLEFT", TJ.MainFrame, "TOPLEFT", 20, -50)
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
            TJ.ClearSS()
        end)
        bt:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(L["重置"], 1, 1, 1, true)
            GameTooltip:Show()
        end)
        bt:SetScript("OnLeave", GameTooltip_Hide)
    end

    function TJ.ClearSS()
        for _, v in ipairs(TJ.frame[FB][bossIndex].all) do
            for _, vv in ipairs(v.edits) do
                vv.edit:ClearAll()
            end
        end
    end
end)


