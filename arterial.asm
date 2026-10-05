.data
    # Simulación del mapa de memoria del módulo de tensión
    TensionControl: .word 0  # 1 = Iniciar medición
    TensionEstado:  .word 0  # 0 = Midiendo, 1 = Listo
    TensionSistol:  .word 0  # Resultado Sistólica
    TensionDiastol: .word 0  # Resultado Diastólica

.text
.globl main

main:
    # Llamada de prueba al controlador
    jal controlador_tension
    
    # Fin del programa
    li $v0, 10
    syscall

# =====================================================================
# Procedimiento: controlador_tension
# Descripción: Inicia la medición, hace polling y retorna las tensiones.
# Salida: $v0 = Tensión Sistólica, $v1 = Tensión Diastólica
# =====================================================================
controlador_tension:
    # 1. Iniciar la medición
    la $t0, TensionControl     # Cargar dirección de TensionControl
    li $t1, 1                  # Valor 1 para arrancar la medición
    sw $t1, 0($t0)             # Escribir en memoria (Manda la señal al periférico)

espera_tension:
    # 2. Bucle de espera activa (Polling)
    la $t0, TensionEstado      # Cargar dirección de TensionEstado
    lw $t1, 0($t0)             # Leer el estado del dispositivo
    
    # Mientras el estado sea 0 (midiendo), el procesador se queda aquí esperando
    beqz $t1, espera_tension   

    # 3. Lectura de los resultados (ya que el estado es 1)
    la $t0, TensionSistol      
    lw $v0, 0($t0)             # Cargar el valor de Sistólica en $v0 (Salida 1)
    
    la $t0, TensionDiastol     
    lw $v1, 0($t0)             # Cargar el valor de Diastólica en $v1 (Salida 2)

    # 4. Finalizar
    jr $ra                     # Retornar al programa que hizo el llamado