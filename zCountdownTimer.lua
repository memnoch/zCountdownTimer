--------------------------------------------------------------------------------
-- Author: Dustin Z.                                        dzCountdownTimer.lua
-- Name: dzCountdownTimer
-- Abstract: 
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- 
--------------------------------------------------------------------------------
local dzCountdownTimer = LibStub("AceAddon-3.0"):NewAddon("dzCountdownTimer", "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0")

-- Defines the name of our mod
local mod = dzCountdownTimer
local strTimeEntered, frmCDT, fsTimerDisplay, ebTimeEntered, btnSet, btnStart, btnStop, Timer
local DEBUG = 1

 -- -- Create the global table if it does not exist yet
 CONFIGMODE_CALLBACKS = CONFIGMODE_CALLBACKS or {}
 -- -- Declare our handler
 CONFIGMODE_CALLBACKS["dzCountdownTimer"] = function(action)
    if action == "ON" then
        dzCountdownTimer.configMode = true
        -- mod:UnlockFrames()
    elseif action == "OFF" then
        dzCountdownTimer.configMode = false
        -- mod:LockFrames()
    end
 end
 
 

local alert_options = {
	type = "group",
	desc = "Alerts",
	args = {
        AudibleAlert = {
            name = "Audible Alert",
            type = "toggle",
            desc = "Play audible alert when countdown is finished?",
            get = function() return db.AudibleAlert end,
            set = function(i, switch)
                db.AudibleAlert = switch
            end
        },
        AlertSound = {
            name = "Alert Sound",
            type = "select",
            dialogControl = "LSM30_Sound",
            desc = "Set Audio Alert Sound.",
            values = AceGUIWidgetLSMlists.sound,
            get = function() return db.AlertSound end,
            set = function(self, key)
                db.AlertSound = key
            end
        },
        VisualAlert = {
            name = "Visual Alert",
            type = "toggle",
            desc = "Display visual alert when countdown is finished?",
            get = function() return db.VisualAlert end,
            set = function(i, switch)
                db.VisualAlert = switch
            end
        },
        AudioChannel = {
            name = "Audio Channel",
            type = "select",
            desc = "Channel to play sounds",
            get = function(info) return db.AudioChannel end,
            set = function(info,v)
                db.AudioChannel = v
            end,
            values = {
                ["Ambience"] = "Ambience",
                ["SFX"] = "Effects",
                ["Music"] = "Music",
                ["Master"] = "Master",
            }
        }
    }
}



local ui_options = {
	type = "group",
	desc = "UI Options",
	args = {
            Visible = {
			name = "Window Visibility",
			type = "toggle",
			desc = "Toggle Display of the Countdown Timers Window.",
			get = function() return db.Visible end,
			set = function(i, switch)
				mod:SetVisibility(switch)
			end
		},
    }
}



--------------------------------------------------------------------------------
-- Name: defaults
-- Abstract: A table which holds our preference variables
--------------------------------------------------------------------------------
local defaults = {
    profile = {
        AlertSound = "Interface\\AddOns\\ClearerCast\\Clearcasting_Impact_Chest.ogg",
        AudibleAlert = true,
        AudioChannel = "Master",
        VisualAlert = true,
        Visible = true,
        width = 275,
        height = 200,
        pos = { },
    }
}



local function ProfileSetup()
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(dzCountdownTimer.db)
	return profiles
end



--------------------------------------------------------------------------------
-- Name: dzCDT:OnInitialize()
-- Abstract: Our would be constructor, isn't it cute?
--------------------------------------------------------------------------------
function dzCountdownTimer:OnInitialize()
	-- self.abacus = LibStub("LibAbacus-3.0")
	self.ACR = LibStub("AceConfigRegistry-3.0")
	self.ACD = LibStub("AceConfigDialog-3.0")
    
	--# Initialize DB
	self.db = LibStub("AceDB-3.0"):New("dzCountdownTimerDB", defaults)
	db = self.db.profile

	--# Register our options
	self.ACR:RegisterOptionsTable("dzCountdownTimer", ProfileSetup)
    self.ACR:RegisterOptionsTable("dzCountdownTimer Alerts",alert_options)
    self.ACR:RegisterOptionsTable("dzCountdownTimer UI Options",ui_options)
	self.ACD:AddToBlizOptions("dzCountdownTimer")
    self.ACD:AddToBlizOptions("dzCountdownTimer Alerts", "Alerts", "dzCountdownTimer")
    self.ACD:AddToBlizOptions("dzCountdownTimer UI Options", "UI Options", "dzCountdownTimer")
    
    self.configMode = false
    
	SlashCmdList["dzCDT"] = function() end
    SLASH_dzCDT1 = "/dzCountdownTimer"
    SLASH_dzCDT2 = "/dzCDT"
   
    mod:dzAddMessage("Loaded!")
