
GLOBAL  archi 


-----------------------------------------------------
----	Outils 	---------------------------------
-----------------------------------------------------
---- Tableau ----
struct tableau_struct (
	
	-- 	Renvois true si  #premierTab  est égale à   #deuxiemeTab. --
	fn comparer  tab1 tab2  = (
		local result = true
		if tab1.count != tab2.count then
			result = false
		else
			for i = 1 to tab1.count do
				if tab1[i] != tab2[i] do result = false
		result
	),
	
	-- 	Supprime les doublons de  #tableau de tableaux. --
	fn supprimerDoublons 	 tableauDeTableaux  = (
		for i = 1 to tableauDeTableaux.count do (
			for j = tableauDeTableaux.count to i+1 by -1 do (
				test = ( comparer  tableauDeTableaux[i] 	tableauDeTableaux[j] )
				if test do
					deleteItem tableauDeTableaux	 j
			)--end j loop
		)--end i loop
	)
	
) -- fin struct tableau --


---- Outils ----
struct outils_struct (
	---- MEMBRES ----
	tableau,
	
	---- EVENEMENTS ----
	on create do tableau = tableau_struct ()
	
) -- fin struct outils --





-----------------------------------------------------
----	Ma,nipulations 	-------------------------
-----------------------------------------------------

---- Modél ----
struct model_struct (
	
	fn preparer noeud:$ =(
		
		-- Convertion en EditPoly --
		convertToPoly noeud
		
		-- Application de L'idMat du mur partout --
		subobjectLevel = 4
		polyop.setFaceSelection noeud #{1..(polyop.getNumFaces noeud)}
		local IDmur = 1
		noeud.EditablePoly.setMaterialIndex 		IDmur		1
		
		---- Appliquer un nouveau materiaux Batiment ---
		archi.materiau.nouveau ()
		
		---- deselectionner les faces ----
		polyop.setFaceSelection noeud #{}
		
	)
	
) -- fin struct Faces --



