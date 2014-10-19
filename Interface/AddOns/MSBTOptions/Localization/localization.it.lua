-------------------------------------------------------------------------------
-- Title: MSBT Options Italian Localization
-- Author: Mikord
-- Italian Translation by: Kelhar@Runetotem-EU
-------------------------------------------------------------------------------

-- Don't do anything if the locale isn't Italian.
if (GetLocale() ~= "itIT") then return end

-- Local reference for faster access.
local L = MikSBT.translations

-------------------------------------------------------------------------------
-- Italian Localization
-------------------------------------------------------------------------------


------------------------------
-- Interface messages
------------------------------

L.MSG_CUSTOM_FONTS					= "Carattere Personalizzato"
L.MSG_INVALID_CUSTOM_FONT_NAME		= "Nome invalido per il carattere."
L.MSG_FONT_NAME_ALREADY_EXISTS		= "Nome esistente per il Carattere."
L.MSG_INVALID_CUSTOM_FONT_PATH		= "Il percorso del Carattere deve puntare ad un file .ttf."
L.MSG_UNABLE_TO_SET_FONT			= "Impossibile impostare il Carattere specificato."
--L.MSG_TESTING_FONT			= "Testing the specified font for validity..."
L.MSG_CUSTOM_SOUNDS					= "Suono Personalizzato"
L.MSG_INVALID_CUSTOM_SOUND_NAME		= "Nome invalido per il suono."
L.MSG_SOUND_NAME_ALREADY_EXISTS		= "Nome esistente per il Suono."
L.MSG_NEW_PROFILE					= "Nuovo Profilo"
L.MSG_PROFILE_ALREADY_EXISTS		= "Nome esistente per il profilo."
L.MSG_INVALID_PROFILE_NAME			= "Nome invalido per il profilo."
L.MSG_NEW_SCROLL_AREA				= "Nuova area di scorrimento"
L.MSG_SCROLL_AREA_ALREADY_EXISTS	= "Nome esistente per l'area di scorrimento."
L.MSG_INVALID_SCROLL_AREA_NAME		= "Nome invalido per l'area di scorrimento."
L.MSG_ACKNOWLEDGE_TEXT				= "Sei sicuro di voler eseguire questa operazione?"
L.MSG_NORMAL_PREVIEW_TEXT			= "Normale"
L.MSG_INVALID_SOUND_FILE			= "Il suono deve essere un file .ogg."
L.MSG_NEW_TRIGGER					= "Nuovo Innesco"
L.MSG_TRIGGER_CLASSES				= "Innesco Classi"
L.MSG_MAIN_EVENTS					= "Evento Principale"
L.MSG_TRIGGER_EXCEPTIONS			= "Innesco Eccezioni"
L.MSG_EVENT_CONDITIONS				= "Condizioni Evento"
L.MSG_DISPLAY_QUALITY				= "Mostra avvisi per oggetti di questa qualita'."
L.MSG_SKILLS						= "Abilita'"
L.MSG_SKILL_ALREADY_EXISTS			= "Nome esistente per l'abilita'."
L.MSG_INVALID_SKILL_NAME			= "Nome per l'abilita' invalido."
L.MSG_HOSTILE						= "Ostile"
L.MSG_ANY							= "Qualsiasi"
L.MSG_CONDITION						= "Condizione"
L.MSG_CONDITIONS					= "Condizioni"
L.MSG_ITEM_QUALITIES				= "Qualita' oggetti"
L.MSG_ITEMS							= "Oggetti"
L.MSG_ITEM_ALREADY_EXISTS			= "Nome esistente per l'oggetto."
L.MSG_INVALID_ITEM_NAME				= "Nome invalido per l'oggetto."


------------------------------
-- Interface tabs
------------------------------

obj = L.TABS
obj["customMedia"]	= { label="Supporti Personalizzati", tooltip="Mostra le opzioni per gestire i supporti personalizzati."}
obj["general"]		= { label="Generale", tooltip="Mostra le opzioni generali."}
obj["scrollAreas"]	= { label="Aree di scorrimento", tooltip="Mostra le opzioni per creare, cancellare e configurare le aree di scorrimento.\n\nPorta il m sopra un cottone per maggiori informazioni."}
obj["events"]		= { label="Eventi", tooltip="Mostra le opzioni per 'in arrivo', 'in uscita' e la notifica di eventi.\n\nPorta il m sopra un cottone per maggiori informazioni."}
obj["triggers"]		= { label="Innceschi", tooltip="Mostra le opzioni per il sistema di inneschi.\n\nPorta il m sopra un cottone per maggiori informazioni."}
obj["spamControl"]	= { label="Controllo Spam", tooltip="Mostra le opzioni per controllare lo spam."}
obj["cooldowns"]	= { label="Cooldowns", tooltip="Mostra le opzioni per le notifiche dei cooldown."}
obj["lootAlerts"]	= { label="Avvisi bottino", tooltip="Mostra le opzioni per le notifiche inerenti al bottino."}
obj["skillIcons"]	= { label="Icone Abilita'", tooltip="Mostra le opzioni per le icone delle abilita'."}


------------------------------
-- Interface checkboxes
------------------------------

obj = L.CHECKBOXES
obj["enableMSBT"]				= { label="Abilita Mik's Scrolling Battle Text", tooltip="Abilita MSBT."}
obj["stickyCrits"]				= { label="Critici Sticky", tooltip="Mostra i critici usando lo stile sticky."}
obj["enableSounds"]				= { label="Attiva Suoni", tooltip="Esegue suoni che sono assegnati agli eventi e inneschi."}
obj["textShadowing"]			= { label="Ombreggiatura Testo", tooltip="Applica un effetto ombreggiatura al testo per migliorarlo."}
obj["colorPartialEffects"]		= { label="Colore Effetti Parziali", tooltip="Applica i colori specificati agli effetti parziali."}
obj["crushing"]					= { label="Colpi Devastanti", tooltip="Mostra la coda per i Colpi Devastanti."}
obj["glancing"]					= { label="Colpi Schivati", tooltip="Mostra la coda per i colpi schivati."}
obj["absorb"]					= { label="Assorbimenti Parziali", tooltip="Mostra l'ammontare dell'assorbimento parziale."}
obj["block"]					= { label="Blocchi Parziali", tooltip="Mostra l'ammontare dei blocchi parziali."}
obj["resist"]					= { label="Resistenze Parziali", tooltip="Mostra l'ammontare delle resistenze parziali."}
obj["vulnerability"]			= { label="Bonus Vulnerabilita'", tooltip="Mostra l'ammontare dei bonus di vulnerabilita'."}
obj["overheal"]					= { label="Sovracure", tooltip="Mostra l'ammontare delle Sovracure."}
obj["overkill"]					= { label="Massacro", tooltip="Mostra l'ammontare di Massacro."}
obj["colorDamageAmounts"]		= { label="Colore Ammontare Danno", tooltip="Applica i colori specificati per l'ammontare dei danni."}
obj["colorDamageEntry"]			= { tooltip="Abilita la colorazione di questo tipo di danni."}
obj["colorUnitNames"]			= { label="Colore Nomi Unita'", tooltip="Applica i colori specificati ai nomi delle unita'."}
obj["colorClassEntry"]			= { tooltip="Abilita la colorazione per le classi."}
obj["enableScrollArea"]			= { tooltip="Abilita le aree di scorrimento."}
obj["inheritField"]				= { label="Eredita", tooltip="Eredita il valore del campo. Deselezionare per sovrascrivere."}
obj["hideSkillIcons"]			= { label="Nascondi Icone", tooltip="Non mostrare le icone per quest'area di scorrimento."}
obj["stickyEvent"]				= { label="Sempre Sticky", tooltip="Mostra sempre gli eventi con lo stile sticky."}
obj["enableTrigger"]			= { tooltip="Abilita gli inneschi."}
obj["allPowerGains"]			= { label="TUTTI i guadagni di potere", tooltip="Mostra tutti i guadagni di potere inclusi quelli non supportati dal registro di combattimento.\n\nATTENZIONE: NON RACCOMANDATA."}
obj["abbreviateSkills"]			= { label="Abbrevia Abilita'", tooltip="Abbrevia il nome delle abilita' (Solo Inglese).\n\nQueste abbreviazioni possono essere sovrascritte da ogni evento con il codice %sl."}
obj["mergeSwings"]				= { label="Unifica Sferzate", tooltip="Unifica sferzate regolaari che colpiscono in un breve periodo."}
--obj["shortenNumbers"]			= { label="Shorten Numbers", tooltip="Display numbers in an abbreviated format (example: 32765 -> 33k)."}
--obj["groupNumbers"]				= { label="Group By Thousands", tooltip="Display numbers grouped by thousands (example: 32765 -> 32,765)."}
obj["hideSkills"]				= { label="Nascondi Abilita'", tooltip="Non mostrare i nomi delle abilita' per 'in attivo' e 'in uscita'.\n\nNon usera' alcune personalizzationi a livello di compatibilita' se scegli questa opzione perche' causa l'evento %s di venir ignorato."}
obj["hideNames"]				= { label="Nascondi Nomi", tooltip="Non mostrare i nomi per 'in attivo' e 'in uscita'.\n\nNon usera' alcune personalizzationi a livello di compatibilita' se scegli questa opzione perche' causa l'evento %s di venir ignorato."}
obj["hideFullOverheals"]		= { label="Nascondi Intere Sovracure", tooltip="Non mostrare le cure non periodiche che hanno come effettiva cura un ammontare pari a zero."}
obj["hideFullHoTOverheals"]		= { label="Nascondi Intere CaT Sovracuranti", tooltip="Non mostrare le cure a tempo che hanno come cura effettiva un ammontare pari a zero."}
obj["hideMergeTrailer"]			= { label="Nascondi Unione Code", tooltip="Non mostrare le code che specificano il numeo di colpi e critici alla fine di un evento unificato."}
obj["allClasses"]				= { label="Tutte le Classi"}
obj["enablePlayerCooldowns"]	= { label="Cooldowns dei Giocatori", tooltip="Mostra le notifiche quando un tuo cooldowns e' completo."}
obj["enablePetCooldowns"]		= { label="Cooldowns dei Famigli", tooltip="Mostra le notifiche quando un cooldowns del tuo famiglio e' completo."}
obj["enableItemCooldowns"]		= { label="Cooldowns degli Oggetti", tooltip="Mostra le notifiche quando il cooldowns di un tuo oggetto e' completo."}
obj["lootedItems"]				= { label="Oggetti Raccolti", tooltip="Mostra le notifiche quando un oggetto e' raccolto."}
obj["moneyGains"]				= { label="Guadagno Monete", tooltip="Attiva la raccolta soldi."}
obj["alwaysShowQuestItems"]		= { label="Mostra sempre oggetti missione", tooltip="Mostra sempre gli oggetti di missione senza badare alla qualita'."}
obj["enableIcons"]				= { label="Abilita Icone Abilita'", tooltip="Mostra le icone per gli eventi che hanno una icona quando possibile."}
obj["exclusiveSkills"]			= { label="Nomi Abilita' Esclusive", tooltip="Mostra solo i nomi dell'abilita' quando una icona non e' disponibile."}


