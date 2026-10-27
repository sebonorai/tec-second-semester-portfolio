# Electromagnetic Modeling — MATLAB

Two MATLAB simulations from the computational modeling courses of the second semester (electrical systems, then electromagnetic systems). Both were team projects, completed in groups of five students and submitted with a joint written report that is not included here. The scripts are published as they were submitted, with one correction: in `electric_field_particles.m` the negative line now contributes negative potential to the potential map (`-qn` on line 207).

## Files

### `magnetic_braking.m` — Magnetic braking of a falling magnet

*Computational Modeling of Electromagnetic Systems (F1014B), June 2026.*

One runnable script with four stages, each with its own plots and a 2D/3D animation:

1. **Basic fields (Biot–Savart).** Field of an infinite straight wire (closed form) and of a circular current loop (numerical Biot–Savart over 100 segments), shown as 3D vector fields plus a magnitude map.
2. **Magnet falling onto a fixed-current ring.** The magnet is a point dipole (50 A·m², 50 g) dropped from z = 2 m with v₀ = −4 m/s onto a ring of radius 0.35 m carrying a fixed current of 1.5×10⁴ A. The force on the dipole, `F(z) = 3 m μ₀ I a² z / [2 (z² + a²)^(5/2)]`, is computed analytically and by finite differences, and the trajectory is integrated with RK4 (dt = 10⁻⁴ s).
   - Speed at the ring plane: 1.29 m/s, versus 7.43 m/s in free fall (about 83 % lower).
   - Analytic and finite-difference forces agree to about 3×10⁻³ N (peak force 3.3 N).
   - There is no terminal velocity in this stage: with a fixed current the force depends on position only, not on speed.
3. **EMF and current in a single loop.** The magnet falls through a loop (R = 5 cm, R_e = 0.5 Ω, L = 0.1 mH) in plain free-fall kinematics, since the back-force of one loop is negligible. The EMF comes from Faraday's law with the chain rule applied to the dipole flux, and the current from the RL circuit with explicit Euler (dt/τ = 0.05). Peak EMF is about 4 mV and peak current about 8 mA, with the current slightly delayed by the inductance.
4. **Tube of 50 loops.** The full coupled system `[z, v, I₁ … I₅₀]` (52 ODEs) is integrated with RK4: the magnet's motion induces a current in every loop (Faraday) and each current pushes back on the magnet (Lenz). Loops: R = 4 cm, 5 mm apart, 1 mΩ and 1 µH each. Magnet: 50 A·m², 50 g, released 0.30 m above the top loop.
   - Inside the tube the magnet settles at a terminal speed of about 0.14 m/s, where the magnetic force balances its weight (mg ≈ 0.49 N).
   - On leaving the bottom of the tube it has only reached about 0.4 m/s, compared with about 17 m/s in free fall over the same 1.76 s.

Simplifications: the loops are independent (no mutual inductance), the magnet is a point dipole, and thermal losses and air drag are ignored.

### `electric_field_particles.m` — Electric field of two line charges and particle separation

*Computational Modeling of Electrical Systems, May 2026.*

Models how a non-uniform electric field pulls apart charged particles of opposite sign, the principle behind techniques such as dielectrophoresis. Two parallel finite line charges of opposite sign are each built from 51 point charges of 1 nC: the positive line (length 10) at x = −8 and the negative line (length 5) at x = +8. The script computes:

- the electric field on a grid by Coulomb superposition, drawn as normalized vectors and as streamlines;
- the electric potential by superposition, drawn as a filled contour map;
- the trajectories of 5 positive and 5 negative test particles, each with random position, charge, mass and initial velocity, advanced with a simple kinematic update until they reach the line of opposite sign.

Test-particle properties are random, so every run produces different trajectories.

## Running

Open either script in MATLAB (R2018b or newer, base MATLAB with no extra toolboxes) and run it:

```matlab
run('magnetic_braking.m')
run('electric_field_particles.m')
```