---- Faces ----
struct faces_struct (
	
	---- Renvois les faces sélectionnées de noeud  ----
	fn selection noeud:$ = (
		polyop.getFaceSelection  noeud	
	),
	---- Selectionne les faces de noeud  ----
	fn selectionner faces noeud:$ =(
		polyop.setFaceSelection  noeud  faces
	),
	
	
	
	
	---- Renvois le centre de la face ----
	fn centre		face 	noeud:$  vMax:false  marquer:false  = (
	
		local result = [0,0,0]
		
		---- la version max fait  une position  moyenne de tout les points , => pb si 5points sur  la face par ex ----
		if vMax then
			result = polyop.getFaceCenter noeud  face
		
		---- debut de version centre perso qui deconne ----
		else (
			
			local listePoints 							= polyop.getFaceVerts  	noeud	face
			local pointsAlignesVerticalement		= #()
			local ptsResult 							= #()
			
			---- regrouper les points alignés verticalement	----
			for  i=1 to listePoints.count do (
				
				local	ID_pt_1 		= listePoints[ i ] 
				local	pt_1 			= noeud.verts[ ID_pt_1 ]				
				local resultTmp 	= #()
				
				for  j=1 to listePoints.count do (
					ID_pt_2 = listePoints[ j ] 					
					pt_2 = noeud.verts[ ID_pt_2 ]
					
					if floor (  pt_1.position.x * 10 )	== floor ( pt_2.position.x * 10 ) do 
						if floor ( pt_1.position.y * 10 ) == floor ( pt_2.position.y * 10 ) do (
							if pt_1.position.z < pt_2.position.z then (
								appendIfUnique resultTmp 		ID_pt_1
								appendIfUnique resultTmp 		ID_pt_2
							) else (
								appendIfUnique resultTmp 		ID_pt_2
								appendIfUnique resultTmp 		ID_pt_1
							)
						)
					
				)
				if resultTmp.count == 2 do 	(
					appendIfUnique  pointsAlignesVerticalement  resultTmp[1]
					appendIfUnique  pointsAlignesVerticalement  resultTmp[2]
				)
				
			)
			

			ptsResult = pointsAlignesVerticalement
			
			archi.points.selectionner 	ptsResult
			
			
			
			---- suppression des couples en trop ----
			local couplesPtsAGarder = #()
			if ( ptsResult.count > 2 ) do (
				
				for IDpt_1 = 1 to ( ptsResult.count ) by 2 do  (
					local distMax = 0.
					local ptsAGarder =#()
					for IDpt_2 = IDpt_1 +2 to ( ptsResult.count ) by 2 do  (
						local dist = length ( noeud.verts[ ptsResult[IDpt_1] ].position - noeud.verts[ ptsResult[IDpt_2]  ].position ) 
						if dist >  distMax then (
							distMax = dist
							ptsAGarder[1] = ptsResult[IDpt_1]
							ptsAGarder[2] = ptsResult[IDpt_1+1]
							ptsAGarder[3] = ptsResult[IDpt_2] 
							ptsAGarder[4] = ptsResult[IDpt_2+1] 
						)
					)
					if ptsAGarder.count  != 0 do (
						
						if couplesPtsAGarder.count == 0 then
							couplesPtsAGarder =  PtsAGarder
						else (
							distBack = length ( noeud.verts[ couplesPtsAGarder[1] ].position - noeud.verts[ couplesPtsAGarder[3]  ].position ) 
							distNew = length ( noeud.verts[ ptsAGarder[1] ].position - noeud.verts[ ptsAGarder[3]  ].position ) 
							
							if distNew > distBack do
								couplesPtsAGarder =  PtsAGarder
						)
					)
				)
				
			) 
			
			---- moyenne des points hauts et bas	----
			result = [0,0,0]
			if couplesPtsAGarder.count != 0 then (
				for IDpt in couplesPtsAGarder do  (
					result += noeud.verts[ IDpt ].position
					if marquer do ptMarque = point name:(uniquename "POINT") 	pos:noeud.verts[ IDpt ].position
				)
				result = result / 4
			) else (
				result = centre		face 	noeud:noeud  vMax:true  marquer:false 
			)
			
			if result == undefined do 
				result = face 	noeud:noeud  vMax:true  --marquer:marquer
			
		)
		
		if marquer do ptMarque = point name:(uniquename "ptOrigine") pos:result
		
		result
		
	),	
	---- 	Renvois l'altitude minimum des points des faces. (cm.)  ----
	fn Zmin 	noeud:$  faces:(selection()) = (
		
		local pointLePlusBas
		
		for face in faces do (
			listePoints = polyop.getFaceVerts  	noeud	face
			for IDpt in listePoints do (
				pt = noeud.verts[IDpt]
				if pointLePlusBas == undefined do pointLePlusBas = pt.position.z
				if pointLePlusBas > pt.position.z do pointLePlusBas = pt.position.z
			)
		)			
		
		pointLePlusBas	
	),	
	---- 	Renvois la hauteur de la face. (cm.) ----
	fn hauteur 	face 	noeud:$   = (
		local listePoints = polyop.getFaceVerts  	noeud	face
		local result = 0, mini = 10000000000, maxi = 0
		for  pt in listePoints 	do (
			pt = noeud.verts[ pt ]		
			if pt.position.z < mini 	do mini 	= pt.position.z
			if pt.position.z > maxi  do maxi 	= pt.position.z
		)
		result = maxi  - mini
		result
	),	
	---- 	Renvois la largeur de la face. (cm.) ----
	fn largeur 	face 	noeud:$   = (
		local listePoints = polyop.getFaceVerts  	noeud		face
		local result = 0
		for  i=1 to listePoints.count-1 do (
			pt_1 = noeud.verts[ listePoints[ i ] ]				
			for  j=i+1 to listePoints.count do (				
				pt_2 	= noeud.verts[ listePoints[ j ] ]
				dist 	= length ( pt_2.position - pt_1.position )
				if pt_1.position.z == pt_2.position.z and dist > result
					do result = dist
			)
		)
		result	
	),
	---- 	Renvois la normal de la face.  ----
	fn normal 	face 	noeud:$   marquer:false  = (
		local result = polyop.getFaceNormal noeud face
		if marquer do (
			ptMarque = point name:(uniquename "pt Normal" ) \
									axistripod:on cross:off Box:off centermarker:off
			ptMarque.transform 	= matrixfromnormal  result
			ptMarque.pos 			= centre		face
		)
		result
	),
	---- 	Renvois l'origine de la face. ----
	fn origine 	face 	noeud:$   marquer:false = (
		
		local centreFace 		= centre	face	noeud:noeud 	vMax:false
		local largeurFace			= largeur	face	noeud:noeud
		local normalFace 		= normal	face	noeud:noeud
		local normalFaceRotZ	= normalFace * rotateZMatrix 90 
		local result					= centreFace + normalFaceRotZ * ( -largeurFace/2 ) 
		
		if marquer do (
			pt = point 	name:( uniquename "pt Origine" ) 		\
							axistripod:off cross:on Box:off centermarker:off
			pt.transform = matrixfromnormal  ( normal 	face )
			pt.pos = result
		)
		
		result
	),
	
	
	
	
	
	
	---- Renvois les faces adjacentes à faces		----
	fn adjacentes	noeud:$  faces:(selection()) = (
		
		local selectBack 	= 	polyop.getFaceSelection  	noeud 
		local facesExtension
		local faces_a_retirer = faces 		
		
		noeud.EditablePoly.GrowSelection ()
		facesExtension	= selection ()
		for face in faces_a_retirer 	
			do facesExtension	[face] 	= false
		
		selectionner 	selectBack
		
		facesExtension
	),
	---- Renvois les faces adjacentes en dessous de faces	----
	fn enDessous	noeud:$ 	faces:(selection()) = (
		
		local facesDuBas	= #()
		
		for face in faces do (
			facesCadre = adjacentes	noeud:noeud	faces:#(face)
			local	faceDuBas
			for faceCadre in facesCadre do 
				if faceDuBas == undefined 	
					then faceDuBas = faceCadre
				else	if ( centre	faceCadre noeud:noeud	).z  <  ( centre	faceDuBas noeud:noeud	).z 	
					then faceDuBas = faceCadre
			
			append facesDuBas 	faceDuBas
		)
				
		facesDuBas
	),
	---- Renvois la faces la plus haute parmi les faces	----
	fn laPlusProcheDe  	ptReference 	noeud:$ 	faces:(selection()) = (
		local faceLaPlusProche
		local distMin = 1000000000000.0
		for face in faces do (
			centreFaceTmp 		= 	centre 	face		noeud:noeud  
			dist = length 	(  	centreFaceTmp - ptReference )
			if dist < distMin do (
				distMin = dist
				faceLaPlusProche = face
			)
		)
		faceLaPlusProche
	),
	---- Renvois la faces la plus haute parmi les faces	----
	fn laPlusHaute noeud:$ faces:(selection()) = (
		local  faceHaute 
		for face in faces do (
			if faceHaute == undefined do faceHaute = face
			if  ( centre 	face		noeud:noeud  ).z  > ( centre 	faceHaute	noeud:noeud  ).z do
				faceHaute = face
		)
		faceHaute
	),
	---- Renvois la faces la plus basse parmi les faces	----
	fn laPlusBasse	noeud:$ faces:(selection()) = (
		local  faceBasse 
		for face in faces do (
			if faceBasse == undefined do faceBasse = face
			if  ( centre 	face		noeud:noeud  ).z  < ( centre	faceBasse	noeud:noeud  ).z do
				faceBasse = face
		)
		faceBasse
	),
	---- Renvois les faces la plus haute parmi les faces	----
	fn lesPlusPetites	noeud:$ faces:(selection()) 	nombre:(floor ( (selection()).count /2 ) ) = (
		
		local result = #()
		
		while result.count != nombre do (
			local min = 1000000000000000000000000000.0
			local faceAAJouter
			for face in faces do (
				if polyop.getFaceArea noeud face <= min  and ( findItem result	 face ) == 0 do (
					faceAAJouter = face
					min 				= polyop.getFaceArea noeud	 face 
				)
			)
			append result 	faceAAJouter
		)
		result
	),
	---- Renvois les faces lplus grandes parmi les faces	----
	fn lesPlusGrandes	noeud:$ faces:(selection())	nombre:(floor ( (selection()).count /2 ) ) = (
		
		local result = #()
		
		while result.count != nombre do (
			local min = 0.0
			local faceAAJouter
			for face in faces do (
				if polyop.getFaceArea noeud face >= min  and ( findItem result	 face ) == 0 do (
					faceAAJouter = face
					min 				= polyop.getFaceArea noeud	 face 
				)
			)
			append result 	faceAAJouter
		)
		result
	),
	---- Renvois les arrêtes constituantes des faces ----
	fn arretes	noeud:$  faces:(selection()) = (
		local result = #()
		for face in faces do (
			local arretesTmp = polyop.getFaceEdges noeud  face
			for  arrete in arretesTmp do
				appendIfUnique result arrete
		)
		result
	),
	---- Renvois les arrêtes en commun entre les faces ----
	fn arretesCommunes	noeud:$ 	faces:(selection()) = (
		local result = #()
		faces = faces as array
		for IDface_1 = 1 to faces.count - 1 do (
			face_1 = faces[IDface_1]
			local arretesFace_1	=	arretes	noeud:noeud 	faces:#(face_1)
			for arreteFace_1 in arretesFace_1 do (
				
				for IDface_2 = IDface_1+1 to faces.count do (
					face_2 = faces[IDface_2]
					local arretesFace_2	=	arretes	noeud:noeud 	faces:#(face_2)
					if (findItem arretesFace_2  arreteFace_1 	 ) !=0  do
						appendIfUnique  result arreteFace_1
				)
				
			)
		) 
		result
	),
	---- Renvois les points constituants des faces ----
	fn points	noeud:$ faces:(selection()) = (
		local result = #()
		for face in faces do (
			local pts = polyop.getFaceVerts  noeud  face
			for  pt in pts do
				appendIfUnique result  pt 
		)
		result
	),
	
	
	
	
	
	
	
	
	
	---- 	Ajoute les faces au groupe de sélection nommé nomDuGroupe. -----
	fn grouper 	nomDuGroupe 	noeud:$  faces:(selection()) = (
		if noeud.faces[nomDuGroupe] == undefined  
		then		noeud.faces[nomDuGroupe] = 	faces
		else		(								
			local tabFaces = for face in noeud.faces[nomDuGroupe] collect face.index
			tabFaces += faces
			noeud.faces[nomDuGroupe] = tabFaces
		)
	),
	----- 	Retire les faces du groupe de sélection nommé nomDuGroupe	----
	fn degrouper 	nomDuGroupe 	noeud:$  facesARetirer:(selection())  = (
		if noeud.faces[nomDuGroupe] != undefined  do		(								
			local tabFaces = for face in noeud.faces[nomDuGroupe] collect 	face.index
				for  face in facesARetirer do (
					local idItem = findItem tabFaces   face
					if idItem >0 do deleteItem 	tabFaces  idItem
				)
			noeud.faces[nomDuGroupe] = tabFaces
		)
	),
	----- 	Renvois les faces appartenant au groupe	----
	fn getGroupe  nomDuGroupe 	noeud:$ = (
		local result = for face in noeud.faces[nomDuGroupe] collect face.index
		result 
	),
	
	
	
	
	---- 	Applique l'ID comme id matériau pour les  faces du nœud.	----
	fn matID    ID	noeud:$  faces:(selection())  = (
		noeud.EditablePoly.setMaterialIndex 		ID	1	
	),
	
	
	
	
	
	----	Extrude les faces du nœud de la  longueur (défaut : mode "by polygone").	-----
	fn extruder    longueur 	mode:2 	noeud:$  faces:(selection())  = (
		
		local selectBack 	= 	polyop.getFaceSelection  noeud 
		polyop.setFaceSelection  noeud  faces
		
		noeud.extrusionType 				= mode
		noeud.faceExtrudeHeight 		= longueur
		noeud.EditablePoly.buttonOp 	#Extrude
		
		polyop.setFaceSelection  noeud  selectBack
	),
	---- 	Incruste (inset) les faces du nœud de la  longueur (défaut : mode "by polygone"). ----
	fn incruster    longueur 	mode:1 	noeud:$   faces:(selection())  = (
		
		local selectBack 	= 	polyop.getFaceSelection  noeud 
		polyop.setFaceSelection  noeud  faces
		
		noeud.insetType = mode
		noeud.insetAmount = longueur
		noeud.EditablePoly.buttonOp 		#Inset
		
		polyop.setFaceSelection  noeud  selectBack
	),
	---- 	Divise verticalement les faces en ratio fois ----
	fn diviserVerticalement	ratio		noeud:$   faces:(selection())  = (
		
		---- Selection des faces (deja selectionnées dans la version de base)	----
		polyop.setFaceSelection  noeud 	faces
		
		local facesFinales = #()
		
		--- Decoupage des faces	----			
		for face in  faces do (
			
			local centreFace 		= 	centre	face	noeud:noeud 
			local largeurFace			=  largeur	face	noeud:noeud
			local origineFace			=  origine	face	noeud:noeud
			
			
			local normalFace			= 	normal	face	noeud:noeud
			local normalFaceRotZ	= 	normalFace * rotateZMatrix 90 	
			local translationRatio	= 	normalFaceRotZ * ( largeurFace / ratio )
			local translation 			= translationRatio
			
			---- Selection des faces (deja selectionnées dans la version de base)	----
			polyop.setFaceSelection  noeud 	#(face)
			
			
			for i = 1 to ( ratio - 1) do (
				
					---- Slice ---				
					polyop.slice noeud  	( selection () )			( Ray ( origineFace + translation )  normalFaceRotZ )
	
				
					---- le nom de la selection des "facades"----
					archi.faces.grouper 	"const_facades"
					for faceFinale in (archi.faces.selection()) do
						appendIfUnique facesFinales faceFinale
					
					---- Actualiser translation	----
					translation += translationRatio
					
			) -- fin for i
		) -- fin for face
		
		---- Selection des faces 	----
		polyop.setFaceSelection  noeud 	facesFinales
		
	),
	---- 	Soude les faces mitoyennes (retire arretes et points communs)----
	fn souder    noeud:$   faces:(selection())  = (
		
		local arretesASouder 		= arretesCommunes noeud:noeud 	faces:faces
		local pointsASouder			= archi.arretes.points 	noeud:noeud 	arretes:arretesASouder
		local subobjectLevelBAK 	= subobjectLevel
		
		archi.arretes.selectionner		arretesASouder
		subobjectLevel = 2
		noeud.EditablePoly.Remove ()
		
		archi.points.selectionner		pointsASouder
		subobjectLevel = 1
		noeud.EditablePoly.Remove ()
		
		subobjectLevel = subobjectLevelBAK
		
	)



) -- fin struct Faces --