------------------------------
-- Interface dropdowns
------------------------------

obj = L.DROPDOWNS
obj["profile"]				= { label="Profilo Corrente:", tooltip="Imposta il profilo corrente."}
obj["normalFont"]			= { label="Carattere Normale:", tooltip="Imposta il carattere usato per i non critici."}
obj["critFont"]				= { label="Carattere Critici:", tooltip="Imposta il carattere usato per i critici."}
obj["normalOutline"]		= { label="Traccia Normale:", tooltip="Imposta lo stile di traccia per i non critici."}
obj["critOutline"]			= { label="Traccia Critici:", tooltip="Imposta lo stile di traccia per i critici."}
obj["scrollArea"]			= { label="Area di Scorrimento:", tooltip="Seleziona l'area di scorrimento da configurare."}
obj["sound"]				= { label="Souni:", tooltip="Seleziona il suono da eseguire quando avviene un evento."}
obj["animationStyle"]		= { label="Stile Animazione:", tooltip="Lo stile d'animazione per i non-sticky nell'area di scorrimento."}
obj["stickyAnimationStyle"]	= { label="Stile Sticky:", tooltip="Lo stile d'animazione per l'animazione sticky nell'area di scorrimento."}
obj["direction"]			= { label="Direzione:", tooltip="La direzione dell'animazione."}
obj["behavior"]				= { label="Comportamento:", tooltip="Il comportamento dell'animazione."}
obj["textAlign"]			= { label="Allineamento del testo:", tooltip="L'allineamento del testo per le animazioni."}
obj["iconAlign"]			= { label="Allineamento Icona:", tooltip="L'allineamento per l'icona dell'abilita' relativa al testo."}
obj["eventCategory"]		= { label="Categoria Evento:", tooltip="La categoria dell'evento da impostare."}
obj["outputScrollArea"]		= { label="Area di scorrimento 'in uscita':", tooltip="Seleziona l'area di scorrimento per 'in uscita'."}
obj["mainEvent"]			= { label="Evento Principale:"}
obj["triggerCondition"]		= { label="Condizione:", tooltip="La condizione da provare."}
obj["triggerRelation"]		= { label="Relazione:"}
obj["triggerParameter"]		= { label="Parametro:"}


------------------------------
-- Interface buttons
------------------------------

