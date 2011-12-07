	org		0x0000							# first processor p0

	ori	$1, $zero, 0x380
	ori	$2, $zero, 0x400
	ori $5, $zero, 0
	ori $6, $zero, 0x480
	ori $7, $zero, 1
	ori $8, $zero, 0x3FF
	
	loop:

nop
nop
nop
	ll $3, 0($1)
	bne $3, $0, loop
	sc $7, 0($1)
	addu $7,$7,$7
	
	sw $0, 0($1)
	sw $7, 4($1) 
	
	ll $3, 0($2)
	bne $3, $0, loop
	addiu $3,$3,1 
	sc $3, 0($2)
	addu $7,$7,$7
	
	sw $0, 0($2)
	sw $7, 4($2) 

	beq $3, $0, loop
	
	ll $3, 0($1)
	bne $3, $0, loop
	sc $7, 0($1)
	addu $7,$7,$7
	
	sw $0, 0($1)
	sw $7, 4($1) 
	
	ll $3, 0($1)
	bne $3, $0, loop
	sc $7, 0($1)
	addu $7,$7,$7
	
	sw $0, 0($1)
	sw $7, 4($1) 
	

  addiu $5, $5, 1
  sw $5, 0($6)
  
  bne $5,$8,loop
  

halt	
	
	

	org		0x200							# second processor p1

		ori	$1, $zero, 0x380
	ori	$2, $zero, 0x400
	ori $5, $zero, 0
	ori $6, $zero, 0x480
	ori $7, $zero, 1
	ori $8, $zero, 0x4FF
	
	loop1:

	ll $3, 0($1)
	bne $3, $0, loop1
	sc $7, 0($1)
	addu $7,$7,$7
	
	sw $0, 0($1)
	sw $7, 4($1) 
	
	ll $3, 0($2)
	bne $3, $0, loop1
	addiu $3,$3,1 
	sc $3, 0($2)
	addu $7,$7,$7
	
	sw $0, 0($2)
	sw $7, 4($2) 

	beq $3, $0, loop1
	
	ll $3, 0($1)
	bne $3, $0, loop1
	sc $7, 0($1)
	addu $7,$7,$7
	
	sw $0, 0($1)
	sw $7, 4($1) 
	
	ll $3, 0($2)
	bne $3, $0, loop1
	addiu $3,$3,1 
	sc $3, 0($2)
	addu $7,$7,$7
	
	sw $0, 0($2)
	sw $7, 4($2) 
	

  addiu $5, $5, 1
  sw $5, 0($6)
  
  bne $5,$8,loop1
  
  halt
	
	
