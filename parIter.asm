#Funcion Paridad de forma iterativa
.data 
	mensaje: .asciiz "La paridad es:"
	n: .word 2
.text
	#Variables
	lw $s0 , n	#Variable con el n 
	li $v0, 0	#Inicializo
	li $t0, 0	#Indice iterativo
	#Inicio del ciclo for 
	for:
	beq $t0, $s0, fin_For	#Si i == n fin del ciclo For
	#Aun no es igual 
	li $t1 , 1	#Variable Temporal
	sub $v0,$t1,$v0		
	addi $t0,$t0,1	#i+=1
	j for	#Vuelve a evaluar la condicion
	fin_For:	#Fin del ciclo
	#Mostrar resultado
	move $t0 , $v0	#Resguardamos resultado
	
	li $v0 , 4	#Mostrar Cadena
	la $a0, mensaje		#Mostrar mensaje
	syscall
	li $v0 , 1	#Mostrar entero
	move $a0 , $t0		#Resultado
	syscall	
	#Finalizar
	li $v0 , 10
	syscall
	#Finalizar
	li $v0 , 10
	syscall