---- Arrêtes ----
struct arretes_struct (
	
	---- Renvois les arretes sélectionnées de noeud  ----
	fn selection noeud:$ = (
		polyop.getEdgeSelection  noeud	
	),
	---- Selectionne les arretes de noeud  ----
	fn selectionner arretes noeud:$ =(
		polyop.setEdgeSelection  noeud  arretes
	),	
	---- Renvois les points constituants des arretes  ----
	fn points	noeud:$ 	arretes:(selection()) = (
		local result = #()
		for arrete in arretes do (
			local pts = polyop.getEdgeVerts  noeud  arrete
			for  pt in pts do
				appendIfUnique result  pt 
		)
		result
	)
	
) -- fin struct arretes -----

---- Points ----
struct points_struct (
	
	---- Renvois les points sélectionnées de noeud  ----
	fn selection noeud:$ = (
		polyop.getVertSelection   noeud	
	),
	---- Selectionne les points de noeud  ----
	fn selectionner points noeud:$ =(
		polyop.setVertSelection   noeud  ( points as bitArray )
	)
	
) -- fin struct opints -----



-----------------------------------------------------
----	Préferences 	-----------------------------
-----------------------------------------------------
---- Préferences  ----
struct prefs_struct (
	fn popo  = (
	)
) -- fin struct prefs -----




