local AddonName, ns = ...

local LibBG = ns.LibBG
local L = ns.L

local AddTexture = ns.AddTexture

local pt = print
local After = C_Timer.After
local BG = TJ

local realmID = GetRealmID()
local player = UnitName("player")


local T = {}
local FB = "TOC"
local bossIndex = 4
--[[
"DEATHKNIGHT"
"PALADIN"
"WARRIOR"
"SHAMAN"
"HUNTER"
"DRUID"
"ROGUE"
"MAGE"
"WARLOCK"
"PRIEST"
 ]]

TJ.Load[FB .. bossIndex] = function()
    local mainFrame = TJ.frame[FB][bossIndex]

    -- 站位图
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 62, -185 } },
            { point = "TOPLEFT", xy = { 292, -70 } },
            { point = "TOPLEFT", xy = { 291, -277 } },
            { point = "TOPLEFT", xy = { 146, -285 } },
            { point = "TOPLEFT", xy = { 335, -177 } },
            { point = "TOPLEFT", xy = { 718, -16 } },
            { point = "TOPLEFT", xy = { 717, -52 } },
            { point = "TOPLEFT", xy = { 717, -87 } },

            [80] = {
                xy = { 722, -129 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["空气\n图腾"],
                isNPC_icon = "Interface\\Icons\\spell_nature_slowingtotem",
            },
            [98] = {
                xy = { 202, -182 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["大团"],
                isNPC_icon = "Interface\\Icons\\spell_magic_lesserinvisibilty",
            },
            [99] = {
                xy = { 180, -102 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["坦克"],
                isNPC_icon = "Interface\\Icons\\Spell_Deathknight_BloodPresence",
            },
            [100] = {
                xy = { 190, -142 },
                isNPC = 'b' .. bossIndex,
            },
        }

        --[[

]]

        local function AutoFuc()
            local tbl = TJ.SortRaidRosterInfo({ 'HUNTER' }, "dps", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
            local tbl = TJ.SortRaidRosterInfo({ 'PRIEST' }, "dps", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
            local tbl = TJ.SortRaidRosterInfo({ 'MAGE' }, "dps", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
        end
        local text = L["优先安排猎人/暗牧，其次是法师。"]

        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
            text)
        local width = 700
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 1394 * 784,
            nil, nil, nil, "v1.29.7", nil,
            nil, 1)
        local t = map:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 30, "OUTLINE")
        t:SetPoint("TOPLEFT", 20, -20)
        t:SetText(L["沙包站位"])
    end

    -- 坦克
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排任意坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["主坦克"],
            text, TJ.tankClass, nil, nil, nil, true)
        TJ.CreateEdit(FB, bossIndex, L["黑暗邪使"])
        TJ.CreateEdit(FB, bossIndex, L["光明邪使"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 精粹
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            65686,
                        },
                        colorNum = 1,
                    },
                    {
                        spellID = {
                            65684,
                        },
                        colorNum = 9,
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_holy_divineprovidence", L["光明/黑暗精粹"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    local spellTbl = {
        [66046] = L["白伤"],
        [66058] = L["黑伤"],
        [65875] = L["黑盾"],
        [65876] = L["白盾"],
    }
    mainFrame.SPELL_CAST_START = function(...)
        local argTbl = { ... }
        local spellID = argTbl[12]
        if spellID and spellTbl[spellID] then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = spellTbl[spellID],
            })
        end
    end
end
