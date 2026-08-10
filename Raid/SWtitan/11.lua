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
local FB = "ZAMtitan"
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

    -- 技能提醒
    if TJ.canUseTips then
        local name = "tips1" .. FB .. bossIndex

        local msg = L["点名>>%s<<，注意%s"]

        mainFrame.SPELL_AURA_APPLIED = function(...)
            local tbl = { ... }
            local spellID = tbl[12]
            if spellID == 43501 and TuanJian.options[name] == 1 and TJ.IsLeader() and tbl[9] then
                local className, class = UnitClass(tbl[9])
                if class == 'PALADIN' then
                    SendChatMessage(msg:format(className, L['奉献']), "RAID_WARNING")
                    SendChatMessage(msg:format(className, L['奉献']), "RAID_WARNING")
                elseif class == 'WARRIOR' then
                    SendChatMessage(msg:format(className, L['旋风斩']), "RAID_WARNING")
                    SendChatMessage(msg:format(className, L['旋风斩']), "RAID_WARNING")
                elseif class == 'DEATHKNIGHT' then
                    SendChatMessage(msg:format(className, L['驱散团员的鲜血印记']), "RAID_WARNING")
                    SendChatMessage(msg:format(className, L['驱散团员的鲜血印记']), "RAID_WARNING")
                end
            end
        end

        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local ontext = {
            L["灵魂虹吸点名团队提醒"],
            L["当点名圣骑士/战士/死亡骑士时，在RW频道自动发送提醒。"],
            L["需要你是团长或助理，该功能才生效。"],
        }
        local f = ns.O.CreateCheckButton(name, AddTexture(136213) .. L["灵魂虹吸点名团队提醒"] .. L["（需要团长/助理）"],
            mainFrame, 40, -150, ontext)
        f:ClearAllPoints()
        f:SetPoint("BOTTOMLEFT", TJ.spChild.title, "TOPRIGHT", 0, 15)
        f:SetHitRectInsets(0, 0, 0, 0)
        --[[
/run TJ.frame["ZAMtitan"][5].SPELL_AURA_APPLIED(nil,nil,nil,nil,nil,nil,nil,nil,"苍穹的小骑士",nil,nil,43501)
 ]]
    end

    -- 减伤链
    local bossSpellID = 43383
    TJ.AddBoard(mainFrame, function()
        local s1, s2, s3 = ns.s1, ns.s2, ns.s3
        local spellTbl = {
            {
                title = L["1/4"],
                class = nil,
                spell = TJ.Board_TJ1
            },
            {
                title = L["2/5"],
                class = nil,
                spell = TJ.Board_TJ1
            },
            {
                title = L["3/6"],
                class = nil,
                spell = TJ.Board_TJ1
            },
        }
        local function AutoFuc()
            local done = {}
            local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
            for _, v in pairs(CopyTable(TJ.SortRaidRosterInfo({ "PALADIN", }, "tank", true))) do
                tinsert(tbl, v)
            end
            for i, v in ipairs(CopyTable(TJ.SortRaidRosterInfo({ "PALADIN" }, "dps", true))) do
                if TuanJian.talentInfo[v.name] == 4 then
                    tinsert(tbl, v)
                end
            end
            for i, v in ipairs(tbl) do
                for _, i in ipairs({ 1, 2, 3, }) do
                    if not done[i] then
                        TJ.SetBoardEditFormNum(v, i, 1, s1)
                        done[i] = true
                        break
                    end
                end
            end
        end

        local tbl = {
            {
                name = L["灵魂之箭减伤链"],
                bossSpellID = bossSpellID,
                arrange = 2,
                icon = "spell_shadow_shadowbolt",
                id = 1,
                spell = spellTbl,
                event = "SPELL_CAST_SUCCESS",
                canUpdate = nil,
                autoNextSpell = nil,
                startIndex = 1,
                bossTime = { 2, 2, },
                autoHide = true,
            },
            AutoFuc = AutoFuc,
        }

        --[[
/run m=TJ.frame["ZAMtitan"][5] TJ.Board_ENCOUNTER_START("ZAMtitan", 5)
/run TJ.Board_SPELL_CAST_SUCCESS(nil,nil,nil,"1",nil,nil,nil,"",nil,nil,nil,43383)
 ]]
        mainFrame.Board_SPELL_CAST_SUCCESS = function(info, ...)
            local tbl = { ... }
            local spellID = tbl[12]
            if spellID == bossSpellID then
                TJ.Board_info[bossSpellID].canUpdate = true
                TJ.Board_info[bossSpellID].updateFrame.t = 0
                After(0, function()
                    info[bossSpellID].index = info[bossSpellID].index + info[bossSpellID].step
                end)
            end
        end

        TJ.frame[FB][bossIndex].Board_test = function()
            TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
            TJ.Board_info[bossSpellID].canUpdate = true
        end

        TJ.CreateBoard(FB, bossIndex, tbl)
    end)

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)


    mainFrame.BOSS_SAY = function(msg)
        if msg:match("^^") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
            return
        end
    end
end
