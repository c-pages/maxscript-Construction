macroScript Construction
category:"#CPages"
toolTip:""
(
	
	global 	CPages_rollConstruction_estOuvert 	= false
	global 	CPages_rollConstruction_prefs 			= false
	global 	CPages_rollConstruction_pos				= [150,150]
	
	fileIn "$userScripts\Construction\perso - Constructions - Refonte.ms"
	
	on execute do 	(		
		
		if CPages_rollConstruction_estOuvert	 then	(
			try destroyDialog rollConstruction catch ()
			CPages_rollConstruction_estOuvert = false
		) else 	(
			createDialog 		rollConstruction pos:CPages_rollConstruction_pos
			CPages_rollConstruction_estOuvert = true
		)
		
	)
	
	on isChecked return try CPages_rollConstruction_estOuvert  catch	( false )
	
)