obj = L.BUTTONS
obj["addCustomFont"]			= { label="Aggiungi Carattere", tooltip="Aggiunge un carattere personalizzato alla lista di quelli disponibili.\n\nATTENZIONE: Il carattere deve esistere *PRIMA* che WoW venga eseguito.\n\nE' ampiamente raccomandato di posizionare tale file in MikScrollingBattleText\\Fonts per evitare qualsiasi problema."}
obj["addCustomSound"]			= { label="Aggiungi Suono", tooltip="Aggiunge un suono personalizzato alla lista di quelli disponibili.\n\nATTENZIONE: Il suono deve esistere *PRIMA* che WoW venga eseguito.\n\nE' ampiamente raccomandato di posizionare tale file in MikScrollingBattleText\\Sounds per evitare qualsiasi problema."}
obj["editCustomFont"]			= { tooltip="Premere per modificare il carattere personalizzato."}
obj["deleteCustomFont"]			= { tooltip="Premere per rimuovere il carattere personalizato da MSBT."}
obj["editCustomSound"]			= { tooltip="Premere per modificare il suono personalizzato."}
obj["deleteCustomSound"]		= { tooltip="Premere per rimuovere il suono personalizzato da MSBT."}
obj["copyProfile"]				= { label="Copia Profilo", tooltip="Copia il profilo su un nuovo profilo con il nome specificato."}
obj["resetProfile"]				= { label="Reimposta Profilo", tooltip="Reimposta il profilo alle impostazioni di base."}
obj["deleteProfile"]			= { label="Cancella Profilo", tooltip="Cancella il profilo."}
obj["masterFont"]				= { label="Carattere Principale", tooltip="Permette di impostare il carattere principale che le impostazioni erediteranno in tutte le aree di scorrimento e gli eventi al loro interno."}
obj["partialEffects"]			= { label="Effetti Parziali", tooltip="Permette di impostare quali effetti parziali verranno mostrati, se hanno colori codificati, e in quale colore."}
obj["damageColors"]				= { label="Colori Danno", tooltip="Permette di impostare se le quantita' sono colorate com tipo di danno e quale colore usare per ogni tipo."}
obj["classColors"]				= { label="Colori Classe", tooltip="Permette di impostare se i nomi delle unita' sono colorate dalla classe e che colore usare per ogni classe." }
obj["inputOkay"]				= { label="OK", tooltip="Accetta l'immissione."}
obj["inputCancel"]				= { label="ANNULLA", tooltip="Annulla l'immissione."}
obj["genericSave"]				= { label="SALVA", tooltip="Salva i cambiamenti."}
obj["genericCancel"]			= { label="ANNULLA", tooltip="Annulla i cambiamenti."}
obj["addScrollArea"]			= { label="Aggiungi Area di Scorrimento", tooltip="Aggiungi una nuova area di scorrimento a cui assegnare eventi ed inneschiposso."}
obj["configScrollAreas"]		= { label="Imposta Aree di Scorrimento", tooltip="Imposta gli stili di animazione normali e sticky, allineamneto testo, altezza/spessore scorrimento e posizione delle aree."}
obj["editScrollAreaName"]		= { tooltip="Premere per modificare il nome dell'area."}
obj["scrollAreaFontSettings"]	= { tooltip="Premere per editare il carattere per l'area che verra' ereditato da tutti gli eventi mostrati in quest'area."}
obj["deleteScrollArea"]			= { tooltip="Premere per cancellare l'area."}
obj["scrollAreasPreview"]		= { label="Anteprima", tooltip="Visiona i cambiamenti."}
obj["toggleAll"]				= { label="Abilita Tutto", tooltip="Abilita lo stato attivo per tutti gli eventi nella categoria selezionata."}
obj["moveAll"]					= { label="Sposta Tutto", tooltip="Muovi tutti gli eventi nella categoria selezionata dell'area specificata."}
obj["eventFontSettings"]		= { tooltip="Premere per modificare le impostazioni dei caratteri per l'evento."}
obj["eventSettings"]			= { tooltip="Premere per editare le impostazioni come l'area 'in uscita', suoni, etc."}
obj["customSound"]				= { tooltip="Premere per inserire un file sonoro personalizzato." }
obj["playSound"]				= { label="Esegui", tooltip="Premere per eseguire il file selezionato."}
obj["addTrigger"]				= { label="Aggiungi Nuovo Innesco", tooltip="Aggiungi un nuovo innesco."}
obj["triggerSettings"]			= { tooltip="Premere per configurare le condizioni dell'innesco."}
obj["deleteTrigger"]			= { tooltip="Premere per cancellare l'innesco."}
obj["editTriggerClasses"]		= { tooltip="Premere per modificare le classi a cui si applica l'innesco."}
obj["addMainEvent"]				= { label="Aggiungi Evento", tooltip=" Quando uno QUALSIASI di questi eventi accade e la loro condizione e' vera, l'innesco si attiva finche uno delle eccezioni specificate e' vera."}
obj["addTriggerException"]		= { label="Aggiungi Eccezione", tooltip="Quando una QUALSIASI di queste eccezioni e' vera, l'innesco non si attiva."}
obj["editEventConditions"]		= { tooltip="Premere per modificare le condizioni dell'evento"}
obj["deleteMainEvent"]			= { tooltip="Premere per cancellare l'evento."}
obj["addEventCondition"]		= { label="Aggiungi Condizione", tooltip="Quando TUTTE queste condizioni sono vere per l'evento selezionato, l'innesco si attiva finche una eccezione specificata e' vera."}
obj["editCondition"]			= { tooltip="Premere per modificare la condizione."}
obj["deleteCondition"]			= { tooltip="Premere per cancellare la condizione."}
obj["throttleList"]				= { label="Lista di Aggregazione", tooltip="Imposta un numero personalizzato di raggruppamento per i tick (ES: invece di avere Fontana di Mana ripetuto 5 volte con i 5 tick si avra' un solo avviso con il totale dei 5 tick)."}
obj["mergeExclusions"]			= { label="Unifica Esclusioni", tooltip="Previene che le abilita' specificate vengano unificate."}
obj["skillSuppressions"]		= { label="Soppressione Abilita'", tooltip="Sopprime le abilita' basato sui nomi."}
obj["skillSubstitutions"]		= { label="Sostituzione Abilita'", tooltip="Sostituisce i nomi delle abilita' con un valore personalizzato."}
obj["addSkill"]					= { label="Aggiungi Abilita'", tooltip="Aggiunge una nuova abilita'."}
obj["deleteSkill"]				= { tooltip="Premere per cancellare l'abilita'."}
obj["cooldownExclusions"]		= { label="Esclusione Cooldown", tooltip="Specifica le abilita' di cui verra' ignorato il tracciamento del cooldown."}
obj["itemsAllowed"]				= { label="Oggetti Permessi", tooltip="Mostra sempre gli oggetti specificati senza badare alla qualita'."}
obj["itemExclusions"]			= { label="Esclusione Oggetti", tooltip="Previene che gli oggetti specificati vengano mostrati."}
obj["addItem"]					= { label="Aggiungi Oggetto", tooltip="Aggiungi un nuovo oggetto alla lista."}
obj["deleteItem"]				= { tooltip="Premere per cancellare l'oggetto."}


------------------------------
-- Interface editboxes
------------------------------

obj = L.EDITBOXES
obj["customFontName"]	= { label="Nome Carattere:", tooltip="Il nome usato epr identificare il carattere"}
obj["customFontPath"]	= { label="Percorso Carattere:", tooltip="Il percorso al file del carattere.\n\nNOTA: se il file e' nella cartella raccomandara MikScrollingBattleText\\Fonts, solo il nome del file necessita di essere inserito invece che l'intero percorso.\n\nEsempio: myFont.ttf "}
obj["customSoundName"]	= { label="Nome Suono:", tooltip="Il nome usato per identificare il suono"}
obj["customSoundPath"]	= { label="Percorso Suono:", tooltip="Il percorso al file del suono.\n\nNOTA: se il file e' nella cartella raccomandara MikScrollingBattleText\\Sounds, solo il nome del file necessita di essere inserito invece che l'intero percorso.\n\nEsempio: mySound.ogg"}
obj["copyProfile"]		= { label="Nome Nuovo Profilo:", tooltip="Nome del nuovo profilo in cui copiare l'attuale."}
obj["partialEffect"]	= { tooltip="La coda da aggiunger dopo che l'effetto parziale e' avvenuto."}
obj["scrollAreaName"]	= { label="Nome nuova area di scorrimento:", tooltip="Il nuovo nome per l'area di scorrimento."}
obj["xOffset"]			= { label="X Spostamento:", tooltip="Lo spotamento di X per l'area selezionata."}
obj["yOffset"]			= { label="Y Spostamento:", tooltip="Lo spotamento di Y per l'area selezionata."}
obj["eventMessage"]		= { label="Messaggio in Uscita:", tooltip="Il messaggio che comparira' quando avviene l'evento."}
obj["soundFile"]		= { label="Nome del file sonoro:", tooltip="Il nome del file sonoro da eseguire quando avviene l'evento."}
obj["iconSkill"]		= { label="Icona Abilita':", tooltip="Il nome o l'ID dell'abilita' di cui l'icona verra' mostrata quando avviene l'evento.\nMSBT cerchera' automaticamente di figurare l'appropriata icona se una non e' specificata.\nNOTA: Un ID deve essere usato al posto di un nome se l'abilita' non e' nel libro degli incantesimi per la classe che si sta giocando quando l'evento avviene. Molti database online come WoWHead si possono usare per scoprire l'ID."}
obj["skillName"]		= { label="Nome Abilita':", tooltip="Il nome dell'abilita' da aggiungere."}
obj["substitutionText"]	= { label="Testo sostitutivo:", tooltip="Il testo da sostituire al nome dell'abilita'."}
obj["itemName"]			= { label="Nome Oggetto:", tooltip="Il nome dell'oggetto da aggiungere."}


------------------------------
-- Interface sliders
------------------------------

obj = L.SLIDERS
obj["animationSpeed"]		= { label="Velocita' Animazione", tooltip="Imposta la veocita' dell'animazione principale.\nOgni area di scorrimento puo' essere impostata indipendentemente."}
obj["normalFontSize"]		= { label="Dimensione Normale", tooltip="Imposta la dimensione del carattere per i non critici."}
obj["normalFontOpacity"]	= { label="Opacita' Normale", tooltip="Importa l'opacita' del carattere per i non critici."}
obj["critFontSize"]			= { label="Dimensione Carattere Critici", tooltip="Imposta la dimensione del carattere per i critici."}
obj["critFontOpacity"]		= { label="Opacita' Critici", tooltip="Imposta l'opacita' del carattere per i critici."}
obj["scrollHeight"]			= { label="Altezza Scorrimento", tooltip="L'altezza dell'area di scorrimento."}
obj["scrollWidth"]			= { label="Larghezza Scorrimento", tooltip="La larghezza dell'area di scorrimento."}
obj["scrollAnimationSpeed"]	= { label="Velocità Animazione", tooltip="Imposta la velocita' di animazione per l'area di scorrimento."}
obj["powerThreshold"]		= { label="Limite Potere", tooltip="Il limite che i guadagni di potere devono superare per essere mostrati."}
obj["healThreshold"]		= { label="Limite Cure", tooltip="Il limite che le cure devono superare per essere mostrate."}
obj["damageThreshold"]		= { label="Limite Danno", tooltip="Il limite che il danno deve superare per essere mostrato."}
obj["dotThrottleTime"]		= { label="Tempo Aggregazione DaT", tooltip="Il numero di secondi prima di aggregare i DaT."}
obj["hotThrottleTime"]		= { label="Tempo Aggregazione CaT", tooltip="Il numero di secondi prima di aggregare le CaT."}
obj["powerThrottleTime"]	= { label="Tempo Aggregazione Potre", tooltip="Il numero di secondi prima di aggregare i cambi di potere."}
obj["skillThrottleTime"]	= { label="Tempo Aggregazione", tooltip="Il numero di secondi per aggregare le abilita'."}
obj["cooldownThreshold"]	= { label="Limite Ripresa", tooltip="Abilita' che hanno una ripresa inferiore al numero di secondi specificato non saranno mostrate."}


