/*

Prelab2.asm

Created: 2/13/2025 11:07:00 PM
Author : Adrián Fernández

Descripción:
	Se realiza dos contadores binario de 4 bits.
	El conteo es visto por medio de LEDs en la protoboard.
	Se usan pushbuttons para el incremento y decrecimiento 
	de los valores.
	Por ultimo se suman ambos contadores y se muestran en 4
	leds aparte, una lad extra para mostrar overflow
*/

.include "M328PDEF.inc" // Include definitions specific to ATMega328P
.cseg
.org 0x0000
.def COUNTER = R20		// Se define contador

// Configuración de la pila
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R16, HIGH(RAMEND)
	OUT SPH, R16

// Configuración del MCU

// Configurar Prescaler "Principal"
	LDI R16, (1 << CLKPCE)
	STS CLKPR, R16			// Habilitar cambio de PRESCALER
	LDI R16, 0x04
	STS CLKPR, R16			// Configurar Prescaler a 16 F_cpu = 1MHz

// Inicializar timer0
	CALL INIT_TMR0
// Configurar PB5 como salida para usarlo como "LED"
	SBI DDRB, 5				// Establecer bit PB5 como salida
	SBI DDRB, 0
	CBI PORTB, 5			// Obligar a LED a estar "APAGADO" inicialmente
	CBI PORTB, 0
// Deshabilitar serial (esto apaga los demas LEDs del Arduino)
	LDI R16, 0x00
	STS UCSR0B, R16