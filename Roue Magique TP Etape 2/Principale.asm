;************************************************************************
; AUTEURS: HOLMES Emily, RIST Samuel
; Date de création: 22/03/2022
; Derniere modification: 29/03/2022

; PROGRAMME: 
; Alterner entre 2 barettes M fois ou jusqu'à ce que le capteur soit activé

; AUTRES FICHIERS: 
; FonctionEtape2.asm : définition des fonctions
; Lumiere.asm : définition des jeux de barettes

;************************************************************************
	THUMB	
	REQUIRE8
	PRESERVE8
;************************************************************************

	include REG_UTILES.inc


;************************************************************************
; 					IMPORT/EXPORT Système
;************************************************************************

	IMPORT ||Lib$$Request$$armlib|| [CODE,WEAK]


; IMPORT/EXPORT de procédure           

	IMPORT Barette1
	IMPORT Barette2
	;IMPORT DriverReg
	;IMPORT DriverGlobal
	IMPORT DriverPile
		
	IMPORT Tempo
	IMPORT Init_Cible

	EXPORT main
	
;*******************************************************************************


;*******************************************************************************
	AREA  mesdonnees, data, readwrite
		
PORTAINPUT EQU 0x40010808	; Pour accéder au capteur
M EQU 50					; M clignotements avant de s'arrêter


;*******************************************************************************
	
	AREA  moncode, code, readonly

;*******************************************************************************
; Procédure principale et point d'entrée du projet
;*******************************************************************************
main  	PROC 

		MOV R0,#1
		BL Init_Cible;		;Initialisation de la roue
	
		MOV R1, #M			; R1 = M
		

DebutBoucleCligno
		LDR R2, = PORTAINPUT
		LDRH R2, [R2]
		AND R2, #0x100		; Lire le capteur avec masque
		
		
		CMP R2, #0x100			
		BNE inf				; Si capteur = 1, stop 
		CMP R1, #0 
		BEQ inf				; Apres M clignotements, stop 

		LDR R0, = Barette1
		PUSH {R0}
		BL DriverPile
		ADD SP, #4			; Jeu 1
		
		MOV R0, #100
		BL Tempo			; Attendre R0 ms 
		
		LDR R0, = Barette2
		PUSH {R0}
		BL DriverPile
		ADD SP, #4			; Jeu 2
		
		MOV R0, #100
		BL Tempo			; Attendre R0 ms 
		
		SUB R1, #1
		B DebutBoucleCligno
		
inf 	B inf		
		ENDP

	END
		
; En tournant la roue, on a moins de chance d'activer le capteur au moment où on fait le CMP dans le programme
; Il y a beaucoup plus de chance de bouger le capteur quand le programme est en "tempo"


;*******************************************************************************




