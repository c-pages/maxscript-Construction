macroScript Construction
category:"#CPages"
toolTip:""
(
	
	local estOuvert = false
	local rollConstruction = fileIn "$userScripts\perso - Constructions.ms"
	
	on execute do 	(		
		
		if estOuvert	 then	(
			try destroyDialog rollConstruction catch ()
			estOuvert = false
		) else 	(
			createDialog 		rollConstruction 
			estOuvert = true
		)
		
	)
	
	on isChecked return try estOuvert  catch	( false )
	
)