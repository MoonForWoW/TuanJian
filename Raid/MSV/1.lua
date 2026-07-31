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
local FB = "MSV"
local bossIndex = 1
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
    local instanceID = TJ.FBinfo[FB].ID
    TJ.autoRaidTargetInfo[instanceID] = TJ.autoRaidTargetInfo[instanceID] or {}
    TJ.autoRaidTargetInfo[instanceID][60047] = { [8] = true } -- 紫
    TJ.autoRaidTargetInfo[instanceID][59915] = { [7] = true } -- 红
    TJ.autoRaidTargetInfo[instanceID][60043] = { [6] = true } -- 青
    TJ.autoRaidTargetInfo[instanceID][60051] = { [5] = true } -- 蓝


    --[[
/run TJ.Board_ENCOUNTER_START("MSV", 1)
/run TJ.Board_SPELL_CAST_SUCCESS(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,115843)
 ]]

    -- 每点能量0.62秒增加一次

    -- 战术板
    do
        local isload
        local init = function()
            isload = true
            local s1, s2, s3, s4, s5, s6, s7, s8 = ns.s1, ns.s2, ns.s3, ns.s4, ns.s5, ns.s6, ns.s7, ns.s8
            local spellTbl = {
                {
                    title = L["第1"],
                    class = TJ.TJClass,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["第2"],
                    class = TJ.TJClass,
                    spell = TJ.Board_TJ1
                },
            }
            local function AutoFuc()
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, nil, true)
                for i, v in ipairs(tbl) do
                    if not done[1] then
                        TJ.SetBoardEditFormNum(v, 1, nil, s2)
                        TJ.SetBoardEditFormNum(v, 1, nil, s3)
                        done[1] = true
                    elseif not done[2] then
                        TJ.SetBoardEditFormNum(v, 2, nil, s2)
                        TJ.SetBoardEditFormNum(v, 2, nil, s3)
                        done[2] = true
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
                for i, v in ipairs(tbl) do
                    if TuanJian.talentInfo[v.name] == 1 then
                        if not done[1] then
                            TJ.SetBoardEditFormNum(v, 1, nil, s5)
                            done[1] = true
                        elseif not done[2] then
                            TJ.SetBoardEditFormNum(v, 2, nil, s5)
                            done[2] = true
                        end
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "ROGUE" }, nil, true)
                for i, v in ipairs(tbl) do
                    if not done[1] then
                        TJ.SetBoardEditFormNum(v, 1, nil, s6)
                        done[1] = true
                    elseif not done[2] then
                        TJ.SetBoardEditFormNum(v, 2, nil, s6)
                        done[2] = true
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    if not done[1] then
                        TJ.SetBoardEditFormNum(v, 1, nil, s7)
                        done[1] = true
                    elseif not done[2] then
                        TJ.SetBoardEditFormNum(v, 2, nil, s7)
                        done[2] = true
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, nil, true)
                for i, v in ipairs(tbl) do
                    if not done[1] then
                        TJ.SetBoardEditFormNum(v, 1, nil, s1)
                        done[1] = true
                    elseif not done[2] then
                        TJ.SetBoardEditFormNum(v, 2, nil, s1)
                        done[2] = true
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "DEATHKNIGHT" }, nil, true)
                for i, v in ipairs(tbl) do
                    if not done[1] then
                        TJ.SetBoardEditFormNum(v, 1, nil, s4)
                        done[1] = true
                    elseif not done[2] then
                        TJ.SetBoardEditFormNum(v, 2, nil, s4)
                        done[2] = true
                    end
                end
            end

            local tbl = {
                {
                    name = L["过载减伤链（Rush打法）"],
                    bossSpellID = 115843,
                    arrange = 7,
                    icon = "inv_jewelcrafting_gem_32",
                    id = 1,
                    spell = spellTbl,
                    sound = "",
                    event = "SPELL_CAST_SUCCESS",
                    canUpdate = nil,
                    autoNextSpell = nil,
                    startIndex = 1,
                    maxIndex = 2,
                    bossTime = { 11, 11 },
                },
                AutoFuc = AutoFuc,
            }
            TJ.CreateBoard(FB, bossIndex, tbl)

            local bossSpellID = 115843
            local f = CreateFrame("Frame")
            f:SetScript("OnEvent", function(self, event, unit, ...)
                if unit:match("boss") then
                    if UnitPower(unit) >= 80 then
                        self:UnregisterEvent("UNIT_POWER_FREQUENT")
                        self.info[bossSpellID].canUpdate = true
                        self.info[bossSpellID].updateFrame.t = 0
                    end
                end
            end)

            TJ.frame[FB][bossIndex].Board_ENCOUNTER_START = function(info)
                f:Show()
                f.info = info
                f.count = 0
                After(3, function()
                    if f:IsVisible() then
                        f:RegisterEvent("UNIT_POWER_FREQUENT")
                    end
                end)
            end
            TJ.frame[FB][bossIndex].Board_ENCOUNTER_END = function(info)
                f:Hide()
                f:UnregisterEvent("UNIT_POWER_FREQUENT")
            end

            local bossSpellIDs = { 115842, 115840, 115843, 115844, }
            TJ.frame[FB][bossIndex].Board_SPELL_CAST_SUCCESS = function(info, ...)
                local tbl = { ... }
                local spellID = tbl[12]
                if TJ.ValueInTable(bossSpellIDs, spellID) and not TJ.SetCD(f, 12) then
                    f.count = f.count + 1
                    TJ.Board_HideNextSpell(bossSpellID)
                    if f.count < 2 then -- 第二次过载后，停止战术板
                        After(10, function()
                            if f:IsVisible() then
                                f:RegisterEvent("UNIT_POWER_FREQUENT")
                            end
                        end)
                    end
                end
            end

            TJ.frame[FB][bossIndex].Board_test = function()
                TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
                f.info[bossSpellID].canUpdate = true
                f.info[bossSpellID].updateFrame.t = 0
            end
        end
        tinsert(TJ.boardCallback, init)
        if TJ.boardInited and not isload then init() end
    end

    -- 坦克
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            local done = {}
            for i, v in ipairs(tbl) do
                if not done[1] then
                    TJ.SetEditTextFormNum(v, title, 1)
                    TJ.SetEditTextFormNum(v, title, 2)
                    done[1] = true
                    done[2] = true
                elseif not done[3] then
                    TJ.SetEditTextFormNum(v, title, 3)
                    TJ.SetEditTextFormNum(v, title, 4)
                    done[3] = true
                    done[4] = true
                end
            end
        end
        local text = L["安排1坦克负责蓝+青，2坦克负责红+紫。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass, nil, nil, nil,
            true, 2)
        TJ.CreateEdit(FB, bossIndex, L["蓝BOSS"])
        TJ.CreateEdit(FB, bossIndex, L["青BOSS"])
        TJ.CreateEdit(FB, bossIndex, L["红BOSS"])
        TJ.CreateEdit(FB, bossIndex, L["紫BOSS"])
    end
    -- 搬砖
    do
        local function AutoFuc(title)
            TJ.SetEditTextFormNum(title.list[1], title, 1)
            TJ.SetEditTextFormNum(title.list[1], title, 2)
            TJ.SetEditTextFormNum(title.list[1], title, 5)
            TJ.SetEditTextFormNum(title.list[2], title, 3)
            TJ.SetEditTextFormNum(title.list[2], title, 4)
        end
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 116304, 116322, 116301, 116199, },
                    },
                },
                destNpcType = { "Player" },
                showCount = function(tbl)
                    local num = 0
                    for _, v in ipairs(tbl) do
                        if not v.stackCount then
                            num = num + 7
                        end
                    end
                    return num
                end
            },
            showRaidMember = L["没有搬砖"],
            notShowDead = true,
            canSend = "count",
            raidMemberFiterFuc = function(v)
                return not TJ.Istank(v)
            end,
        }
        local text = L["安排1、2、5队左边搬砖，3、4队右边搬砖"]
        local list = {
            L["左边"],
            L["右边"],
        }
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "inv_misc_stonetablet_03", L["搬砖"],
            text, TJ.tankClass, nil, info, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["1队"], nil, list)
        TJ.CreateEdit(FB, bossIndex, L["2队"], nil, list)
        TJ.CreateEdit(FB, bossIndex, L["3队"], nil, list)
        TJ.CreateEdit(FB, bossIndex, L["4队"], nil, list)
        TJ.CreateEdit(FB, bossIndex, L["5队"], nil, list)
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)
    -- 过载
    do
        local info = {
            {
                beDamage2 = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                115842, 115840, 115843, 115844,
                            },
                        },
                    },
                    destNpcType = { "Player" },
                },
            },
        }
        tinsert(info, TJ.combatInfoMore)
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_jewelcrafting_gem_32", L["过载"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 红玉锁链
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 130395, },
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_belt_44b", L["红玉锁链"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 蓝晶冲击
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 116281, },
                    },
                },
                destNpcType = { "Player" },
                showCount = true,
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 429386, L["蓝晶冲击"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    TJ.frame[FB][bossIndex].BOSS_SAY = function(msg)
        if msg:match("能源关闭") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = L["地砖重置"],
            })
            return
        end
    end
end
