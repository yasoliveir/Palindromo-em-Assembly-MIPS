.data
	num: .asciiz "Informe um número inteiro: "
	msg1: .asciiz "Número inválido, informe um número maior que 1 e menor que 10000.\n"
	msg2: .asciiz "O número é palindromo!\n"
	msg3: .asciiz "O número não é palindromo.\n"
	msg4: .asciiz "O número palindromo mais próximo e anterior a ele é: "
	
.text
.globl main
main:
	# LEITURA DO NUMERO INICIAL
	li $v0, 4
	la $a0, num
	syscall # imprime a string
	
	li $v0, 5 # le o inteiro
	syscall
	move $t0, $v0 # salva num em $t0
	
# CONFERIR SE 1 > NUM < 10000
loop_intervalo:
	bge $t0, 10000, nao_entra # SE num >= 10000 vai para o procedimento "nao entra"
	ble $t0, 1, nao_entra #SE num <= 1 vai pra nao_entra
	#no intervalo correto:
	j entra

# SE O NUMERO NAO ENTRAR NO INTERVALO
nao_entra:
	li $v0, 4
	la $a0, msg1 # Pedir novo numero para o usuario
	syscall
	
	li $v0, 5 # le um novo numero inteiro
	syscall
	move $t0, $v0 # atualiza o num em $t0
	j loop_intervalo # testa o valor do num novamente

# SE ENTRAR NO INTERVALO
entra:
	# TESTAR O NUMERO DIGITADO ($t0)
	move $t1, $t0 # $t1 passa a ser o endereço do numero que vamos testar
	jal testa_palindromo
	
	# Verificar retorno (v0 == 1 é true, v0 == 0 é false)
	beq $v0, 1, num_palindromo
	j nao_palindromo
	
num_palindromo:
	li $v0, 4
	la $a0, msg2
	syscall
	j fim
	
nao_palindromo:
	li $v0, 4
	la $a0, msg3
	syscall
	
	# PROCURAR O PALINDROMO ANTERIOR
	move $t1, $t0 # inicia a partir do numero digitado
	
loop_num_anterior:
	addi $t1, $t1, -1 # num atual -= 1
	ble $t1, 0, fim # se chegar a 0, vai pro "fim"
	jal testa_palindromo # testa se t1 é palindromo
	
	beq $v0, 1, encontrou_anterior # se v0 == 1, o numero é palindromo
	j loop_num_anterior # se nao, subtrai 1 e tenta de novo

encontrou_anterior:
	li $v0, 4
	la $a0, msg4
	syscall
	
	li $v0, 1 # imprimir o numero palindromo anterior armazenado em t1
	move $a0, $t1
	syscall
	j fim
	
# ======================================
# TESTAR O NUMERO PARA VER SE É PALINDROMO
# v0 = 1 (True) / ou 0 (False)
# ======================================
testa_palindromo:
	# Casa milhar numero // 1000 
	div $t2, $t1, 1000 # t2 = MILHAR

	# Casa centena  = (num % 1000) // 100
	rem $t3, $t1, 1000
	div $t3, $t3, 100 # t3 = CENTENA
	
	# Casa dezena (num % 100) // 10
	rem $t4, $t1, 100
	div $t4, $t4, 10 # t4 = DEZENA
	
	# Unidade (num % 10)
	rem $t5, $t1, 10 # t5 = UNIDADE
	
	# Verifica quantos digitos o numero digitado tem
	bgt $t2, 0, quatro_digitos # if mil > 0
	bgt $t3, 0, tres_digitos # elif cen > 0
	bgt $t4, 0, dois_digitos # elif dez > 0
	j retorna_true
	
quatro_digitos:
	bne $t2, $t5, retorna_false # se milhar != unidade -> nao é palindromo!
	bne $t3, $t4, retorna_false # se centena != dezena -> nao é palindromo!
	j retorna_true
	
tres_digitos:
	bne $t3, $t5, retorna_false # se centena != unidade -> nao é palindromo!
	j retorna_true

dois_digitos:
	bne $t4, $t5, retorna_false # se dez != unidade -> nao é palindromo!
	j retorna_true
	
retorna_true:
	li $v0, 1
	jr $ra # volta para entra ou loop_anterior
	
retorna_false:
	li $v0, 0
	jr $ra # volta para entra ou loop_anterior

# FIM
fim:
	li $v0, 10
	syscall
