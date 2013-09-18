local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local loc = GetLocale()

local ToolTipColors = {
	"|cFF269CFF",	-- Header 1
	"|cFFFF8000",	-- Header 2
	"|cFFFFFFFF",	-- Plain Text
	"|cFF909090",	-- Grey Text
	"|cFFE0E0E0",	-- Light Grey Text
	"|cFF00D8FF"	-- Blue Text
}

local ButtonTexts, ToolTipStrings, ToolTipTexts

---- Localizations
--[[

Notes:

When editing Localizations, make sure not to touch any of the 'codes'
Codes:  |r  \n  |cff######

To test changes, first reload the ui (/rl) then reactive the tutorial (/run TestTutorial())

]]--

-- loc = "deDE"

if loc == "deDE" then	-- Deutsch
	ButtonTexts = {
		tutorial = "Führung",
		skip = "übergehen",
		finished = "fertig",
	}
	ToolTipStrings = {
		mouseover =			ToolTipColors[4].."(wird bei Mouseover angezeigt)|r",
		endbox =			ToolTipColors[2].."Kästchen am Ende:|r\n"..ToolTipColors[3].."Klasse/Feindseligkeit eingefärbt|r",
		statusindicators =	ToolTipColors[2].."Statusanzeigen:|r\n|cff00FF00Ausruhen|r\n|cffFFFF00AFK|r\n|cffFF0000Im Kampf|r\n|cff00FFFFAnführer|r\n\n"..ToolTipColors[2].."Health Bar Indicators:|r\n|cff00FF00PvP Friendly|r\n|cffFF0000PvP Hostile|r\n|cffFFFF00Elite|r\n|cffC0C0C0Rare|r",
		setfocus =			ToolTipColors[6].."Shift+Click|r"..ToolTipColors[5].." als Fokus setzen.",
		abconfig =			ToolTipColors[5].."Schreibe "..ToolTipColors[6].."/bar|r "..ToolTipColors[5].."zum konfigurieren.|r",
		buffconfig =		ToolTipColors[5].."Schreibe "..ToolTipColors[6].."/raven|r "..ToolTipColors[5].."zum konfigurieren.|r",
	}
	ToolTipTexts = {
		minimap =			ToolTipColors[1].."Minimap|r\n\n"..ToolTipColors[2].."Unten links: |r"..ToolTipColors[3].."Koordinaten|r\n"..ToolTipColors[2].."Unten rechts: |r"..ToolTipColors[3].."Feindseligkeit der Zone|r\n"..ToolTipColors[2].."Oben: |r"..ToolTipColors[3].."Steuerung |r"..ToolTipColors[4].."(mouseover)|r\n"..ToolTipColors[2].."Darunter: |r"..ToolTipColors[3].."Minimap Buttons |r"..ToolTipColors[4].."(mouseover)|r",
		buffs =				ToolTipColors[1].."Spieler-Buffs - Langzeit|r\n\n"..ToolTipColors[3].."Zeigt die Buffs des Spieler mit einer Dauer von > 1 Minute.|r\n\n"..ToolTipStrings.buffconfig,
		playerframe =		ToolTipColors[1].."Spieler-Frame|r\n\n"..ToolTipStrings.statusindicators.."\n\n"..ToolTipColors[2].."Statustexte:|r\n"..ToolTipColors[3].."P = PvP|r\n\n"..ToolTipStrings.setfocus,
		targetframe =		ToolTipColors[1].."Ziel-Frame|r\n\n"..ToolTipStrings.endbox.."\n\n"..ToolTipStrings.statusindicators.."\n\n"..ToolTipStrings.setfocus,
		focusframes =		ToolTipColors[1].."Fokus/Fokusziel-Frames|r\n\n"..ToolTipStrings.endbox.."\n\n"..ToolTipStrings.statusindicators,
		totframe =			ToolTipColors[1].."Ziel des Ziels-Frame|r\n\n"..ToolTipStrings.endbox.."\n\n"..ToolTipStrings.statusindicators.."\n\n"..ToolTipStrings.setfocus,
		playerbuffs =		ToolTipColors[1].."Spieler-Buffs - Kurzzeit|r\n\n"..ToolTipColors[3].."Zeigt die Buffs des Spieler mit einer Dauer von <= 1 Minute.|r\n\n"..ToolTipStrings.buffconfig,
		playerdebuffs =		ToolTipColors[1].."Spieler-Debuffs|r\n\n"..ToolTipColors[3].."Zeigt alle Debuffs des Spieler.|r\n\n"..ToolTipStrings.buffconfig,
		targetbuffs =		ToolTipColors[1].."Ziel-Buffs|r\n\n"..ToolTipColors[3].."Zeigt Buffs auf dem Ziel.|r\n\n"..ToolTipStrings.buffconfig,
		targetdebuffs =		ToolTipColors[1].."Ziel-Debuffs|r\n\n"..ToolTipColors[3].."Displays Debuffs on your Target.\n\n"..ToolTipColors[2].."Critera:\n"..ToolTipColors[3].."Cast durch den Spieler\nKann vom Spieler gecastet werden\nKann vom Spieler dispelled werden\nCast durch ein Fahreug\nCast durch einen NPC|r\n\n"..ToolTipStrings.buffconfig,
		focusbuffs =		ToolTipColors[1].."Fokus-Buffs|r\n\n"..ToolTipColors[3].."Displays Buffs on your Focus target.\n\n"..ToolTipColors[2].."Critera:\n"..ToolTipColors[3].."Cast durch den Spieler\nKann vom Spieler gestohlen werden\nCast durch ein Fahreug\nCast durch einen NPC|r\n\n"..ToolTipStrings.buffconfig,
		totdebuffs =		ToolTipColors[1].."Ziel des Ziels-Debuffs|r\n\n"..ToolTipColors[3].."Displays Debuffs on your Target's Target.\n\n"..ToolTipColors[2].."Critera:\n"..ToolTipColors[3].."Cast durch den Spieler\nKann vom Spieler gecastet werden\nKann vom Spieler dispelled werden\nCast durch ein Fahreug\nCast durch einen NPC|r\n\n"..ToolTipStrings.buffconfig,
		actionbars =		ToolTipColors[1].."Primäre Aktionsleiste|r\n\n"..ToolTipColors[2].."Leisten:|r\n"..ToolTipColors[3].."Leisten 1, 2, 3|r\n\n"..ToolTipColors[2].."Sichtbarkeitsbedingungen:|r\n"..ToolTipColors[3].."Strg-Taste gedrückt\nFokus gesetzt\nAngreifbares Ziel ausgewählt\nIm Kampf\nIn einer Gruppe|r\n\n"..ToolTipStrings.abconfig,
		petbar =			ToolTipColors[1].."Pet Action Bar|r\n\n"..ToolTipColors[2].."Visibility Conditions:|r\n"..ToolTipColors[3].."Mouse-over\nCtrl key pressed\n\n"..ToolTipStrings.abconfig,
		stancebar =			ToolTipColors[1].."Stance Bar|r\n\n"..ToolTipColors[2].."Visibility Conditions:|r\n"..ToolTipColors[3].."Mouse-over\nCtrl key pressed\n\n"..ToolTipStrings.abconfig,
		moactionbars2 =		ToolTipColors[1].."Sekundäre Aktionsleisten|r\n"..ToolTipStrings.mouseover.."\n\n"..ToolTipColors[2].."Leisten:|r\n"..ToolTipColors[3].."Leiste 4, 5|r",
		infolineright =		ToolTipColors[1].."Infozeile - Rechts|r\n\n"..ToolTipColors[2].."Elemente:|r\n"..ToolTipColors[3].."Uhr\nSchalter für Damage-Meter\nLayout-Wechsler|r\n|cff909090(DPS/Tank, Heilung, Niedr./Hohe Auflösung)|r\n"..ToolTipColors[3].."Spec-Wechsler, Ausrüst.-Manager\nFPS und Latenz|r",
		infolineleft =		ToolTipColors[1].."Infozeile - Links|r\n\n"..ToolTipColors[2].."Elemente:|r\n"..ToolTipColors[3].."Optionsbutton / Mikromenü\nNeue Mail-Anzeige\nGilde\nFreunde\nHaltbarkeit |r"..ToolTipColors[4].."(< 95%)|r\n"..ToolTipColors[3].."Leere Inventarplätze\nWährung\nXP / Ruf|r",
		watchFrame =		ToolTipColors[1].."Watch Frame|r\n\n"..ToolTipColors[2].."Right Click:|r\n"..ToolTipColors[3].."Track quest on World Map|r\n\n"..ToolTipColors[2].."Shift + Right Click:|r\n"..ToolTipColors[3].."Show DropDown menu|r\n\n"..ToolTipColors[2].."Shift + Left Click:|r\n"..ToolTipColors[3].."Stop tracking quest|r",
	}
