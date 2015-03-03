local RDDB = Grid2Options:GetRaidDebuffsTable()

RDDB["The Lich King"] = {
	[604] = { -- Ciudadela de la Corona de Hielo 
		["Lord Marrowgar"] = {
		order = 1, ejid = nil,
		69065, -- Empalado
		},
		["Lady Deathwhisper"] = {
		order = 2, ejid = nil,
		71289, -- Subyugar mente
		71204, -- Toque de insignificancia
		71237, -- Maldición de sopor
		},
		["Gunship Battle"] = {
		order = 3, ejid = nil,
		69651, -- Golpe hiriente
		},
		["Deathbringer Saurfang"] = {
		order = 4, ejid = nil,
		72293, -- Marca del campeón caído
		72769, -- Aroma de sangre
		},
		["Festergut"] = {
		order = 5, ejid = nil,
		69290, -- Esporas contagiadas
		69248, -- Gas inmundo
		72219, -- Hinchazón gástrica
		69278, -- Espora de gas
		},
		["Rotface"] = {
		order = 6, ejid = nil,
		69674, -- Infección mutada
		69508, -- Pulverizador de babas
		30494, -- Moco pegajoso
		},
		["Professor Putricide"] = {
		order = 7, ejid = nil,
		70215, -- Hinchazón gaseosa
		72454, -- Peste mutada
		70341, -- Charco de baba
		70342, -- Charco de baba
		70911, -- Peste desatada
		69774, -- Moco pegajoso
		},
		["Blood Prince Council"] = {
		order = 8, ejid = nil,
		72999, -- Prisión de las Sombras
		71807, -- Chispas relumbrantes
		},
		["Blood-Queen Lana'thel"] = {
		order = 9, ejid = nil,
		70838, -- Espejo de sangre
		71623, -- Tajo delirante
		70949, -- Esencia de la Reina de Sangre
		72151, -- Sed de sangre frenética
		71340, -- Pacto de los Caído Oscuro
		72985, -- Sombras enjambradoras
		70923, -- Frenesí incontrolable
		},
		["Valithria Dreamwalker"] = {
		order = 10, ejid = nil,
		70873, -- Vigor esmeralda
		70744, -- Ráfaga de ácido
		70751, -- Corrosión
		70633, -- Pulverizador de tripas
		71941, -- Pesadillas retorcidas
		70766, -- Estado onírico
		},
		["Sindragosa"] = {
		order = 11, ejid = nil,
		70107, -- Escalofrío penetrante
		70106, -- Helado hasta los huesos
		69766, -- Inestabilidad
		71665, -- Asfixia
		70126, -- Señal de Escarcha
		70157, -- Tumba de hielo
		},
		["Lich King"] = {
		order = 12, ejid = nil,
		72133, -- Dolor y sufrimiento
		68981, -- Invierno sin remordimientos
		69242, -- Chillido de alma
		69409, -- Segador de almas
		70541, -- Infestar
		27177, -- Profanar
		68980, -- Recolectar alma
		},
		["Trash"] = {
		order = nil, ejid = nil,
		70980, -- Trampa arácnida
		70450, -- Espejo de sangre
		71089, -- Pus burbujeante
		69483, -- Expiación oscura
		71163, -- Devorar humanoide
		71127, -- Herida mortal
		70435, -- Descuartizar
		70671, -- Putrefacción parasitante
		70432, -- Porrazo de sangre
		71257, -- Golpe barbárico
		},
	},
	[609] = { -- El Sagrario Rubí 
		["Halion"] = {
		order = 1, ejid = nil,
		74562, -- Combustión ígnea
		74567, -- Marca de combustión
		74792, -- Consumo de alma
		74795, -- Marca de Consumo
		},
		["General Zarithrian"] = {
		order = nil, ejid = nil,
		74367, -- Rajar armadura
		},
		["Baltharus the Warborn"] = {
		order = nil, ejid = nil,
		74502, -- Marca enervante
		},
		["Saviana Ragefire"] = {
		order = nil, ejid = nil,
		74452, -- Conflagración
		},
	},
	[527] = { -- El Ojo de la Eternidad 
		["Malygos"] = {
		order = nil, ejid = nil,
		56272, -- Aliento Arcano
		57407, -- Oleada de poder
		},
	},
	[543] = { -- Prueba del Cruzado 
		["Lord Jaraxxus"] = {
		order = 2, ejid = nil,
		66532, -- Bola de Fuego vil
		66237, -- Incinerar carne
		66242, -- Inferno ardiente
		66197, -- Llama de la Legión
		66283, -- Punta de dolor giratoria
		66209, -- Toque de Jaraxxus
		66211, -- Maldición del infierno
		66333, -- Perforador nerubiano
		},
		["Faction Champions"] = {
		order = 3, ejid = nil,
		65812, -- Aflicción inestable
		},
		["The Twin Val'kyr"] = {
		order = 4, ejid = nil,
		},
		["Anub'arak"] = {
		order = 5, ejid = nil,
		67574, -- Perseguido por Anub'arak
		66013, -- Frío penetrante
		66012, -- Tajo congelante
		},
		["Acidmaw"] = {
		order = nil, ejid = nil,
		66819, -- Vómito acídulo
		66821, -- Vómito de arrabio
		66823, -- Toxina paralizadora
		66869, -- Bilis ardiente
		},
		["Gormok the Impaler"] = {
		order = nil, ejid = nil,
		66331, -- Empalar
		66406, -- ¡Snoboldado!
		},
		["Icehowl"] = {
		order = nil, ejid = nil,
		66770, -- Golpe atroz
		66689, -- Aliento ártico
		66683, -- Colisión monumental
		},
	},
	[531] = { -- El Sagrario Obsidiana 
		["Sartharion"] = {
		order = 1, ejid = nil,
		60708, -- Debilitar armadura
		57491, -- Tsunami de llamas
		},
		["Trash"] = {
		order = nil, ejid = nil,
		39647, -- Maldición de alivio
		58936, -- Lluvia de Fuego
		},
	},
	[532] = { -- La Cámara de Archavon 
		["Koralon"] = {
		order = 3, ejid = nil,
		},
		["Toravon the Ice Watcher"] = {
		order = 4, ejid = nil,
		72004, -- Congelamiento
		},
	},
	[535] = { -- Naxxramas 
		["Anub'Rekhan"] = {
		order = 1, ejid = nil,
		28786, -- Enjambre de langostas
		},
		["Grand Widow Faerlina"] = {
		order = 2, ejid = nil,
		28796, -- Salva de descarga de veneno
		28794, -- Lluvia de Fuego
		},
		["Maexxna"] = {
		order = 3, ejid = nil,
		28622, -- Trampa arácnida
		54121, -- Veneno necrótico
		},
		["Noth the Plaguebringer"] = {
		order = 4, ejid = nil,
		29213, -- Maldición del Pesteador
		29214, -- Cólera del Pesteador
		29212, -- Entorpecer
		},
		["Heigan the Unclean"] = {
		order = 5, ejid = nil,
		29998, -- Fiebre decrépita
		29310, -- Perturbación de hechizo
		},
		["Instructor Razuvious"] = {
		order = 7, ejid = nil,
		55550, -- Cuchillo de sierra
		},
		["Grobbulus"] = {
		order = 11, ejid = nil,
		28169, -- Inyección mutante
		},
		["Gluth"] = {
		order = 12, ejid = nil,
		54378, -- Herida mortal
		29306, -- Herida infectada
		},
		["Thaddius"] = {
		order = 13, ejid = nil,
		28084, -- Carga negativa
		28059, -- Carga positiva
		},
		["Sapphiron"] = {
		order = 14, ejid = nil,
		28522, -- Descarga de hielo
		28542, -- Drenaje de vida
		},
		["Kel'Thuzad"] = {
		order = 15, ejid = nil,
		28410, -- Cadenas de Kel'Thuzad
		27819, -- Detonar maná
		27808, -- Explosión de Escarcha
		},
		["Trash"] = {
		order = nil, ejid = nil,
		55314, -- Estrangular
		},
	},
	[529] = { -- Ulduar 
		["Ignis the Furnace Master"] = {
		order = 2, ejid = nil,
		62548, -- Agostar
		62680, -- Caños de llamas
		62717, -- Olla de escoria
		},
		["Razorscale"] = {
		order = 3, ejid = nil,
		64771, -- Fundir armadura
		},
		["XT-002"] = {
		order = 4, ejid = nil,
		63024, -- Bomba de gravedad
		63018, -- Luz abrasadora
		},
		["The Assembly of Iron"] = {
		order = 5, ejid = nil,
		61888, -- Poder sobrecogedor
		62269, -- Runa de Muerte
		61903, -- Golpe de fusión
		61912, -- Perturbación estática
		},
		["Kologarn"] = {
		order = 6, ejid = nil,
		64290, -- Agarre pétreo
		63355, -- Aplastar armadura
		62055, -- Piel quebradiza
		},
		["Freya"] = {
		order = 8, ejid = nil,
		62532, -- Apretón de conservador
		62589, -- Furia de la naturaleza
		62861, -- Raíces férreas
		},
		["Hodir"] = {
		order = 9, ejid = nil,
		62469, -- Congelar
		61969, -- Congelación apresurada
		62188, -- Frío cortante
		},
		["Mimiron"] = {
		order = 10, ejid = nil,
		63666, -- Concha de Napalm
		62997, -- Explosión de plasma
		64668, -- Campo magnético
		},
		["Thorim"] = {
		order = 11, ejid = nil,
		62042, -- Martillo de tormenta
		62130, -- Golpe desequilibrante
		62526, -- Detonación de runa
		62470, -- Trueno ensordecedor
		62331, -- Empalar
		},
		["General Vezax"] = {
		order = 12, ejid = nil,
		63276, -- Marca de los Ignotos
		63322, -- Vapores de saronita
		},
		["Yogg-Saron"] = {
		order = 13, ejid = nil,
		63147, -- Ira de Sara
		63134, -- Bendición de Sara
		63138, -- Fervor de Sara
		63830, -- Mal de la mente
		63802, -- Vínculo cerebral
		63042, -- Subyugar mente
		64152, -- Veneno drenador
		64153, -- Peste negra
		64125, -- Exprimir
		64156, -- Apatía
		64157, -- Maldición de fatalidad
		},
		["Algalon"] = {
		order = 14, ejid = nil,
		64412, -- Cambiar de fase
		},
		["Trash"] = {
		order = nil, ejid = nil,
		62310, -- Empalar
		63612, -- Enseña de relámpagos
		63615, -- Devastar armadura
		62283, -- Raíces férreas
		63169, -- Petrificar articulaciones
		},
	},
}