------------------------------
-- Event categories
------------------------------
obj = L.EVENT_CATEGORIES
obj[1] = "Giocatore 'in entrata'"
obj[2] = "Famiglio 'in entrata'"
obj[3] = "Giocatore 'in uscita'"
obj[4] = "Fafmiglio 'in uscita'"
obj[5] = "Notifiche"


------------------------------
-- Event codes
------------------------------

obj = L.EVENT_CODES
obj["DAMAGE_TAKEN"]			= "%a - Ammontare di Danni subiti.\n"
obj["HEALING_TAKEN"]		= "%a - Ammontare di Cure subite.\n"
obj["DAMAGE_DONE"]			= "%a - Ammontare di Danni inflitti.\n"
obj["HEALING_DONE"]			= "%a - Ammontare di Cure imposte.\n"
obj["ABSORBED_AMOUNT"]		= "%a - Ammontare di danni assorbiti.\n"
obj["AURA_AMOUNT"]			= "%a - Ammontare di quantita' per l'aura.\n"
obj["ENERGY_AMOUNT"]		= "%a - Ammontare di Energia.\n"
--obj["CHI_AMOUNT"]			= "%a - Amount of chi you have.\n"
obj["CP_AMOUNT"]			= "%a - Ammontare di Punti Combinazione che hai.\n"
obj["HOLY_POWER_AMOUNT"]	= "%a - Ammontare di Potere Divino che hai.\n"
--obj["SHADOW_ORBS_AMOUNT"]	= "%a - Amount of shadow orbs you have.\n"
obj["HONOR_AMOUNT"]			= "%a - Ammontare di onore.\n"
obj["REP_AMOUNT"]			= "%a - Ammontare di reputazione.\n"
obj["ITEM_AMOUNT"]			= "%a - Ammontare di oggetti predati.\n"
obj["SKILL_AMOUNT"]			= "%a - Ammontare di punti in un'abilita'.\n"
obj["EXPERIENCE_AMOUNT"]	= "%a - Ammontare di esperienza guadagnata.\n"
obj["PARTIAL_AMOUNT"]		= "%a - Ammontare di effetti parziali.\n"
obj["ATTACKER_NAME"]		= "%n - Nome dell'attaccante.\n"
obj["HEALER_NAME"]			= "%n - Nome del curatore.\n"
obj["ATTACKED_NAME"]		= "%n - Nome dell'unita' attaccata.\n"
obj["HEALED_NAME"]			= "%n - Nome dell'unita' curata.\n"
obj["BUFFED_NAME"]			= "%n - Nome dell'unita' mogliorata.\n"
obj["UNIT_KILLED"]			= "%n - Nome dell'unita' uccisa.\n"
obj["SKILL_NAME"]			= "%s - Nome dell'abilita'.\n"
obj["SPELL_NAME"]			= "%s - Nome dell'incantesimo.\n"
obj["DEBUFF_NAME"]			= "%s - Nome della penalita'.\n"
obj["BUFF_NAME"]			= "%s - Nome del miglioramento.\n"
obj["ITEM_BUFF_NAME"]		= "%s - Nome del miglioramento per l'oggetto.\n"
obj["EXTRA_ATTACKS"]		= "%s - Nome dell'abilita' che carantgisce attacchi extra.\n"
obj["SKILL_LONG"]			= "%sl - Forma lunga per %s. Usata per sovrascrivere le abbreviazioni per gli eventi.\n"
obj["DAMAGE_TYPE_TAKEN"]	= "%t - Tipo di danno subito.\n"
obj["DAMAGE_TYPE_DONE"]		= "%t - Tipo di danno inflitto.\n"
obj["ENVIRONMENTAL_DAMAGE"]	= "%e - Nome della sorgente dei danni (caduta, affogamento, lava, etc...)\n"
obj["FACTION_NAME"]			= "%e - Nome della fazione.\n"
obj["EMOTE_TEXT"]			= "%e - Il testo dell'emote.\n"
obj["MONEY_TEXT"]			= "%e - Testo delle monete guadagnate.\n"
obj["COOLDOWN_NAME"]		= "%e - Il nome dell'abilita' che e' pronta.\n"
obj["ITEM_COOLDOWN_NAME"]	= "%e - Il nome dell'oggetto che e' pronto.\n"
obj["ITEM_NAME"]			= "%e - Il nome dell'oggetto predato.\n"
obj["POWER_TYPE"]			= "%p - Il tipo di potere (energia, rabbia, mana).\n"
obj["TOTAL_ITEMS"]			= "%t - Il numero totale degli oggetti predati nell'inventario."


------------------------------
-- Incoming events
------------------------------

obj = L.INCOMING_PLAYER_EVENTS
obj["INCOMING_DAMAGE"]						= { label="Corpo a Corpo Colpi", tooltip="Abilita colpi 'in entrata' per Corpo a Corpo."}
obj["INCOMING_DAMAGE_CRIT"]					= { label="Corpo a Corpo Critici", tooltip="Abilita critici 'in entrata' per Corpo a Corpo."}
obj["INCOMING_MISS"]						= { label="Corpo a Corpo Mancati", tooltip="Abilita mancati 'in entrata' per Corpo a Corpo."}
obj["INCOMING_DODGE"]						= { label="Corpo a Corpo Schivati", tooltip="Abilita scivati 'in entrata' per Corpo a Corpo."}
obj["INCOMING_PARRY"]						= { label="Corpo a Corpo Parati", tooltip="Abilita parati 'in entrata' per Corpo a Corpo."}
obj["INCOMING_BLOCK"]						= { label="Corpo a Corpo Bloccati", tooltip="Abilita bloccati 'in entrata' per Corpo a Corpo."}
obj["INCOMING_DEFLECT"]						= { label="Corpo a Corpo Deflessi", tooltip="Abilita deflessi 'in entrata' per Corpo a Corpo."}
obj["INCOMING_ABSORB"]						= { label="Corpo a Corpo Assorbiti", tooltip="Abilita danni assorbiti 'in entrata' per Corpo a Corpo."}
obj["INCOMING_IMMUNE"]						= { label="Corpo a Corpo Ammuni", tooltip="Abilita immunita' ai danni 'in entrata' per Corpo a Corpo."}
obj["INCOMING_SPELL_DAMAGE"]				= { label="Abilita' Colpi", tooltip="Abilita colpi 'in entrata' per Abilita'."}
obj["INCOMING_SPELL_DAMAGE_CRIT"]			= { label="Abilita' Critici", tooltip="Abilita critici 'in entrata' per Abilita'."}
obj["INCOMING_SPELL_DOT"]					= { label="Abilita' DaT", tooltip="Abilita danno a tempo 'in entrata' per Abilita'."}
obj["INCOMING_SPELL_DOT_CRIT"]				= { label="Abilita' DaT Critici", tooltip="Abilita danni a tempo critici 'in entrata' per Abilita'."}
obj["INCOMING_SPELL_DAMAGE_SHIELD"]			= { label="Scudo Danno Colpi", tooltip="Abilita danni 'in entrata' infarti dagli scudi dannosi."}
obj["INCOMING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Scudo Danno Critici", tooltip="Abilita critici 'in entrata' inferti dagli scudi dannosi."}
obj["INCOMING_SPELL_MISS"]					= { label="Abilita' Mancati", tooltip="Abilita mancati 'in entrata' per Abilita'."}
obj["INCOMING_SPELL_DODGE"]					= { label="Abilita' Schivati", tooltip="Abilita schivate 'in entrata' per Abilita'."}
obj["INCOMING_SPELL_PARRY"]					= { label="Abilita' Parati", tooltip="Abilita parate 'in entrata' per Abilita'."}
obj["INCOMING_SPELL_BLOCK"]					= { label="Abilita' Bloccati", tooltip="Abilita blocchi 'in entrata' per Abilita'."}
obj["INCOMING_SPELL_DEFLECT"]				= { label="Abilita' Deflessi", tooltip="Abilita deflessioni 'in entrata' per Abilita'."}
obj["INCOMING_SPELL_RESIST"]				= { label="Incantesimi Resistiti", tooltip="Abilita resistenze 'in entrata' per Incantesimi."}
obj["INCOMING_SPELL_ABSORB"]				= { label="Abilita' Assorbiti", tooltip="Abiltia i danni assorbiti 'in entrata' Abilita'."}
obj["INCOMING_SPELL_IMMUNE"]				= { label="Abilita' Immuni", tooltip="Abilita immunita' 'in entrata' per Abilita'."}
obj["INCOMING_SPELL_REFLECT"]				= { label="Abilita' Riflesse", tooltip="Abilita danni riflessi 'in entrata' per Abilita'."}
obj["INCOMING_SPELL_INTERRUPT"]				= { label="Incantesimi Interrotti", tooltip="Abilita interruzioni 'in entrata' per Incantesimi."}
obj["INCOMING_HEAL"]						= { label="Cure", tooltip="Abilita Cure 'in entrata'."}
obj["INCOMING_HEAL_CRIT"]					= { label="Cure Critiche", tooltip="Abilita Critici per Cure 'in entrata'."}
obj["INCOMING_HOT"]							= { label="Cure a Tempo", tooltip="Abilita Cure a Tempo 'in entrata'."}
obj["INCOMING_HOT_CRIT"]					= { label="Cure a Tempo Critici", tooltip="Abilita Citici per cure a Tempo 'in entrata'."}
obj["INCOMING_ENVIRONMENTAL"]				= { label="Danni Ambientali", tooltip="Abilita danni ambientali (caduta, affogamento, lava, etc...)."}