-- elseif loc == "itIT" then	-- Italiano
	
elseif loc == "frFR" then	-- French
	ButtonTexts = {
		tutorial = "Tutoriel",
		skip = "Passer",
		finished = "Fini",
	}
	ToolTipStrings = {
		mouseover =			ToolTipColors[4].."(S'affiche au passage de la souris)|r",
		endbox =			ToolTipColors[2].."Rectangle à l'extremite:|r\n"..ToolTipColors[3].."Couleur en fonction de Classe/Hostilite|r",
		statusindicators =	ToolTipColors[2].."Indicateurs de Statut:|r\n|cff00FF00Se Repose|r\n|cffFFFF00AFK|r\n|cffFF0000En Combat|r\n|cff00FFFFChef|r\n\n"..ToolTipColors[2].."Health Bar Indicators:|r\n|cff00FF00PvP Friendly|r\n|cffFF0000PvP Hostile|r\n|cffFFFF00Elite|r\n|cffC0C0C0Rare|r",
		setfocus =			ToolTipColors[6].."Shift+Click|r"..ToolTipColors[5].." Pour definir le focus.",
		abconfig =			ToolTipColors[5].."Taper "..ToolTipColors[6].."/bar|r "..ToolTipColors[5].."pour configurer.|r",
		buffconfig =		ToolTipColors[5].."Taper "..ToolTipColors[6].."/raven|r "..ToolTipColors[5].."pour configurer.|r",
	}
	ToolTipTexts = {
		minimap =			ToolTipColors[1].."Minicarte|r\n\n"..ToolTipColors[2].."Inferieur Gauche: |r"..ToolTipColors[3].."Coordonnees|r\n"..ToolTipColors[2].."Inferieur Droit: |r"..ToolTipColors[3].."Hostilite de la zone|r\n"..ToolTipColors[2].."Dessus: |r"..ToolTipColors[3].."Controles |r"..ToolTipColors[4].."(mouseover)|r\n"..ToolTipColors[2].."En dessous: |r"..ToolTipColors[3].."Boutons de la minicarte |r"..ToolTipColors[4].."(mouseover)|r",
		buffs =				ToolTipColors[1].."Ameliorations de Joueurs - Long Terme|r\n\n"..ToolTipColors[3].."Affiche les ameliorations sur le joueur ayant une duree  > 1min.|r\n\n"..ToolTipStrings.buffconfig,
		playerframe =		ToolTipColors[1].."Cadre du Joueur|r\n\n"..ToolTipStrings.statusindicators.."\n\n"..ToolTipColors[2].."Textes de Statut:|r\n"..ToolTipColors[3].."P = PvP|r\n\n"..ToolTipStrings.setfocus,
		targetframe =		ToolTipColors[1].."Cadre de le cible|r\n\n"..ToolTipStrings.endbox.."\n\n"..ToolTipStrings.statusindicators.."\n\n"..ToolTipStrings.setfocus,
		focusframes =		ToolTipColors[1].."Cadres de la Focalisation/Cible de la Focalisation|r\n\n"..ToolTipStrings.endbox.."\n\n"..ToolTipStrings.statusindicators,
		totframe =			ToolTipColors[1].."Cadre de la Cible de la Cible|r\n\n"..ToolTipStrings.endbox.."\n\n"..ToolTipStrings.statusindicators.."\n\n"..ToolTipStrings.setfocus,
		playerbuffs =		ToolTipColors[1].."Amelioration du joueur - Court Terme|r\n\n"..ToolTipColors[3].."Affiche les ameliorations sur le joueur ayant une duree <= 1min.|r\n\n"..ToolTipStrings.buffconfig,
		playerdebuffs =		ToolTipColors[1].."Corruption du joueur|r\n\n"..ToolTipColors[3].."Affiche toutes les corruptions sur le joueur.|r\n\n"..ToolTipStrings.buffconfig,
		targetbuffs =		ToolTipColors[1].."Ameliorations de la cible|r\n\n"..ToolTipColors[3].."Affiche toutes les ameliorations de la cible.|r\n\n"..ToolTipStrings.buffconfig,
		targetdebuffs =		ToolTipColors[1].."Corruptions de la cible|r\n\n"..ToolTipColors[3].."Affiche toutes les corruptions de votre cible.\n\n"..ToolTipColors[2].."Critere:\n"..ToolTipColors[3].."Lancer par le joueur\nPeut etre lance par le joueur\nPeut etre annulee par le joueur\nLancer par un vehicule\nLancer par un PNJ|r\n\n"..ToolTipStrings.buffconfig,
		focusbuffs =		ToolTipColors[1].."Ameliorations du la Focalisation|r\n\n"..ToolTipColors[3].."Affiche les ameliorations sur la focalisation.\n\n"..ToolTipColors[2].."Critere:\n"..ToolTipColors[3].."Lancer par le joueur\nPeut être vole par le joueur\nLancer par un vehicule\nLancer par un PNJ|r\n\n"..ToolTipStrings.buffconfig,
		totdebuffs =		ToolTipColors[1].."Corruptions de la cible de votre cible|r\n\n"..ToolTipColors[3].."Affiche les corruptions de la cible de votre cible.\n\n"..ToolTipColors[2].."Critere:\n"..ToolTipColors[3].."Lancer par le joueur\nPeut etre lance par le joueur\nPeut etre annule par le joueur\nLancer par un vehicule\nLancer par un PNJ|r\n\n"..ToolTipStrings.buffconfig,
		actionbars =		ToolTipColors[1].."Barres d'actions principales|r\n\n"..ToolTipColors[2].."Barres:|r\n"..ToolTipColors[3].."Barres 1, 2, 3|r\n\n"..ToolTipColors[2].."Conditions de visibilite:|r\n"..ToolTipColors[3].."Touche Ctrl pressee\nDefinir Focalisation\nCible Attaquable selectionnee\nEn Combat\nDans un Groupe|r\n\n"..ToolTipStrings.abconfig,
		petbar =			ToolTipColors[1].."Pet Action Bar|r\n\n"..ToolTipColors[2].."Visibility Conditions:|r\n"..ToolTipColors[3].."Mouse-over\nCtrl key pressed\n\n"..ToolTipStrings.abconfig,
		stancebar =			ToolTipColors[1].."Stance Bar|r\n\n"..ToolTipColors[2].."Visibility Conditions:|r\n"..ToolTipColors[3].."Mouse-over\nCtrl key pressed\n\n"..ToolTipStrings.abconfig,
		moactionbars2 =		ToolTipColors[1].."Barres d'actions secondaires|r\n"..ToolTipStrings.mouseover.."\n\n"..ToolTipColors[2].."Barres:|r\n"..ToolTipColors[3].."Barre 4, 5|r",
		infolineright =		ToolTipColors[1].."Ligne d'information - Droite|r\n\n"..ToolTipColors[2].."Elements:|r\n"..ToolTipColors[3].."Horloge\nSelecteur de compteur de degats\nSelecteur de disposition|r\n|cff909090(DPS/Tank, Soigneur, Basse/Haute Resolution)|r\n"..ToolTipColors[3].."Selecteur de Spec, Gestionnaire d'equipement\nIPS et Latence|r",
		infolineleft =		ToolTipColors[1].."Ligne d'information - Gauche|r\n\n"..ToolTipColors[2].."Elements:|r\n"..ToolTipColors[3].."Boutons d'Options / Micromenu\nIndicateur de nouveaux messages\nGuilde\nAmis\nDurabilite |r"..ToolTipColors[4].."(< 95%)|r\n"..ToolTipColors[3].."Sacs : Emplacements libres\nDevise\nXP / Reputation|r",
		watchFrame =		ToolTipColors[1].."Watch Frame|r\n\n"..ToolTipColors[2].."Right Click:|r\n"..ToolTipColors[3].."Track quest on World Map|r\n\n"..ToolTipColors[2].."Shift + Right Click:|r\n"..ToolTipColors[3].."Show DropDown menu|r\n\n"..ToolTipColors[2].."Shift + Left Click:|r\n"..ToolTipColors[3].."Stop tracking quest|r",
	}