-----------------------------------------------------
----	Materiaux 	-----------------------------
-----------------------------------------------------
/* 
---- La structure des Materiaux ID ----
struct matIDStruct (
	
	mur 				= 1,
	menuiseries 	= 2,
	tablette			= 3,
	couvertine		= 4,
	verre  			= 5,
	garvier			= 6,
	terre  			= 7,
	couverture		= 8,
	goutiere			= 9,
	
	fn compte = (
		(getPropNames this).count - 1 		---- ( moins le nbre de fonctions (1) )
	)
	
)	-- fin struct matID -----
 */

--- La structure portant les parametre des materiaux ---
struct mat_struct (
	nom,
	
	diff_lvl	= .6,
	diff_col,
	
	refl_lvl,
	refl_col,
	refl_glos,
	refl_thin,
	
	refr_lvl,
	refr_col,
	refr_glos
)

--- La structure de gestion des materiaux ---
struct materiaux_struct (
	
	---- Membres  ----------------------------
	mats = #(), ---- porte les structures de mats ----	
	
	---- Fonction ----------------------------
	--- initialise les mats ----
	fn initialiser = (
		
		---- 1 ) Mur ----
		matTmp 			= mat_struct ()
		matTmp.nom 		= "Mur"
		matTmp.diff_lvl 	= .6
		matTmp.diff_col 	= color	255	255	255
		matTmp.refl_lvl 	= .2
		matTmp.refl_col 	= color	255	255	255
		matTmp.refl_glos	= .3
		matTmp.refl_thin	= true
		matTmp.refr_lvl	= 0
		matTmp.refr_col 	= color	255	255	255
		matTmp.refr_glos	= 1
		append 	mats	matTmp
		
		---- 2 ) Menuiseries ----
		matTmp 			= mat_struct ()
		matTmp.nom 		= "Menuiseries"
		matTmp.diff_lvl 	= .6
		matTmp.diff_col 	= color	20		20		20
		matTmp.refl_lvl 	= .7
		matTmp.refl_col 	= color	255	255	255
		matTmp.refl_glos	= .7
		matTmp.refl_thin	= true
		matTmp.refr_lvl	= 0
		matTmp.refr_col 	= color	255	255	255
		matTmp.refr_glos	= .7
		append 	mats	matTmp
		
		---- 3 ) Tablette ----
		matTmp 			= mat_struct ()
		matTmp.nom 		= "Tablette"
		matTmp.diff_lvl 	= .6
		matTmp.diff_col 	= color	20		20		20
		matTmp.refl_lvl 	= .7
		matTmp.refl_col 	= color	255	255	255
		matTmp.refl_glos	= .7
		matTmp.refl_thin	= true
		matTmp.refr_lvl	= 0
		matTmp.refr_col 	= color	255	255	255
		matTmp.refr_glos	= .7
		append 	mats	matTmp
		
		---- 4 ) Couvertine ----
		matTmp 			= mat_struct ()
		matTmp.nom 		= "Couvertine"
		matTmp.diff_lvl 	= .6
		matTmp.diff_col 	= color	20		20		20
		matTmp.refl_lvl 	= .7
		matTmp.refl_col 	= color	255	255	255
		matTmp.refl_glos	= .7
		matTmp.refl_thin	= true
		matTmp.refr_lvl	= 0
		matTmp.refr_col 	= color	255	255	255
		matTmp.refr_glos	= .7
		append 	mats	matTmp
		
		---- 5 ) Verre ----
		matTmp 			= mat_struct ()
		matTmp.nom 		= "Verre"
		matTmp.diff_lvl 	= .0
		matTmp.diff_col 	= color	0		0		0
		matTmp.refl_lvl 	= 1
		matTmp.refl_col 	= color	255	255	255
		matTmp.refl_glos	= .7
		matTmp.refl_thin	= true
		matTmp.refr_lvl	= .7
		matTmp.refr_col 	= color	255	255	255
		matTmp.refr_glos	= 1
		append 	mats	matTmp
		
		---- 6 ) Gravier ----
		matTmp 			= mat_struct ()
		matTmp.nom 		= "Gravier"
		matTmp.diff_lvl 	= .6
		matTmp.diff_col 	= color	50		50		50
		matTmp.refl_lvl 	= .2
		matTmp.refl_col 	= color	255	255	255
		matTmp.refl_glos	= .3
		matTmp.refl_thin	= true
		matTmp.refr_lvl	= 0
		matTmp.refr_col 	= color	255	255	255
		matTmp.refr_glos	= 1
		append 	mats	matTmp
		
		---- 7 ) Terre ----
		matTmp 			= mat_struct ()
		matTmp.nom 		= "Terre"
		matTmp.diff_lvl 	= .6
		matTmp.diff_col 	= color	80		30		30
		matTmp.refl_lvl 	= .2
		matTmp.refl_col 	= color	255	255	255
		matTmp.refl_glos	= .3
		matTmp.refl_thin	= true
		matTmp.refr_lvl	= 0
		matTmp.refr_col 	= color	255	255	255
		matTmp.refr_glos	= 1
		append 	mats	matTmp
		
		---- 8 ) Couverture ----
		matTmp 			= mat_struct ()
		matTmp.nom 		= "Couverture"
		matTmp.diff_lvl 	= .6
		matTmp.diff_col 	= color	100	100	150
		matTmp.refl_lvl 	= .2
		matTmp.refl_col 	= color	255	255	255
		matTmp.refl_glos	= .3
		matTmp.refl_thin	= true
		matTmp.refr_lvl	= 0
		matTmp.refr_col 	= color	255	255	255
		matTmp.refr_glos	= 1
		append 	mats	matTmp
		
		---- 9 ) Goutiere ----
		matTmp 			= mat_struct ()
		matTmp.nom 		= "Goutiere"
		matTmp.diff_lvl 	= .6
		matTmp.diff_col 	= color	20		20		20
		matTmp.refl_lvl 	= .7
		matTmp.refl_col 	= color	255	255	255
		matTmp.refl_glos	= .7
		matTmp.refl_thin	= true
		matTmp.refr_lvl	= 0
		matTmp.refr_col 	= color	255	255	255
		matTmp.refr_glos	= .7
		append 	mats	matTmp
		
	),
	--- Renvois un nouveau multiMat ---
	fn nouveau  noeud:$ 	= (		
		nouveauMat = Multimaterial numsubs:( mats.count )	name:"Archi - Bâtiment"		
		for i=1 to mats.count do	 (	
			local mat 						= mats[i]
			nouveauMat.names[i]		= mat.nom
			nouveauMat.materialList[i]	= CoronaMtl 	name:("Archi - " + mat.nom)		\
																	levelDiffuse:mat.diff_lvl				\
																	colorDiffuse:mat.diff_col			\
																	levelReflect:mat.refl_lvl				\
																	colorReflect:mat.refl_col			\
																	reflectGlossiness:mat.refl_glos	\			
																	thin:mat.refl_thin						\
																	levelRefract:mat.refr_lvl			\
																	colorRefract:mat.refr_col 			\
																	reflectGlossiness:mat.refr_glos
		)
		noeud.material = nouveauMat
		nouveauMat
	),
	
	
	/* ---- Applique à neoud un nouveau materiaux ---
	fn appliquer 	noeud:$		= (
		local nouveauMat = nouveau ()
		noeud.material = nouveauMat
	), */
	
	
	---- Evenements ----
	on create do initialiser ()
	
	
) -- fin struct prefs -----





