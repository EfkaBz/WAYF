-- Déclaration de la table flags comme variable globale
local flags = {
    ["Français"]= {
       path = "Interface\\AddOns\\WAYF\\Drapeaux\\fr.blp",
   },
   Deutsch = {
       path = "Interface\\AddOns\\WAYF\\Drapeaux\\de.blp",
   },
   English = {
       path = "Interface\\AddOns\\WAYF\\Drapeaux\\us.blp",
   },
   Spanish = {
       path = "Interface\\AddOns\\WAYF\\Drapeaux\\es.blp",
   },
   Italian = {
       path = "Interface\\AddOns\\WAYF\\Drapeaux\\it.blp",
   },
}

local logMsg = "[WAYF] ";
local logMsgPlayerList = "[WAYF - Liste des joueurs] ";

print(logMsg, "Salut "..UnitName("player")..", 'Where Are You From ?' est ON. Addon dev by Daeler and Faareoh !")

local frame = CreateFrame("Frame")
local selectedLanguage

-- Création de la fenêtre principale
local UIConfig = CreateFrame("Frame", "WAYFConfig", UIParent, "BasicFrameTemplateWithInset");
UIConfig:SetSize(300, 200);
UIConfig:SetPoint("CENTER"); 
UIConfig.title = UIConfig:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
UIConfig.title:SetPoint("CENTER", UIConfig.TitleBg, "CENTER", 0, 0);
UIConfig.title:SetText("WAYF - Sélection de la langue");

UIConfig:SetMovable(true)
UIConfig:EnableMouse(true)
UIConfig:RegisterForDrag("LeftButton")
UIConfig:SetScript("OnDragStart", UIConfig.StartMoving)
UIConfig:SetScript("OnDragStop", UIConfig.StopMovingOrSizing)

-- Création de la texture pour afficher le drapeau
UIConfig.languageFlag = UIConfig:CreateTexture(nil, "OVERLAY");
UIConfig.languageFlag:SetPoint("RIGHT", UIConfig, "RIGHT", -75, -32);
UIConfig.languageFlag:SetSize(50, 50); -- Ajustez la taille selon vos besoins

-- Création du menu déroulant
UIConfig.languageDropdown = CreateFrame("Frame", "LanguageDropdown", UIConfig, "UIDropDownMenuTemplate");
UIConfig.languageDropdown:SetPoint("TOPLEFT", UIConfig, "TOPLEFT", 20, -50);
UIDropDownMenu_SetWidth(UIConfig.languageDropdown, 160);
UIDropDownMenu_SetText(UIConfig.languageDropdown, "Sélectionnez une langue");

-- Fonction pour gérer la sélection du menu déroulant
local function OnLanguageSelected(self, arg1)
   UIDropDownMenu_SetText(UIConfig.languageDropdown, arg1);

   selectedLanguage = arg1;  -- Mettez à jour selectedLanguage ici

   -- Mettez à jour la texture du drapeau avec le chemin correspondant a la langue sélectionnée
   if selectedLanguage and flags[selectedLanguage] then
       local flagPath = flags[selectedLanguage].path;
       UIConfig.languageFlag:SetTexture(flagPath);
   end
end

-- Fonction de mise à jour du menu déroulant
local function UpdateDropdown()
   local info = UIDropDownMenu_CreateInfo();

   for language, _ in pairs(flags) do
       info.text = language;
       info.value = language;
       info.func = function()
           OnLanguageSelected(self, language);
       end
       UIDropDownMenu_AddButton(info);
   end
end

-- Appel initial pour remplir le menu déroulant
UpdateDropdown();

-- Création du menu déroulant
UIDropDownMenu_Initialize(UIConfig.languageDropdown, function(self, level, menuList)
   UpdateDropdown();
end);

-- Création du bouton "Ok"
UIConfig.okButton = CreateFrame("Button", "WAYF_OKButton", UIConfig, "UIPanelButtonTemplate");
UIConfig.okButton:SetPoint("TOPLEFT", UIConfig, "TOPLEFT", 20, -120);
UIConfig.okButton:SetSize(80, 25);
UIConfig.okButton:SetText("Ok");

local newUIConfig = CreateFrame("Frame", "NewUIConfig", UIConfig, "BasicFrameTemplateWithInset");
newUIConfig:SetSize(300, 80);
newUIConfig:SetPoint("BOTTOM", UIConfig, "TOP", 0, 10); 
newUIConfig.title = newUIConfig:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
newUIConfig.title:SetPoint("CENTER", newUIConfig.TitleBg, "CENTER", 0, 0);
newUIConfig.title:SetText("Raccourcis clavier")
newUIConfig.description = newUIConfig:CreateFontString(nil, "OVERLAY", "GameFontNormal");
newUIConfig.description:SetPoint("TOPLEFT", newUIConfig, "TOPLEFT", 20, -30);
newUIConfig.description:SetText("- /wayf pour ouvrir cette fenêtre\n- /wayfList pour ouvrir la liste des joueurs\n  Je vous conseille de faire des macros !");

