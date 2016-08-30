
	---- Prefs de Etage ---------------------------------------------------------------------------------------------
	rollout rollEtage "Etage" width:775 height:376
	(
		button 'btn_etage' "Etage" pos:[21,25] width:40 height:40 align:#left
		button 'btn_accrotere' "Accrotère" pos:[89,26] width:60 height:40 align:#left
		button 'btn_pansDeux' "2 pans" pos:[154,26] width:60 height:40 align:#left
		button 'btn_pansTrois' "3 pans" pos:[219,26] width:60 height:40 align:#left
		button 'btn_pansQuatre' "4 pans" pos:[284,26] width:60 height:40 align:#left
		button 'btn_baies' "Bais" pos:[368,26] width:60 height:40 align:#left
		button 'btn_ventDeux' "2 venteaux" pos:[434,26] width:60 height:40 align:#left
		button 'btn_ventDeuxAllege' "2 vent. + allège" pos:[504,26] width:60 height:40 align:#left
		button 'btn_balcon' "Balcon" pos:[591,26] width:60 height:40 align:#left
		button 'btn_loggia' "Loggia" pos:[661,26] width:60 height:40 align:#left
	
		GroupBox 'grp_etage' "Etage" pos:[11,6] width:62 height:67 align:#left
		GroupBox 'grp_toiture' "Toiture" pos:[82,6] width:269 height:67 align:#left
		GroupBox 'grp_baies' "Baies" pos:[359,6] width:213 height:67 align:#left
		GroupBox 'grp_bacons' "Balcons" pos:[583,6] width:146 height:67 align:#left

		checkbutton 'btn_details' "+" pos:[735,55] width:17 height:17 align:#left
	
	subrollout 		'sousRoll' 					"Paramêtres" 		pos:[8,89] 		width:745 	height:255 	align:#left
	button				'btn_defauts' 			"Défauts" 				pos:[9,350]		width:86 		height:20 		align:#left

	)
	/* 
	
		ht_etage 				= 270, 	---- Hauteur d'un étage.
	
		ep_mur					=	30,	---- Epaisseur du mur.
		ht_accrotere 			= 50, 	---- Hauteur de l'accrotere.
		ep_couvertine		=	5,		---- Epaisseur de la couvertine.
		ht_couvertine		=	5,		---- Hauteur de la couvertine.
		
		ht_allege				= 90,	---- Hauteur de l'allège
		ht_fenetre				= 210,	---- Hauteur de la fenetre
		larg_fenetre			= 100,	---- Largeur de la fenetre
		larg_entreFenetre	= 150,	---- Largeur du lpen entre 2 fenetres
		 */
	---- Prefs de Etage ---------------------------------------------------------------------------------------------
	rollout rollAccrotere "Accrotère" width:743 height:99
	(
		label 'lbl_allege' "Allège :" pos:[8,7] width:100 height:19 align:#left
		spinner 'spn_allege' "" pos:[114,9] width:100 height:16 range:[90,10000,0] type:#worldunits align:#left		
		
		label 'lbl_fen_Larg' "Largeur :" pos:[264,29] width:60 height:19 align:#left
		spinner 'spn_fen_Larg' "" pos:[324,31] width:100 height:16 range:[100,10000,0] type:#worldunits align:#left
		label 'lbl_fen_hauteur' "Hauteur :" pos:[449,29] width:60 height:19 align:#left
		spinner 'spn_fen_hauteur' "" pos:[509,31] width:100 height:16 range:[90,10000,0] type:#worldunits align:#left
		label 'lbl_fen_nombre' "Fenetres :" pos:[9,29] width:100 height:19 align:#left
		spinner 'spn_fen_nombre' "" pos:[114,30] width:100 height:16 range:[0,10000,0] type:#integer scale:1 align:#left
		radiobuttons 'rdo_align' "Alignement" pos:[9,56] width:235 height:30 labels:#("Gauche", "Centre", "Droite") default:1 columns:3 align:#left
		label 'lbl_espacement' "Espacmt. :" pos:[449,70] width:60 height:19 align:#left
		spinner 'spn_espacement' "" pos:[509,71] width:100 height:16 range:[100,10000,0] type:#worldunits align:#left
		label 'lbl_decalage' "Décalage :" pos:[264,70] width:60 height:19 align:#left
		spinner 'spn_decalage' "" pos:[324,71] width:100 height:16 range:[0,10000,0] type:#worldunits align:#left
	
		
	)
	
	
	---- Prefs de Baies ---------------------------------------------------------------------------------------------
	rollout rollBaies "Baies" width:743 height:99
	(
-- 		button 'btn_appliquer' "Appliquer" pos:[624,9] width:108 height:82 align:#left
		
		label 'lbl_allege' "Allège :" pos:[8,7] width:100 height:19 align:#left
		spinner 'spn_allege' "" pos:[114,9] width:100 height:16 range:[90,10000,0] type:#worldunits align:#left		
		
		label 'lbl_fen_Larg' "Largeur :" pos:[264,29] width:60 height:19 align:#left
		spinner 'spn_fen_Larg' "" pos:[324,31] width:100 height:16 range:[100,10000,0] type:#worldunits align:#left
		label 'lbl_fen_hauteur' "Hauteur :" pos:[449,29] width:60 height:19 align:#left
		spinner 'spn_fen_hauteur' "" pos:[509,31] width:100 height:16 range:[90,10000,0] type:#worldunits align:#left
		label 'lbl_fen_nombre' "Fenetres :" pos:[9,29] width:100 height:19 align:#left
		spinner 'spn_fen_nombre' "" pos:[114,30] width:100 height:16 range:[0,10000,0] type:#integer scale:1 align:#left
		radiobuttons 'rdo_align' "Alignement" pos:[9,56] width:235 height:30 labels:#("Gauche", "Centre", "Droite") default:1 columns:3 align:#left
		label 'lbl_espacement' "Espacmt. :" pos:[449,70] width:60 height:19 align:#left
		spinner 'spn_espacement' "" pos:[509,71] width:100 height:16 range:[100,10000,0] type:#worldunits align:#left
		label 'lbl_decalage' "Décalage :" pos:[264,70] width:60 height:19 align:#left
		spinner 'spn_decalage' "" pos:[324,71] width:100 height:16 range:[0,10000,0] type:#worldunits align:#left
	
		
		---- evenements ----
		on rollBaies open do ( 
			
			/* ---- Membres	----
			ep_mur					=	30,	---- Epaisseur du mur.
			ht_etage 				= 270, 	---- Hauteur d'un étage.
			ht_accrotere 			= 50, 	---- Hauteur de l'accrotere.
			ep_couvertine		=	5,		---- Epaisseur de la couvertine.
			ht_couvertine		=	5,		---- Hauteur de la couvertine.
			
			ht_allege				= 90,	---- Hauteur de l'allège
			ht_fenetre				= 210,	---- Hauteur de la fenetre
			larg_fenetre			= 100,	---- Largeur de la fenetre
			larg_entreFenetre	= 150,	---- Largeur du lpen entre 2 fenetres
 */		)
		
-- 		on  btn_appliquer 	pressed 			do const.baies ()
		on  rdo_align			changed	arg 	do (			
			lbl_decalage.enabled 		= ( arg != 2 )
			spn_decalage.enabled 	= ( arg != 2 )
		)
	)