obj = L.INCOMING_PET_EVENTS
obj["PET_INCOMING_DAMAGE"]						= { label="Corpo a Corpo Colpi", tooltip="(Famiglio) Abiita colpi 'in entrata' per Corpo a Corpo."}
obj["PET_INCOMING_DAMAGE_CRIT"]					= { label="Corpo a Corpo Critici", tooltip="(Famiglio) Abiita critici 'in entrata' per Corpo a Corpo."}
obj["PET_INCOMING_MISS"]						= { label="Corpo a Corpo Mancati", tooltip="(Famiglio) Abiita mancati 'in entrata' per Corpo a Corpo."}
obj["PET_INCOMING_DODGE"]						= { label="Corpo a Corpo Schivati", tooltip="(Famiglio) Abiita scivati 'in entrata' per Corpo a Corpo."}
obj["PET_INCOMING_PARRY"]						= { label="Corpo a Corpo Parati", tooltip="(Famiglio) Abiita parati 'in entrata' per Corpo a Corpo."}
obj["PET_INCOMING_BLOCK"]						= { label="Corpo a Corpo Bloccati", tooltip="(Famiglio) Abiita bloccati 'in entrata' per Corpo a Corpo."}
obj["PET_INCOMING_DEFLECT"]						= { label="Corpo a Corpo Deflessi", tooltip="(Famiglio) Abiita deflessi 'in entrata' per Corpo a Corpo."}
obj["PET_INCOMING_ABSORB"]						= { label="Corpo a Corpo Assorbiti", tooltip="(Famiglio) Abiita danni assorbiti 'in entrata' per Corpo a Corpo."}
obj["PET_INCOMING_IMMUNE"]						= { label="Corpo a Corpo Ammuni", tooltip="(Famiglio) Abiita immunita' ai danni 'in entrata' per Corpo a Corpo."}
obj["PET_INCOMING_SPELL_DAMAGE"]				= { label="Abiita' Colpi", tooltip="(Famiglio) Abiita colpi 'in entrata' per Abiita'."}
obj["PET_INCOMING_SPELL_DAMAGE_CRIT"]			= { label="Abilita' Critici", tooltip="(Famiglio) Abiita critici 'in entrata' per Abilita'."}
obj["PET_INCOMING_SPELL_DOT"]					= { label="Abilita' DaT", tooltip="(Famiglio) Abiita danno a tempo 'in entrata' per Abilita'."}
obj["PET_INCOMING_SPELL_DOT_CRIT"]				= { label="Abilita' DaT Critici", tooltip="(Famiglio) Abiita danni a tempo critici 'in entrata' per Abilita'."}
obj["PET_INCOMING_SPELL_DAMAGE_SHIELD"]			= { label="Scudo Danno Colpi", tooltip="(Famiglio) Abiita danni 'in entrata' infarti dagli scudi dannosi."}
obj["PET_INCOMING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Scudo Danno Critici", tooltip="(Famiglio) Abiita critici 'in entrata' inferti dagli scudi dannosi."}
obj["PET_INCOMING_SPELL_MISS"]					= { label="Abilita' Mancati", tooltip="(Famiglio) Abiita mancati 'in entrata' per Abilita'."}
obj["PET_INCOMING_SPELL_DODGE"]					= { label="Abilita' Schivati", tooltip="(Famiglio) Abiita schivate 'in entrata' per Abilita'."}
obj["PET_INCOMING_SPELL_PARRY"]					= { label="Abilita' Parati", tooltip="(Famiglio) Abiita parate 'in entrata' per Abilita'."}
obj["PET_INCOMING_SPELL_BLOCK"]					= { label="Abilita' Bloccati", tooltip="(Famiglio) Abiita blocchi 'in entrata' per Abilita'."}
obj["PET_INCOMING_SPELL_DEFLECT"]				= { label="Abilita' Deflessi", tooltip="(Famiglio) Abiita deflessioni 'in entrata' per Abilita'."}
obj["PET_INCOMING_SPELL_RESIST"]				= { label="Incantesimi Resistiti", tooltip="(Famiglio) Abiita resistenze 'in entrata' per Incantesimi."}
obj["PET_INCOMING_SPELL_ABSORB"]				= { label="Abilita' Assorbiti", tooltip="(Famiglio) Abiita i danni assorbiti 'in entrata' Abilita'."}
obj["PET_INCOMING_SPELL_IMMUNE"]				= { label="Abilita' Immuni", tooltip="(Famiglio) Abiita immunita' 'in entrata' per Abilita'."}
obj["PET_INCOMING_HEAL"]						= { label="Cure", tooltip="(Famiglio) Abiita Cure 'in entrata'."}
obj["PET_INCOMING_HEAL_CRIT"]					= { label="Cure Critiche", tooltip="(Famiglio) Abiita Critici per Cure 'in entrata'."}
obj["PET_INCOMING_HOT"]							= { label="Cure a Tempo", tooltip="(Famiglio) Abiita Cure a Tempo 'in entrata'."}
obj["PET_INCOMING_HOT_CRIT"]					= { label="Cure a Tempo Critici", tooltip="(Famiglio) Abiita Citici per cure a Tempo 'in entrata'."}


------------------------------
-- Outgoing events
------------------------------