else	-- Default
	ButtonTexts = {
		tutorial = "Tutorial",
		skip = "Skip",
		finished = "Finished",
	}
	ToolTipStrings = {
		mouseover =			ToolTipColors[4].."(shows on mouseover)|r",
		endbox =			ToolTipColors[2].."End Box:|r\n"..ToolTipColors[3].."Class/Hostility Colored|r",
		statusindicators =	ToolTipColors[2].."Status Indicators:|r\n|cff00FF00Resting|r\n|cffFFFF00AFK|r\n|cffFF0000In Combat|r\n|cff00FFFFLeader|r\n\n"..ToolTipColors[2].."Health Bar Indicators:|r\n|cff00FF00PvP Friendly|r\n|cffFF0000PvP Hostile|r\n|cffFFFF00Elite|r\n|cffC0C0C0Rare|r",
		setfocus =			ToolTipColors[6].."Shift+Click|r"..ToolTipColors[5].." to set as Focus.",
		abconfig =			ToolTipColors[5].."Type "..ToolTipColors[6].."/bar|r "..ToolTipColors[5].."to configure.|r",
		buffconfig =		ToolTipColors[5].."Type "..ToolTipColors[6].."/raven|r "..ToolTipColors[5].."to configure.|r",
	}
	ToolTipTexts = {
		minimap =			ToolTipColors[1].."Minimap|r\n\n"..ToolTipColors[2].."Bottom Left: |r"..ToolTipColors[3].."Coordinates|r\n"..ToolTipColors[2].."Bottom Right: |r"..ToolTipColors[3].."Zone Hostility|r\n"..ToolTipColors[2].."Top: |r"..ToolTipColors[3].."Controls |r"..ToolTipColors[4].."(mouseover)|r\n"..ToolTipColors[2].."Underneath: |r"..ToolTipColors[3].."Minimap Buttons |r"..ToolTipColors[4].."(mouseover)|r",
		buffs =				ToolTipColors[1].."Player Buffs - Long Term|r\n\n"..ToolTipColors[3].."Displays Buffs on the Player with a duration > 1min.|r\n\n"..ToolTipStrings.buffconfig,
		playerframe =		ToolTipColors[1].."Player Frame|r\n\n"..ToolTipStrings.statusindicators.."\n\n"..ToolTipColors[2].."Status Texts:|r\n"..ToolTipColors[3].."P = PvP|r\n\n"..ToolTipStrings.setfocus,
		targetframe =		ToolTipColors[1].."Target Frame|r\n\n"..ToolTipStrings.endbox.."\n\n"..ToolTipStrings.statusindicators.."\n\n"..ToolTipStrings.setfocus,
		focusframes =		ToolTipColors[1].."Focus/Focus Target Frames|r\n\n"..ToolTipStrings.endbox.."\n\n"..ToolTipStrings.statusindicators,
		totframe =			ToolTipColors[1].."Target's Target Frame|r\n\n"..ToolTipStrings.endbox.."\n\n"..ToolTipStrings.statusindicators.."\n\n"..ToolTipStrings.setfocus,
		playerbuffs =		ToolTipColors[1].."Player Buffs - Short Term|r\n\n"..ToolTipColors[3].."Displays Buffs on the Player that have a duration <= 1min.|r\n\n"..ToolTipStrings.buffconfig,
		playerdebuffs =		ToolTipColors[1].."Player Debuffs|r\n\n"..ToolTipColors[3].."Displays all Debuffs on the Player.|r\n\n"..ToolTipStrings.buffconfig,
		targetbuffs =		ToolTipColors[1].."Target Buffs|r\n\n"..ToolTipColors[3].."Displays Buffs on the Target.|r\n\n"..ToolTipStrings.buffconfig,
		targetdebuffs =		ToolTipColors[1].."Target Debuffs|r\n\n"..ToolTipColors[3].."Displays Debuffs on your Target.\n\n"..ToolTipColors[2].."Critera:\n"..ToolTipColors[3].."Cast by Player\nCastable by Player\nDispellable by Player\nCast by a Vehicle\nCast by an NPC|r\n\n"..ToolTipStrings.buffconfig,
		focusbuffs =		ToolTipColors[1].."Focus Buffs|r\n\n"..ToolTipColors[3].."Displays Buffs on your Focus target.\n\n"..ToolTipColors[2].."Critera:\n"..ToolTipColors[3].."Cast by Player\nSpellstealable by Player\nCast by a Vehicle\nCast by an NPC|r\n\n"..ToolTipStrings.buffconfig,
		totdebuffs =		ToolTipColors[1].."Target's Target Debuffs|r\n\n"..ToolTipColors[3].."Displays Debuffs on your Target's Target.\n\n"..ToolTipColors[2].."Critera:\n"..ToolTipColors[3].."Cast by Player\nCastable by Player\nDispellable by Player\nCast by a Vehicle\nCast by an NPC|r\n\n"..ToolTipStrings.buffconfig,
		actionbars =		ToolTipColors[1].."Primary Action Bars|r\n\n"..ToolTipColors[2].."Bars:|r\n"..ToolTipColors[3].."Bars 1, 2, 3|r\n\n"..ToolTipColors[2].."Visibility Conditions:|r\n"..ToolTipColors[3].."Ctrl key pressed\nFocus set\nAttackable target selected\nIn Combat\nIn a Group|r\n\n"..ToolTipStrings.abconfig,
		petbar =			ToolTipColors[1].."Pet Action Bar|r\n\n"..ToolTipColors[2].."Visibility Conditions:|r\n"..ToolTipColors[3].."Mouse-over\nCtrl key pressed\n\n"..ToolTipStrings.abconfig,
		stancebar =			ToolTipColors[1].."Stance Bar|r\n\n"..ToolTipColors[2].."Visibility Conditions:|r\n"..ToolTipColors[3].."Mouse-over\nCtrl key pressed\n\n"..ToolTipStrings.abconfig,
		moactionbars2 =		ToolTipColors[1].."Secondary Action Bars|r\n"..ToolTipStrings.mouseover.."\n\n"..ToolTipColors[2].."Bars:|r\n"..ToolTipColors[3].."Bar 4, 5|r",
		infolineright =		ToolTipColors[1].."Info Line - Right|r\n\n"..ToolTipColors[2].."Elements:|r\n"..ToolTipColors[3].."Clock\nDamage Meter Toggle\nLayout Changer|r\n|cff909090(DPS/Tank, Healing, Low/High Resolution)|r\n"..ToolTipColors[3].."Spec Changer, Equip Manager\nFPS and Latency|r",
		infolineleft =		ToolTipColors[1].."Info Line - Left|r\n\n"..ToolTipColors[2].."Elements:|r\n"..ToolTipColors[3].."Options Button / Micromenu\nNew Mail Indicator\nGuild\nFriends\nDurability |r"..ToolTipColors[4].."(< 95%)|r\n"..ToolTipColors[3].."Empty Bag Slots\nCurrency\nXP / Reputation|r",
		watchFrame =		ToolTipColors[1].."Watch Frame|r\n\n"..ToolTipColors[2].."Right Click:|r\n"..ToolTipColors[3].."Track quest on World Map|r\n\n"..ToolTipColors[2].."Shift + Right Click:|r\n"..ToolTipColors[3].."Show DropDown menu|r\n\n"..ToolTipColors[2].."Shift + Left Click:|r\n"..ToolTipColors[3].."Stop tracking quest|r",
	}
