
#----------------------------------------------------------
# First Processor
#----------------------------------------------------------
	org		0x0000							# first processor p0

	ori	$s0, $zero, 0x80
	ori	$s1, $zero, 0x100

	lw		$t0, 0($s0)
	lw		$t1, 0($s0)
	lw		$t3, 0($s1)
	addiu	$t4, $t3, 1
	sw		$t4, 0($s1)
	lw		$t5, 0($s1)
	addiu	$t5, $t5, 1
	sw		$t5, 0($s1)
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	lw		$t6, 0($s1)
	halt


	org	0x80
	cfw	0x0001
	org	0x100
	cfw	0x0002
	org	0x180
	cfw	0x0003


#----------------------------------------------------------
# Second Processor
#----------------------------------------------------------
	org		0x200							# second processor p1

	ori	$s0, $zero, 0x100
	ori	$s1, $zero, 0x180

	lw		$t0, 0($s0)
	lw		$t1, 0($s0)
	ori	$t2, $zero, 5
	sw		$t2, 0($s1)
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ori	$t3, $zero, 10
	sw		$t3, 0($s0)
	halt
