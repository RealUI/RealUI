local _, private = ...

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L

if RealUI.locale == "esES" then

-- cf-localization: locale="esES", format="lua_additive_table", handle-unlocalized="comment"
L["ActionBars_ActionBarsDesc"] = "Modifica la posición y tamaño de las barras de acción."
L["ActionBars_Center"] = "Centro"
L["ActionBars_CenterDesc"] = "Ajusta la posición centrada de las tres barras de acción."
L["ActionBars_CenterOption"] = "%d centro - %d abajo"
L["ActionBars_EAB"] = "Botón de acción extra"
L["ActionBars_Move"] = "Mover"
L["ActionBars_MoveDesc"] = [=[
Marque para permitir que RealUI controle la posición del %s.]=]
L["ActionBars_Pet"] = "Barra de mascota"
L["ActionBars_ShowDoodads"] = "Mostrar Dooads"
L["ActionBars_ShowDoodadsDesc"] = "Mostrar Dooads para indicar la posicion de la mascota y las barras de estancia"
L["ActionBars_Sides"] = "Lados"
L["ActionBars_SidesDesc"] = "Ajustar la localización de las dos barras de acciones laterales"
L["ActionBars_SidesOption"] = "%d Izquierda - %d Derecha"
L["ActionBars_Stance"] = "Barra de estados"
L["Alert_CantOpenInCombat"] = "No se puede abrir la configuración de RealUI mientras estés en combate."
L["Alert_CombatLockdown"] = "Bloquear en combate"
--[[Translation missing --]]
--[[ L["Alert_WaitCombatLockdown"] = "Combat restrictions are active. The UI will be updated when out of combat."--]] 
L["Appearance_ButtonColor"] = "Color del botón"
L["Appearance_ClassColorHealth"] = "Colorear Salud por Clase"
L["Appearance_ClassColorNames"] = "Colorear Nombres por Clase"
L["Appearance_FrameColor"] = "Color del frame"
L["Appearance_HighRes"] = "Sube resolución"
L["Appearance_HighResDesc"] = "Esto dobla la actual scala del UI para hacer que los elementos de la interfaz sean más fáciles de ver.\\n\\nNota: Solo se recomienda cuando se utiliza una pantalla con una resolución vertical de 1440 px o más."
L["Appearance_ModScale"] = "Escalar Mod en la Interfaz de Usuario"
L["Appearance_ModScaleDesc"] = "Este cambio solo afecta a ciertos frames en este momento, pero eventualmente se usará para la Interfaz de Usuario entera.\\n\\n%s"
L["Appearance_Pixel"] = "Pixel perfecto"
L["Appearance_PixelDesc"] = "Establece la escala de la interfaz de usuario para que un píxel del juego coincida con los píxeles de la pantalla física."
L["Appearance_Skins"] = "Diseños"
L["Appearance_StripeOpacity"] = "Opacidad de la línea"
L["Appearance_UIScale"] = "Escalado Personalizado de la Interfaz de Usuario"
L["Appearance_UIScaleDesc"] = "Establece una escala de interfaz de usuario personalizada (% .2f -% .2f). Nota: los elementos de la interfaz de usuario pueden perder nitidez."
--[[Translation missing --]]
--[[ L["BindingsReminder"] = "Bindings Reminder"--]] 
--[[Translation missing --]]
--[[ L["BindingsReminderDesc"] = "Shows a visual reminder of what actions are bound to each key."--]] 
L["CastBars"] = "Barras de casteo"
L["CastBars_Bottom"] = "Debajo"
L["CastBars_BottomDesc"] = "El Nombre y la duración se muestran debajo de las barras de casteo."
L["CastBars_Inside"] = "Dentro"
L["CastBars_InsideDesc"] = "El nombre y la duración se muestran a la izquierda para el jugador y a la derecha para el objetivo."
--[[Translation missing --]]
--[[ L["Chat"] = "Chat"--]] 
--[[Translation missing --]]
--[[ L["Chat_ClassColor"] = "Class colored names"--]] 
--[[Translation missing --]]
--[[ L["Chat_ClassColorDesc"] = "Show player names in their class color."--]] 
L["Clock_CalenderInvites"] = "Invitaciones pendientes:"
L["Clock_Date"] = "Fecha"
L["Clock_ShowCalendar"] = "<Click> Abrir calendario"
L["Clock_ShowTimer"] = "<Alt+Click> Abre ajustes del reloj"
L["CombatFade"] = "Desvanecimiento en combate"
L["CombatFade_Desc"] = "Cambia automáticamente la opacidad de un frame basandose en el estado de combate, salud y estado del objetivo."
L["CombatFade_HarmTarget"] = "Objetivo atacable"
L["CombatFade_Hurt"] = "Herir"
L["CombatFade_InCombat"] = "En combate"
L["CombatFade_NoCombat"] = "Fuera de combate"
L["CombatFade_Target"] = "Objetivo seleccionado"
--[[Translation missing --]]
--[[ L["CombatText"] = "Combat Text"--]] 
--[[Translation missing --]]
--[[ L["CombatText_MergeHits"] = " [%d Hits]"--]] 
L["Control_AddonControl"] = "Controlar AddOn"
L["Control_Layout"] = "Controlar diseño"
L["Control_LayoutDesc"] = "Permite a RealUI controlar las opciones de diseño de %s."
L["Control_Position"] = "Controlar posición"
L["Control_PositionDesc"] = "Permite a RealUI controlar la posición de %s."
L["Currency_Cycle"] = "<Click> Abrir lista actual, <Alt+Click> Ciclo de moneda mostrada"
L["Currency_EraseData"] = "<Alt+Click>Borrar datos de caracteres resaltados"
L["Currency_TotalMoney"] = "Dinero total en el reino:"
L["Currency_UpdatedAbbr"] = "Act."
L["DoReloadUI"] = "Es necesario recargar el UI para que los cambios se hagan efectivos. ¿Recargar ahora?"
L["Fonts"] = "Fuentes"
L["Fonts_Chat"] = "Fuente del chat"
L["Fonts_ChatDesc"] = "Esta fuente se utiliza para la ventana de chat y ocasionalmente números."
--[[Translation missing --]]
--[[ L["Fonts_Crit"] = "Crit Font"--]] 
L["Fonts_Header"] = "Fuente del encabezado"
L["Fonts_HeaderDesc"] = "Esta fuente se utiliza principalmente para títulos y encabezados."
L["Fonts_Normal"] = "Fuente normal"
L["Fonts_NormalDesc"] = "Esta fuente se utiliza para la mayoría de la UI, como descripciones emegergentes, misiones y objetivos."
--[[Translation missing --]]
--[[ L["General_AnchorPoint"] = "Anchor Point"--]] 
L["General_Debug"] = "Depuración"
L["General_DebugDesc"] = "Proporciona información adicional de depuración"
L["General_Enabled"] = "Habilitado"
L["General_EnabledDesc"] = "Habilita/Deshabilita %s"
L["General_InvalidParent"] = "El marco principal establecido para %s no existe. Escriba /realadv y vaya a %s -> %s para establecer un nuevo padre."
L["General_Lock"] = "Bloqueado"
L["General_LockDesc"] = "Mover o bloquear la posición del cuadro."
L["General_NoteParent"] = "Para encontrar el nombre de un marco, escriba / fstack y desplace el mouse sobre el marco que desea adjuntar. Use ALT para ciclar el área resaltada en verde"
L["General_NoteReload"] = "Nota: será necesario recargar la UI (/rl) para que los cambios surtan efecto."
L["General_Position"] = "Posición"
L["General_Positions"] = "Posiciones"
L["General_Tristatefalse"] = "|cffff0000Ignorado|r - Único - Varios"
L["General_Tristatenil"] = "Ignorado - Único - |cff00ff00Varios|r"
L["General_Tristatetrue"] = "Ignorado - |cff00ff00Único|r - Varios"
L["General_XOffset"] = "Desplazamiento X"
L["General_XOffsetDesc"] = "Desplazamiento en la dirección X (horizontal) desde el punto de anclaje dado."
L["General_YOffset"] = "Desplazamiento Y"
L["General_YOffsetDesc"] = "Desplazamiento en dirección Y (vertical) desde el punto de anclaje dado."
L["GuildFriend_WhisperInvite"] = "<Click> Enviar susurro, <Alt+Click> %s"
L["HuD_AlertHuDChangeSize"] = "Cambiar el tamaño de HuD puede alterar las posiciones de algunos elementos, por lo tanto, se recomienda verificar las posiciones de los elementos de la UI una vez aplicados los cambios."
L["HuD_Height"] = "Alto"
L["HuD_Horizontal"] = "Horizontal"
L["HuD_ReverseBars"] = "Dirección de la barra inversa"
L["HuD_ShowElements"] = "Mostrar elementos de la UI"
L["HuD_Uninterruptible"] = "Ininterrumpible"
L["HuD_UseLarge"] = "Usar HuD grande"
L["HuD_UseLargeDesc"] = "Aumenta el tamaño de los elementos clave del HuD (Marcos de unidades, etc)."
L["HuD_Vertical"] = "Vertical"
L["HuD_VerticalDesc"] = "Ajusta la posición vertical de todo el HuD"
L["HuD_Width"] = "Ancho"
L["Infobar"] = "Barra de información"
--[[Translation missing --]]
--[[ L["Infobar_AllBlocks"] = "All Blocks"--]] 
L["Infobar_BlockGap"] = "Interespaciado"
L["Infobar_BlockGapDesc"] = "Cantidad de espacio entre cada bloque."
--[[Translation missing --]]
--[[ L["Infobar_CombatTooltips"] = "In Combat Tooltips"--]] 
--[[Translation missing --]]
--[[ L["Infobar_CombatTooltipsDesc"] = "Show tooltips while in combat."--]] 
--[[Translation missing --]]
--[[ L["Infobar_Desc"] = "LDB supported data display"--]] 
L["Infobar_ShowIcon"] = "Mostrar icono"
L["Infobar_ShowLabel"] = "Mostrar etiqueta"
L["Infobar_ShowStatusBar"] = "Mostrar barra de estado"
--[[Translation missing --]]
--[[ L["Infobar_ShowStatusBarDesc"] = "Show the progress watch status bars."--]] 
L["Install"] = "PULSE PARA INSTALAR"
--[[Translation missing --]]
--[[ L["Install_UseHighRes"] = "Enable high resolution scaling"--]] 
--[[Translation missing --]]
--[[ L["Install_UseHighResDec"] = "Set up RealUI using 2x UI Scaling so that UI elements are easier to see on a high resolution display."--]] 
--[[Translation missing --]]
--[[ L["Inventory"] = "Inventory"--]] 
--[[Translation missing --]]
--[[ L["Inventory_AddFilter"] = "Create a new filter bag"--]] 
--[[Translation missing --]]
--[[ L["Inventory_AddFilterDesc"] = "New filter bags cannot share a name with an existing one. They are not case sensitive."--]] 
--[[Translation missing --]]
--[[ L["Inventory_Duplicate"] = "A filter with this name already exists."--]] 
--[[Translation missing --]]
--[[ L["Inventory_MaxHeight"] = "Max Height"--]] 
--[[Translation missing --]]
--[[ L["Inventory_MaxHeightDesc"] = "The height at which Inventory will create a new column, as a percentage of screen height."--]] 
--[[Translation missing --]]
--[[ L["Inventory_Restack"] = "Re-stack Items"--]] 
--[[Translation missing --]]
--[[ L["Inventory_SellJunk"] = "Auto Sell Junk"--]] 
L["Layout_ApplyOOC"] = "El diseño cambiará cuando dejes de estar en combate."
L["Layout_DPSTank"] = "DPS/Tanque"
L["Layout_Healing"] = "Sanación"
L["Layout_Layout"] = "Diseño"
L["Layout_Link"] = "Diseño de los enlaces"
L["Layout_LinkDesc"] = "Utilice la misma configuración entre los diseños DPS / Tanque y Curación."
L["Misc_SpellAlertsDesc"] = "Modificar la posición y el tamaño de las alertas de hechizo."
--[[Translation missing --]]
--[[ L["Misc_SpellAlertsWidthDesc"] = "Adjust the distance between the left and right Spell Alert Overlays."--]] 
L["Patch_DoApply"] = "Se ha aplicado un parche, la interfaz de usuario debe volver a cargarse para que los cambios surtan efecto."
L["Patch_MiniPatch"] = "Mini parche RealUI"
--[[Translation missing --]]
--[[ L["Patch_UpdateAddonSettings"] = "The default settings for %s have been updated. Would you like to apply these changes?"--]] 
L["Progress"] = "Indicador de progreso"
L["Progress_Cycle"] = "<Alt+Click> Pantalla de ciclo"
L["Progress_OpenArt"] = "<Click> Abrir artefacto equipado"
L["Progress_OpenHonor"] = "<Click> Abrir talentos de honor"
L["Progress_OpenRep"] = "<Click> Abrir lista de facción"
L["Raid_30Width"] = "Ancho de 30 jugadores"
L["Raid_40Width"] = "Ancho de 40 jugadores"
L["Raid_HideRaidFilter"] = "Ocultar filtros de raid"
L["Raid_HideRaidFilterDesc"] = "Ocultar los filtros de grupo para el gestor de de frames de raid de Blizzard"
L["Raid_LargeGroup"] = "Grupos grandes"
L["Raid_LargeGroupDesc"] = "Usa grupos horizontales mientras estés en grupos grandes como bandas o campos de batalla."
L["Raid_ShowSolo"] = "Mostrar cuando estés solo"
L["Raid_SmallGroup"] = "Grupos pequeños"
L["Raid_SmallGroupDesc"] = "Usa grupos horizontales en pequeños grupos como mazmorras o arenas"
L["Reset_Confirm"] = "¿Estás seguro de que deseas reiniciar RealUI?"
L["Reset_SettingsLost"] = "Se perderán todos los ajustes del usuario."
L["Resource"] = "Recurso de clase"
L["Resource_Gap"] = "Espaciado"
L["Resource_GapDesc"] = "La distancia entre cada %s."
--[[Translation missing --]]
--[[ L["Resource_HeightDesc"] = "Adjust the height of the resource anchor."--]] 
L["Resource_HideUnused"] = "Esconder %s sin usar"
L["Resource_HideUnusedDesc"] = "Mostrar solo las %s que tienes."
L["Resource_Reverse"] = "Orientación inversa"
L["Resource_ReverseDesc"] = "Invertir la orientación de la pantalla %s."
--[[Translation missing --]]
--[[ L["Resource_WidthDesc"] = "Adjust the width of the resource anchor."--]] 
L["Slash_Profile"] = "|cFFBB0000¡El perfil de la CPU está habilitado!|r Para deshabilitarlo teclee: |cFF8080FF/cpuProfiling|r"
L["Slash_RealUI"] = "Escriba %s para configurar el estilo de la interfaz de usuario, las posiciones y la configuración."
L["Slash_Taint"] = "|cFFBB0000¡El log taint está habilitado!|r Para deshabilitarlo teclee: |cFF8080FF/taintLogging|r"
--[[Translation missing --]]
--[[ L["Spec_ChangeGear"] = "<Right+Click> Cycle equip sets, <Alt+Right+Click> Unassign equip set"--]] 
L["Spec_ChangeSpec"] = "<Click> Cambiar especialización, <Alt+Click> cambiar especialización de botín\\n<Right+Click> rotar conjuntos de equipo, <Alt+Right+Click> desasignar conjuntos de equipo"
L["Spec_Open"] = "<Click> Abre la ventana de talentos"
--[[Translation missing --]]
--[[ L["Spec_SpecChanger"] = "Spec Changer"--]] 
L["Start"] = "Iniciar"
L["Start_Config"] = "Configuración de RealUI"
L["Sys_AverageAbbr"] = "Med"
L["Sys_CurrentAbbr"] = "Act"
L["Sys_Stat"] = "Estadística"
L["Sys_SysInfo"] = "Información del sistema"
--[[Translation missing --]]
--[[ L["Tooltips"] = "Tooltips"--]] 
--[[Translation missing --]]
--[[ L["Tooltips_AtCursor"] = "At Cursor"--]] 
--[[Translation missing --]]
--[[ L["Tooltips_AtCursorDesc"] = "Position the tooltip at the cursor by default."--]] 
--[[Translation missing --]]
--[[ L["Tooltips_ShowIDs"] = "Show object IDs"--]] 
--[[Translation missing --]]
--[[ L["Tooltips_ShowRealm"] = "Show realm names"--]] 
--[[Translation missing --]]
--[[ L["Tooltips_ShowTitles"] = "Show player titles"--]] 
--[[Translation missing --]]
--[[ L["Tweaks_CooldownCount"] = "Cooldown Count"--]] 
--[[Translation missing --]]
--[[ L["Tweaks_CooldownCountDesc"] = "Modifies the countdown text on cooldown swipes"--]] 
L["Tweaks_UITweaks"] = "Ajustes de UI"
L["Tweaks_UITweaksDesc"] = "Pequeños ajustes funcionales para la interfaz de usuario predeterminada"
L["UnitFrames_AnchorWidth"] = "Anchura de anclaje"
L["UnitFrames_AnchorWidthDesc"] = "La cantidad de espacio entre el marco del jugador y el marco del objetivo."
L["UnitFrames_AnnounceChatDesc"] = "Canal de chat usado para los mensajes de abalorio."
L["UnitFrames_AnnounceTrink"] = "Mensajes de avalorio"
L["UnitFrames_AnnounceTrinkDesc"] = "Mostrar los mensajes de abalorio enemigos en el chat."
--[[Translation missing --]]
--[[ L["UnitFrames_BuffCount"] = "Buff Count"--]] 
--[[Translation missing --]]
--[[ L["UnitFrames_DebuffCount"] = "Debuff Count"--]] 
L["UnitFrames_Gap"] = "Interespaciado"
L["UnitFrames_GapDesc"] = "Distancia vertical entre cada unidad."
--[[Translation missing --]]
--[[ L["UnitFrames_ModifierKey"] = "Modifier Key"--]] 
L["UnitFrames_NPCAuras"] = "Mostrar auras de NPC"
--[[Translation missing --]]
--[[ L["UnitFrames_NPCAurasDesc"] = "Show Buffs/Debuffs cast by NPCs."--]] 
--[[Translation missing --]]
--[[ L["UnitFrames_PlayerAuras"] = "Show Player Auras"--]] 
--[[Translation missing --]]
--[[ L["UnitFrames_PlayerAurasDesc"] = "Show Buffs/Debuffs cast by you."--]] 
--[[Translation missing --]]
--[[ L["UnitFrames_SetFocus"] = "Click to set Focus"--]] 
--[[Translation missing --]]
--[[ L["UnitFrames_SetFocusDesc"] = "Set focus by click+modifier on a Unit Frame."--]] 
--[[Translation missing --]]
--[[ L["UnitFrames_Units"] = "Units"--]] 
L["Version"] = "Versión"
--[[Translation missing --]]
--[[ L["WorldMarker"] = "World Marker"--]] 
--[[Translation missing --]]
--[[ L["WorldMarker_Show"] = "Show the World Marker in..."--]] 
--[[Translation missing --]]
--[[ L["WorldMarkerDesc"] = "Quick access to World Markers"--]] 
-- cf-localization end
end
