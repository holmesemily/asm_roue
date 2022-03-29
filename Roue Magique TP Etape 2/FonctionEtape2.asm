;***************************************************************************
	THUMB	
	REQUIRE8
	PRESERVE8

;**************************************************************************
;  Fichier FonctionEtape2.asm
; Auteur : HOLMES Emily, RIST Samuel
; Date :  12/11/2013

; Fonctions:
; Set et Reset SCLK et SIN
; Allumer LED selon barette (diff�rents passages d'arguments)
; Temporiser N ms

;**************************************************************************

;***************IMPORT/EXPORT**********************************************

	EXPORT DriverGlobal
	EXPORT DriverReg
	EXPORT DriverPile
	EXPORT Tempo
		
	IMPORT Barette1
	IMPORT Barette2
	IMPORT DataSend
		
;**************************************************************************



;***************CONSTANTES*************************************************



;**************************************************************************


;***************VARIABLES**************************************************
	 AREA  MesDonnees, data, readwrite
;**************************************************************************

PORTASET EQU 0x40010810
PORTARESET EQU 0x40010814
PIN5 EQU 0x01 << 5
PIN7 EQU 0x01 << 7

;**************************************************************************


;***************CODE*******************************************************
   	AREA  moncode, code, readonly
;**************************************************************************


;########################################################################
; Proc�dure DriverGlobal
;########################################################################
; Allume le jeu de LED donn� en Barette1

; Param�tre entrant  : /
; Param�tre sortant  : /
; Variables globales : /
; Registres modifi�s : R0-R3

; R0 = NbLed, DataSend
; R1 = NbBit
; R2 = Valcourante (octet de LED)
; R3 sert de masque (bit de PF � 1)
;------------------------------------------------------------------------


DriverGlobal PROC
		PUSH{R14}
		BL SetSCLK
		MOV R0, #0			; R0 = NbLed = 0 
		
Debutpour
		MOV R1, #0			; R1 = NbBit = 1
		CMP R0, #47					
		BHI Finpour			; Pour NbLed = 0 � 47
		
		LDR R2, = Barette1
		LDRB R2, [R2, R0, LSL #1]	; R2 = Valcourante <- Barette1[NbLed]
		UXTB R2, R2					; Promotion de valcourante sur 32bits
		LSL R2, R2, #24				; Valcourante << 24
		
Debutpour2   
		CMP R1, #11
		BHI Finpour2			; Pour Nbbit = 0 � 11
		
		BL ResetSCLK
		MOV R3, #1
		LSL R3, R3, #31			; Mettre � 1 le bit de PF
		AND R3, R3, R2
		
		CMP R3, #0x80000000
		BNE Sinon			; Pf(Valcourante) = 1
		
		BL SetSIN
		B FinSi
		
Sinon	BL ResetSIN

FinSi	LSL R2, R2, #1		; Valcourante << 1
		BL SetSCLK
		ADD R1, #1
		B Debutpour2

Finpour2
		ADD R0, #1
		B Debutpour
Finpour
		BL ResetSCLK		
		MOV R1, #0
		LDR R0, = DataSend
		STR R1, [R0]
		POP {R14}
		BX LR
		ENDP
			
;########################################################################
; Proc�dure DriverReg
;########################################################################
; Affiche une barette de LED, argument pass� par r�f�rence

; Param�tre entrant  : R0
; Param�tre sortant  : /
; Variables globales : /
; Registres modifi�s : R1-R4

; R0 = Adresse de la barette de LED � afficher
; R1 = NbBit
; R2 = Valcourante (octet de LED)
; R3 sert de masque (bit de PF � 1)
; R4 = NbLed
;------------------------------------------------------------------------


DriverReg PROC
		PUSH{R0-R4, R14}
		BL SetSCLK
		MOV R4, #0				; R4 = NbLed = 0 
		
RegDebutpour
		MOV R1, #0				; R1 = NbBit = 1
		CMP R4, #47					
		BHI RegFinpour			; Pour NbLed = 0 � 47
		
		LDRB R2, [R0, R4, LSL #1]	; R2 = Valcourante <- Barette1[NbLed]
		UXTB R2, R2					; Promotion de valcourante sur 32bits
		LSL R2, R2, #24				; Valcourante << 24
		
RegDebutpour2   
		CMP R1, #11
		BHI RegFinpour2			; Pour Nbbit = 0 � 11
		
		BL ResetSCLK
		MOV R3, #1
		LSL R3, R3, #31			; Mettre � 1 le bit de PF dans R3
		AND R3, R3, R2
		
		CMP R3, #0x80000000
		BNE RegSinon			; Pf(Valcourante) = 1
		
		BL SetSIN
		B RegFinSi
		
RegSinon	BL ResetSIN

RegFinSi	LSL R2, R2, #1		; Valcourante << 1
		BL SetSCLK
		ADD R1, #1
		B RegDebutpour2

RegFinpour2
		ADD R4, #1
		B RegDebutpour
RegFinpour
		BL ResetSCLK		
		MOV R1, #0
		LDR R4, = DataSend
		STR R1, [R4]
		POP {R0-R4, R14}
		BX LR
		ENDP

;########################################################################
; Proc�dure DriverPile
;########################################################################
; Affiche une barette de LED, argument pass� par la pile syst�me

; Param�tre entrant  : R0 (pile systeme)
; Param�tre sortant  : /
; Variables globales : /
; Registres modifi�s : R1-R4, R7

; R0 = Adresse de la barette de LED � afficher
; R1 = NbBit
; R2 = Valcourante (octet de LED)
; R3 sert de masque (bit de PF � 1)
; R4 = NbLed
; R7 = enregistre SP avant pile syst�me
;------------------------------------------------------------------------


DriverPile PROC
		PUSH {R7}
		MOV R7, SP
		
		PUSH{R0-R4, R14}
		
		LDR R0, [R7, #4]
		
		BL SetSCLK
		MOV R4, #0			; R4 = NbLed = 0 
		
PileDebutpour
		MOV R1, #0			; R1 = NbBit = 1
		CMP R4, #47					
		BHI PileFinpour			; Pour NbLed = 0 � 47
		
		LDRB R2, [R0, R4, LSL #1]	; R2 = Valcourante <- Barette1[NbLed]
		UXTB R2, R2					; Promotion de valcourante sur 32bits
		LSL R2, R2, #24				; Valcourante << 24
		
PileDebutpour2   
		CMP R1, #11
		BHI PileFinpour2			; Pour Nbbit = 0 � 11
		
		BL ResetSCLK
		MOV R3, #1
		LSL R3, R3, #31				; Mettre � 1 le bit de PF dans R3
		AND R3, R3, R2
		
		CMP R3, #0x80000000
		BNE PileSinon			; Pf(Valcourante) = 1
		
		BL SetSIN
		B PileFinSi
		
PileSinon	BL ResetSIN

PileFinSi	LSL R2, R2, #1		; Valcourante << 1
		BL SetSCLK
		ADD R1, #1
		B PileDebutpour2

PileFinpour2
		ADD R4, #1
		B PileDebutpour
PileFinpour
		BL ResetSCLK		
		MOV R1, #0
		LDR R4, = DataSend
		STR R1, [R4]
		POP {R0-R4, R14}
		POP {R7}
		BX LR
		ENDP


;########################################################################
; Proc�dure Tempo
;########################################################################
; Temporiser pendant N ms
; Param�tre entrant  : R0
; Param�tre sortant  : /
; Variables globales : /
; Registres modifi�s : R1, R2

; R0 = N
; NOP r�p�t� R1 fois pour attendre 0.1ms
; R2 = 10N 

;------------------------------------------------------------------------

Tempo PROC
		PUSH{R1-R2}
		MOV R2, #10
		MUL R2, R0	; R2 = 10N (R0=N)

TDebutpour2
		MOV R1, #1000
		CMP R2, #0
		BEQ TFinpour2		
		
TDebutpour			; Boucle de 0.1ms
		CMP R1, #0
		BEQ TFinpour
		
		NOP
		SUB R1, #1
		B TDebutpour
		
TFinpour			; Fin boucle de 0.1ms
		SUB R2, #1 
		B TDebutpour2
		
TFinpour2
		POP {R1-R2}
		BX LR
		ENDP



;########################################################################
; Proc�dure SetSCLK, ResetSCLK
;########################################################################
; Set ou reset la clock SCLK pour valider la r�ception par le circuit

; Param�tre entrant  : /
; Param�tre sortant  : /
; Variables globales : /
; Registres modifi�s : R0, R1

; R0 = Adresse PortASet ou PortAReset
; R1 = Pin concern� (pin5)

;------------------------------------------------------------------------


SetSCLK PROC
		PUSH {R0-R1}
		LDR R0, = PORTASET
		LDR R1, = PIN5
		STR R1, [R0]
		POP {R0-R1}
		BX LR
		ENDP
		
		
ResetSCLK PROC
		PUSH {R0-R1}
		LDR R0, = PORTARESET
		LDR R1, = PIN5
		STR R1, [R0]
		POP {R0-R1}
		BX LR
		ENDP			


;########################################################################
; Proc�dure SetSIN, ResetSIN
;########################################################################
; Set ou Reset le SIN (envoyer valeurs des 16 leds)

; Param�tre entrant  : /
; Param�tre sortant  : /
; Variables globales : /
; Registres modifi�s : R0, R1

; R0 = Adresse PortASet ou PortAReset
; R1 = Pin concern� (pin7)
;------------------------------------------------------------------------

SetSIN PROC
		PUSH {R0-R1}
		LDR R0, = PORTASET
		LDR R1, = PIN7
		STR R1, [R0]
		POP {R0-R1}
		BX LR
		ENDP
		
		
ResetSIN PROC
		PUSH {R0-R1}
		LDR R0, = PORTARESET
		LDR R1, = PIN7
		STR R1, [R0]
		POP {R0-R1}
		BX LR
		ENDP			

;**************************************************************************
	END