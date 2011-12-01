
	#------------------------------------------------------------------
	# Test llsc1
	#------------------------------------------------------------------

	org		0x0000
	ori		$1, $zero, 0xFFFF
	lui   $1, 0x7FFF
	ori		$2, $zero, 0xFFFF
	lui   $2, 0xFFFF
	ori   $3, $zero, 0x0000
	lui   $3, 0x8000
	ori   $4, $zero, 0x0000
	ori   $5, $zero, 0x0001
	ori   $26, $zero, 0x0300

	sltu $6, $1,$2
	sw $6, 0($26)
	sltu $7, $1,$3	
	sw $7, 4($26)
	sltu $8, $1,$4
	sw $8, 8($26)
	sltu $9, $1,$5
	sw $9, 12($26)
  sltu $10, $2,$1
	sw $10, 16($26)
	sltu $11, $2,$3
	sw $11, 20($26)
	sltu $12, $2,$4
	sw $12, 24($26)
	sltu $13, $2,$5
	sw $13, 28($26)
	sltu $14, $3,$1
	sw $14, 32($26)
	sltu $15, $3,$2
	sw $15, 36($26)
	sltu $16, $3,$4
	sw $16, 40($26)
	sltu $17, $3,$5
	sw $17, 44($26)
	sltu $18, $4,$1
	sw $18, 48($26)
	sltu $19, $4,$2
	sw $19, 52($26)

	
							

	halt			# that's all

	org		0x0200
	ori		$1, $zero, 0x7FFF
	ori		$2, $zero, 0xFFFF
	ori   $3, $zero, 0x8000
	ori   $4, $zero, 0x0000
	ori   $5, $zero, 0x0001
	ori   $26, $zero, 0x0300	

	sltu $20, $4,$3
	sw $20, 56($26)
	sltu $21, $4,$5
	sw $21, 60($26)
	sltu $22, $5,$1
	sw $22, 64($26)
	sltu $23, $5,$2
	sw $23, 68($26)
	sltu $24, $5,$3
	sw $24, 72($26)
	sltu $25, $5,$4
	sw $25, 76($26)

	halt			# that's all