obj = L.OUTGOING_PLAYER_EVENTS
obj["OUTGOING_DAMAGE"]						= { label="Corpo a Corpo Colpi", tooltip="Abilita colpi 'in uscita' per Corpo a Corpo."}
obj["OUTGOING_DAMAGE_CRIT"]					= { label="Corpo a Corpo Critici", tooltip="Abilita critici 'in uscita' per Corpo a Corpo."}
obj["OUTGOING_MISS"]						= { label="Corpo a Corpo Mancati", tooltip="Abilita mancati 'in uscita' per Corpo a Corpo."}
obj["OUTGOING_DODGE"]						= { label="Corpo a Corpo Schivati", tooltip="Abilita scivati 'in uscita' per Corpo a Corpo."}
obj["OUTGOING_PARRY"]						= { label="Corpo a Corpo Parati", tooltip="Abilita parati 'in uscita' per Corpo a Corpo."}
obj["OUTGOING_BLOCK"]						= { label="Corpo a Corpo Bloccati", tooltip="Abilita bloccati 'in uscita' per Corpo a Corpo."}
obj["OUTGOING_DEFLECT"]						= { label="Corpo a Corpo Deflessi", tooltip="Abilita deflessi 'in uscita' per Corpo a Corpo."}
obj["OUTGOING_ABSORB"]						= { label="Corpo a Corpo Assorbiti", tooltip="Abilita danni assorbiti 'in uscita' per Corpo a Corpo."}
obj["OUTGOING_IMMUNE"]						= { label="Corpo a Corpo Ammuni", tooltip="Abilita immunita' ai danni 'in uscita' per Corpo a Corpo."}
obj["OUTGOING_EVADE"]						= { label="Corpo a Corpo Evasi", tooltip="Abilita evasioni 'in uscita' per Corpo a Corpo."}
obj["OUTGOING_SPELL_DAMAGE"]				= { label="Abilita' Colpi", tooltip="Abilita colpi 'in uscita' per Abilita'."}
obj["OUTGOING_SPELL_DAMAGE_CRIT"]			= { label="Abilita' Critici", tooltip="Abilita critici 'in uscita' per Abilita'."}
obj["OUTGOING_SPELL_DOT"]					= { label="Abilita' DaT", tooltip="Abilita danno a tempo 'in uscita' per Abilita'."}
obj["OUTGOING_SPELL_DOT_CRIT"]				= { label="Abilita' DaT Critici", tooltip="Abilita danni a tempo critici 'in uscita' per Abilita'."}
obj["OUTGOING_SPELL_DAMAGE_SHIELD"]			= { label="Scudo Danno Colpi", tooltip="Abilita danni 'in uscita' infarti dagli scudi dannosi."}
obj["OUTGOING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Scudo Danno Critici", tooltip="Abilita critici 'in uscita' inferti dagli scudi dannosi."}
obj["OUTGOING_SPELL_MISS"]					= { label="Abilita' Mancati", tooltip="Abilita mancati 'in uscita' per Abilita'."}
obj["OUTGOING_SPELL_DODGE"]					= { label="Abilita' Schivati", tooltip="Abilita schivate 'in uscita' per Abilita'."}
obj["OUTGOING_SPELL_PARRY"]					= { label="Abilita' Parati", tooltip="Abilita parate 'in uscita' per Abilita'."}
obj["OUTGOING_SPELL_BLOCK"]					= { label="Abilita' Bloccati", tooltip="Abilita blocchi 'in uscita' per Abilita'."}
obj["OUTGOING_SPELL_DEFLECT"]				= { label="Abilita' Deflessi", tooltip="Abilita deflessioni 'in uscita' per Abilita'."}
obj["OUTGOING_SPELL_RESIST"]				= { label="Incantesimi Resistiti", tooltip="Abilita resistenze 'in uscita' per Incantesimi."}
obj["OUTGOING_SPELL_ABSORB"]				= { label="Abilita' Assorbiti", tooltip="Abiltia i danni assorbiti 'in uscita' Abilita'."}
obj["OUTGOING_SPELL_IMMUNE"]				= { label="Abilita' Immuni", tooltip="Abilita immunita' 'in uscita' per Abilita'."}
obj["OUTGOING_SPELL_REFLECT"]				= { label="Abilita' Riflesse", tooltip="Abilita danni riflessi 'in uscita' per Abilita'."}
obj["OUTGOING_SPELL_INTERRUPT"]				= { label="Incantesimi Interrotti", tooltip="Abilita interruzioni 'in uscita' per Incantesimi."}
obj["OUTGOING_SPELL_EVADE"]					= { label="Abilita' Evasioni", tooltip="Abilita evasioni 'in uscita' per Abilita'."}
obj["OUTGOING_HEAL"]						= { label="Cure", tooltip="Abilita Cure 'in uscita'."}
obj["OUTGOING_HEAL_CRIT"]					= { label="Cure Critiche", tooltip="Abilita Critici per Cure 'in uscita'."}
obj["OUTGOING_HOT"]							= { label="Cure a Tempo", tooltip="Abilita Cure a Tempo 'in uscita'."}
obj["OUTGOING_HOT_CRIT"]					= { label="Cure a Tempo Critici", tooltip="Abilita Citici per cure a Tempo 'in uscita'."}
obj["OUTGOING_DISPEL"]						= { label="Dissipazioni", tooltip="Abilita dissipazioni 'in uscita'."}

obj = L.OUTGOING_PET_EVENTS
obj["PET_OUTGOING_DAMAGE"]						= { label="Corpo a Corpo Colpi", tooltip="(Famiglio) Abiita colpi 'in uscita' per Corpo a Corpo."}
obj["PET_OUTGOING_DAMAGE_CRIT"]					= { label="Corpo a Corpo Critici", tooltip="(Famiglio) Abiita critici 'in uscita' per Corpo a Corpo."}
obj["PET_OUTGOING_MISS"]						= { label="Corpo a Corpo Mancati", tooltip="(Famiglio) Abiita mancati 'in uscita' per Corpo a Corpo."}
obj["PET_OUTGOING_DODGE"]						= { label="Corpo a Corpo Schivati", tooltip="(Famiglio) Abiita scivati 'in uscita' per Corpo a Corpo."}
obj["PET_OUTGOING_PARRY"]						= { label="Corpo a Corpo Parati", tooltip="(Famiglio) Abiita parati 'in uscita' per Corpo a Corpo."}
obj["PET_OUTGOING_BLOCK"]						= { label="Corpo a Corpo Bloccati", tooltip="(Famiglio) Abiita bloccati 'in uscita' per Corpo a Corpo."}
obj["PET_OUTGOING_DEFLECT"]						= { label="Corpo a Corpo Deflessi", tooltip="(Famiglio) Abiita deflessi 'in uscita' per Corpo a Corpo."}
obj["PET_OUTGOING_ABSORB"]						= { label="Corpo a Corpo Assorbiti", tooltip="(Famiglio) Abiita danni assorbiti 'in uscita' per Corpo a Corpo."}
obj["PET_OUTGOING_IMMUNE"]						= { label="Corpo a Corpo Ammuni", tooltip="(Famiglio) Abiita immunita' ai danni 'in uscita' per Corpo a Corpo."}
obj["PET_OUTGOING_EVADE"]						= { label="Corpo a Corpo Evasi", tooltip="(Famiglio) Abilita le evasioni 'in uscita' per Corpo a Corpo."}
obj["PET_OUTGOING_SPELL_DAMAGE"]				= { label="Abiita' Colpi", tooltip="(Famiglio) Abiita colpi 'in uscita' per Abiita'."}
obj["PET_OUTGOING_SPELL_DAMAGE_CRIT"]			= { label="Abilita' Critici", tooltip="(Famiglio) Abiita critici 'in uscita' per Abilita'."}
obj["PET_OUTGOING_SPELL_DOT"]					= { label="Abilita' DaT", tooltip="(Famiglio) Abiita danno a tempo 'in uscita' per Abilita'."}
obj["PET_OUTGOING_SPELL_DOT_CRIT"]				= { label="Abilita' DaT Critici", tooltip="(Famiglio) Abiita danni a tempo critici 'in uscita' per Abilita'."}
obj["PET_OUTGOING_SPELL_DAMAGE_SHIELD"]			= { label="Scudo Danno Colpi", tooltip="(Famiglio) Abiita danni 'in uscita' infarti dagli scudi dannosi."}
obj["PET_OUTGOING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Scudo Danno Critici", tooltip="(Famiglio) Abiita critici 'in uscita' inferti dagli scudi dannosi."}
obj["PET_OUTGOING_SPELL_MISS"]					= { label="Abilita' Mancati", tooltip="(Famiglio) Abiita mancati 'in uscita' per Abilita'."}
obj["PET_OUTGOING_SPELL_DODGE"]					= { label="Abilita' Schivati", tooltip="(Famiglio) Abiita schivate 'in uscita' per Abilita'."}
obj["PET_OUTGOING_SPELL_PARRY"]					= { label="Abilita' Parati", tooltip="(Famiglio) Abiita parate 'in uscita' per Abilita'."}
obj["PET_OUTGOING_SPELL_BLOCK"]					= { label="Abilita' Bloccati", tooltip="(Famiglio) Abiita blocchi 'in uscita' per Abilita'."}
obj["PET_OUTGOING_SPELL_DEFLECT"]				= { label="Abilita' Deflessi", tooltip="(Famiglio) Abiita deflessioni 'in uscita' per Abilita'."}
obj["PET_OUTGOING_SPELL_RESIST"]				= { label="Incantesimi Resistiti", tooltip="(Famiglio) Abiita resistenze 'in uscita' per Incantesimi."}
obj["PET_OUTGOING_SPELL_ABSORB"]				= { label="Abilita' Assorbiti", tooltip="(Famiglio) Abiita i danni assorbiti 'in uscita' Abilita'."}
obj["PET_OUTGOING_SPELL_IMMUNE"]				= { label="Abilita' Immuni", tooltip="(Famiglio) Abiita immunita' 'in uscita' per Abilita'."}
obj["PET_OUTGOING_SPELL_EVADE"]					= { label="Abilita' Evasioni", tooltip="(Famiglio) Abilita evasioni 'in uscita' per Abilita'."}
obj["PET_OUTGOING_HEAL"]						= { label="Cure", tooltip="(Famiglio) Abiita Cure 'in uscita'."}
obj["PET_OUTGOING_HEAL_CRIT"]					= { label="Cure Critiche", tooltip="(Famiglio) Abiita Critici per Cure 'in uscita'."}
obj["PET_OUTGOING_HOT"]							= { label="Cure a Tempo", tooltip="(Famiglio) Abiita Cure a Tempo 'in uscita'."}
obj["PET_OUTGOING_HOT_CRIT"]					= { label="Cure a Tempo Critici", tooltip="(Famiglio) Abiita Citici per cure a Tempo 'in uscita'."}
obj["PET_OUTGOING_DISPEL"]						= { label="Dispels", tooltip="Enable your pet's outgoing dispels."}