-----------------------------------------------------
----	Modeler 	---------------------------------
-----------------------------------------------------
---- Modeler  ----
struct modeler_struct (
	fn division  = (
	)
) -- fin struct modeler -----



-----------------------------------------------------
----	Créer 	---------------------------------
-----------------------------------------------------
---- Créer  ----
struct creer_struct (
	fn popo  = (
		archi.sousSelection.faces.adjacentes ()
	)
) -- fin struct creer -----



-----------------------------------------------------
----	ARCHITECTURE 	-------------------------
-----------------------------------------------------
struct architecture_struct (
	
	------- structs -----------------------------
	-- Outils gobaux --
	outils,		---- Differents outils (manipulations de tableaux de tableaux ) --
	prefs,		---- Les préferenes utilisateur --
	
	-- Materiau --
	materiau,	---- La gestion des materiaux --
	
	-- Manipulations --
	model,		---- Manipulation du model complet --
	faces,		---- Manipulation des faces --
	arretes,		---- Manipulation des arretes --
	points,		---- Manipulation des points --
	
	-- Modélisation --
	modeler,		---- Outils de modélisation de base) --
	creer,		---- Outils de modélisation des éléments architecturaux --
	
	
	
	------- fonctions -----------------------------
	fn ouvrirRollout = (
	),
	fn fermerRollout = (
	),
	
	
	
	------- evenements -----------------------------
	on create do (
		outils 		= outils_struct ()
		model 		= model_struct ()
		materiau 	= materiaux_struct ()
		faces 		= faces_struct ()
		arretes 		= arretes_struct ()
		points 		= points_struct ()
		prefs 		= prefs_struct ()
		modeler 		= modeler_struct ()
		creer 		= creer_struct ()
	)
) -- fin struct ARCHITECTURE ----




---- Creation du struct principal ----
archi = architecture_struct ()







