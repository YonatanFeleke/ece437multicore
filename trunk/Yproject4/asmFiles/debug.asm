org		0x0000
ori		$sp, $zero, 0x3ffc
jal		mp0
halt

lock:
ll		$t0, 0($a0)
bne		$t0, $0, lock
addi	$t0, $t0, 1
sc		$t0, 0($a0)
beq		$t0, $0, lock
jr		$ra

unlock:
sw	$0, 0($a0)
jr	$ra

mp0:
push	$ra

ori		$a0, $zero, l1
jal		lock
ori		$t2, $zero, res
lw		$t0, 0($t2)
addiu	$t1, $t0, 0x2000
sw		$t1, 0($t2)
ori		$a0, $zero, l1
jal		unlock
pop		$ra
jr		$ra

l1:
cfw		0x0

org		0x0200
ori		$sp, $zero, 0x7ffc
jal		mp1
halt

mp1:
push	$ra
ori		$a0, $zero, l1
jal		lock
ori		$t2, $zero, res
lw		$t0, 0($t2)
addiu	$t1, $t0, -66
sw		$t1, 0($t2)
ori		$a0, $zero, l1
jal		unlock
pop		$ra
jr		$ra

res:
cfw		0xBEEF
