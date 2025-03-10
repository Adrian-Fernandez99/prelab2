/*

Prelab2.asm

Created: 2/13/2025 11:07:00 PM
Author : Adri�n Fern�ndez

Descripci�n:
	Se realiza dos contadores binario de 4 bits.
	El conteo es visto por medio de LEDs en la protoboard.
	Se usan pushbuttons para el incremento y decrecimiento 
	de los valores.
	Por ultimo se suman ambos contadores y se muestran en 4
	leds aparte, una lad extra para mostrar overflow
*/

.include "M328PDEF.inc"		// Include definitions specific to ATMega328P
.cseg
.org 0x0000
.def COUNTER = R20			// Se define contador

// Configuraci�n de la pila
	LDI		R16, LOW(RAMEND)
	OUT		SPL, R16
	LDI		R16, HIGH(RAMEND)
	OUT		SPH, R16

// Configuraci�n del MCU
// Configurar Prescaler "Principal"
	LDI		R16, (1 << CLKPCE)
	STS		CLKPR, R16		// Habilitar cambio de PRESCALER
	LDI		R16, 0x04
	STS		CLKPR, R16		// Configurar Prescaler a 16 F_cpu = 1MHz

// Inicializar timer0
	CALL	INIT_TMR0
// Configurar PB5 como salida para usarlo como "LED"
	SBI		DDRC, 5			// Establecer bit PB5 como salida
	SBI		DDRC, 0
	CBI		PORTC, 5		// Obligar a LED a estar "APAGADO" inicialmente
	CBI		PORTC, 0
// Deshabilitar serial (esto apaga los demas LEDs del Arduino)
	LDI		R16, 0x00
	STS		UCSR0B, R16

// Main loop
MAIN_LOOP:
	IN		R16, TIFR0		// Leer registro de interrupci�n de TIMER0
	SBRS	R16, TOV0		// Salta si el bit 0 est "set" (TOV0 bit)
	RJMP	MAIN_LOOP		// Reiniciar loop
	SBI		TIFR0, TOV0		// Limpiar bandera de "overflow"
	LDI		R16, 131
	OUT		TCNT0, R16		// Volver a cargar valor inicial en TCNT0
	INC		COUNTER
	CPI		COUNTER, 125	// Se necesitan hacer 125 overflows para 100ms
	BRNE	MAIN_LOOP
	CLR		COUNTER			// Se reinicia el conteo de overflows
	CALL	SUMA			// Se llama al incremento del contador
	OUT		PORTC, R19		// Sale la se�al
	RJMP	MAIN_LOOP		// Regresa al main loop

// NON-Interrupt subroutines
INIT_TMR0:
	LDI		R16, (1<<CS01)
	OUT		TCCR0B, R16		// Setear prescaler del TIMER 0 a 8
	LDI		R16, 131
	OUT		TCNT0, R16		// Cargar valor inicial en TCNT0
	RET

SUMA:						// Funci�n para el incremento del primer contador
	INC		R19				// Se incrementa el valor
	SBRC	R19, 4			// Se observa si tiene m�s de 4 bits
	LDI		R19, 0x00		// En ese caso es overflow y debe regresar a 0
	RET

// Interrupt routines