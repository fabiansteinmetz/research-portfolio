# Traffic Congestion Analysis: Berlin Road Network

**Course**: Modeling and Analysis of Complex Systems - Minerva University  
**Date**: Fall 2025  
**Tools**: Python, NetworkX, OSMnx, Agent-Based Modeling

## Overview
Improved and analyzed an agent-based traffic simulation on Berlin's real road network using OpenStreetMap data. Developed a density-based congestion model and derived a predictive metric combining betweenness centrality with road capacity.

## Research Question
Can we predict which roads will experience the highest congestion based purely on network structure, without running simulations?

## Key Findings
- Discovered power-law relationship between "traffic pressure" (betweenness centrality / capacity) and congestion: Congestion ∝ (Pressure)^1.0632
- Model achieved R² = 0.80 on Berlin network and R² = 0.92 when applied to Buenos Aires without recalibration
- Short road segments create density bottlenecks due to rapid capacity saturation
- Kottbusser Tor intersection identified as highest congestion point across 960 simulation trials

## Methodology
- Enhanced simulation from fixed threshold to density-dependent speed model based on Nagel-Schreckenberg principles
- Ran 960+ trials until convergence (< 1% change) to account for stochastic routing
- Derived theoretical prediction using edge betweenness centrality weighted by road capacity
- Validated on two cities to test generalizability

## Files
- `report.pdf` - Full analysis with network visualizations and theoretical derivations
- `simulation.ipynb` - Traffic simulation code with OSMnx integration

## Technologies
- Python 3.x
- OSMnx for real road network data
- NetworkX for graph analysis and centrality metrics
- Matplotlib for congestion heatmaps

## Key Takeaways
Network topology alone can predict congestion hotspots with high accuracy. The combination of centrality (how many routes use a road) and capacity (road length) creates a physics-inspired "pressure" metric that generalizes across cities.