end



--------------------------------------------------------------------------------
-- Name: dzCDT:OnEnable()
-- Abstract: Our would be constructor, isn't it cute?
--------------------------------------------------------------------------------
function dzCountdownTimer:OnEnable()

	for varname, val in pairs(alert_options.args) do
		if db[varname] then alert_options.args[varname].set(true, db[varname]) end
	end
    
    -- for varname, val in pairs(ui_options.args) do
		-- if db[varname] then ui_options.args[varname].set(true, db[varname]) end
	-- end
    
    -- create our interface frame
    mod:CreateInterface()
    
    -- send msg on enable
    mod:dzAddMessage("Enabled!")
end



--------------------------------------------------------------------------------
-- Name: dzCDT:OnDisable()
-- Abstract: Our would be de-constructor, isn't it cute?
--------------------------------------------------------------------------------
function dzCountdownTimer:OnDisable()
--   -- Unhook, Unregister Events, Hide frames that you created.
--   -- You would probably only use an OnDisable if you want to 
--   -- build a "standby" mode, or be able to toggle modules on/off.
    -- send messag eon disable
    mod:dzAddMessage("Disabled!")
end



--------------------------------------------------------------------------------
-- Name: dzCDT:dzAddMessage(msg, r, g, b)
-- Abstract: 
--------------------------------------------------------------------------------
function dzCountdownTimer:dzAddMessage(msg, r, g, b)
    -- strMod = format("|cff0062ffdz|r|cff0deb11CountdownTimers|r")
    strMod = format("|cff696969dz|r|cff008B8BCountdownTimers|r")
    DEFAULT_CHAT_FRAME:AddMessage("" .. strMod .. ": " .. tostring(msg), r, g, b)
end



--------------------------------------------------------------------------------
-- Name: dzCDT:CreateInterface()
-- Abstract: Creates our interface for dzCDT, whee!
--------------------------------------------------------------------------------
function dzCountdownTimer:CreateInterfacepkb()

local AceGUI = LibStub("AceGUI-3.0")
    frmCDT = AceGUI:Create("Frame")
    frmCDT:SetTitle("dzCDT")
    frmCDT:SetWidth(275)
    frmCDT:SetHeight(200)
    -- frmCDT:SetUserPlaced(1)
    frmCDT:SetStatusText("")
    frmCDT:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    frmCDT:SetLayout("Flow")
    
    lblTimerDisplay = AceGUI:Create("Label")
    lblTimerDisplay:SetFont("Interface\\Addons\\dzCDT\\Fonts\\Calibri.ttf", 18)
    lblTimerDisplay:SetText("00:00:00")
    frmCDT:AddChild(lblTimerDisplay)
    
    txtTimeEntered = AceGUI:Create("EditBox")
    txtTimeEntered:SetLabel("Enter countdown time (hh:mm:ss):")
    txtTimeEntered:SetMaxLetters(8)
    -- txtTimeEntered:SetWidth(37)
    txtTimeEntered:SetFocus()
    txtTimeEntered:SetText("00:00:00")
    txtTimeEntered:SetCallback("OnEnterPressed", function(widget, event, text) mod:SetTime(text) end)
    frmCDT:AddChild(txtTimeEntered)
        
    -- btnSet = AceGUI:Create("Button")
    -- btnSet:SetText("Set")
    -- btnSet:SetWidth(75)
    -- btnSet:SetCallback("OnClick", function(widget, event, text) mod:SetTime(txtTimeEntered:GetText()))
    -- frmCDT:AddChild(btnSet)

    btnStart = AceGUI:Create("Button")
    btnStart:SetText("Start")
    btnStart:SetWidth(75)
    btnStart:SetCallback("OnClick", function(widget, event, text) mod:StartTimer() end)
    frmCDT:AddChild(btnStart)
    
    btnStop = AceGUI:Create("Button")
    btnStop:SetText("Stop")
    btnStop:SetWidth(75)
    frmCDT:AddChild(btnStop)

end



--------------------------------------------------------------------------------
-- Name: dzCDT:CreateInterface()
-- Abstract: Creates our interface for dzCDT, whee!
--------------------------------------------------------------------------------
function dzCountdownTimer:CreateInterface()

