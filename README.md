# CSMA Strategies Simulation

This repository contains MATLAB simulations for analyzing different Carrier Sense Multiple Access (CSMA) backoff strategies for collision avoidance in network protocols. The simulation implements and compares various backoff strategies to understand their impact on network performance.

## Overview

The simulation models a network with multiple nodes attempting to transmit packets simultaneously. It implements different backoff strategies to handle collisions and optimize network utilization.

## Features

- Simulates multiple nodes in a network environment
- Implements 5 different backoff strategies:
  1. Binary Exponential Backoff (BEB)
  2. Linear Backoff
  3. Exponential Backoff with Reset
  4. Linear Decrease
  5. Exponential Decrease
- Configurable parameters:
  - Number of nodes
  - Packet size
  - Simulation time
  - Network data rate (6 Mbps)
  - Time slot size (9 μs)
  - Minimum contention window size

## Requirements

- MATLAB
- Input parameter file (`input_network.txt`)

## Usage

1. Create an `input_network.txt` file with the following parameters (one per line):
   - Number of nodes
   - Packet size (in bytes)
   - Simulation time (in milliseconds)
   - Backoff strategy (1-5)

2. Run the simulation:
```matlab
script
```

3. The simulation will output:
   - Network utilization
   - Number of successful transmissions
   - Collision statistics

## Backoff Strategies

1. **Binary Exponential Backoff (BEB)**
   - Doubles contention window after collisions
   - Resets to minimum window after successful transmission

2. **Linear Backoff**
   - Increases contention window linearly after collisions
   - Maintains window size after successful transmission

3. **Exponential Backoff with Reset**
   - Doubles contention window after collisions
   - Resets to minimum window after successful transmission
   - Includes additional reset conditions

4. **Linear Decrease**
   - Decreases contention window linearly after successful transmission
   - Increases linearly after collisions

5. **Exponential Decrease**
   - Decreases contention window exponentially after successful transmission
   - Doubles window size after collisions

## Performance Analysis

To generate comparative graphs:

1. Run simulations with different numbers of nodes (e.g., 2, 4, 8, 16, 32)
2. Test each backoff strategy
3. Compare metrics:
   - Network utilization
   - Collision rate
   - Throughput
   - Fairness

## License

This project is part of the Internetworking Protocols coursework.
