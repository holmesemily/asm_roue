		

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

	IMPORT Init_Cible
	IMPORT Allume_LED
	IMPORT Eteint_LED

	EXPORT main
	
;*******************************************************************************


;*******************************************************************************
	AREA  mesdonnees, data, readwrite
		
PORTAINPUT EQU 0x40010808
OLD_ETAT   DCW 0x0
NB EQU 4


;*******************************************************************************
	
	AREA  moncode, code, readonly
		


;*******************************************************************************
; Procédure principale et point d'entrée du projet
;*******************************************************************************
main  	PROC 
	
; Algorithme détection fronts montants 
;	debut: 
;			Old_Etat = LireCapteur
;			while(1)
;				if (Capteur == 0) then
;					while (1)
;						if (Capteur == 1 && Old_Etat == 0) then
;							Allume_Led;
;							Old_Etat = 1;
;							B début;
;						else if (Capteur == 1 && Old_LED == 1) then
;							Eteint_Led;
;							Old_Etat = 0;
;							B début;
;						endif
;					end loop
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
		
		LDR R4, = NB
		STRB R4, [R4]
		 

Debut	LDRH R0, [R1]
		AND R0, #0x100	   		; R0 = LireCapteur
		LDRH R2, [R3]
		
		CMP R4, #0
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
		SUB R4, #1				; décrémenter le compteur
		B Debut
	  
OldEtatVrai 					; if (Capteur == 1 && Old_Etat == 1) then
		BL Eteint_LED
		MOV R2, #0
		STRH R2, [R3]
		SUB R4, #1				; décrémenter le compteur
		B Debut

Fin
		BL Allume_LED
		B .
		ENDP

	END


;*******************************************************************************
;		Allumer/Eteindre suivant valeur du capteur
;Debut   
;		LDR R0, = PORTAINPUT
;		LDRH R0, [R0] 
;		AND R0, #0x100   	; R0 = Capteur
;		
;		CMP R0, #0x100
;		BNE CapteurFaux
;		BL Allume_LED
;		B Debut
;		
;CapteurFaux 
;		BL Eteint_LED
;		B Debut
;		
;		
;		B .			 ; boucle infinie terminale...
;*******************************************************************************

;*******************************************************************************
;		Ancien code pour allumer/éteindre

;		LDR R1, = 0X40010C0C
;		LDRH R3, [R1, #10]   ; R3 = PortB.Output
;		MOV R4, R3           ; R4 = Etat_PortB <- PortB.Output
;		ORR R4, R4, R2		 ; Etat_PortB <- Etat_PortB ou 0.01 << 10
;		STRH R4, [R1]	 ; PortB.Output <- Etat_PortB
;		
;		LDRH R4, [R1, #10]   ; Etat_PortB = <-(PortB.Output)	 
;		MVN R2, R2 			 ; NOT (0.01 << 10)
;		AND R3, R3, R2	     ; Etat_PortB = (Etat_PortB) et not(0x01 << 10)
;		STRH R4, [R1]   ; (PortB.Output)= <- (Etat_PortB)

;*******************************************************************************