-- Récupération des informations du fichier TOC
local tocFile = "Interface\\AddOns\\WAYF\\WAYF.toc";
local tocText = GetAddOnMetadata("WAYF", "Version") or "Unknown";

-- Création du texte pour afficher les informations de l'addon
UIConfig.addonInfoText = UIConfig:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
UIConfig.addonInfoText:SetPoint("BOTTOM", UIConfig, "BOTTOM", 0, 10);
UIConfig.addonInfoText:SetText("WAYF " .. tocText);

-- Fonction déclenchée lorsque le bouton "Ok" est cliqué
UIConfig.okButton:SetScript("OnClick", function()
   local selectedLanguage = UIDropDownMenu_GetText(UIConfig.languageDropdown); 
   if selectedLanguage and flags[selectedLanguage] then
       local flagPath = flags[selectedLanguage].path;
       SendSelectedLanguage(selectedLanguage);  -- Envoyez le langue sélectionné aux autres joueurs
       -- Ajoutez ici le code pour effectuer les actions en fonction du langue sélectionné
   else
       print(logMsg, "Veuillez sélectionner une langue.");
   end
end);

-- Fonction pour afficher la fenêtre de sélection de langue
local function ShowLanguageSelectionWindow()
   if not UIConfig:IsShown() or not newUIConfig:IsShown() then
       UIConfig:Show();
       newUIConfig:Show();
       print(logMsg, "Utilisez /wayf pour réafficher la fenêtre de sélection de langue.");
   end
end

local COMM_CHANNEL = "WayfChannel";  -- Choisissez un nom de canal unique
local allUserFlags = {} -- Tableau pour stocker les drapeaux des autres joueurs

-- Fonction pour envoyer le drapeau sélectionné aux autres joueurs
function SendSelectedLanguage(selectedLanguage)
   local message = "WAYF:" .. selectedLanguage;  -- Utilisez une convention pour votre message
   local sender = UnitName("player").."-"..GetNormalizedRealmName()

   if allUserFlags[sender] and allUserFlags[sender] == selectedLanguage then
       print(logMsg, "Attention " ..sender.. " vous avez déjà selectionné la langue " .. selectedLanguage .. " !")
   else
       C_ChatInfo.SendAddonMessage(COMM_CHANNEL, message);
    end
end


function OnAddonMessageReceived(prefix, message, channel, sender)
    if prefix == COMM_CHANNEL and message:sub(1, 5) == "WAYF:" then
        local selectedLanguage = message:sub(6);

        if flags[selectedLanguage] then
            if not allUserFlags[sender] or allUserFlags[sender] ~= selectedLanguage then
                print(logMsg, sender .. " parle " .. selectedLanguage);
                allUserFlags[sender] = selectedLanguage;
                UpdatePlayerList();
                SavePlayerLanguages();  -- Sauvegarder les langues après chaque mise à jour
            end
        end
    end
end

function SavePlayerLanguages()
    WAYFSavedVariables = WAYFSavedVariables or {};  -- Initialisez la variable SavedVariable s'il n'existe pas encore
    WAYFSavedVariables.PlayerLanguages = allUserFlags;  -- Enregistrez les langues dans la variable SavedVariable
end

function LoadSavedPlayerLanguages()
    WAYFSavedVariables = WAYFSavedVariables or {};

    if WAYFSavedVariables.PlayerLanguages then
        allUserFlags = WAYFSavedVariables.PlayerLanguages;
        UpdatePlayerList();
    end
end

-- Enregistrez la fonction OnAddonMessageReceived pour gérer les messages reçus
C_ChatInfo.RegisterAddonMessagePrefix(COMM_CHANNEL);


frame:RegisterEvent("CHAT_MSG_ADDON")

frame:SetScript("OnEvent", function(_, event, prefix, message, channel, sender)
   if event == "CHAT_MSG_ADDON" then
       OnAddonMessageReceived(prefix, message, channel, sender);
   end
end);

frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        LoadSavedPlayerLanguages();
    elseif event == "CHAT_MSG_ADDON" then
        OnAddonMessageReceived(...);
    end
end);

-- Commande Slash 1
SLASH_WAYF1 = "/wayf";
SlashCmdList["WAYF"] = function()
   ShowLanguageSelectionWindow();
end

-- Création de la fenêtre pour la liste des langues sélectionnées
UIPlayerList = CreateFrame("Frame", "WAYFPlayerList", UIParent, "BasicFrameTemplateWithInset");
UIPlayerList:Hide();  -- Masquez la fenêtre au démarrage
UIPlayerList:SetSize(300, 400);
UIPlayerList:SetPoint("TOPLEFT", 350, -50);
UIPlayerList.title = UIPlayerList:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
UIPlayerList.title:SetPoint("CENTER", UIPlayerList.TitleBg, "CENTER", 0, 0);
UIPlayerList.title:SetText("WAYF - Liste des Langues Sélectionnées");