end
---- end Localizations


local rTB
RealUI_HelpPlate = {
	[1] = {		--minimap
		ButtonAnchor = "TOPLEFT",
		ButtonPos = { x = Minimap:GetWidth() + 2, y = -(Minimap:GetHeight()) + 84 },
		ToolTipDir = "RIGHT",
		ToolTipText = ToolTipTexts.minimap,
	},
	[2] = {		--buffs
		ButtonAnchor = "TOPRIGHT",
		ButtonPos = { x = -110, y = -26 },
		ToolTipDir = "DOWN",
		ToolTipText = ToolTipTexts.buffs,
	},
	[3] = {		--player frame
		ButtonAnchor = "CENTER",
		ButtonPos = { x = -184, y = -38 },
		ToolTipDir = "RIGHT",
		ToolTipText = ToolTipTexts.playerframe,
	},
	[4] = {		--target frame
		ButtonAnchor = "CENTER",
		ButtonPos = { x = 184, y = -38 },
		ToolTipDir = "LEFT",
		ToolTipText = ToolTipTexts.targetframe,
	},
	[5] = {		--focus frames
		ButtonAnchor = "CENTER",
		ButtonPos = { x = -184, y = -98 },
		ToolTipDir = "RIGHT",
		ToolTipText = ToolTipTexts.focusframes,
	},
	[6] = {		--tot frame
		ButtonAnchor = "CENTER",
		ButtonPos = { x = 184, y = -98 },
		ToolTipDir = "LEFT",
		ToolTipText = ToolTipTexts.totframe,
	},
	[7] = {		--player buffs
		ButtonAnchor = "CENTER",
		ButtonPos = { x = -447, y = -38 },
		ToolTipDir = "UP",
		ToolTipText = ToolTipTexts.playerbuffs,
	},
	[8] = {		--player debuffs
		ButtonAnchor = "CENTER",
		ButtonPos = { x = -447, y = 0 },
		ToolTipDir = "UP",
		ToolTipText = ToolTipTexts.playerdebuffs,
	},
	[9] = {		--target buffs
		ButtonAnchor = "CENTER",
		ButtonPos = { x = 447, y = -38 },
		ToolTipDir = "UP",
		ToolTipText = ToolTipTexts.targetbuffs,
	},
	[10] = {	--target debuffs
		ButtonAnchor = "CENTER",
		ButtonPos = { x = 447, y = 0 },
		ToolTipDir = "UP",
		ToolTipText = ToolTipTexts.targetdebuffs,
	},
	[11] = {	--focus buffs
		ButtonAnchor = "CENTER",
		ButtonPos = { x = -410, y = -98 },
		ToolTipDir = "DOWN",
		ToolTipText = ToolTipTexts.focusbuffs,
	},
	[12] = {	--tot debuffs
		ButtonAnchor = "CENTER",
		ButtonPos = { x = 410, y = -98 },
		ToolTipDir = "DOWN",
		ToolTipText = ToolTipTexts.totdebuffs,
	},
	[13] = {	--action bars
		ButtonAnchor = "CENTER",
		ButtonPos = { x = 0, y = -192 },
		ToolTipDir = "UP",
		ToolTipText = ToolTipTexts.actionbars,
	},
	[14] = {	--infoline right
		ButtonAnchor = "BOTTOMRIGHT",
		ButtonPos = { x = -110, y = 12 },
		ToolTipDir = "UP",
		ToolTipText = ToolTipTexts.infolineright,
	},
	[15] = {	--infoline left
		ButtonAnchor = "BOTTOMLEFT",
		ButtonPos = { x = 110, y = 12 },
		ToolTipDir = "UP",
		ToolTipText = ToolTipTexts.infolineleft,
	},
	[16] = {	-- secondary action bars
		ButtonAnchor = "RIGHT",
		ButtonPos = { x = -21, y = 0 },
		ToolTipDir = "LEFT",
		ToolTipText = ToolTipTexts.moactionbars2,
	},
	[17] = {	-- pet bar
		ButtonAnchor = "LEFT",
		ButtonPos = { x = 21, y = 0 },
		ToolTipDir = "RIGHT",
		ToolTipText = ToolTipTexts.petbar,
	},
	[18] = {	--stance bar
		ButtonAnchor = "BOTTOMRIGHT",
		ButtonPos = { x = -284, y = 12 },
		ToolTipDir = "UP",
		ToolTipText = ToolTipTexts.stancebar,
	},
	[19] = {	--watch frane
		ButtonAnchor = "TOPRIGHT",
		ButtonPos = { x = -32, y = -180 },
		ToolTipDir = "LEFT",
		ToolTipText = ToolTipTexts.watchFrame,
	},
}