/* rollout popo "popo" width:763 height:79
(
	
	
	button 'btn_etage' "Etage" pos:[21,25] width:40 height:40 align:#left
	button 'btn_accrotere' "Accrotère" pos:[89,26] width:60 height:40 align:#left
	button 'btn_pansDeux' "2 pans" pos:[154,26] width:60 height:40 align:#left
	button 'btn_pansTrois' "3 pans" pos:[219,26] width:60 height:40 align:#left
	button 'btn_pansQuatre' "4 pans" pos:[284,26] width:60 height:40 align:#left
	button 'btn_baies' "Bais" pos:[368,26] width:60 height:40 align:#left
	button 'btn_ventDeux' "2 venteaux" pos:[434,26] width:60 height:40 align:#left
	button 'btn_ventDeuxAllege' "2 vent. + allège" pos:[504,26] width:60 height:40 align:#left
	button 'btn_balcon' "Balcon" pos:[591,26] width:60 height:40 align:#left
	button 'btn_loggia' "Loggia" pos:[661,26] width:60 height:40 align:#left
	
	GroupBox 'grp_etage' "Etage" pos:[11,6] width:62 height:67 align:#left
	GroupBox 'grp_toiture' "Toiture" pos:[82,6] width:269 height:67 align:#left
	GroupBox 'grp_baies' "Baies" pos:[359,6] width:213 height:67 align:#left
	GroupBox 'grp_bacons' "Balcons" pos:[583,6] width:146 height:67 align:#left
	button 'btn_details' "+" pos:[735,52] width:20 height:20 align:#left

) *