-- Rendre la fenêtre déplaçable
UIPlayerList:SetMovable(true)
UIPlayerList:EnableMouse(true)
UIPlayerList:RegisterForDrag("LeftButton")
UIPlayerList:SetScript("OnDragStart", UIPlayerList.StartMoving)
UIPlayerList:SetScript("OnDragStop", UIPlayerList.StopMovingOrSizing)


-- Création de la zone de texte pour afficher la liste
UIPlayerList.scrollFrame = CreateFrame("ScrollFrame", "WAYFPlayerListScrollFrame", UIPlayerList, "UIPanelScrollFrameTemplate");
UIPlayerList.scrollFrame:SetPoint("TOPLEFT", UIPlayerList, "TOPLEFT", 10, -30);
UIPlayerList.scrollFrame:SetPoint("BOTTOMRIGHT", UIPlayerList, "BOTTOMRIGHT", -30, 10);

UIPlayerList.scrollChild = CreateFrame("Frame", nil, UIPlayerList.scrollFrame);
UIPlayerList.scrollChild:SetSize(260, 1);  -- La hauteur sera ajustée dynamiquement
UIPlayerList.scrollFrame:SetScrollChild(UIPlayerList.scrollChild);

-- Fonction pour mettre à jour la liste des joueurs
function UpdatePlayerList()
   local yOffset = -5;  -- Marge supérieure

   for user, language in pairs(allUserFlags) do
       local playerInfo = UIPlayerList.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal");
       playerInfo:SetPoint("TOPLEFT", 10, yOffset);
       playerInfo:SetText(user .. " parle " .. language);
       yOffset = yOffset - 20;  -- Ajustez la hauteur entre chaque ligne
   end

   local totalHeight = math.abs(yOffset) + 40;  -- Hauteur totale du contenu
   UIPlayerList.scrollChild:SetSize(260, totalHeight);
end

function TextualShowAllUsersLanguages()
    if not next(allUserFlags) then
        print(logMsgPlayerList, "Aucun joueur n'a sélectionné de langue depuis votre connexion.");
    end
     for user,language in pairs(allUserFlags) do
         print(logMsgPlayerList, user .. " parle " .. language)
     end
    end


-- Commande Slash 2 pour afficher la liste des joueurs
SLASH_WAYFLIST1 = "/wayfList";
SlashCmdList["WAYFLIST"] = function()
   UpdatePlayerList();
   TextualShowAllUsersLanguages();
   UIPlayerList:Show();
end

-- Création de la fenêtre de bienvenue
local WelcomeFrame = CreateFrame("Frame", "WAYFWelcomeFrame", UIParent, "BasicFrameTemplateWithInset");
WelcomeFrame:SetSize(400, 250);
WelcomeFrame:SetPoint("CENTER");
WelcomeFrame.title = WelcomeFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge");
WelcomeFrame.title:SetPoint("TOP", WelcomeFrame, "TOP", 0, -4);
WelcomeFrame.title:SetText("Bienvenue dans l'addon 'Where are you from ?'");

-- Ajout de la texture du logo à la fenêtre de bienvenue
WelcomeFrame.logoTexture = WelcomeFrame:CreateTexture(nil, "OVERLAY");
WelcomeFrame.logoTexture:SetTexture("Interface\\AddOns\\WAYF\\Data\\logo WAYF.blp"); -- Remplacez le chemin par le bon chemin de votre image
WelcomeFrame.logoTexture:SetSize(75, 75);  -- Ajustez la taille du logo selon vos besoins
WelcomeFrame.logoTexture:SetPoint("TOP", WelcomeFrame.title, "BOTTOM", 0, -20);  -- Ajustez la position du logo

-- Rendre la fenêtre déplaçable
WelcomeFrame:SetMovable(true)
WelcomeFrame:EnableMouse(true)
WelcomeFrame:RegisterForDrag("LeftButton")
WelcomeFrame:SetScript("OnDragStart", WelcomeFrame.StartMoving)
WelcomeFrame:SetScript("OnDragStop", WelcomeFrame.StopMovingOrSizing)

-- Ajout d'un message de bienvenue
local WelcomeMessage = WelcomeFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
WelcomeMessage:SetPoint("TOPLEFT", 20, -40);
WelcomeMessage:SetPoint("BOTTOMRIGHT", -20, 0);
WelcomeMessage:SetText("Nous sommes ravis de vous accueillir dans            'Where are you from ?' !                                     Une addOn codée par Daeler & Faareoh");

-- Ajouter un bouton "C'est parti !"
local StartButton = CreateFrame("Button", nil, WelcomeFrame, "UIPanelButtonTemplate");
StartButton:SetPoint("BOTTOM", WelcomeFrame, "BOTTOM", 0, 20);
StartButton:SetSize(120, 25);
StartButton:SetText("C'est parti !");
StartButton:SetScript("OnClick", function()
    WelcomeFrame:Hide();  -- Cacher la fenêtre lorsque le bouton est cliqué
end);

-- Ajuster la priorité de la couche
WelcomeFrame:SetFrameStrata("HIGH");

-- Afficher la fenêtre de bienvenue
WelcomeFrame:Show();

