# Numerical Methods — MATLAB

Root-finding, ODE integration, and regression routines written for the Numerical Methods course.

## Files

### `linregression.m`
Least-squares linear regression from first principles — no toolbox functions. Returns slope, intercept, standard error of the estimate, standard deviation, and R². Written as a reusable function and called by `circuit_analysis.m`.

### `circuit_analysis.m`
Applies the regression routine to experimental current/voltage measurements to estimate the resistance of a circuit. The slope recovers resistance via Ohm's law and the intercept exposes the voltage offset, with R² reporting how well the linear model holds.

### `crunKut.m`
Fourth-order Runge-Kutta integrator, implemented as a general function taking any `f(t,y)`, initial conditions, step count, and step size. Applied here to the first-order ODEs describing current and capacitor voltage in an RC circuit driven by a sinusoidal source.

### `mat1.m`
Step-size convergence study. Integrates `y' = -y` over `[0,5]` with h = 1, 0.1, and 0.05, then plots the solutions together to show how truncation error shrinks as the step size decreases.

### `mullerraiz.m`
Müller's method for root-finding. Uses three points and divided differences to fit a quadratic through them, taking its root as the next iterate — which lets it converge on roots that bracketing methods struggle with. Applied to `f(x) = x³ - 13x - 12`.

## Running

Open in MATLAB and run the script directly:

```matlab
run('circuit_analysis.m')
```

`linregression.m` and `crunKut.m` are functions — call them from another script or the command window.
