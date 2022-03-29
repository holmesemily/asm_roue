;************************************************************************
; AUTEURS: HOLMES Emily, RIST Samuel
; Date de cr�ation: 21/03/2022

; PROGRAMME: 
; Allume ou Eteint LED sur d�tection de fronts montants
; S'arr�te apr�s NB fronts montants

; AUTRES FICHIERS: 
; FonctionEtape.asm -> Procedure eteindre/allumer LED

;************************************************************************
	THUMB	
	REQUIRE8
	PRESERVE8
;************************************************************************

	include REG_UTILES.inc


;************************************************************************
; 					IMPORT/EXPORT Syst�me
;************************************************************************

	IMPORT ||Lib$$Request$$armlib|| [CODE,WEAK]




; IMPORT/EXPORT de proc�dure           

	IMPORT Init_Cible
	IMPORT Allume_LED
	IMPORT Eteint_LED

	EXPORT main
	
;*******************************************************************************


;*******************************************************************************
	AREA  mesdonnees, data, readwrite
		
PORTAINPUT EQU 0x40010808	; Pour acc�der au capteur
OLD_ETAT   DCW 0x0 			; Ancien Etat du capteur
NB EQU 12					; Nb de fronts montants � d�tecter


;*******************************************************************************
	
	AREA  moncode, code, readonly
		


;*******************************************************************************
; Proc�dure principale et point d'entr�e du projet
;*******************************************************************************
main  	PROC 

;*******************************************************************************
; Algorithme d�tection fronts montants 

;	debut: 
;			Old_Etat = LireCapteur
;			while(1)
;				if (nb>0) then 
;				if (LireCapteur == 0) then
;					while (1)
;						if (LireCapteur == 1 && Old_Etat == 0) then
;							Allume_Led;
;							Old_Etat = 1;
;							nb--;
;							B d�but;
;						else if (LireCapteur == 1 && Old_LED == 1) then
;							Eteint_Led;
;							Old_Etat = 0;
;							nb--;
;							B d�but;
;						endif
;					end loop
;				endif
;				endif
;			end loop
;			
;*******************************************************************************
		
		MOV R0,#0
		BL Init_Cible;
		
		LDR R1, = PORTAINPUT
		LDRH R2, [R1]
		AND R2, #0x100
		LDR R3, = OLD_ETAT
		STRH R2, [R3]  			; R2 = OldEtat <- Capteur
		
		LDR R4, = NB			; R4 = Nb de r�p�titions
		 

Debut	LDRH R0, [R1]
		AND R0, #0x100	   		; R0 = LireCapteur
		LDRH R2, [R3]
		
		CMP R4, #0				; Saut � la fin si on a fait la boucle NB fois
		BEQ Fin
		CMP R0, #0
		BNE Debut 				 
	  
AttenteFront					; if Capteur == 0
		LDR R0, = PORTAINPUT
		LDRH R0, [R0]
		AND R0, #0x100
		
		CMP R0, #0x100
		BNE AttenteFront 
		CMP R2, #0
		BNE OldEtatVrai   
		
		BL Allume_LED			; if (Capteur == 1 && Old_Etat == 0) then
		MOV R2, #0x100
		STRH R2, [R3] 
		SUB R4, #1				; D�cr�menter le compteur
		B Debut
	  
OldEtatVrai 					; if (Capteur == 1 && Old_Etat == 1) then
		BL Eteint_LED
		MOV R2, #0
		STRH R2, [R3]
		SUB R4, #1				; D�cr�menter le compteur
		B Debut

Fin
		BL Allume_LED			; Laisser la LED allumee
		B .
		ENDP

	END


