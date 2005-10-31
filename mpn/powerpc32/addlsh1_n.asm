dnl  PowerPC-32 mpn_addlsh1_n -- rp[] = up[] + (vp[] << 1)

dnl  Copyright 2003, 2005 Free Software Foundation, Inc.

dnl  This file is part of the GNU MP Library.

dnl  The GNU MP Library is free software; you can redistribute it and/or modify
dnl  it under the terms of the GNU Lesser General Public License as published
dnl  by the Free Software Foundation; either version 2.1 of the License, or (at
dnl  your option) any later version.

dnl  The GNU MP Library is distributed in the hope that it will be useful, but
dnl  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
dnl  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
dnl  License for more details.

dnl  You should have received a copy of the GNU Lesser General Public License
dnl  along with the GNU MP Library; see the file COPYING.LIB.  If not, write to
dnl  the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
dnl  MA 02111-1307, USA.

include(`../config.m4')

C                cycles/limb
C 603e:            ?
C 604e:            4.0
C 75x (G3):        5.0
C 7400,7410 (G4):  5.0
C 744x,745x (G4+): 5.0
C power4/ppc970:   4.25
C power5:          5.0

C INPUT PARAMETERS
C rp	r3
C up	r4
C vp	r5
C n	r6

define(`rp',`r3')
define(`up',`r4')
define(`vp',`r5')

define(`s0',`r6')
define(`s1',`r7')
define(`u0',`r8')
define(`v0',`r10')
define(`v1',`r11')

ASM_START()
PROLOGUE(mpn_addlsh1_n)
	mtctr	r6		C copy n in ctr
	addic	r31, r31, 0	C clear cy

	lwz	v0, 0(vp)	C load v limb
	lwz	u0, 0(up)	C load u limb
	addi	up, up, -4	C update up
	addi	rp, rp, -4	C update rp
	slwi	s1, v0, 1
	bdz	.Lend		C If done, skip loop

.Loop:	lwz	v1, 4(vp)	C load v limb
	adde	s1, s1, u0	C add limbs with cy, set cy
	srwi	s0, v0, 31	C shift down previous v limb
	stw	s1, 4(rp)	C store result limb
	lwzu	u0, 8(up)	C load u limb and update up
	rlwimi	s0, v1, 1, 0,30	C left shift v limb and merge with prev v limb

	bdz	.Lexit		C decrement ctr and exit if done

	lwzu	v0, 8(vp)	C load v limb and update vp
	adde	s0, s0, u0	C add limbs with cy, set cy
	srwi	s1, v1, 31	C shift down previous v limb
	stwu	s0, 8(rp)	C store result limb and update rp
	lwz	u0, 4(up)	C load u limb
	rlwimi	s1, v0, 1, 0,30	C left shift v limb and merge with prev v limb

	bdnz	.Loop		C decrement ctr and loop back

.Lend:	adde	r7, s1, u0
	srwi	r4, v0, 31
	stw	r7, 4(rp)	C store last result limb
	addze	r3, r4
	blr
.Lexit:	adde	r7, s0, u0
	srwi	r4, v1, 31
	stw	r7, 8(rp)	C store last result limb
	addze	r3, r4
	blr
EPILOGUE()
