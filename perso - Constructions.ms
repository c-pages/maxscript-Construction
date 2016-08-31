
/* #######################################################################################################################

	2017 Christophe Pages (http://www.c-pages.fr) 	

##########################################################################################################################
	
	Construction: Outils de modélisation d'éléments architecturaux sur un editable poly 
	
##########################################################################################################################

	todo:	
	
##########################################################################################################################

	changelog:
	*v0.0 - [2016/08] -----------------------------------------------------------------------------
	- Mise en place globale 
	
######################################################################################################################## */ 




	
------------------------------------------------------------------------------------------------------------------------
---- Rollout	--------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
rollout rollConstruction "Construction" 	width:765 	height:80
(
	
	------------------------------------------------------------
	---- Membres --------------------------------------------
	------------------------------------------------------------
	
	---- Les structures ----
	local const, outils, matID, prefs
	
	---- L'interface ----
	local boutons
	
	---- Ecouteurs ----
	local	ecouteurChangeEtat
	
	------------------------------------------------------------
	---- Structures ------------------------------------------
	------------------------------------------------------------
	---- la structure des Materiaux ID ---------------------------------------------------------------------------------------------
	struct matIDStruct (
		
		mur 				= 1,
		menuiseries 	= 2,
		tablette			= 2,
		couvertine		= 3,
		verre  			= 4
		
	)
	
	---- la structure outils divers	---------------------------------------------------------------------------------------------
	struct outilsStruct (
		
		---- manipulation de tableaux ----
		fn ComparerTableaux 	first 	second =
		(
			result = true
			if first.count != second.count then
				result = false
			else
				for i = 1 to first.count do
					if first[i] != second[i] do result = false
			result
		),
		fn virerDoublonsDansTableau  _tab = (
			for i = 1 to _tab.count do
			(
				for j = _tab.count to i+1 by -1 do
				(
					test = ( ComparerTableaux  _tab[i] _tab[j] )
					if test do
					(
						deleteItem _tab j
					)
				)--end j loop
			)--end i loop
		),
		
		
		---- tester la selection pour la mise a jour du rollout	----
		fn estValide	=	(
			
			if (selection as array).count != 1  				do return false
			_node = ( selection as array )[1]
			if classOf _node != Editable_Poly  				do return false
			if subobjectLevel != 4 								do return false
			_faces = (  polyop.getFaceSelection  _node  ) as array 
			if _faces.count == 0									do return false
			
			return true
			
		),
		
		
		---- manipulation des faces du node ----
		fn etendreSelecFaces		_node 	_faces	= (
			
			_faces_a_retirer = _faces 		---- ( polyop.getFaceSelection  _node ) as array
			_node.EditablePoly.GrowSelection ()
			_facesExtension	= ( polyop.getFaceSelection  _node ) 
			for face in _faces_a_retirer 	do _facesExtension	[face] 	= false
			polyop.setFaceSelection  _node 	_facesExtension	
			
		),

		fn 	arreteLaPlusPetite		_node		_listeArretes	= (
			
			local arretePlusPetite,  longMin
			for arrete in _listeArretes do (
				listePoints = polyop.getEdgeVerts  	_node	arrete
				pt1 = _node.verts[listePoints[1]]
				pt2 = _node.verts[listePoints[2]]
				longueurArrete =  length ( pt1.position	- pt2.position  )
				
				if longMin == undefined do longMin = longueurArrete
				if longueurArrete < longMin do (
					longMin = longueurArrete
					arretePlusPetite = arrete
				)
			)
			return 	arretePlusPetite
		),
		
		fn ZMinFace 	_node  _listeFaces = (
			
			local pointLePlusBas
			
			for face in _listeFaces do (
				listePoints = polyop.getFaceVerts  	_node	face
				for IDpt in listePoints do (
					pt = _node.verts[IDpt]
					if pointLePlusBas == undefined do pointLePlusBas = pt.position.z
					if pointLePlusBas > pt.position.z do pointLePlusBas = pt.position.z
				)
			)			
			return 	pointLePlusBas			
		),
		
		fn largeurFace 	_node _face = (
			local listePoints = polyop.getFaceVerts  	_node	_face
			local result = 0
			for  i=1 to listePoints.count-1 do (
				pt_1 = _node.verts[ listePoints[ i ] ]				
				for  j=i+1 to listePoints.count do (				
					pt_2 	= _node.verts[ listePoints[ j ] ]
					dist 		= length ( pt_2.position - pt_1.position )
					if pt_1.position.z == pt_2.position.z and dist > result
						do result = dist
				)
			)
			return result
		),
		
		fn hauteurFace 	_node 	_face = (
			local listePoints = polyop.getFaceVerts  	_node	_face
			local result = 0, mini = 10000000000, maxi = 0
			for  pt in listePoints 	do (
				pt = _node.verts[ pt ]		
				if pt.position.z < mini 	do mini 	= pt.position.z
				if pt.position.z > maxi 	do maxi 	= pt.position.z
			)
			result = maxi  - mini
			return result
		),
		fn faceLaPlusHaute 	_node 	_faces = (
			local  faceHaute 
			for faceID in _faces do (
				if faceHaute = undefined do faceHaute = faceID
				if  ( polyop.getFaceCenter 	_node 	faceID ).z  > ( polyop.getFaceCenter 	_node	faceHaute ).z do
					 faceHaute = faceID
			)
			return faceHaute
		),
		
		fn faceLaPlusBasse 	_node 	_faces = (
			local  faceHaute 
			for faceID in _faces do (
				if faceHaute == undefined do faceHaute = faceID
				if  ( polyop.getFaceCenter 	_node 	faceID ).z  < ( polyop.getFaceCenter 	_node	faceHaute ).z do
					 faceHaute = faceID
			)
			return faceHaute
		),
		
		fn centreDeLaFace	_node	_face = (
			
			local listePoints 	= polyop.getFaceVerts  	_node	_face
			local pointsAlignesVerticalement 			= #()
			local ptsResult 		= #()
			local coinHtG, coinHtD, coinBsG, coinBsD
			
			---- regrouper les points alignés verticalement	----
			for  i=1 to listePoints.count do (
				ID_pt_1 = listePoints[ i ] 
				pt_1 = _node.verts[ ID_pt_1 ]
				
				local resultTmp 			= #( ID_pt_1 )
				
				for  j=1 to listePoints.count do (
					ID_pt_2 = listePoints[ j ] 					
					pt_2 = _node.verts[ ID_pt_2 ]
					
					
					if floor (  pt_1.position.x * 10 )== floor ( pt_2.position.x * 10 ) do 
						if floor ( pt_1.position.y * 10 ) == floor ( pt_2.position.y * 10 ) do 
							appendIfUnique resultTmp 		ID_pt_2
					
				)
				sort resultTmp
				
				if resultTmp.count > 1 do 	append 	 	pointsAlignesVerticalement 		resultTmp
				
			)
			
			virerDoublonsDansTableau  pointsAlignesVerticalement 
			
			---- selection dans chaque groupe de points du plus haut et du plus bas	----
			for listPts in pointsAlignesVerticalement do (
				---- min ----
				local minZ, maxZ
				for ptID in listPts do (
					if minZ == undefined do minZ = ptID
					if maxZ == undefined do maxZ = ptID
					
					if _node.verts[ ptID ].position.z > _node.verts[ minZ ].position.z   do minZ =ptID
					if _node.verts[ ptID ].position.z < _node.verts[ maxZ ].position.z  do maxZ =ptID
					
				)
				append ptsResult minZ
				append ptsResult maxZ
			)
			
			sort ptsResult
			
			---- moyenne des points hauts et bas	----
			centre = [0,0,0]
			if ptsResult.count != 0 do (
				for IDpt in ptsResult do 
					centre += _node.verts[ IDpt ].position
				
				centre = centre/ ptsResult.count
			)
			
			centre
		)
		
	)	-- fin struct outils

	
	---- la structure des preferences	---------------------------------------------------------------------------------------------
	struct prefsStruct (
		
		---- le fichier des preferences	----
		fichier 					= "$userScripts\construction.ini",
		
		
		---- les preferences	----
		ep_mur					=	30,	---- Epaisseur du mur.
		
		ht_etage 				= 255, 	---- Hauteur d'un étage.
		ep_dalle				=	25,	---- Epaisseur des dalles.
		
		ht_accrotere 			= 50, 	---- Hauteur de l'accrotere.
		ep_couvertine		=	5,		---- Epaisseur de la couvertine.
		ht_couvertine		=	5,		---- Hauteur de la couvertine.
		
		ht_allege				= 90,	---- Hauteur de l'allège
		nbr_fenetre			= 0,		---- Nombre de fenetre à creer ( 0: remplis la face fenetres )
		ht_fenetre				= 210,	---- Hauteur de la fenetre
		larg_fenetre			= 100,	---- Largeur de la fenetre
		esp_fenetre			= 150,	---- Largeur du plein entre 2 fenetres
		align_fenetre			= 1,		---- L'alignement des fenetre dans la face
		decal_fenetre			= 50,	---- Le décalage de la premiere fenetre pa rapport au bord de la face.
		
		
		/* 
		spn_ht_allege.value 				= prefs.ht_allege
		spn_larg_fenetre.value 			= prefs.larg_fenetre
		spn_ht_fenetre.value 			= prefs.ht_fenetre
		spn_nbr_fenetre.value 			= prefs.nbr_fenetre
		rdo_align_fenetre.value 			= prefs.align_fenetre
		spn_esp_fenetre.value 			= prefs.esp_fenetre
		spn_decal_fenetre.value 		= prefs.decal_fenetre */
		
		
		--- Fontions ----
		fn sauvegarder 	= (
			
			setINISetting   fichier		"prefs"   "ep_mur"  				( ep_mur as string )
			
			setINISetting   fichier		"prefs"   "ht_etage"  				( ht_etage as string )
			setINISetting   fichier		"prefs"   "ep_dalle"  				( ep_dalle as string )
			
			setINISetting   fichier		"prefs"   "ht_accrotere"  			( ht_accrotere as string )
			setINISetting   fichier		"prefs"   "ep_couvertine"		( ep_couvertine as string )
			setINISetting   fichier		"prefs"   "ht_couvertine"  		( ht_couvertine as string )
			
			setINISetting   fichier		"prefs"   "ht_allege"  				( ht_allege as string )
			setINISetting   fichier		"prefs"   "nbr_fenetre"  			( nbr_fenetre as string )
			setINISetting   fichier		"prefs"   "ht_fenetre"  			( ht_fenetre as string )
			setINISetting   fichier		"prefs"   "larg_fenetre"  			( larg_fenetre as string )
			setINISetting   fichier		"prefs"   "esp_fenetre"			( esp_fenetre as string )
			setINISetting   fichier		"prefs"   "align_fenetre"			( align_fenetre as string )
			setINISetting   fichier		"prefs"   "decal_fenetre"			( decal_fenetre as string )
			
		),
		
		fn charger 	= (
			
			ep_mur 				= 	( getINISetting   fichier		"prefs"   "ep_mur"  			as float )		
			
			ht_etage				= 	( getINISetting   fichier	"prefs"   "ht_etage"  				as float )
			ep_dalle				= 	( getINISetting   fichier	"prefs"   "ep_dalle"  				as float )
			
			ht_accrotere 			=	( getINISetting   fichier	"prefs"   "ht_accrotere"  			as float )
			ep_couvertine		=	( getINISetting   fichier	"prefs"   "ep_couvertine"		as float )
			ht_couvertine		=	( getINISetting   fichier	"prefs"   "ht_couvertine"  		as float )
			
			ht_allege				= 	( getINISetting   fichier	"prefs"   "ht_allege"  				as float )
			nbr_fenetre			= 	( getINISetting   fichier	"prefs"   "nbr_fenetre"  			as float )
			ht_fenetre				= 	( getINISetting   fichier	"prefs"   "ht_fenetre"  			as float )
			larg_fenetre			=	( getINISetting   fichier	"prefs"   "larg_fenetre"  			as float )
			esp_fenetre			=	( getINISetting   fichier	"prefs"   "esp_fenetre"			as float )
			align_fenetre			=	( getINISetting   fichier	"prefs"   "align_fenetre"			as integer )
			decal_fenetre			=	( getINISetting   fichier	"prefs"   "decal_fenetre"			as float )
			
		),
		
		fn resetFichier = (
			deleteFile  fichier
		),
		
		---- evenements ----
		on create do (
			if not doesFileExist fichier
					then	sauvegarder ()
					else 	charger ()
		)
		
	)	-- fin struct prefs	---
	
	
	
	---- la structure de construction	---------------------------------------------------------------------------------------------
	struct constructionStruct (
		
		--- Fontions ----
		fn etage = (
			undo "construction : étage" on (
				with redraw off (
					
					local _node = $
					
					---- extrusion de la hauteur sous plafond----
					_node.extrusionType = 0
					_node.faceExtrudeHeight = prefs.ht_etage
					_node.EditablePoly.buttonOp #Extrude
					
					---- extrusion de l'épaisseur de la dalle----
					_node.faceExtrudeHeight = prefs.ep_dalle
					_node.EditablePoly.buttonOp #Extrude
					
				) -- fin redraw off
				redrawViews()
			)	-- fin undo
		),
		
		fn accrotere 	= (
			undo "construction : accrotere" on (
				with redraw off (
					
					local _node = $
					
					---- MatID mur	----
					_node.EditablePoly.setMaterialIndex 		matID.mur	 	1
					
					---- Inset de l'épaisseur du mur ----
					_node.insetType = 0
					_node.insetAmount = prefs.ep_mur
					_node.EditablePoly.buttonOp 		#Inset
					
					---- Extusion de l'accrotere	----
					outils.etendreSelecFaces 		_node 	( ( polyop.getFaceSelection  _node ) as array )
					_node.extrusionType 				= 0
					_node.faceExtrudeHeight 		= prefs.ht_accrotere
					_node.EditablePoly.buttonOp	#Extrude
					
					---- Copie des faces pour creer la base de la couvertine 	----
					_facesCouvertine = _node.EditablePoly.getSelection #Face
					_node.EditablePoly.detachToElement 	#Face 		keepOriginal:on
					
					---- MatID couvertine	----
					_node.EditablePoly.setMaterialIndex 		matID.couvertine	 	1
					
					---- Epaisseur de la couvertine 	----
					_node.faceExtrudeHeight = prefs.ht_couvertine
					_node.EditablePoly.buttonOp #Extrude
					
					-- listes des trucs a supprimer	(points et arretes en trop )	----
					listeArretesAVirer 	= polyop.getEdgesUsingFace	_node	( ( polyop.getFaceSelection  _node ) as array )
					listePointsAVirer 	= polyop.getVertsUsingFace  	_node	( ( polyop.getFaceSelection  _node ) as array )
					
					---- Extrusion du débord de la couvertine 	----
					outils.etendreSelecFaces		_node		( ( polyop.getFaceSelection  _node ) as array )
					_node.faceExtrudeHeight = prefs.ht_couvertine
					_node.extrusionType = 1
					_node.EditablePoly.buttonOp #Extrude
					
					---- Suppression des trucs (points et arretes en trop )	----
					_node.EditablePoly.SetSelection #Edge 		listeArretesAVirer
					_node.EditablePoly.SetSelection #Vertex 	listePointsAVirer
					subobjectLevel = 2
					_node.EditablePoly.Remove ()
					subobjectLevel = 1
					_node.EditablePoly.Remove ()
					
					---- Deselection des faces ----
					subobjectLevel = 4
					_node.EditablePoly.SetSelection #Face #{}
					
					
				) -- fin redraw off
				redrawViews()
			)	-- fin undo
		),
		
		fn pansDeux = (
			undo "construction : 2 pans" on (
				with redraw off (
					
					local _node = $
					
					---- Calcul edge le plus petit 	----
					listeArretes = polyop.getEdgesUsingFace 	_node	( polyop.getFaceSelection  _node )
					arretePlusPetite  = outils.arreteLaPlusPetite		_node		listeArretes
					if arretePlusPetite != undefined do (
						polyop.setEdgeSelection  _node #(arretePlusPetite)
						subobjectLevel = 2
					)
					
				) -- fin redraw off
				redrawViews()
			)	-- fin undo
		),
		
		fn pansTrois = (
			format "pansTrois\n"
			
		),
		
		fn pansQuatre = (
			format "pansQuatre\n"
			
		),
		
		fn baies = (
			
			undo "construction : bais" on (
				with redraw off (
					
					--- declarations	----
					local _node = $
					local _arretesAlleges 	= #()
					local	 _arretesLintots 		= #()
					local _facesBandeaux	= #()
					local _facesBais			= #()
					local _facesSelection 	= ( polyop.getFaceSelection  _node )
					
					---- MatID mur	----
					_node.EditablePoly.setMaterialIndex 		matID.mur	 	1
					
					--- DECOUPAGE DES BAIES	----
					polyop.setEdgeSelection  _node #()
					for face in  _facesSelection do (
						
						--- vérification de la validité de la face ----
						hauteurFace 		= outils.hauteurFace 	_node	face
						largeurFace		= outils.largeurFace	_node	face
						hauteurFaceMin	= prefs.ht_fenetre
						largeurFaceMin	= prefs.larg_Fenetre + prefs.ep_mur
						
						if hauteurFace >= hauteurFaceMin and largeurFace >= largeurFaceMin	do (
							
							
							---- Découpe de l'allège	----
							Zmin = outils.ZMinFace 		_node 	#(face)
							polyop.setFaceSelection  	_node 	#(face)
							_node.slice [0,0,1] [0,0,Zmin + prefs.ht_allege ] 	flaggedFacesOnly:true
							append		_arretesAlleges	(  _node.GetNumEdges	() )
							append 	_facesBandeaux	(  _node.GetNumFaces	() )
							
							---- Découpe du lintot	----
							_node.slice [0,0,1] [0,0,Zmin + prefs.ht_fenetre ] 	flaggedFacesOnly:true
							append		_arretesLintots	(  _node.GetNumEdges	() )
							
							-- Selection de la face à découper --
							facesTmp 		= 	polyop.getEdgeFaces		_node	( _node.GetNumEdges	() )
							nouvelleFace 	=	outils.faceLaPlusBasse 	_node 	facesTmp
							polyop.setFaceSelection  _node		#( nouvelleFace  )
							
							---- Decoupage vertical	----
							centreFace 		= 		outils.centreDeLaFace		_node	face
							normalFace 		= 	(	polyop.getFaceNormal  	_node 	face ) * rotateZMatrix 90 
							largeurFace 		= outils.largeurFace 		_node 	face
							origine				= centreFace + normalFace * ( -largeurFace/2 + prefs.ep_mur )
							transl_fenetre	= normalFace * prefs.larg_Fenetre
							transl_plein		= normalFace * prefs.esp_fenetre
							
							translation			= [0,0,0]
							
							while  length ( translation + transl_fenetre  + normalFace *	prefs.ep_mur ) < largeurFace do (
								
								---- Slice debut fenetre ----
								_node.slice 	normalFace 	( origine + translation ) 	flaggedFacesOnly:true
								
								---- Actualiser translation	----
								translation += transl_fenetre	
								
								---- Slice fin fenetre ----
								polyop.setEdgeSelection  _node		#()
								_node.slice 	normalFace 	( origine + translation ) 	flaggedFacesOnly:true
								
								----	Ajout de la face de la fenetre dans la liste pour extrusion epaisseur du mur	----
								derniereArrete 	=	(( polyop.getEdgeSelection  	_node ) as array )[1]
								facesTmp 			= 	polyop.getEdgeFaces			_node		derniereArrete
								local faceAAjouter
								distMin = 1000000000000
								for faceTmp in facesTmp do (
									centreFaceTmp 		= 		outils.centreDeLaFace		_node		faceTmp
									dist = length 	(  	centreFaceTmp - origine )
									if dist < distMin do (
										distMin = dist
										faceAAjouter = faceTmp
									)
								)
								append 	_facesBais		(  faceAAjouter )
								
								---- Actualiser translation	----
								translation += transl_plein
								
							)	-- fin du while
						)	-- fin du if 
					)	-- fin du for
					
					---- Extrusion epaisseur du mur ----
					polyop.setFaceSelection  _node		_facesBais
					_node.faceExtrudeHeight 	= -prefs.ep_mur
					_node.extrusionType 			= 1
					_node.EditablePoly.buttonOp #Extrude
					
					---- le nom de la selection des faces ----
					if _node.faces["const_baies"] == undefined  
							then		_node.faces["const_baies"] = 	( polyop.getFaceSelection  _node ) as array
							else		_node.faces["const_baies"] += 	( polyop.getFaceSelection  _node ) as array
					
					---- MatID verre	----
					_node.EditablePoly.setMaterialIndex 		matID.verre	 	1
					
				) -- fin redraw off
				redrawViews() 
			)	-- fin undo
			
		),
		
		fn ventDeux = (
			
			undo "construction : deux ventaux" on (
				with redraw off (
					
					--- declarations	----
					local _node = $
					local _facesSelection 	= ( polyop.getFaceSelection  _node )
					
					---- CREATION DE LA TABLETTE	---------------------
					---- Selection des faces du bas ----
					local	_facesDuBas = #()
					for _face in _facesSelection do (
						polyop.setFaceSelection  _node 	#(_face)
						outils.etendreSelecFaces 		_node 	#(_face)
						facesCadre = polyop.getFaceSelection  _node
						local		_faceDuBas
						for _faceCadre in facesCadre do 
							if _faceDuBas == undefined 	then _faceDuBas = _faceCadre
								else	if ( outils.centreDeLaFace		_node		_faceCadre ).z  <  (outils.centreDeLaFace		_node		_faceDuBas ).z 	then _faceDuBas = _faceCadre
						
						append _facesDuBas _faceDuBas
					)
					
					
					polyop.setFaceSelection  _node 	_facesDuBas
					
					---- matID  tablette	----
					_node.EditablePoly.setMaterialIndex 		matID.tablette	 	1
					
					---- extrusion  tablette	----
					_node.extrusionType 				= 0
					_node.faceExtrudeHeight 		= prefs.ht_couvertine
					_node.EditablePoly.buttonOp 	#Extrude
					
					-- listes des trucs a supprimer	(points et arretes en trop )	----
					listeArretesAVirer 	= polyop.getEdgesUsingFace	_node	( ( polyop.getFaceSelection  _node ) as array )
					listePointsAVirer 	= polyop.getVertsUsingFace  	_node	( ( polyop.getFaceSelection  _node ) as array )
					
					---- Extrusion du débord de la couvertine 	----
					outils.etendreSelecFaces		_node		( ( polyop.getFaceSelection  _node ) as array )
					_node.faceExtrudeHeight = prefs.ht_couvertine
					_node.extrusionType = 1
					_node.EditablePoly.buttonOp #Extrude
					
					---- Suppression des trucs (points et arretes en trop )	----
					_node.EditablePoly.SetSelection #Edge 		listeArretesAVirer
					_node.EditablePoly.SetSelection #Vertex 	listePointsAVirer
					subobjectLevel = 2
					_node.EditablePoly.Remove ()
					subobjectLevel = 1
					_node.EditablePoly.Remove ()
					
					---- Deselection des faces ----
					subobjectLevel = 4
					_node.EditablePoly.SetSelection #Face #{}
					
				) -- fin redraw off				
				redrawViews() 	 				
			)	-- fin undo
			
		),
		fn ventDeuxAllege = (
			format "ventDeuxAllege\n"
			
		),
		fn balcon = (
			format "balcon\n"
			
		),
		fn loggia = (
			format "loggia\n"
			
		)
		
	)
	
	
	
	------------------------------------------------------------
	---- UI ---------------------------------------------------
	------------------------------------------------------------
	groupBox 		'grp_etage' 				"Etage" 				pos:[11,6] 		width:62 		height:67 		align:#left
	groupBox 		'grp_toiture' 				"Toiture" 				pos:[82,6] 		width:269		height:67 		align:#left
	groupBox 		'grp_baies' 				"Baies" 					pos:[359,6] 		width:213 	height:67 		align:#left
	groupBox 		'grp_bacons'				"Balcons" 				pos:[583,6] 		width:146 	height:67 		align:#left
	
	button 			'btn_etage' 				"Etage" 				pos:[21,25] 		width:40 		height:40 		align:#left
	button 			'btn_accrotere' 			"Accrotère" 			pos:[89,26] 		width:60 		height:40 		align:#left
	button 			'btn_pansDeux' 			"2 pans" 				pos:[154,26] 	width:60 		height:40 		align:#left
	button 			'btn_pansTrois' 			"3 pans" 				pos:[219,26] 	width:60 		height:40 		align:#left
	button 			'btn_pansQuatre' 		"4 pans" 				pos:[284,26] 	width:60 		height:40 		align:#left
	button			 	'btn_baies' 				"Bais" 					pos:[368,26] 	width:60 		height:40 		align:#left
	button 			'btn_ventDeux' 			"2 venteaux" 		pos:[434,26] 	width:60 		height:40 		align:#left
	button 			'btn_ventDeuxAllege' "2 vent. + allège" 	pos:[504,26] 	width:60 		height:40 		align:#left
	button 			'btn_balcon' 				"Balcon" 				pos:[591,26] 	width:60 		height:40 		align:#left
	button 			'btn_loggia' 				"Loggia" 				pos:[661,26] 	width:60 		height:40 		align:#left
	

	GroupBox 		'grp_params' 			"Paramêtres " 		pos:[11,82] 		width:745 	height:283 	align:#left
	
	checkButton 	'btn_details' 				"+" 						pos:[735,55] 	width:17 		height:17 		align:#left	
	subRollout 		'sousRoll' 					"Paramêtres" 		pos:[24,102] 	width:720 	height:234 	align:#left
	button 			'btn_defauts' 			"Défauts" 				pos:[23,340] 	width:86 		height:18 		align:#left


	------------------------------------------------------------
	---- Rollout secondaires ------------------------------------------
	------------------------------------------------------------
	
	---- Rollout de Etage ---------------------------------------------------------------------------------------------
	rollout rollEtage "Etage" width:743 height:99 	(
		
		---- UI ----
		label 		'lbl_htSsPlaf' 	"Hauteur sous plaf. :" 	pos:[8,9] 		width:100 height:19 align:#left
		spinner 	'spn_htSsPlaf' 	"" 								pos:[114,9] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left		
		label 		'lbl_epDalle' 		"Ep. dalle :" 					pos:[264,9] 	width:60 	height:19 align:#left
		spinner	'spn_epDalle' 	"" 								pos:[324,9] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left
		
		---- fonctions ----
		fn actualiser = (
			spn_htSsPlaf.value 	= prefs.ht_etage
			spn_epDalle.value 		= prefs.ep_dalle			
		)
		
		---- evenements ----
		on rollEtage open do actualiser ()
		on spn_htSsPlaf changed val do (
			prefs.ht_etage	=	val
			prefs.sauvegarder()
		)
		on spn_epDalle changed val do (
			prefs.ep_dalle	=	val
			prefs.sauvegarder()
		)
		
	)	-- fin rollout etage --
	
	
	---- Rollout de Accrotère ---------------------------------------------------------------------------------------------
	rollout rollAccrotere "Accrotère" width:743 height:99 	(
		
		---- UI ----
		label 		'lbl_ep_mur' 				"Epaisseur mur :" 			pos:[8,9] 			width:100 height:19 align:#left
		spinner 	'spn_ep_mur' 			"" 								pos:[114,9] 		width:100 height:16 range:[0,10000,0] type:#worldunits align:#left		
		label 		'lbl_ht_accrotere' 		"Hauteur accrotère :" 	pos:[264,9] 		width:60 	height:19 align:#left
		spinner	'spn_ht_accrotere' 	"" 								pos:[324,9] 		width:100 height:16 range:[0,10000,0] type:#worldunits align:#left
		
		label 		'lbl_ep_couvertine' 	"Epaisseur couvertine :"	pos:[8,29] 		width:100 height:19 align:#left
		spinner 	'spn_ep_couvertine' 	"" 								pos:[114,29] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left		
		label 		'lbl_ht_couvertine' 	"Hauteur couvertine :" 	pos:[264,29] 	width:60 	height:19 align:#left
		spinner	'spn_ht_couvertine' 	"" 								pos:[324,29] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left
		
		
		---- fonctions ----
		fn actualiser = (
			spn_ep_mur.value 			= prefs.ep_mur
			spn_ht_accrotere.value 		= prefs.ht_accrotere		
			spn_ep_couvertine.value 	= prefs.ep_couvertine
			spn_ht_couvertine.value 	= prefs.ht_couvertine		
		)
		
		---- evenements ----
		on rollAccrotere open do actualiser ()
		
		on  spn_ep_mur			changed	val 	do (	
			prefs.ep_mur	=	val
			prefs.sauvegarder()		
		)
		on  spn_ht_accrotere			changed	val 	do (	
			prefs.ht_accrotere	=	val
			prefs.sauvegarder()		
		)
		on  spn_ep_couvertine			changed	val 	do (	
			prefs.ep_couvertine	=	val
			prefs.sauvegarder()		
		)
		on  spn_ht_couvertine			changed	val 	do (	
			prefs.ht_couvertine	=	val
			prefs.sauvegarder()		
		)
		
	)	-- fin rollout Accrotère --
	
	
	---- Rollout deux pans  ---------------------------------------------------------------------------------------------
	rollout rollDeuxPans "2 pans" width:743 height:99 	(
		
		---- UI ----
		label 		'lbl_htSsPlaf' 	"Hauteur sous plaf. :" 	pos:[8,9] 		width:100 height:19 align:#left
		spinner 	'spn_htSsPlaf' 	"" 								pos:[114,9] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left		
		label 		'lbl_epDalle' 		"Ep. dalle :" 					pos:[264,9] 	width:60 	height:19 align:#left
		spinner	'spn_epDalle' 	"" 								pos:[324,9] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left
		
		---- fonctions ----
		fn actualiser = (
			spn_htSsPlaf.value 	= prefs.ht_etage
			spn_epDalle.value 		= prefs.ep_dalle			
		)
		
		---- evenements ----
		on rollEtage open do actualiser ()
		on spn_htSsPlaf changed val do (
			prefs.ht_etage	=	val
			prefs.sauvegarder()
		)
		on spn_epDalle changed val do (
			prefs.ep_dalle	=	val
			prefs.sauvegarder()
		)
		
	)	-- fin Rollout deux pans   --
	
	
	---- Rollout 4 pans  ---------------------------------------------------------------------------------------------
	rollout rollQuatrePans "4 pans" width:743 height:99 	(
		
		---- UI ----
		label 		'lbl_htSsPlaf' 	"Hauteur sous plaf. :" 	pos:[8,9] 		width:100 height:19 align:#left
		spinner 	'spn_htSsPlaf' 	"" 								pos:[114,9] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left		
		label 		'lbl_epDalle' 		"Ep. dalle :" 					pos:[264,9] 	width:60 	height:19 align:#left
		spinner	'spn_epDalle' 	"" 								pos:[324,9] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left
		
		---- fonctions ----
		fn actualiser = (
			spn_htSsPlaf.value 	= prefs.ht_etage
			spn_epDalle.value 		= prefs.ep_dalle			
		)
		
		---- evenements ----
		on rollEtage open do actualiser ()
		on spn_htSsPlaf changed val do (
			prefs.ht_etage	=	val
			prefs.sauvegarder()
		)
		on spn_epDalle changed val do (
			prefs.ep_dalle	=	val
			prefs.sauvegarder()
		)
		
	)	-- fin Rollout 4 pans   --
	
	
	---- Rollout de Baies ---------------------------------------------------------------------------------------------
	rollout rollBaies "Baies" width:743 height:99 	(
-- 		button 'btn_appliquer' "Appliquer" pos:[624,9] width:108 height:82 align:#left
		
		label 				'lbl_allege' 				"Allège :" 		pos:[8,7] 			width:100 height:19 align:#left
		spinner 			'spn_ht_allege' 			"" 				pos:[114,9] 		width:100 height:16 range:[0,10000,0] type:#worldunits align:#left		
		
		label 				'lbl_larg_fenetre' 		"Largeur :" 	pos:[264,29] 	width:60 height:19 align:#left
		spinner 			'spn_larg_fenetre' 		"" 				pos:[324,31] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left
		label				'lbl_ht_fenetre' 			"Hauteur :" 	pos:[449,29] 	width:60 height:19 align:#left
		spinner			'spn_ht_fenetre' 		"" 				pos:[509,31] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left
		label 				'lbl_nbr_fenetre' 		"Fenetres :" 	pos:[9,29] 		width:100 height:19 align:#left
		spinner 			'spn_nbr_fenetre' 		"" 				pos:[114,30] 	width:100 height:16 range:[0,10000,0] type:#integer scale:1 align:#left
		radiobuttons 	'rdo_align_fenetre'		"Alignement" pos:[9,56] 		width:235 height:30 labels:#("Gauche", "Centre", "Droite") default:1 columns:3 align:#left
		label 				'lbl_esp_fenetre' 		"Espacmt. :" 	pos:[449,70] 	width:60 height:19 align:#left
		spinner 			'spn_esp_fenetre'		"" 				pos:[509,71] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left
		label 				'lbl_decal_fenetre' 		"Décalage :" 	pos:[264,70] 	width:60 height:19 align:#left
		spinner 			'spn_decal_fenetre' 	"" 				pos:[324,71] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left
	
		
		---- fonctions ----
		fn actualiser = (
			spn_ht_allege.value 				= prefs.ht_allege
			spn_larg_fenetre.value 			= prefs.larg_fenetre
			spn_ht_fenetre.value 			= prefs.ht_fenetre
			spn_nbr_fenetre.value 			= prefs.nbr_fenetre
			rdo_align_fenetre.state 			= prefs.align_fenetre
			spn_esp_fenetre.value 			= prefs.esp_fenetre
			spn_decal_fenetre.value 		= prefs.decal_fenetre
			
			---- on gere les activité des boutons	----
			lbl_decal_fenetre.enabled 		= ( rdo_align_fenetre.state != 2 )
			spn_decal_fenetre.enabled 	= ( rdo_align_fenetre.state != 2 )
			
		)
		
		
		---- evenements ----
		on rollBaies open do actualiser ()
		
		on  spn_ht_allege			changed	val 	do (	
			prefs.ht_allege	=	val
			prefs.sauvegarder()		
		)
		on  spn_larg_fenetre			changed	val 	do (	
			prefs.larg_fenetre	=	val
			prefs.sauvegarder()		
		)
		on  spn_ht_fenetre			changed	val 	do (	
			prefs.ht_fenetre	=	val
			prefs.sauvegarder()		
		)
		on  spn_nbr_fenetre			changed	val 	do (	
			prefs.nbr_fenetre	=	val
			prefs.sauvegarder()		
		)
		on  rdo_align_fenetre			changed		arg 	do (	
			
			--- on gere les preferences -----
			prefs.align_fenetre	=	arg
			prefs.sauvegarder()
			actualiser ()
			
		)
		on  spn_esp_fenetre			changed	val 	do (	
			prefs.esp_fenetre	=	val
			prefs.sauvegarder()		
		)
		on  spn_decal_fenetre			changed	val 	do (	
			prefs.decal_fenetre	=	val
			prefs.sauvegarder()		
		)
		
		
		
	)	-- fin rollout Baies --

	
	---- Rollout 2 ventaux  ---------------------------------------------------------------------------------------------
	rollout rollDeuxVentaux "2 ventaux" width:743 height:99 	(
		
		---- UI ----
		label 		'lbl_htSsPlaf' 	"Hauteur sous plaf. :" 	pos:[8,9] 		width:100 height:19 align:#left
		spinner 	'spn_htSsPlaf' 	"" 								pos:[114,9] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left		
		label 		'lbl_epDalle' 		"Ep. dalle :" 					pos:[264,9] 	width:60 	height:19 align:#left
		spinner	'spn_epDalle' 	"" 								pos:[324,9] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left
		
		---- fonctions ----
		fn actualiser = (
			spn_htSsPlaf.value 	= prefs.ht_etage
			spn_epDalle.value 		= prefs.ep_dalle			
		)
		
		---- evenements ----
		on rollEtage open do actualiser ()
		on spn_htSsPlaf changed val do (
			prefs.ht_etage	=	val
			prefs.sauvegarder()
		)
		on spn_epDalle changed val do (
			prefs.ep_dalle	=	val
			prefs.sauvegarder()
		)
		
	)	-- fin Rollout 2 ventaux   --
	
	
	---- Rollout 2 ventaux allege ---------------------------------------------------------------------------------------------
	rollout rollDeuxVentauxAllege "2 ventaux avec allège" width:743 height:99 	(
		
		---- UI ----
		label 		'lbl_htSsPlaf' 	"Hauteur sous plaf. :" 	pos:[8,9] 		width:100 height:19 align:#left
		spinner 	'spn_htSsPlaf' 	"" 								pos:[114,9] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left		
		label 		'lbl_epDalle' 		"Ep. dalle :" 					pos:[264,9] 	width:60 	height:19 align:#left
		spinner	'spn_epDalle' 	"" 								pos:[324,9] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left
		
		---- fonctions ----
		fn actualiser = (
			spn_htSsPlaf.value 	= prefs.ht_etage
			spn_epDalle.value 		= prefs.ep_dalle			
		)
		
		---- evenements ----
		on rollEtage open do actualiser ()
		on spn_htSsPlaf changed val do (
			prefs.ht_etage	=	val
			prefs.sauvegarder()
		)
		on spn_epDalle changed val do (
			prefs.ep_dalle	=	val
			prefs.sauvegarder()
		)
		
	)	-- fin  rollDeuxVentauxAllege   --
	
	
	------------------------------------------------------------
	---- Fonctions	----------------------------------------
	------------------------------------------------------------
		
	
	---- Pour fonctionnement du rollout	----
	fn actualiserUI = (
		
		---- mise à jour des boutons ----
		b_actif = outils.estValide ()
		for bouton in boutons do 
			bouton.enabled = b_actif
		
	)
	fn actualiserSousRollout = (
		rollEtage.actualiser ()
		rollAccrotere.actualiser ()
		rollDeuxPans.actualiser ()
		rollQuatrePans.actualiser ()
		rollBaies.actualiser ()
		rollDeuxVentaux.actualiser ()
		rollDeuxVentauxAllege.actualiser ()
	)
	fn fermerSsRollouts = (
		rollEtage.open						=false
		rollAccrotere.open					=false
		rollDeuxPans.open					=false
		rollQuatrePans.open				=false
		rollBaies.open						=false
		rollDeuxVentaux.open			=false
		rollDeuxVentauxAllege.open	=false
	)
	fn initialiser = (
		
		---- creation des structures ----
		const 	= constructionStruct ()
		outils 	= outilsStruct ()
		matID 	= matIDStruct ()
		prefs		= prefsStruct ()
		
		---- le tableau des boutons de l'interface ----
		boutons = #( btn_etage, btn_accrotere, btn_pansDeux, btn_pansTrois, btn_pansQuatre, btn_baies, btn_ventDeux, btn_ventDeuxAllege, btn_balcon, btn_loggia )
		
		---- actualiser l'interface ----
		actualiserUI ()
		
		---- les ecouteurs ----
		fn ecouterChangeEtat		ev nd = 	actualiserUI ()		
		ecouteurChangeEtat = NodeEventCallback 	mouseUp:true 	delay:1000	selectionChanged:ecouterChangeEtat 		subobjectSelectionChanged:ecouterChangeEtat
		callbacks.addScript #sceneRedo "rollConstruction.actualiserUI()" id:#Perso_construction
		callbacks.addScript #sceneUndo "rollConstruction.actualiserUI()" id:#Perso_construction
		
		---- les rollout dans le sousRoll -----
		AddSubRollout sousRoll	 rollEtage 
		AddSubRollout sousRoll	 rollAccrotere 
		AddSubRollout sousRoll	 rollDeuxPans 
		AddSubRollout sousRoll	 rollQuatrePans 
		AddSubRollout sousRoll	 rollBaies 
		AddSubRollout sousRoll	 rollDeuxVentaux 
		AddSubRollout sousRoll	 rollDeuxVentauxAllege 
		
		fermerSsRollouts ()
		
	)
	fn fermer = (
		
		--- vider ecouteur	 ---
		ecouteurChangeEtat = undefined
		callbacks.removeScripts #sceneRedo id:#Perso_construction
		callbacks.removeScripts #sceneUndo id:#Perso_construction
		gc light:true
		
		---- update le bouton macro	----
		estOuvert = false
		updateToolbarButtons()
		
	)
	fn togglerDetails _state = (
		case _state of (
			true:		(
				btn_details.text = "-"
				rollConstruction.height = 375
			)
			false:	(
				btn_details.text = "+"
				rollConstruction.height = 78
			)
		)
	)
	
	------------------------------------------------------------
	---- Evenements -----------------------------------------
	------------------------------------------------------------
	---- rollout	----
	on rollConstruction open  			do 	initialiser ()
	on rollConstruction close  			do	fermer ()
	
	---- cliques gauche	----
	on btn_etage 				pressed	do 	const.etage ()
	on btn_accrotere 			pressed	do 	const.accrotere ()
	on btn_pansDeux 			pressed do 	const.pansDeux ()
	on btn_pansTrois 			pressed do 	const.pansTrois  ()
	on btn_pansQuatre 		pressed do 	const.pansQuatre ()
	on btn_baies			 		pressed do 	const.baies ()
	on btn_ventDeux 			pressed do 	const.ventDeux ()
	on btn_ventDeuxAllege 	pressed do 	const.ventDeuxAllege ()
	on btn_balcon 				pressed do 	const.balcon ()
	on btn_loggia 				pressed do 	const.loggia ()
	
	---- cliques droit	----
	on btn_etage 				rightclick 	do 	(
		fermerSsRollouts ()
		rollEtage.open		=	true		
	)
	on btn_accrotere 				rightclick 	do 	(
		fermerSsRollouts ()
		rollAccrotere.open		=	true		
	)
	on btn_baies 				rightclick 	do 	(
		fermerSsRollouts ()
		rollBaies.open		=	true		
	)
	
	
	---- UI ----
	on btn_details 				changed _state 	do togglerDetails _state	
	on btn_defauts 				pressed 			do ( 
		prefs.resetFichier ()
		prefs = prefsStruct ()
		actualiserSousRollout  ()
	)
	
)	-- fin rollout

rollConstruction






