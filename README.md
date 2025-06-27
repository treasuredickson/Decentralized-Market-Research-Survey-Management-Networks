# Decentralized Market Research Survey Management Networks

A comprehensive blockchain-based solution for managing market research surveys in a decentralized, transparent, and verifiable manner.

## Overview

This project implements a decentralized market research survey management system using Clarity smart contracts. The system enables organizations to conduct market research surveys with enhanced transparency, data integrity, and participant incentivization.

## Architecture

The system consists of five independent smart contracts:

### 1. Survey Coordinator Verification Contract
Manages the registration and verification of survey coordinators who can create and manage surveys.

### 2. Survey Design Contract
Handles the creation, configuration, and management of market research surveys with customizable parameters.

### 3. Response Collection Contract
Manages the secure collection of survey responses from participants with proper validation.

### 4. Data Validation Contract
Ensures the integrity and validity of collected survey data through various validation mechanisms.

### 5. Analysis Coordination Contract
Coordinates the analysis workflow and manages the distribution of analysis results.

## Features

- **Decentralized Coordinator Management**: Transparent verification and management of survey coordinators
- **Flexible Survey Design**: Customizable survey parameters and configurations
- **Secure Response Collection**: Protected and validated response submission process
- **Data Integrity Assurance**: Comprehensive validation of collected data
- **Analysis Workflow**: Coordinated analysis process with result distribution
- **Incentive System**: Built-in reward mechanisms for participants and coordinators
- **Transparency**: All operations recorded on blockchain for full auditability

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Stacks blockchain development environment

### Installation
1. Clone the repository
2. Install dependencies using Clarinet
3. Deploy contracts to local testnet
4. Run tests to verify functionality

### Usage
1. Register as a survey coordinator through the verification contract
2. Create surveys using the survey design contract
3. Collect responses via the response collection contract
4. Validate data using the data validation contract
5. Coordinate analysis through the analysis coordination contract

## Testing

The project includes comprehensive tests using Vitest framework covering:
- Contract deployment and initialization
- Function execution and state changes
- Error handling and edge cases
- Integration scenarios

Run tests using:
\`\`\`
npm test
\`\`\`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request
