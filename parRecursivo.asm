#Funcion Paridad Recursivo para un n >= 0
.data
	mensaje: .asciiz "La paridad es:"
	n: .word 2
.text
# Inicio del Algoritmo
	lw $a0 , n	#Asigna el n al parametro con lw
	jal paridad	#Llama a la funcion paridad retorna en $v0
	move $t0 , $v0		#Aseguramos el resultado
	#mostrar Mensajes
	li $v0 , 4	#Mostrar Cadena
	la $a0, mensaje		#Mostrar mensaje
	syscall
	li $v0 , 1	#Mostrar entero
	move $a0 , $t0		#Resultado
	syscall	
	#Finalizar
	li $v0 , 10
	syscall
	
#Fin del Algoritmo
	paridad:	#Funcion paridad
	addi $sp, $sp, -8	#Reservar la pil
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	beqz $a0 , casoBase		#Si $n es igual a 0 al caso base
	#No es igual a 0 
	addi $a0,$a0,-1		#n-1
	jal paridad	#Retorna en $v0
	#Liberar pila
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	addi $sp, $sp, 8	#Liberamos la pila
	#Preparamos retorno
	li $t0, 1	#variable Temporal
	sub $v0,$t0,$v0		#1 - paridad(n-1)
	jr $ra		#Retorna a donde lo llamo
	
	casoBase:	#Caso base
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	addi $sp, $sp, 8	#Liberamos la pila
	#Preparamos el retorno
	li $v0, 0
	jr $ra		#Retorna a donde lo llamo
	
#Fin de la funcion Paridad