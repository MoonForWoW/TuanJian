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
local FB = "MCtitan"
local bossIndex = 6
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
--[[
/run TJ.Board_ENCOUNTER_START("MCtitan", 6)
/run TJ.Board_SPELL_CAST_SUCCESS(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,19695)
 ]]
TJ.Load[FB .. bossIndex] = function()
    local mainFrame = TJ.frame[FB][bossIndex]
    -- 战术板
    do
        local isload
        local init = function()
            isload = true
            local s1, s2, s3 = ns.s1, ns.s2, ns.s3
            local spellTbl = {
                {
                    title = L["1/7"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["2/8"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["3/9"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["4/10"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["5/11"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["6/12"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
            }
            local function AutoFuc()
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    if not done[1] then
                        TJ.SetBoardEditFormNum(v, 1, 1, s1)
                        TJ.SetBoardEditFormNum(v, 2, 1, s2)
                        done[1] = true
                        done[2] = true
                    elseif not done[3] then
                        TJ.SetBoardEditFormNum(v, 3, 1, s1)
                        TJ.SetBoardEditFormNum(v, 4, 1, s2)
                        done[3] = true
                        done[4] = true
                    end
                end
                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "tank", true)
                for i, v in ipairs(tbl) do
                    for i = 1, #spellTbl do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, 1, s1)
                            done[i] = true
                            break
                        end
                    end
                end
                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "dps", true)
                for i, v in ipairs(tbl) do
                    for i = 1, #spellTbl do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, 1, TuanJian.talentInfo[v.name] == 4 and s1 or s2)
                            done[i] = true
                            break
                        end
                    end
                end
                local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, "tank", true)
                for i, v in ipairs(tbl) do
                    for i = 1, #spellTbl do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, 1, s3)
                            done[i] = true
                            break
                        end
                    end
                end
            end

            local tbl = {
                {
                    name = L["地狱火减伤链"],
                    bossSpellID = 19695,
                    arrange = 2,
                    icon = "spell_fire_incinerate",
                    id = 1,
                    spell = spellTbl,
                    event = "SPELL_CAST_SUCCESS",
                    canUpdate = true,
                    autoNextSpell = true,
                    startIndex = 1,
                    bossTime = { 15, 24, },
                },
                AutoFuc = AutoFuc,
            }

            TJ.frame[FB][bossIndex].Board_test = function()
                TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
                TJ.Board_info[19695].updateFrame.t = 5
            end

            TJ.CreateBoard(FB, bossIndex, tbl)
        end
        tinsert(TJ.boardCallback, init)
        if TJ.boardInited and not isload then init() end
    end

    -- 团员火抗
    TJ.CreateResistanceFrame(FB, bossIndex, "spell_fire_sealoffire", L["团员火抗"], 2)

    -- 技能提醒
    if TJ.canUseTips then
        local name = "tips1" .. FB .. bossIndex

        local msg = L["你中了活化炸弹，请马上远离大团，否则将会灭团。"]

        mainFrame.SPELL_AURA_APPLIED = function(...)
            local tbl = { ... }
            local spellID = tbl[12]
            if spellID == 20475 and TuanJian.options[name] == 1 and TJ.IsLeader() and tbl[9] then
                SendChatMessage(msg, "WHISPER", nil, tbl[9])
            end
        end

        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local ontext = {
            L["自动密语提醒活化炸弹出人群"],
            L["当有人中了活化炸弹时，自动密语该团员出人群。"],
            L["需要你是团长或助理，该功能才生效。"],
            " ",
            L["密语内容如下："],
            msg,
        }
        local f = ns.O.CreateCheckButton(name, AddTexture(132863) .. L["自动密语提醒活化炸弹出人群"] .. L["（需要团长/助理）"],
            TJ.frame[FB][bossIndex], 40, -150, ontext)
        f:ClearAllPoints()
        f:SetPoint("BOTTOMLEFT", TJ.spChild.title, "TOPRIGHT", 0, 15)
        f:SetHitRectInsets(0, 0, 0, 0)
    end

    -- 坦克
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                if v.class == "DEATHKNIGHT" then
                    TJ.SetEditTextFormNum(v, title, 1)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["BOSS优先安排DKT。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass, nil, nil, nil, nil)
        TJ.CreateEdit(FB, bossIndex, L["BOSS坦"])
    end

    -- 驱散点燃法力
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, nil, true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "dps", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local info = {
            dispel = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            19659,
                        },
                        colorNum = 1,
                        frameLevel = 1,
                    },
                },
                sourceNpcType = { "Player" },
            }
        }
        local text = L["安排所有牧师、惩戒骑。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_fire_incinerate", L["驱散点燃法力"],
            text, { "PRIEST", "PALADIN" }, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["驱散魔法"])
        TJ.CreateEdit(FB, bossIndex, L["驱散魔法"])
        TJ.CreateEdit(FB, bossIndex, L["驱散魔法"])
        TJ.CreateEdit(FB, bossIndex, L["驱散魔法"])
        TJ.CreateEdit(FB, bossIndex, L["驱散魔法"])
        TJ.CreateEdit(FB, bossIndex, L["驱散魔法"])

        TJ.AddDispelInfo(19659, 1, FB, bossIndex)
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 活化炸弹
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            20475,
                        },
                        colorNum = 2
                    },
                },
                destNpcType = { "Player" },
            },
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            20476,
                        },
                        colorNum = 1
                    },
                },
                destNpcType = { "Player" },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_enchant_essenceastralsmall", L["活化炸弹"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 地狱火
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                19698,
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["受到%s伤害"]:format(L["地狱火"]) },
            },
        }
        tinsert(info, TJ.combatInfoMore)
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_incinerate", L["地狱火"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
end