-- Skin Help Plate frames
local function SkinHelpPlateFrames()
	if Aurora then
		for i = 1, HelpPlateTooltip:GetNumRegions() do
			local region = select(i, HelpPlateTooltip:GetRegions())
			if region:GetObjectType() == "Texture" then
				region:SetTexture(nil)
			end
		end
		
		Aurora[1].SetBD(HelpPlateTooltip)
	end
end

local HP_CP
function RealUITutorial_HelpPlate_AnimateOnFinished(self)
	-- Hide the parent button
	self.parent:Hide()
	self:SetScript("OnFinished", nil)

	-- Hide everything
	for i = 1, #HELP_PLATE_BUTTONS do
		local button = HELP_PLATE_BUTTONS[i]
		button.box:Hide()
		button.boxHighlight:Hide()
	end
	
	HP_CP = nil
	HelpPlate:Hide()
	nibRealUI.db.global.tutorial.stage = -1
end

function RealUITutorial_HelpPlate_AnimateOut()
    if ( HP_CP ) then
        for i = 1, #HELP_PLATE_BUTTONS do
            local button = HELP_PLATE_BUTTONS[i]
            button.tooltipDir = "RIGHT"
            if ( button:IsShown() ) then
                if ( button.animGroup_Show:IsPlaying() ) then
                    button.animGroup_Show:Stop()
                end
                button.animGroup_Show:SetScript("OnFinished", RealUITutorial_HelpPlate_AnimateOnFinished)
                button.animGroup_Show.translate:SetDuration(0.3)
                button.animGroup_Show.alpha:SetDuration(0.3)
                button.animGroup_Show:Play()
            end
        end
    end