------------------------------
-- Notification events
------------------------------

obj = L.NOTIFICATION_EVENTS
obj["NOTIFICATION_DEBUFF"]				= { label="Penalita'", tooltip="Abilita le penalita' da cui sei afflitto."}
obj["NOTIFICATION_DEBUFF_STACK"]		= { label="Quantita' Penalita'", tooltip="Abilita la quantita' di una Penalita' di cui sei afflitto."}
obj["NOTIFICATION_BUFF"]				= { label="Miglioramenti", tooltip="Abilita i miglioramenti ricevuti."}
obj["NOTIFICATION_BUFF_STACK"]			= { label="Quantita' Miglioramenti", tooltip="Abilita la quantita' di un miglioramento che hai ricevuto."}
obj["NOTIFICATION_ITEM_BUFF"]			= { label="Miglioramenti Oggetti", tooltip="Abilita i miglioramneti ricevuti dai tuoi oggetti."}
obj["NOTIFICATION_DEBUFF_FADE"]			= { label="Dissipazione Penalita'", tooltip="Abilita la visione di una penalita' che si dissipa da te."}
obj["NOTIFICATION_BUFF_FADE"]			= { label="Dissipazione Miglioramento", tooltip="Abilita la visione di un miglioramento che si dissipa da te."}
obj["NOTIFICATION_ITEM_BUFF_FADE"]		= { label="Dissipazione Miglioramento Oggetto", tooltip="Abilita la visione di un miglioramento che si dissipa da un tuo oggetto."}
obj["NOTIFICATION_COMBAT_ENTER"]		= { label="Entri in Combattimento", tooltip="Abilita il messaggio di quando entri in combattimento."}
obj["NOTIFICATION_COMBAT_LEAVE"]		= { label="Lasci il Combattimento", tooltip="Abilita il messaggio di quando lasci un combattimento."}
obj["NOTIFICATION_POWER_GAIN"]			= { label="Guadagno Potere", tooltip="Abilita la visione di quando guadagni mana, rabbia o energia."}
obj["NOTIFICATION_POWER_LOSS"]			= { label="Perdita Potere", tooltip="Abilita la visione di quando perdi potere mana, rabbia, or energia per un prosciugamento."}
--obj["NOTIFICATION_ALT_POWER_GAIN"]		= { label="Alternate Power Gains", tooltip="Enable when you gain alternate power such as sound level on Atramedes."}
--obj["NOTIFICATION_ALT_POWER_LOSS"]		= { label="Alternate Power Losses", tooltip="Enable when you lose alternate power from drains."}
--obj["NOTIFICATION_CHI_CHANGE"]			= { label="Chi Changes", tooltip="Enable when you change chi."}
--obj["NOTIFICATION_CHI_FULL"]			= { label="Chi Full", tooltip="Enable when you attain full chi."}
obj["NOTIFICATION_CP_GAIN"]				= { label="Guadagno Punti Combinazione", tooltip="Abilita quando guadagni PC."}
obj["NOTIFICATION_CP_FULL"]				= { label="Punti Combinazione Pieni", tooltip="Abilita quando ottieni pieni PC."}
obj["NOTIFICATION_HOLY_POWER_CHANGE"]	= { label="Carica Potere Divino", tooltip="Abilita quando cambia il tuo potere divino."}
obj["NOTIFICATION_HOLY_POWER_FULL"]		= { label="Potere Divino Pieno", tooltip="Abilita quando il potere divino e' pieno (3 cariche)."}
--obj["NOTIFICATION_SHADOW_ORBS_CHANGE"]	= { label="Shadow Orb Changes", tooltip="Enable when you change shadow orbs."}
--obj["NOTIFICATION_SHADOW_ORBS_FULL"]	= { label="Shadow Orbs Full", tooltip="Enable when you attain full shadow orbs."}
obj["NOTIFICATION_HONOR_GAIN"]			= { label="Guadagno Onore", tooltip="Abilita quando guadagni onore."}
obj["NOTIFICATION_REP_GAIN"]			= { label="Guadagno Reputazione", tooltip="Abilita quando guadagni reputazione."}
obj["NOTIFICATION_REP_LOSS"]			= { label="Perdita Reputazione", tooltip="Abiltia quando perdi reputazione."}
obj["NOTIFICATION_SKILL_GAIN"]			= { label="Guadagno Abilita'", tooltip="Abilita quando guadagni punti abilita'."}
obj["NOTIFICATION_EXPERIENCE_GAIN"]		= { label="Guadagno Esperienza", tooltip="Abilita quando guadagni esperienza."}
obj["NOTIFICATION_PC_KILLING_BLOW"]		= { label="Colpo Mortale Giocatore", tooltip="Abilita quando sei tu ha infliggere il colpo mortale su un giocatore ostile."}
obj["NOTIFICATION_NPC_KILLING_BLOW"]	= { label="Colpo Mortale NPG", tooltip="Abilita quando sei tu a infliggere un colpo mortale ad un NPG."}
obj["NOTIFICATION_EXTRA_ATTACK"]		= { label="Attacchi Extra", tooltip="Abilita quando guadagni attacchi extra attraverso un abilita'."}
obj["NOTIFICATION_ENEMY_BUFF"]			= { label="Guadagno Miglioramenti Nemico", tooltip="Abilita quando un nemico guadagna un miglioramento."}
obj["NOTIFICATION_MONSTER_EMOTE"]		= { label="Emote Mostri", tooltip="Abiltia emote dal mostro selezionato al momento."}


------------------------------
-- Trigger info
------------------------------

