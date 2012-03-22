; Main entry point

; ------------------------------------------------------------------------------
; Hardware Details
;	- Using PIC16F819
;	- Clock: 20MHz Crystal across OSC1/OSC2
;	- PORTB:
;		- B0 is Midi Input from 6N137 Optocopuler
;		- B6:B7 is for UP00B Programmer
;		- B2: 10-bit PWM output ('fake' CV analog out).  The PIC18F2431 can support 4 14-bit PWM outs.
;		- B1,B3:B5 currently unsued
;	- PORTA:
;		- Debugging output data on A0:A4
;		- A5 is MCLR/Vpp for UP00B Programmer
;		- A6:A7 is for the crystal


	list	P=PIC16F819

#include p16f819.inc
#include inc/vars.inc


; ------------------------------------------------------------------------------
; External code refs
;
	extern	_MAIN		; Main App code
	extern	_SERVICE	; Interrupt handlers
	extern	_SETUP		; Setup code

; ------------------------------------------------------------------------------
; CONFIG
;	- Use 20MHz crystal, leaing all PORTB ports as I/O
;	- Disable watchdog timer
;	- PWM on RB2
	__config	_HS_OSC & _WDT_OFF & _CCPMX_RB2 & _BOREN_OFF & _PWRTE_ON


; ------------------------------------------------------------------------------
; Main entry and RESET vector
;
.RESET	org	0x0000
	call	_SETUP		; Init hardware
	goto	_MAIN		; Main app code


; ------------------------------------------------------------------------------
; Interrupt vector
;
.IVEC	org	0x0004
	goto	_SERVICE	; Points to interrupt service routine


; ------------------------------------------------------------------------------
; EEPROM Data => CV_DATA
;
;	This data set holds a lookup table for scaling 127 bit CV Controler
;	data values to a 160 bit based value.
;		- This  table contains 128 values from 0x2100 to 0x217F.
;		- This maps onto EEPROM data addresses 0x00 to 0x7F.
;		- Base EEPROM address refrenced by global var CV_DATA (0x7F)
;	Calculated: y = x * 160 / 127;
;
	org	0x2100
	de	0x00, 0x01, 0x02, 0x03, 0x05, 0x06, 0x07, 0x08
	de	0x0a, 0x0b, 0x0c, 0x0d, 0x0f, 0x10, 0x11, 0x12
	de	0x14, 0x15, 0x16, 0x17, 0x19, 0x1a, 0x1b, 0x1c
	de	0x1e, 0x1f, 0x20, 0x22, 0x23, 0x24, 0x25, 0x27
	de	0x28, 0x29, 0x2a, 0x2c, 0x2d, 0x2e, 0x2f, 0x31
	de	0x32, 0x33, 0x34, 0x36, 0x37, 0x38, 0x39, 0x3b
	de	0x3c, 0x3d, 0x3e, 0x40, 0x41, 0x42, 0x44, 0x45
	de	0x46, 0x47, 0x49, 0x4a, 0x4b, 0x4c, 0x4e, 0x4f
	de	0x50, 0x51, 0x53, 0x54, 0x55, 0x56, 0x58, 0x59
	de	0x5a, 0x5b, 0x5d, 0x5e, 0x5f, 0x61, 0x62, 0x63
	de	0x64, 0x66, 0x67, 0x68, 0x69, 0x6b, 0x6c, 0x6d
	de	0x6e, 0x70, 0x71, 0x72, 0x73, 0x75, 0x76, 0x77
	de	0x78, 0x7a, 0x7b, 0x7c, 0x7d, 0x7f, 0x80, 0x81
	de	0x83, 0x84, 0x85, 0x86, 0x88, 0x89, 0x8a, 0x8b
	de	0x8d, 0x8e, 0x8f, 0x90, 0x92, 0x93, 0x94, 0x95
	de	0x97, 0x98, 0x99, 0x9a, 0x9c, 0x9d, 0x9e, 0xa0

; ------------------------------------------------------------------------------
; EEPROM Data => CV_NOTE
;
;	This data set holds a lookup table for scaling 127-bit MIDI note values to a
;	160 bit based value.  The supported note values are only for 21 to 81.
;		- This  table contains 128 values from 0x2180 to 0x21FF
;		- This maps onto EEPROM data addresses 0x80 to 0xFF
;		- Base EEPROM address refrenced by global var CV_NOTE (0x80)
;	C4 (60) = 3.0V
;	Calculated: y = (x - 24)* 160 / (84-24);
;
	org	0x2180
	de	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	de	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	de	0x00, 0x00, 0x00, 0x00, 0x00, 0xf8, 0xfb, 0xfe
	de	0x00, 0x02, 0x05, 0x08, 0x0a, 0x0d, 0x10, 0x12
	de	0x15, 0x18, 0x1a, 0x1d, 0x20, 0x22, 0x25, 0x28
	de	0x2a, 0x2d, 0x30, 0x32, 0x35, 0x38, 0x3a, 0x3d
	de	0x40, 0x42, 0x45, 0x48, 0x4a, 0x4d, 0x50, 0x52
	de	0x55, 0x58, 0x5a, 0x5d, 0x60, 0x62, 0x65, 0x68
	de	0x6a, 0x6d, 0x70, 0x72, 0x75, 0x78, 0x7a, 0x7d
	de	0x80, 0x82, 0x85, 0x88, 0x8a, 0x8d, 0x90, 0x92
	de	0x95, 0x98, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0
	de	0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0
	de	0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0
	de	0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0
	de	0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0
	de	0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0, 0xa0

	end