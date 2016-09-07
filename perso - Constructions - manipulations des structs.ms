	archi.faces.selectionner	(archi.faces.enDessous())
	archi.faces.laPlusProcheDe pos
	archi.faces.selection()



	archi.faces.enDessous()
	archi.faces.selectionner	(archi.faces.laPlusProcheDe pos)

	archi.faces.laPlusHaute()

	archi.faces.selectionner ( archi.faces.laPlusHaute() )


	archi.faces.laPlusBasse()

	archi.faces.selectionner ( archi.faces.laPlusBasse() )
	redrawviews()

	archi.faces.lesPlusPetites()
	archi.faces.selectionner ( archi.faces.lesPlusPetites nombre:1 )

	archi.faces.lesPlusGrandes()
	archi.faces.selectionner ( archi.faces.lesPlusGrandes nombre:1)
	pos = $.pos


	archi.faces.arretes()
	archi.arretes.selectionner ( archi.faces.arretes() )


	archi.arretes.points()
	archi.points.selectionner ( archi.arretes.points() )



	archi.faces.grouper "Nom du groupe"
	archi.faces.selectionner ( archi.faces.getGroupe "Nom du groupe")



	archi.arretes.selectionner ( archi.faces.arretesCommunes () )

	archi.faces.matID 7

	archi.faces.extruder 7 mode:0

	archi.faces.incruster 2 mode:0





	archi.faces.diviserVerticalement	20


	archi.faces.origine ((archi.faces.selection() as array )[1]) marquer:true
	archi.faces.centre ((archi.faces.selection() as array )[1]) marquer:true 	vMax:false


archi.points.selectionner #(252,253)


					polyop.setSlicePlane $  ( Ray (archi.faces.centre 3 ) [-1,0,0] )  100
polyop.slice $  	(archi.faces.selection())			( Ray (archi.faces.centre 3 ) [-1,0,0] )


