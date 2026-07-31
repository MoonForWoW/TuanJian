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
local FB = "SSCtitan"
local bossIndex = 5
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
    -- 坦克
    do
        local function AutoFuc(title)
            local dk = TJ.SortRaidRosterInfo({ "DEATHKNIGHT" }, "tank", true)
            for i, v in ipairs(dk) do
                TJ.SetEditTextFormNum(v, title, 1)
                tremove(dk, i)
                break
            end
            local fq = TJ.SortRaidRosterInfo({ "PALADIN" }, "tank", true)
            for i, v in ipairs(fq) do
                TJ.SetEditTextFormNum(v, title, 2)
                tremove(fq, i)
                break
            end
            local tbl = TJ.SortRaidRosterInfo({ "WARRIOR", "DRUID" }, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            for i, v in ipairs(dk) do
                TJ.SetEditText(v, title)
            end
            for i, v in ipairs(fq) do
                TJ.SetEditText(v, title)
            end
        end
        local text = TJ.IsTBC and L["小怪优先安排防骑。"] or L["BOSS优先安排DKT，小怪优先安排防骑。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass, nil, nil, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["BOSS"])
        TJ.CreateEdit(FB, bossIndex, L["上面小怪"])
        TJ.CreateEdit(FB, bossIndex, L["下面小怪"])
    end
    -- 治疗水墓
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
                break
            end
            local tbl = TJ.SortRaidRosterInfo({ "PRIEST", "SHAMAN", "DRUID" }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排一个奶骑和一个其他治疗。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Holy_HolyBolt", L["治疗水墓"],
            text, TJ.healerClass, nil, nil, nil,
            nil)
        TJ.CreateEdit(FB, bossIndex, L["治疗水墓"])
        TJ.CreateEdit(FB, bossIndex, L["治疗水墓"])
    end
    -- 小怪误导/嫁祸
    do
        local function AutoFuc(title)
            local tbl = CopyTable(TJ.SortRaidRosterInfo(title.classTbl, nil, true))
            for i, v in ipairs(tbl) do
                if v.class == "HUNTER" then
                    tbl[i].index = 1
                elseif not TJ.IsTBC and v.class == "ROGUE" then
                    tbl[i].index = 2
                end
            end
            sort(tbl, function(a, b)
                if a.index and b.index then
                    return a.index < b.index
                end
                return false
            end)
            local done = {}
            for _, v in ipairs(tbl) do
                for _, i in ipairs({ 1, 4, 2, 5, 3, 6 }) do
                    if not done[i] then
                        TJ.SetEditTextFormNum(v, title, i)
                        done[i] = true
                        break
                    end
                end
            end
        end
        local text = L["安排猎人。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "ability_hunter_misdirection", L["小怪误导"],
            text, { "HUNTER", "ROGUE" }, nil, nil, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["12点小怪"])
        TJ.CreateEdit(FB, bossIndex, L["12点小怪"])
        TJ.CreateEdit(FB, bossIndex, L["12点小怪"])
        TJ.CreateEdit(FB, bossIndex, L["6点小怪"])
        TJ.CreateEdit(FB, bossIndex, L["6点小怪"])
        TJ.CreateEdit(FB, bossIndex, L["6点小怪"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 海潮之波
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            37730
                        },
                    },
                },
                destNpcType = { "Player" },
            },
            title = { name = L["受到%s伤害"]:format(L["海潮之波"]) },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_frost_chillingblast", L["海潮之波"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 水之墓穴
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            37850, 38024, 38023, 38025, 38049
                        },
                        colorNum = 1,
                    }
                },
                destNpcType = { "Player" },
            },
            title = L["点名"],
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_demonbreath", L["水之墓穴"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 水泡
    do
        local info = {
            -- aura = {
            --     type = "d",
            --     spell = {
            --         {
            --             spellID = {
            --                 37871
            --             },
            --             colorNum = 1,
            --         }
            --     },
            --     destNpcType = { "Player" },
            -- },
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            37871
                        },
                    },
                },
                destNpcType = { "Player" },
            },
            title = { name = L["受到%s伤害"]:format(L["水泡"]) },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_frost_glacier", L["水泡"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 地震
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                37764,
                            },
                            colorNum = 2,
                        },
                    },
                },
                title = { name = L["Boss施放%s"]:format(L["地震"]) },
            },
        }
        tinsert(info, TJ.combatInfoMore)
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_earthquake", L["地震"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.SPELL_SUMMON = function(...)
        local tbl = { ... }
        local spell = tbl[12]
        if spell == 37854 and not next(TJ.GetNewCombatLog().otherTime) then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
        end
    end
end