end

local function RealUITutorial_HelpPlate_Show(self, parent, mainHelpButton)
	if HP_CP then return end

	-- Low Res Optimization reposition
	if nibRealUI.db.global.tags.lowResOptimized then
		for i = 3, 12 do
			RealUI_HelpPlate[i].ButtonPos.y = RealUI_HelpPlate[i].ButtonPos.y + 33
		end
	end
	
	HP_CP = self
	HP_CP.mainHelpButton = mainHelpButton
	for i = 1, #self do
		local button = HelpPlate_GetButton()
		button:ClearAllPoints()
		button:SetPoint( self[i].ButtonAnchor, HelpPlate, self[i].ButtonAnchor, self[i].ButtonPos.x, self[i].ButtonPos.y )
		button.tooltipDir = self[i].ToolTipDir
		button.toolTipText = self[i].ToolTipText
		button.viewed = false
		button:Show()
		button.BigI:Show()
		button.Ring:Show()
		button.Pulse:Play()
	end
	HelpPlate:SetPoint( "CENTER", parent, "CENTER", 0, 0 )
	HelpPlate:SetSize( UIParent:GetWidth(), UIParent:GetHeight() )
	HelpPlate.userToggled = true
	HelpPlate:Show()
end

function RealUIHideTutorial()
	RealUITutorial_HelpPlate_AnimateOut()
	RealUITutorialButtonClose:Hide()
	UIFrameFadeOut(RealUITutorialBG, 0.3, 0.5, 0)
	RealUITutorialLogo:Hide()
	RealUIConfigBarToggle(true)
	nibRealUI.db.global.tutorial.stage = -1
