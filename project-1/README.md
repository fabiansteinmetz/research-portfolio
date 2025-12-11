# Predator-Prey Ecosystem Simulation

**Course**: Modeling and Analysis of Complex Systems - Minerva University  
**Date**: Fall 2025  
**Tools**: Python, NumPy, Matplotlib, SciPy

## Overview
Agent-based simulation modeling population dynamics between foxes (predators) and bunnies (prey) using reaction-diffusion equations on a spatial grid. Analyzed how growth rates, diffusion patterns, and mortality affect species coexistence and pattern formation.

## Key Findings
- Identified critical bunny growth rate threshold (g_b ≈ 0.04) where system transitions from stable to oscillatory behavior
- Discovered three distinct spatial patterns based on diffusion rate ratios: scattered populations, clustering with surrounding patterns, and uniform distribution
- Found fox populations die out when growth rate falls below mortality rate (g_f < m_f ≈ 0.03)
- Compared empirical simulation results with mean-field theoretical analysis

## Methodology
- Implemented spatial grid simulation (200×200) with periodic boundary conditions
- Used Fast Fourier Transform analysis to detect oscillatory patterns
- Tested convergence over 300+ trials to account for stochastic effects
- Derived theoretical equilibrium using mean-field approximation

## Files
- `report.pdf` - Complete analysis with visualizations and theoretical derivations
- `simulation.ipynb` - Python implementation with visualization code

## Technologies
- Python 3.x
- NumPy, Matplotlib for simulation and visualization
- SciPy for FFT analysis
- NetworkX concepts for spatial modeling

## Key Takeaways
Spatial structure enables species coexistence at higher population densities than theoretical models predict. Small parameter changes can trigger dramatic behavioral shifts (phase transitions) in complex systems.
