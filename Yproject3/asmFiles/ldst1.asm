
	#------------------------------------------------------------------
	# Test lw sw
	#------------------------------------------------------------------

	org		0x0000
	ori		$1, $zero, 0xF0
	ori		$2, $zero, 0x100

#two hazard

#dtaHZ	lw		$3, 0($1)
	lw		$4, 4($1)
	subu	$7, $4, $3						# compare loaded element with search var	

#one hazard
	lw		$5, 8($1)
	or		$8, $5, $zero
#data hazard forced
lw		$3, 0($1)
	sw		$3, 0($2)
	sw		$4, 4($2)
	sw		$5, 8($2)
	halt			# that's all

	org		0x00F0
	cfw		0x7337
	cfw		0x2701
	cfw		0x1337
