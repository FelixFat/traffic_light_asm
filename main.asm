; NAME:	 Фаталиев Даниил Андреевич, КРБО-02-17
; SUBJ:	 Микропроцессорная техника в мехатронике и робототехнике
; TITLE: Система управления светофорами на перекрестке
; DATE:	 24.11.2019

.def Temp_1 = r16					; Первая вспомогательная переменная
.def Temp_2 = r17					; Вторая вспомогательная переменная
.def Time = r18						; Счетчик времени работы цикла
.def Blink_1 = r19					; Время мигания Зеленого света 1-ой пары
.def Blink_2 = r20					; Время мигания Зеленого света 2-ой пары
.def Frequency_Rate = r21			; Частота миганий

.equ Frequency = 1					; Частота
.equ Blink_Green_1 = 27				; Время начала мигания Зеленого света 1-ой пары
.equ Blink_Green_2 = 12				; Время начала мигания Зеленого света 2-ой пары
.equ Red_Light = 11					; Время работы Красного света
.equ Yellow_Light = 16				; Время работы Желтого света
.equ Green_Light = 26				; Время работы Зеленого света
.equ End_Cycle = 31					; Время конца цикла

.cseg
.org 0x0000
rjmp Init

.org 0x0006
rjmp Timer

; Прерывание по таймер/счетчику
Timer:
	; Подсчет времени работы цикла
	inc Time						

	cpi Time, Red_Light				
	brne Time_Comparison_1

	; 1-ая пара - выключение Красного света
	ldi Temp_1, (0 << PB0)
	out PORTB, Temp_1
	ldi Temp_1, (0 << PC0)
	out PORTC, Temp_1
	; 1-ая пара - включение Желтого света
	ldi Temp_1, (1 << PB1)			
	out PORTB, Temp_1
	ldi Temp_1, (1 << PC1)
	out PORTC, Temp_1

	Time_Comparison_1: cpi Time, Yellow_Light
	brne Time_Comparison_2

	; 1-ая пара - выключение Желтого света
	ldi Temp_1, (0 << PB1)
	out PORTB, Temp_1
	ldi Temp_1, (0 << PC1)
	out PORTC, Temp_1

	Time_Comparison_2: cp Time, Blink_2	
	brne Time_Comparison_3
	add Blink_2, Frequency_Rate

	; 2-ая пара - мигание Зеленым светом
	ldi Temp_2, (1 << PINA2)
	in Temp_1, PINA
	sub Temp_2, Temp_1
	out PORTA, Temp_2

	ldi Temp_2, (1 << PIND2)
	in Temp_1, PIND
	sub Temp_2, Temp_1
	out PORTD, Temp_2

	cpi Time, Yellow_Light
	brne Time_Comparison_3
	ldi Blink_2, 0

	; 1-ая пара - включение Зеленого света
	ldi Temp_1, (1 << PB2)
	out PORTB, Temp_1
	ldi Temp_1, (1 << PC2)
	out PORTC, Temp_1
	; 2-ая пара - включение Красного света
	ldi Temp_1, (1 << PA0)
	out PORTA, Temp_1
	ldi Temp_1, (1 << PD0)
	out PORTD, Temp_1
	
	Time_Comparison_3: cp Time, Blink_1
	brne Return
	add Blink_1, Frequency_Rate

	; 2-ая пара - включение Желтого света
	ldi Temp_1, (1 << PA1)
	out PORTA, Temp_1
	ldi Temp_1, (1 << PD1)
	out PORTD, Temp_1

	; 1-ая пара - мигание Зеленым светом
	ldi Temp_2, (1 << PINB2)
	in Temp_1, PINB
	sub Temp_2, Temp_1
	out PORTB, Temp_2

	ldi Temp_2, (1 << PINC2)
	in Temp_1, PINC
	sub Temp_2, Temp_1
	out PORTC, Temp_2

	cpi Time, End_Cycle
	brne Return
	
	; Сброс значений переменных в начальные

	; 1-ая пара - включение Красного света
	ldi Temp_1, (1 << PB0)
	out PORTB, Temp_1
	ldi Temp_1, (1 << PC0)
	out PORTC, Temp_1
	; 2-ая пара - включение Зеленым светом
	ldi Temp_1, (1 << PA2)
	out PORTA, Temp_1
	ldi Temp_1, (1 << PD2)
	out PORTD, Temp_1

	ldi Time, 0
	ldi Blink_1, Blink_Green_1
	ldi Blink_2, Blink_Green_2

	Return: reti

; Инициализация всех начальных значений
Init:
	; Объявление стека
	ldi Temp_1, low(RAMEND)
	out SPL, Temp_1
	ldi Temp_1, high(RAMEND)
	out SPH, Temp_1

	; Начальные значения переменных
	ldi Time, 0						
	ldi Blink_1, Blink_Green_1
	ldi Blink_2, Blink_Green_2
	ldi Frequency_Rate, Frequency

	; Светодиоды порта A
	ldi Temp_1, 0b00000111			
	out DDRA, Temp_1
	ldi Temp_1, 0b00000100
	out PORTA, Temp_1

	; Светодиоды порта B
	ldi Temp_1, 0b00000111			
	out DDRB, Temp_1
	ldi Temp_1, 0b00000001
	out PORTB, Temp_1

	; Светодиоды порта C
	ldi Temp_1, 0b00000111			
	out DDRC, Temp_1
	ldi Temp_1, 0b00000001
	out PORTC, Temp_1

	; Светодиоды порта D
	ldi Temp_1, 0b00000111			
	out DDRD, Temp_1
	ldi Temp_1, 0b00000100
	out PORTD, Temp_1

	sei

	; Объявление таймер/счетчика
	ldi Temp_1, 0b00011101			
	out TCCR2, Temp_1
	ldi Temp_1, (1 << AS2)
	out ASSR, Temp_1
	ldi Temp_1, (1 << OCIE2)
	out TIMSK, Temp_1
	ldi Temp_1, 255
	out OCR2, Temp_1
	
	rjmp Cycle

Cycle:
	rjmp Cycle	

.exit