;***************************************************************************
	THUMB	
	REQUIRE8
	PRESERVE8

;**************************************************************************
;  Fichier Vierge.asm
; Auteur : V.MAHOUT
; Date :  12/11/2013
;**************************************************************************

;***************IMPORT/EXPORT**********************************************

	EXPORT Allume_LED
	EXPORT Eteint_LED

;**************************************************************************



;***************CONSTANTES*************************************************

	include REG_UTILES.inc 

;**************************************************************************


;***************VARIABLES**************************************************
	 AREA  MesDonnees, data, readwrite
;**************************************************************************

PORTBSET EQU 0x40010C10
PORTBRESET EQU 0x40010C14
PIN10 EQU 0x01 << 10	


;**************************************************************************


;***************CODE*******************************************************
   	AREA  moncode, code, readonly
;**************************************************************************


;########################################################################
; Proc?dure ALLUME_LED
;########################################################################
; Change la valeur du pin 10 pour allumer la LED (Set)

; Param?tre entrant  : /
; Param?tre sortant  : /
; Variables globales : /
; Registres modifi?s : R1, R2
; R1 <- Adresse PORTBSET
; R2 <- Set le pin10 ? 1 
;------------------------------------------------------------------------


Allume_LED PROC
		PUSH {R1-R2}
		LDR R1, = PORTBSET		
		LDR R2, = PIN10
		STR R2, [R1]		; PortB.Set <- 0.01 << 10
		POP {R1-R2}
		BX LR
		ENDP

;########################################################################
; Proc?dure ETEINT_LED
;########################################################################
; Change la valeur du pin 10 pour ?teindre la LED (Reset)

; Param?tre entrant  : /
; Param?tre sortant  : /
; Variables globales : /
; Registres modifi?s : R1, R2
; R1 <- Adresse PORTBRESET
; R2 <- Set le pin10 ? 1 
;------------------------------------------------------------------------


Eteint_LED PROC
		PUSH {R1-R2}
		LDR R1, = PORTBRESET
		LDR R2, = PIN10
		STR R2, [R1]		; PortB.Reset <- 0.01 << 10
		POP {R1-R2}
		BX LR
		ENDP




;**************************************************************************
	END