-- Main events.
obj = L.TRIGGER_DATA
obj["SWING_DAMAGE"]				= "Sferzata Danno"
obj["RANGE_DAMAGE"]				= "Distanza Danno"
obj["SPELL_DAMAGE"]				= "Abilita' Danno"
obj["GENERIC_DAMAGE"]			= "Sferzata/Distanza/Abilita' Danno"
obj["SPELL_PERIODIC_DAMAGE"]	= "Danno Periodico (DaT)"
obj["DAMAGE_SHIELD"]			= "Danno Scudo"
obj["DAMAGE_SPLIT"]				= "Danno Diviso"
obj["ENVIRONMENTAL_DAMAGE"]		= "Danno Ambientali"
obj["SWING_MISSED"]				= "Sferzata Miss"
obj["RANGE_MISSED"]				= "Distanza Miss"
obj["SPELL_MISSED"]				= "Abilita' Miss"
obj["GENERIC_MISSED"]			= "Sferzata/Distanza/Abilita' Miss"
obj["SPELL_PERIODIC_MISSED"]	= "Abilita' Periodica Miss"
obj["SPELL_DISPEL_FAILED"]		= "Dissipazione Fallita"
obj["DAMAGE_SHIELD_MISSED"]		= "Scudo Danno Miss"
obj["SPELL_HEAL"]				= "Cura"
obj["SPELL_PERIODIC_HEAL"]		= "Cura Periodica (CaT)"
obj["SPELL_ENERGIZE"]			= "Guadagno Potere"
obj["SPELL_PERIODIC_ENERGIZE"]	= "Guadagno Periodico Potere"
obj["SPELL_DRAIN"]				= "Drenaggio Potere"
obj["SPELL_PERIODIC_DRAIN"]		= "Dreanggio Periodico Potere"
obj["SPELL_LEECH"]				= "Risuccio Potere"
obj["SPELL_PERIODIC_LEECH"]		= "Risuccio Periodico Potere"
obj["SPELL_INTERRUPT"]			= "Interruzione Abilita'"
obj["SPELL_AURA_APPLIED"]		= "Aura Applicata"
obj["SPELL_AURA_REMOVED"]		= "Aura Rimossa"
obj["SPELL_STOLEN"]				= "Aura Rubata"
obj["SPELL_DISPEL"]				= "Aura Dissolta"
obj["SPELL_AURA_REFRESH"]		= "Aura Ravvivata"
obj["SPELL_AURA_BROKEN_SPELL"]	= "Aura Spezzata"
obj["ENCHANT_APPLIED"]			= "Applicazione Incanto"
obj["ENCHANT_REMOVED"]			= "Rimozione Incanto"
obj["SPELL_CAST_START"]			= "Inizio Lancio"
obj["SPELL_CAST_SUCCESS"]		= "Lancio Riuscito"
obj["SPELL_CAST_FAILED"]		= "Fallimento di Lancio"
obj["SPELL_SUMMON"]				= "Evoca"
obj["SPELL_CREATE"]				= "Crea"
obj["PARTY_KILL"]				= "Colpo Mortale"
obj["UNIT_DIED"]				= "Unita' Morta"
obj["UNIT_DESTROYED"]			= "Unita' Distrutta"
obj["SPELL_EXTRA_ATTACKS"]		= "Attacco Extra"
obj["UNIT_HEALTH"]				= "Cambio Vita"
obj["UNIT_POWER"]				= "Cambio Potere"
obj["SKILL_COOLDOWN"]			= "Cooldown Giocatore Completo"
obj["PET_COOLDOWN"]				= "Cooldown Famiglio Completo"
obj["ITEM_COOLDOWN"]			= "Cooldown Oggetto Completo"
 
-- Main event conditions.
obj["sourceName"]				= "Nome Unita' Sorgente"
obj["sourceAffiliation"]		= "Affiliazione Unita' Sorgente"
obj["sourceReaction"]			= "Reazione Unita' Sorgente"
obj["sourceControl"]			= "Controllo Unita' Sorgente"
obj["sourceUnitType"]			= "Tipo Unita' Sorgente"
obj["recipientName"]			= "Nome Unita' Destinataria"
obj["recipientAffiliation"]		= "Affiliazione Unita' Destinataria"
obj["recipientReaction"]		= "Reazione Unita' Destinataria"
obj["recipientControl"]			= "Controllo Unita' Destinataria"
obj["recipientUnitType"]		= "Tipo Unita' Destinataria"
obj["skillID"]					= "ID Abilita'"
obj["skillName"]				= "Nome Abilita'"
obj["skillSchool"]				= "Scuola Abilita'"
obj["extraSkillID"]				= "ID Abilita' Extra"
obj["extraSkillName"]			= "Nome Abilita' Extra"
obj["extraSkillSchool"]			= "Scuola Abilita' Extra"
obj["amount"]					= "Ammontare"
obj["overkillAmount"]			= "Ammontare Massacro"
obj["damageType"]				= "Tipo Danno"
obj["resistAmount"]				= "Ammontare Resistito"
obj["blockAmount"]				= "Ammontare bloccato"
obj["absorbAmount"]				= "Ammontare Assorbito"
obj["isCrit"]					= "Critico"
obj["isGlancing"]				= "Colpo Deviato"
obj["isCrushing"]				= "Colpo Devastante"
obj["extraAmount"]				= "Ammontare Extra"
obj["missType"]					= "Tipo Mancanto"
obj["hazardType"]				= "Tipo Pericolo"
obj["powerType"]				= "Tipo Potere"
obj["auraType"]					= "Tipo Aura"
obj["threshold"]				= "Limite"
obj["unitID"]					= "ID Unita'"
obj["unitReaction"]				= "Reazione Unita'"
obj["itemID"]					= "ID Oggetto"
obj["itemName"]					= "Nome Oggetto"

-- Exception conditions.
obj["activeTalents"]			= "Talenti Attivi"
obj["buffActive"]				= "Benefici Attivi"
obj["buffInactive"]				= "Benefici Inattivi"
obj["currentCP"]				= "Punti Combinazione Correnti"
obj["currentPower"]				= "Potere Corrente"
obj["inCombat"]					= "In Combattimento"
obj["recentlyFired"]			= "Inneschi Recenti"
obj["trivialTarget"]			= "Bersaglio Facile"
obj["unavailableSkill"]			= "Abilita' non disponibile"
obj["warriorStance"]			= "Postura del Guerriero"
obj["zoneName"]					= "Nome Zona"
obj["zoneType"]					= "Tipo Zona"
 
-- Relationships.
obj["eq"]						= "E' UgualeIs A"
obj["ne"]						= "Non E' Uguale A"
obj["like"]						= "E' Come"
obj["unlike"]					= "Non E' Come"
obj["lt"]						= "E' Meno Di"
obj["gt"]						= "E' Piu' Di"
 
-- Affiliations.
obj["affiliationMine"]			= "Mio"
obj["affiliationParty"]			= "Membro Scorreria"
obj["affiliationRaid"]			= "Membro Incursione"
obj["affiliationOutsider"]		= "Straniero"
obj["affiliationTarget"]		= "Bersaglio"
obj["affiliationFocus"]			= FOCUS
obj["affiliationYou"]			= "TE"

-- Reactions.
obj["reactionFriendly"]			= "Amichevole"
obj["reactionNeutral"]			= "Neutrale"
obj["reactionHostile"]			= "Ostile"

-- Control types.
obj["controlServer"]			= "Server"
obj["controlHuman"]				= "Umano"

-- Unit types.
obj["unitTypePlayer"]			= "Giocatore" 
obj["unitTypeNPC"]				= "PNG"
obj["unitTypePet"]				= "Famiglio"
obj["unitTypeGuardian"]			= "Guardiano"
obj["unitTypeObject"]			= "Oggetto"

-- Aura types.
obj["auraTypeBuff"]				= "Miglioramento"
obj["auraTypeDebuff"]			= "Penalita'"

-- Zone types.
obj["zoneTypeArena"]			= "Arena"
obj["zoneTypePvP"]				= "Campo di Battaglia"
obj["zoneTypeParty"]			= "Istanza 5 uomini"
obj["zoneTypeRaid"]				= "Istanza d'Incursione"

-- Booleans
obj["booleanTrue"]				= "True"
obj["booleanFalse"]				= "False"


------------------------------
-- Font info
------------------------------

-- Font outlines.
obj = L.OUTLINES
obj[1] = "Nessuno"
obj[2] = "Sottile"
obj[3] = "Spesso"
obj[4] = "Monocromo"
obj[5] = "Monocromo + Sottile"
obj[6] = "Monocromo + Spesso"

-- Text aligns.
obj = L.TEXT_ALIGNS
obj[1] = "Sinistra"
obj[2] = "Centro"
obj[3] = "Destra"


------------------------------
-- Sound info
------------------------------

obj = L.SOUNDS
obj["MSBT Low Mana"]	= "MSBT Mana Basso"
obj["MSBT Low Health"]	= "MSBT Vita bassa"
obj["MSBT Cooldown"]	= "MSBT Cooldown"


------------------------------
-- Animation style info
------------------------------

-- Animation styles
obj = L.ANIMATION_STYLE_DATA
obj["Angled"]		= "Angolare"
obj["Horizontal"]	= "Orizzontale"
obj["Parabola"]		= "Parabola"
obj["Straight"]		= "Dritto"
obj["Static"]		= "Statico"
obj["Pow"]			= "Pow"

-- Animation style directions.
obj["Alternate"]	= "Alternato"
obj["Left"]			= "Sinistra"
obj["Right"]		= "Destra"
obj["Up"]			= "Su"
obj["Down"]			= "Giu'"

-- Animation style behaviors.
obj["AngleUp"]			= "Angolato Verso l'Alto"
obj["AngleDown"]		= "Angolato Verso il Basso"
obj["GrowUp"]			= "Crescita Verso l'Alto"
obj["GrowDown"]			= "Crescia Verso il Basso"
obj["CurvedLeft"]		= "Curvato a Sinistra"
obj["CurvedRight"]		= "Curvato a Destra"
obj["Jiggle"]			= "Oscillante"
obj["Normal"]			= "Normale"