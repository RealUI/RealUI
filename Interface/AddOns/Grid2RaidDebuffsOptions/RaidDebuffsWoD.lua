local RDDB = Grid2Options:GetRaidDebuffsTable()
RDDB["Warlords of Draenor"] = {
	[994] = { -- Highmaul
		["Kargath Bladefist"] = {
		order = 1, ejid = 1128,
		158986, -- Berserker Rush
		159947, -- Chain Hurl
		162497, -- On the Hunt	
		159178, -- Open Wounds
		159213, -- Monster's Brawl
		159410, -- Mauling Brew
		159413, -- Mauling Brew
		160521, -- Vile Breath
		159386, -- Iron Bomb
		159188, -- Grapple
		159202, -- Flame Jet
		159311, -- Flame Jet		
		159113, -- Impale
		},
		["The Butcher"] = {
		order = 2, ejid = 971,
		156147, -- The Cleaver
		156151, -- The Tenderizer
		156152, -- Gushing Wounds
		163046, -- Pale Vitriol
		},
		["Tectus"] = {
		order = 3, ejid = 1195,
		162346, -- Crystalline Barrage
		162892, -- Petrification
		162370, -- Crystalline Barrage2
		},
		["Brackenspore"] = {
		order = 4, ejid = 1196,
		163241, -- Rot
		163242, -- Infesting Spores
		163590, -- Creeping Moss
		159220, -- Necrotic Breath
		160179, -- Mind Fungus
		159972, -- Flesh Eater
		},
		["Twin Ogron"] = {
		order = 5, ejid = 1148,
		167200, -- Arcane Wound
		158241, -- Blaze
		163372, -- Arcane Volatility
		158026, -- Enfeebling Roar
		155569, -- Injured
		159709, -- Weakened Defenses
		},
		["Ko'ragh"] = {
		order = 6, ejid = 1153,
		162186, -- Expel Magic: Arcane
		172813, -- Expel Magic: Frost
		162185, -- Expel Magic: Fire
		162184, -- Expel Magic: Shadow
		161345, -- Suppression Field
		161242, -- Caustic Energy
		163472, -- Dominating Power
		163134, -- Barrera anuladora
		172886, -- Marca anuladora
		},
		["Imperator Mar'gok"] = {
		order = 7, ejid = 1197,
		16400,  -- Poison
		156225, -- Branded
		164005, -- Branded: Fortification
		164006, -- Branded: Replication
		164004, -- Branded: Displacement
		158605, -- Mark of Chaos
		164176, -- Mark of Chaos: Displacement
		164178, -- Mark of Chaos: Fortification
		164191, -- Mark of Chaos: Replication
		159200, -- Destructive Resonance
		157353, -- Force Nova
		158619, -- Fetter
		174106, -- Destructive Resonance
		157801, -- Slow
		157763, -- Fixate
		158553, -- Crush Armor
		},
		["Trash"] = {
		order = 50,
		175601, -- Tainted Claws
		172069, -- Radiating Poison
		56037,  -- Rune of Destruction
		175654, -- Rune of Disintegration
		174446, -- Pulverize
		166185, -- Rending Slash
		166171, -- Intimidating Roar
		166175, -- Earthdevastating Slam
		174404, -- Frozen Core
		173827, -- Wild Flames
		174500, -- Rending Throw
		166200, -- Arcane Volatility
		175599, -- Devour
		174961, -- Time Stop
		174452, -- Pulverized
		166779, -- Staggering Blow
		175614, -- Chaos Blast
		161635, -- Molten Bomb
		174473, -- Corrupted Blood
		174475, -- Corrupted Blood
		174405, -- Nucleo helado
		172066, -- Veneno radiante
		175636, -- Runa de destruccion
		175816, -- Alma de vacio
		},
	},
	[988] = { -- Fundición Roca Negra 
		["Gruul"] = {
		order = 1, ejid = 1161,
		155078, -- Golpes sobrecogedores
		155323, -- Embate petrificador
		155506, -- Petrificado
		162322, -- Golpe de inferno
		155080, -- Tajo infernal
		173192, -- Derrumbamiento
		},
		["Oregorger"] = {
		order = 2, ejid = 1202,
		173471, -- Fauces ácidas
		156297, -- Torrente ácido
		156374, -- Fragmento explosivo
		},
		["Beastlord Darmac"] = {
		order = 3, ejid = 1122,
		154960, -- Inmovilizado
		154981, -- Conflagración
		155061, -- Desgarrar y rasgar
		155030, -- Carne chamuscada
		155236, -- Machacar armadura
		154989, -- Aliento infernal
		156824, -- Pira infernal
		155499, -- Metralla sobrecalentada
		156823, -- Chatarra sobrecalentada
		155657, -- Infusión de llamas
		},
		["Flamebender Ka'graz"] = {
		order = 4, ejid = 1123,
		154932, -- Torrente de magma
		163284, -- Llamas crecientes
		154952, -- Fijar
		},
		["Hans'gar and Franzok"] = {
		order = 5, ejid = 1155,
		157139, -- Vértebras destrozadas
		157853, -- Réplica
		155818, -- Quemaduras agostadoras
		161570, -- Placas abrasadoras
		},
		["Operator Thogar"] = {
		order = 6, ejid = 1147,
		155921, -- Incendiar
		155864, -- Prototipo de granada de pulso
		159481, -- Bomba de asedio tardía
		164380, -- Ardiendo
		155701, -- Tajo dentado
		},
		["The Blast Furnace"] = {
		order = 7, ejid = 1154,
		155196, -- Fijar
		155192, -- Bomba
		176121, -- Fuego volátil
		175104, -- Fundir armadura
		155242, -- Calor
		158246, -- Sangre caliente
		156934, -- Ruptura
		156932, -- Ruptura
		155743, -- Charco de escoria
		},
		["Kromog"] = {
		order = 8, ejid = 1162,
		156766, -- Armadura alabeada
		},
		["The Iron Maidens"] = {
		order = 9, ejid = 1203,
		156626, -- Fuego rápido
		164271, -- Disparo penetrante
		156214, -- Sombras convulsivas
		156007, -- Empalar
		158315, -- Cacería oscura
		157950, -- Buscacorazones empapado de sangre
		},
		["Blackhand"] = {
		order = 10, ejid = 959,
		157000, -- Adherir bombas de escoria
		156096, -- Marcado para morir
		},
		["Trash"] = {
		order = 50, ejid = nil,
		175987, -- Pinchar herida
		159632, -- Apetito insaciable
		159520, -- Carga devastadora
		159939, -- Fauceácida
		162508, -- Embate con escudo
		162516, -- Acero giratorio
		162672, -- Flagelo sangriento
		162663, -- Tormenta eléctrica
		162748, -- Disparo de dispersión
		162761, -- Trampa de hielo
		174773, -- Vapores de combustión
		160260, -- Bomba de Fuego
		160109, -- Intimidación
		163126, -- Capón
		177891, -- Patada ascendente ardiente
		177855, -- Ascuas en el viento
		175765, -- Machaque aereo
		175752, -- Aliento de escoria
		175603, -- Escoria atenazante
		156345, -- Ignicion
		175624, -- Heridas mortalmente graves
		},
	},
	[1026] = {
		["Hellfire Assault"] = {
		order = 1, ejid = 1426,
		184243, -- Slam
		185806, -- Conducted Shock Pulse
		184379, -- Howling Axe
		184238, -- Cower (movement)
		180022, -- Bore (frontal cone damage)
		185157, -- Burn (cone dot)
		180079, -- Felfire Munitions (carrying, dot)		
		},
		["Iron Reaver"] = {
		order = 2, ejid = 1425,		
		182001, -- Orbe inestable
		182074, -- Inmolation
		179897, -- Blitz (carry, silence, not dispellable)
		182022, -- Pounding
		182280, -- Artillery
		182003, -- Fuel Streak (movement)		
		},
		["Kormrok"] = {
		order = 3, ejid = 1392,
		181306, -- Explosive Burst	
		181321, -- Fel Touch
		180244, -- Pound
		187819, -- Crush
		188081, -- Crush (dot)
		181345, -- Foul Crush (tank dot)
		186559, -- Fiery Pool (standing in pool)
		185519, -- Fiery Globule (dot)
		181082, -- Shadowy Pool (standing in pool)
		180270, -- Shadow Globule (dot)
		186560, -- Foul Pool (standing in pool)
		185521, -- Foul Globule (dot)		
		},
		["Hellfire High Council"] = {
		order = 4, ejid = 1432,
		184450, -- Mark of the Necromancer (dot, dispellable)
		184358, -- Fel Rage (aggro target)
		184355, -- Bloodboil (dot, stacks)
		184847, -- Acidic Wound (tank dot, stacks)
		184357, -- Tainted Blood (debuff, stacks)
		184652, -- Reap (standing in puddle?)		
		},
		["Kilrogg Deadeye"] = {
		order = 5, ejid = 1396,	
		180372, -- Heart Seeker
		182159, -- Fel Corruption
		180200, -- Shredded Armor
		180224, -- Death Throes
		},
		["Gorefiend"] = {
		order = 6, ejid = 1372,
		179864, -- Shadow of Death
		179978, -- Touch of Doom
		179909, -- Shared Fate
		180148, -- Hunger for Life
		},
		["Shadow-Lord Iskar"] = {
		order = 7, ejid = 1433,
		179202,  -- Eye of Anzu
		181956,  -- Phantasmal Winds
		182323,  -- Phantasmal Wounds
		182173,  -- Fel Chakram
		181753,  -- Fel Bomb
		185747,  -- Fel Beam Fixate
		182600,  -- Fel Fire
		179218,  -- Phantasmal Obliteration
		185239,  -- Radiance-of-anzu
		},
		["Socrethar the Eternal"] = {
		order = 8, ejid = 1427,	
		182038, -- Shattered Defenses
		182635, -- Reverberating Blow
		184239, -- Shadow Word Agony
		136913, -- Overwhelming Power
		184124, -- Gift of the Man'ari
		182769, -- Ghastly Fixation		
		},
		["Fel Lord Zakuun"] = {
		order = 9, ejid = 1391,	
		181508, -- Seed of destruction
		189260, -- Cloven Soul		
		179711, -- Befouled
		182008, -- Latent Energy
		179620, -- Fel Crystal
		189030, -- BEFOULEDRED
		189031, -- BEFOULEDORANGE
		189032, -- BEFOULEDGREEN		
		},
		["Xhul'horac"] = {
		order = 10, ejid = 1447,	
		186490, -- Chains of Fel
		186546, -- Black Hole
		186407, -- Fel Surge
		186073, -- Felsinged
		186134, -- Feltouched
		185656, -- Shadowfel Annihilation		
		186333, -- Void Surge
		186063, -- Wasting Void
		186135, -- Voidtouched		
		186448, -- Felblaze Flurry		
		},
		["Tyrant Velhari"] = {
		order = 11, ejid = 1394,
		180166, -- Touch of Harm
		180128, -- Edict of Condemnation
		179999, -- Seal of decay
		180300, -- Infernal tempest
		180526, -- Font of corruption
		180533, -- Tainted Shadows
		180569, -- Tainted Shadows
		180604, -- Despoiled Ground		
		},
		["Mannoroth"] = {
		order = 12, ejid = 1395,
		181099, -- Mark of Doom
		181597, -- Mannoroth's Gaze	
		181359, -- Massive Blast	
		184252, -- Puncture Wound	
		181116, -- Doom Spike
		181275, -- Curse of the Legion
		186362, -- Wrath of Gul'dan
		186350, -- Gripping Shadows		
		181841, -- Shadowforce
		182088, -- Empowered Shadowforce		
		},
		["Archimonde"] = {
		order = 13, ejid = 1438,
		189891, -- Nether Tear
		186952, -- Nether Banish		
		185590, -- Desecrate
		183864, -- Shadow Blast
		183828, -- Death Brand
		184931, -- Shackled Torment		
		182879, -- Doomfire Fixate
		183586, -- Doomfire
		186123, -- Wrought Chaos		
		183634, -- Shadowfel Burst
		187047, -- Devour Life
		185014, -- Focused Chaos		
		190341, -- Nether Corruption
		183963, -- Light of the Naaru
		189895, -- Void Star Fixate
		187255, -- Nether Storm		
		},
		["Trash"] = {
		order = 50, ejid = nil,
		184621, -- Hellfire Blast
		184587, -- Touch of Mortality		
		},
	},
	-- world bosses
	[949] = { -- Gorgrond
		["Drov the Ruiner"] = {
		ejid = 1291,
		175915, -- Acid Breath
		},
		["Tarlna the Ageless"] = {
		ejid = 1211,
		176004, -- Savage Vines
		}
	},
	[948] = { -- Spires of Arak
		["Rukhmar"] = {
		ejid = 1262,
		167615, -- Pierced Armor
		}
	},
	-- 5 man Instances
	[987] = { -- Puerto de Hierro 
		["Nok'Gar"] = {
		order = 1, ejid = 1235,
		164837, -- Vapuleo salvaje
		164504, -- Intimidado
		},
		["Makogg Hojascuas"] = {
		order = 2, ejid = 1236,
		163390, -- Trampas de ogro
		163740, -- Sangre corrupta
		163276, -- Tendones desgarrados
		},
		["Oshir"] = {
		order = 3, ejid = 1237,
		},
		["Skulloc"] = {
		order = 4, ejid = 1238,
		168398, -- Fijación de objetivo de Fuego rápido
		168227, -- Machaque gronn
		},
		["Trash"] = {
		order = 100, ejid = nil,
		172771, -- Proyectil incendiario
		169341, -- Rugido desmoralizador
		167240, -- Disparo en la pierna
		172889, -- Carga con tajo
		173113, -- Lanzamiento de hachuela
		173307, -- Lanza dentada
		158341, -- Heridas sangrantes
		},
	},
	[989] = { -- Trecho Celestial 
		["Ranjit"] = {
		order = 1, ejid = 965,
		153757, -- Abanico de hojas
		153759, -- Muro de viento
		154043, -- Destello luminoso
		153139, -- Cuatro vientos
		},
		["Araknath"] = {
		order = 2, ejid = 966,
		154150, -- Energizar
		},
		["Rukhran"] = {
		order = 3, ejid = 967,
		176544, -- Fijar
		160149, -- Débil
		},
		["Trash"] = {
		order = 100, ejid = nil,
		153123, -- Cuchilla giratoria
		156841, -- Tormenta
		153907, -- Derviche
		160288, -- Detonación solar
		152982, -- Exponer debilidad
		152838, -- Fijado
		153001, -- Quemar
		152999, -- Quemar
		160303, -- Detonación solar
		},
	},
	[1008] = { -- El Vergel Eterno 
		["Cortezamustia"] = {
		order = 1, ejid = 1214,
		164294, -- Crecimiento descontrolado
		},
		["Ancianos protectores"] = {
		order = 2, ejid = 1207,
		167977, -- Zona de zarzas
		169658, -- Heridas infectadas
		168187, -- Carga desgarradora
		},
		["Archimaga Sol"] = {
		order = 3, ejid = 1208,
		166492, -- Flor de fuego
		168894, -- Bola de Fuego
		170016, -- Polen Focoluz
		166726, -- Lluvia helada
		},
		["Xeri'tac"] = {
		order = 4, ejid = 1209,
		173080, -- Fijar
		169376, -- Picadura venenosa
		169223, -- Gas tóxico
		},
		["Yalnu"] = {
		order = 5, ejid = 1210,
		169179, -- Arremetida colosal
		170132, -- Enredo
		169879, -- Aliento nocivo
		169876, -- Desgarre de tendón
		},
		["Trash"] = {
		order = 100, ejid = nil,
		169823, -- Bola de Fuego
		169840, -- Descarga de Escarcha
		169844, -- Aliento de dragón
		169824, -- Descarga de Escarcha
		169850, -- Ola gélida
		169839, -- Bola de Fuego
		164886, -- Toxina de horripétalo
		164834, -- Tromba de hojas
		164965, -- Vides asfixiantes
		},
	},
	[995] = { -- Cumbre de Roca Negra Superior 
		["Gor'ashan"] = {
		order = 1, ejid = 1226,
		},
		["Kyrak"] = {
		order = 2, ejid = 1227,
		162600, -- Ungüento de emanaciones tóxicas
		},
		["Comandante Tharbek"] = {
		order = 3, ejid = 1228,
		161772, -- Aliento incinerador
		161765, -- Hacha de hierro
		155589, -- Nova de Escarcha
		},
		["Alaíra el Indomable"] = {
		order = 4, ejid = 1229,
		155056, -- Fuego envolvente
		155065, -- Garra destripadora
		},
		["Señora de la guerra Zaela"] = {
		order = 5, ejid = 1234,
		155721, -- Ciclón Hierro Umbrío
		},
		["Son of the Beast"] = {
		order = 50, ejid = nil,
		157428, -- Rugido aterrorizador
		},
		["Trash"] = {
		order = 100, ejid = nil,
		1604, -- Atontado
		153832, -- Devastar
		153897, -- Tajo desgarrador
		153981, -- Obús incendiario
		155037, -- Erupción
		155586, -- Velo de Sombras
		155581, -- Hender armadura
		167259, -- Grito intimidador
		155572, -- Machaque
		154827, -- Rugido intimidatorio
		163057, -- Choque de llamas
		165944, -- Machaque devastador
		165954, -- Ola de choque
		},
	},
	[984] = { -- Auchindoun 
		["Vigilante Kaathar"] = {
		order = 1, ejid = 1185,
		153430, -- Suelo santificado
		},
		["Vinculadora de almas Nyami"] = {
		order = 2, ejid = 1186,
		154477, -- Palabra de las Sombras: dolor
		154218, -- Martillo de mediador
		},
		["Azzakel"] = {
		order = 3, ejid = 1216,
		153234, -- Látigo vil
		153396, -- Cortina de llamas
		},
		["Teron'gor"] = {
		order = 4, ejid = 1225,
		156964, -- Inmolar
		156960, -- Conflagrar
		},
		["Trash"] = {
		order = 100, ejid = nil,
		157165, -- Cortar tendón
		157170, -- Abrasamiento mental
		176511, -- Escudo de vengador
		157797, -- Martillo de mediador
		154852, -- Martillo de celador
		154263, -- Cadena del celador
		157168, -- Fijar
		156954, -- Aflicción inestable
		157052, -- Corrupción
		156854, -- Drenar vida
		156856, -- Lluvia de Fuego
		},
	},
	[993] = { -- Terminal Malavía 
		["Chispahete y Borka"] = {
		order = 1, ejid = 1138,
		162507, -- Adquiriendo objetivos
		162491, -- Adquiriendo objetivos
		},
		["Nitrogg Torre del Trueno"] = {
		order = 2, ejid = 1163,
		166570, -- Carga de escoria
		160681, -- Fuego supresivo
		},
		["Señora del Cielo Tovra"] = {
		order = 3, ejid = 1133,
		162057, -- Lanza giratoria
		163447, -- Marca del cazador
		161588, -- Energía difusa
		162065, -- Cepo congelante
		},
		["Trash"] = {
		order = 100, ejid = nil,
		164192, -- 50 000 voltios
		176025, -- Espiral de lava
		176033, -- Lengua de Fuego
		164218, -- Tajo doble
		176147, -- Ignición
		164241, -- Heridas hemorrágicas
		166340, -- Zona de trueno
		},
	},
	[964] = { -- Minas Machacasangre 
		["Magmolatus"] = {
		order = 1, ejid = 893,
		150011, -- Tromba de magma
		149941, -- Machaque duro
		149975, -- Llamas bailarinas
		150032, -- Llamas fulminantes
		150023, -- Machaque de escoria
		},
		["Vigilante de esclavos Crushto"] = {
		order = 2, ejid = 888,
		153679, -- Aplastamiento terráqueo
		150751, -- Salto aplastante
		150807, -- Golpe traumático
		151092, -- Golpe traumático
		},
		["Roltall"] = {
		order = 3, ejid = 887,
		167739, -- Aura agostadora
		152897, -- Ola de calor
		153227, -- Escoria ardiente
		},
		["Gug'rokk"] = {
		order = 4, ejid = 889,
		163802, -- Sacudida de llamas
		164616, -- Canalizar llamas
		150784, -- Erupción de magma
		},
		["Trash"] = {
		order = 100, ejid = nil,
		151415, -- Aplastar
		151446, -- Machaque
		152089, -- Boleadora eléctrica
		151638, -- Campo de anulación
		151697, -- Subyugar
		152235, -- Rugido atemorizador
		151685, -- Abolladura de armadura
		151720, -- Arco de lava
		1604, -- Atontado
		151566, -- Vínculo de magma
		},
	},
	[969] = { -- Cementerio de Sombraluna 
		["Nhallish"] = {
		order = 2, ejid = 1168,
		153070, -- Devastación del vacío
		153501, -- Explosión del Vacío
		156776, -- Látigo del vacío sajador
		152819, -- Palabra de las Sombras: flaqueza
		},
		["Ner'zhul"] = {
		order = 4, ejid = 1160,
		154442, -- Malevolencia
		154469, -- Ritual de huesos
		},
		["Trash"] = {
		order = 100, ejid = nil,
		1604, -- Atontado
		153524, -- Flema de peste
		},
	},
}