end

local hasAdjustedPositions = false
function RealUIShowTutorial_Stage1()
	local helpPlate = RealUI_HelpPlate
	if ( helpPlate and not HelpPlate_IsShowing(helpPlate) ) then
		RealUITutorial_HelpPlate_Show( helpPlate, UIParent, rTB )
	end
	
	HelpPlate:EnableMouse(false)
	SkinHelpPlateFrames()
end

local function createTextButton(name, parent)
	local btn = CreateFrame("Button", name, parent, "SecureActionButtonTemplate")
	btn:SetNormalFontObject(NumberFontNormal)
	btn:SetFrameStrata("DIALOG")
	btn:SetFrameLevel(50)
	btn:SetSize(110, 50)
	return btn
end

function nibRealUI:InitTutorial()
	-- MainHelpPlateButton
	rTB = CreateFrame("Button", "RealUITutorialButton", UIParent, "MainHelpPlateButton")
	rTB:SetPoint("CENTER", UIParent, "CENTER", 0, -38)
	rTB:Hide()
	
	-- Dark BG
	local tBG = CreateFrame("Frame", "RealUITutorialBG", UIParent)
	tBG:SetParent(UIParent)
	tBG:SetPoint("CENTER", UIParent, "CENTER")
	tBG:SetFrameStrata("BACKGROUND")
	tBG:SetFrameLevel(0)
	tBG:SetWidth(UIParent:GetWidth() + 2000)
	tBG:SetHeight(UIParent:GetHeight() + 2000)
	tBG:SetBackdrop({
		bgFile = [[Interface\AddOns\nibRealUI\Media\Plain]],
	})
	tBG:SetBackdropColor(0, 0, 0, 0.4)
	
	-- Logo
	local rLogo = UIParent:CreateTexture("RealUITutorialLogo", "ARTWORK")
	rLogo:SetTexture([[Interface\AddOns\nibRealUI\Media\Logo]])
	rLogo:SetSize(64, 64)
	rLogo:SetPoint("CENTER", UIParent, "CENTER", 0, 65)
	
	-- Buttons
	local btnOpen = createTextButton("RealUITutorialButtonOpen", UIParent)
	btnOpen:SetPoint("CENTER", parent, "CENTER", 0, 0)
	btnOpen:SetText(ButtonTexts.tutorial)
	btnOpen:SetAttribute("type", "macro")
	btnOpen:SetAttribute("macrotext", "/tar "..nibRealUI.name.."\n/focus\n/run RealUIShowTutorial_Stage1()\n/run RealUITutorialButtonClose:Show()\n/run RealUITutorialButtonOpen:Hide()\n/run RealUITutorialButtonSkip:Hide()")
	nibRealUI:AddButtonHighlight(btnOpen)
	
	local btnSkip = createTextButton("RealUITutorialButtonSkip", UIParent)
	btnSkip:SetPoint("CENTER", parent, "CENTER", 0, -54)
	btnSkip:SetText(ButtonTexts.skip)
	btnSkip:RegisterForClicks("LeftButtonUp")
	btnSkip:SetScript("OnClick", function()
		rTB:Hide()
		rLogo:Hide()
		btnOpen:Hide()
		btnSkip:Hide()
		tBG:Hide()
		RealUIConfigBarToggle(true)
		nibRealUI.db.global.tutorial.stage = -1
	end)
	nibRealUI:AddButtonHighlight(btnSkip)
	
	local btnClose = createTextButton("RealUITutorialButtonClose", HelpPlate)
	btnClose:SetPoint("CENTER", parent, "CENTER", 0, 0)
	btnClose:SetText(ButtonTexts.finished)
	btnClose:SetAttribute("type", "macro")
	btnClose:SetAttribute("macrotext", "/clearfocus\n/cleartarget\n/run RealUIHideTutorial()")
	btnClose:Hide()
	nibRealUI:AddButtonHighlight(btnClose)
	
	-- Skin Buttons
	if Aurora then
		Aurora[1].Reskin(btnOpen)
		Aurora[1].Reskin(btnSkip)
		Aurora[1].Reskin(btnClose)
	end
end

function TestTutorial()
	if RealUITutorialButton then
		RealUITutorialLogo:Show()
		RealUITutorialButtonOpen:Show()
		RealUITutorialButtonSkip:Show()
		RealUITutorialBG:Show()
	else
		nibRealUI:InitTutorial()
	end
end