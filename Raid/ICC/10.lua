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
local FB = "ICC"
local bossIndex = 10
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
    -- 进内场
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 71941, 70873, },
                    },
                },
            }
        }
        local text = L["仅安排奶骑/奶萨。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, 135831, L["进内场"],
            text, TJ.healerClass, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["内场"])
        TJ.CreateEdit(FB, bossIndex, L["内场"])
        TJ.CreateEdit(FB, bossIndex, L["内场"])
        TJ.CreateEdit(FB, bossIndex, L["内场"])
        TJ.CreateEdit(FB, bossIndex, L["内场"])
        TJ.CreateEdit(FB, bossIndex, L["内场"])
    end
    -- 风筝脓疮僵尸
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "HUNTER" }, nil, true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = ns.sp["扰乱射击"],
                        colorNum = 1
                    },
                },
                destNPCID = { 37934, },
            }
        }
        local text = L["仅安排猎人。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_arcane_blink", L["风筝脓疮僵尸"],
            text, { "HUNTER" }, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["风筝僵尸"])
        TJ.CreateEdit(FB, bossIndex, L["风筝僵尸"])
        TJ.CreateEdit(FB, bossIndex, L["风筝僵尸"])
    end
    -- 灵魂石
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo({ "PRIEST", "DRUID", "SHAMAN" }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local function updateFuc(index)
            local count = 0
            for i, v in ipairs(TJ.raidRosterInfo) do
                if count >= 3 then break end
                if v.role ~= "MAINASSIST" and v.class == "WARLOCK" then
                    count = count + 1
                    local name = "|c" .. select(4, GetClassColor(v.class)) .. TJ.GetIconAndName(v) .. "|r"
                    TJ.CreateEdit(FB, bossIndex, name, index)
                end
            end
        end
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = ns.sp["灵魂石"],
                    },
                },
            }
        }
        local text = L["优先绑奶骑，然后绑其他治疗。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_shadow_soulgem", L["灵魂石"],
            text, nil, updateFuc, info)
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)
    -- 绿龙承伤
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                70702, 70759,
                            },
                            colorNum = 6,
                        },
                        {
                            spellID = {
                                70744,
                            },
                            colorNum = 1,
                        },
                    },
                    destNPCID = { 36789 },
                    notPeriodicDamage=true,
                }
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = ns.sp["狂乱"],
                        },
                    },
                    destNPCID = { 36789 },
                },
                title = { icon = 49016, name = L["狂乱"] },
            },
            isMany=true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_misc_head_dragon_green", L["绿龙承伤"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
end