local AceGUI = LibStub("AceGUI-3.0")

    width = db.width
    height = db.height
    
    frmCDT = CreateFrame("Frame","frmCDT",UIParent)
    local f = frmCDT
    f:SetPoint("CENTER",0,0)
    f:SetWidth(275)
    f:SetHeight(200)
    f:SetMinResize(120, 80)
    f:SetMovable(true)
    f:SetResizable(true)
    f:SetUserPlaced(1)
    -- f:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    f:EnableMouse(enable)
    f:RegisterForDrag("LeftButton")
    f:SetClampedToScreen(true)
    f:SetClampRectInsets(10, -10, -10, 10)
    f:SetBackdropBorderColor(1,1,1,1)
    txFCDT = f:CreateTexture("Interface\\DialogFrame\\UI-DialogBox-Background", "BACKGROUND")
    ftx = txFCDT
    -- ftx = f:CreateTexture()
    ftx:SetAllPoints(f)
    ftx:SetTexture(0,0,0,.5)
    
    ftrFCDT = f:CreateTitleRegion()
    local ftr = ftrFCDT
    ftr:SetPoint("CENTER", f, "TOP")
    ftr:SetHeight(20)
    ftr:SetWidth(f:GetRight() - f:GetLeft() - 10)
    
    fsTimerDisplay = f:CreateFontString("fsTimerDisplay", nil)
    local fstd = fsTimerDisplay
    fstd:SetPoint('CENTER', f, 'TOP', 0, -20)
    fstd:SetJustifyV('MIDDLE')
    fstd:SetJustifyH('CENTER')
    fstd:SetHeight(20)
    fstd:SetWidth(f:GetRight() - f:GetLeft() - 10)
    fstd:SetFont("Interface\\Addons\\dzCountdownTimer\\Fonts\\Calibri.ttf", 24)
    fstd:SetText("00:00:00")
    
    btnClose = CreateFrame("Button", "btnClose", f, "UIPanelCloseButton")
    local fbcls = btnClose
    -- fbcls:SetWidth(75)
    fbcls:SetText("Start")
    fbcls:SetPoint("TOPRIGHT", f, "TOPRIGHT", 2, 0)
    fbcls:SetScript("OnClick", function() f:Hide() end)
    
    ebTimeEntered = CreateFrame("EditBox", "ebTimeEntered", f, "InputBoxTemplate")
    local febte = ebTimeEntered
    febte:SetHeight(20)
    febte:SetWidth(75)
    febte:SetMaxLetters(8)
    -- febte:SetFocus()
    febte:SetFont("Interface\\Addons\\dzCountdownTimer\\Fonts\\Calibri.ttf", 18)
    febte:AddHistoryLine("00:00:00")
    febte:SetText("00:00:00")
    febte:HighlightText()
    febte:SetPoint("CENTER", f, "TOP", 0, -90)
    febte:SetScript("OnEnterPressed", function(widget, event, text) mod:SetTime(text) end)
    
    btnSet = CreateFrame("Button", "btnSet", f, "UIPanelButtonTemplate")
    local fbset = btnSet
    fbset:SetHeight(20)
    fbset:SetWidth(60)
    fbset:SetText("Set")
    fbset:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 5, 5)
    fbset:SetScript("OnClick", function() mod:SetTime() end)
    
    btnStart = CreateFrame("Button", "btnStart", f, "UIPanelButtonTemplate")
    local fbsrt = btnStart
    fbsrt:SetHeight(20)
    fbsrt:SetWidth(60)
    fbsrt:SetText("Start")
    fbsrt:SetPoint("LEFT", fbset, "RIGHT", 5, 0)
    fbsrt:SetScript("OnClick", function() mod:StartTimer() end)
    
    btnStop = CreateFrame("Button", "btnStop", f, "UIPanelButtonTemplate")
    local fbstp = btnStop
    fbstp:SetHeight(20)
    fbstp:SetWidth(60)
    fbstp:SetText("Stop")
    fbstp:SetPoint("LEFT", btnStart, "RIGHT", 5, 0)
    fbstp:SetScript("OnClick", function() mod:StopTimer() end)
    
    btnResize = CreateFrame("Button", "btnResize", f, "UIPanelButtonGrayTemplate")
    local fbr = btnResize
    -- fbr:SetWidth(8)
    -- fbr:SetHeight(8)
    fbr:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -4, 4)
    fbr:SetScript("OnMouseDown", ResizeStart)
    fbr:SetScript("OnMouseUp", ResizeEnd)
    fbr:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    fbr:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    fbr:SetWidth(14)
    fbr:SetHeight(14)
end



