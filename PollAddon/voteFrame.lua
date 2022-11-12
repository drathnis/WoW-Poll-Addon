local AceGUI = LibStub("AceGUI-3.0")
local LibAceSerializer = LibStub:GetLibrary("AceSerializer-3.0")

local rootVoteFrame = nil
local buttons = {}

local prefix_PA = "PollAddonComms"

local AceComm = nil

local voteFrameOpen = false


local function sendVote(option)
    local data = {}
    data[1] = "voteSend"
    data[2] = option
    local encoded = LibAceSerializer:Serialize(data)
    AceComm:SendCommMessage(prefix_PA, encoded, "RAID");
    rootVoteFrame:Hide()
end



local function setOptions(opts)
    local qLable
    local vButton
    
    for index, value in ipairs(opts) do
        --print(value)
        qLable = AceGUI:Create("Label")
        qLable:SetText(value)
        qLable:SetFont("AceGUI30LabelFont", 70)
        qLable:SetFullWidth(true)
        rootVoteFrame:AddChild(qLable)
        
        local button = AceGUI:Create("Button")
        button:SetText("Vote!")
        button:SetWidth(200)
        button:SetCallback("OnClick", function ()
            sendVote(index)
        end)
        rootVoteFrame:AddChild(button)
        --resultValues[index]=0
        
    end
end

function CreateVoteFrame(opts, comms)

    if voteFrameOpen then
        rootVoteFrame:Hide()
    end
    

    rootVoteFrame = AceGUI:Create("Frame")
    rootVoteFrame:SetTitle("VOTE!")
    rootVoteFrame:SetStatusText("ResultsPage")
    rootVoteFrame:SetWidth(500)
    rootVoteFrame:SetLayout("flow")
    AceComm = comms

    _G["MyGlobalFrameName"] = rootVoteFrame.frame
    tinsert(UISpecialFrames, "MyGlobalFrameName")

    setOptions(opts)
    
    voteFrameOpen = true

    rootVoteFrame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) voteFrameOpen = false end)


end