--------------------------------------------------------------------------------
-- Name: dzCDT:SetTime(time)
-- Abstract: Set's the time for the countdown timer
--------------------------------------------------------------------------------
function dzCountdownTimer:SetTime(time)
    strTimeEntered = 0
    strTimeEntered = time
    strTimeEntered = ebTimeEntered:GetText()
    fsTimerDisplay:SetText(strTimeEntered)
    
    if (DEBUG) then
        mod:dzAddMessage("CDT Time: " .. strTimeEntered)
    end
end



--------------------------------------------------------------------------------
-- Name: dzCDT:SetTime(time)
-- Abstract: Set's the time for the countdown timer
--------------------------------------------------------------------------------
function dzCountdownTimer:ParseTime()
    intHours = 0
    intMinutes = 0
    intSeconds = 0
    intTotal = 0
    
    intHours = strTimeEntered:sub(1, 2)
    intMinutes = strTimeEntered:sub(4, 5)
    intSeconds = strTimeEntered:sub(7, 8)
    
    intTotal = ( ( (intHours * 60) * 60) + ( intMinutes * 60) + intSeconds )
    
    if (DEBUG) then
        mod:dzAddMessage(intHours .. " hours " .. intMinutes .. " minutes " .. intSeconds .. " seconds = " .. intTotal .. " seconds!")
    end
    return intTotal
end



--------------------------------------------------------------------------------
-- Name: dzCDT:StartTimer()
-- Abstract: Start the countdown timer
--------------------------------------------------------------------------------
function dzCountdownTimer:StartTimer()
    intTime = 0
    
    intTime = mod:ParseTime()
    Timer = self:ScheduleTimer("TimerComplete", intTime)
    
    if (DEBUG) then
        mod:dzAddMessage(Timer .. " was set for " .. intTime)
    end
end



--------------------------------------------------------------------------------
-- Name: dzCDT:StopTimer()
-- Abstract: Set's the time for the countdown timer
--------------------------------------------------------------------------------
function dzCountdownTimer:StopTimer()
    self:CancelTimer(Timer)    
    if (DEBUG) then
        mod:dzAddMessage(Timer .. " was cancelled!")
    end
end



--------------------------------------------------------------------------------
-- Name: dzCDT:TimerComplete()
-- Abstract: What we do when the timer finishes
--------------------------------------------------------------------------------
function dzCountdownTimer:TimerComplete()

	if db.AudibleAlert == true then
		local sound = _G[db.AlertSound]
        local audiochannel = _G[db.AudioChannel]
		PlaySoundFile(sound, audiochannel)
	end
    
    if (DEBUG) then
        mod:dzAddMessage("WERK WERK, TIMER COMPLETE!@#")
    end
    
end



--------------------------------------------------------------------------------
-- Name: dzCDT:TimeRemaining()
-- Abstract: Return's the amount of time left in the timer
--------------------------------------------------------------------------------
function dzCountdownTimer:TimeRemaining()

    intTimeLeft = 0
    intTimeLeft = self:TimeLeft(self.Timer)
    return intTimeLeft
    
end



--------------------------------------------------------------------------------
-- Name: dzCDT:SetVisibility()
-- Abstract: Set the Visibility of dzCDT Window
--------------------------------------------------------------------------------
function dzCountdownTimer:SetVisibility(blnVisible)
    db.Visible = blnVisible
    
    if (db.Visible == true) then
        if not frmCDT:IsHidden() then
            frmCDT:Show()
            mod:dzAddMessage("Show teh framez0r!@#")
        end
    elseif (db.Visible == false) then
        if frmCDT:IsHidden() then
            frmCDT:Hide()
            mod:dzAddMessage("Hide teh framez0r!@#")
        end
    else
        mod:dzAddMessage("Some Kind Of Error!@#")
    end
end



--------------------------------------------------------------------------------
-- Name: dzCDT:ToggleVisibility()
-- Abstract: Toggle Visibility of dzCDT Window
--------------------------------------------------------------------------------
function dzCountdownTimer:ToggleVisibility()
    if (db.Visible == true) then
        db.Visible = false
        frmCDT:Hide()
        lblTimerDisplay:Hide()
        txtTimeEntered:Hide()
        btnSet:Hide()
        btnStart:Hide()
        btnStop:Hide()
        mod:dzAddMessage("Hide teh framez0r!@#")
    elseif (db.Visible == false) then
        db.Visible = true
        frmCDT:Show()
        lblTimerDisplay:Show()
        txtTimeEntered:Show()
        btnSet:Show()
        btnStart:Show()
        btnStop:Show()
        mod:dzAddMessage("Show teh framez0r!@#")
    else
    end
end



--------------------------------------------------------------------------------
-- Event Handlers
--------------------------------------------------------------------------------
