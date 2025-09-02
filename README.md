# VaultForge Protocol

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Clarity](https://img.shields.io/badge/clarity-3.0-orange.svg)](https://clarity-lang.org)
[![Stacks](https://img.shields.io/badge/stacks-blockchain-purple.svg)](https://stacks.org)
[![Tests](https://img.shields.io/badge/tests-passing-green.svg)](#testing)

## Next-generation Bitcoin lending infrastructure with adaptive collateral management

## Overview

VaultForge Protocol pioneers a revolutionary approach to Bitcoin-based lending by implementing an adaptive collateral framework that evolves with user behavior. Unlike static DeFi protocols, VaultForge continuously analyzes on-chain activities, payment histories, and risk profiles to create personalized lending experiences.

### Key Features

- **🧠 Adaptive Reputation Engine**: Machine-learning inspired algorithms that reward responsible borrowing behavior
- **⚡ Dynamic Collateral Ratios**: Lower collateral requirements for high-reputation users
- **🔒 Bitcoin-Secured**: Built on Stacks blockchain for Bitcoin-native DeFi
- **📊 Behavioral Analytics**: Real-time risk assessment based on on-chain activity
- **💰 Progressive Interest Rates**: Better rates for established borrowers
- **🛡️ Automated Risk Management**: Built-in default protection and liquidation mechanisms

## Architecture

### Core Components

#### 1. Reputation Engine

The protocol's proprietary scoring system that tracks:

- Payment history and timeliness
- Total borrowed and repaid amounts
- Loan completion rate
- On-chain behavioral patterns

#### 2. Adaptive Collateral Framework

- **Minimum Score Required**: 70/100 for loan eligibility
- **Dynamic Collateral Calculation**: Based on reputation score
- **Progressive Reduction**: Higher scores = lower collateral requirements

#### 3. Multi-Loan Portfolio Management

- Support for up to 5 concurrent loans per user
- Real-time portfolio tracking
- Automated loan lifecycle management

## Smart Contract Interface

### Core Functions

#### User Management

```clarity
;; Initialize user reputation profile
(define-public (initialize-score))

;; Get user reputation data
(define-read-only (get-user-score (user principal)))
```

#### Loan Operations

```clarity
;; Request a new loan with adaptive terms
(define-public (request-loan (amount uint) (collateral uint) (duration uint)))

;; Repay loan with automatic reputation enhancement
(define-public (repay-loan (loan-id uint) (amount uint)))

;; Get loan details
(define-read-only (get-loan (loan-id uint)))
```

#### Portfolio Management

```clarity
;; View active loans
(define-read-only (get-user-active-loans (user principal)))

;; Administrative default marking
(define-public (mark-loan-defaulted (loan-id uint)))
```

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) v2.0+
- [Node.js](https://nodejs.org/) v18+
- [Stacks Wallet](https://www.hiro.so/wallet) for interaction

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/carlie-brent/vault-forge.git
   cd vault-forge
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Verify setup**

   ```bash
   clarinet check
   ```

### Development

#### Running Tests

```bash
# Run all tests
npm test

# Run tests with coverage report
npm run test:report

# Watch mode for development
npm run test:watch
```

#### Local Development

```bash
# Start Clarinet console
clarinet console

# Deploy to local network
clarinet integrate
```

## Protocol Parameters

### Reputation Scoring

- **Minimum Score**: 50/100 (starting score for new users)
- **Maximum Score**: 100/100
- **Loan Eligibility**: 70/100 minimum
- **Score Adjustments**:
  - Successful repayment: +2 points
  - Default: -10 points

### Loan Terms

- **Maximum Duration**: 52,560 blocks (~1 year)
- **Interest Rate**: Dynamic based on reputation (5-10%)
- **Collateral Ratio**: 50-100% based on reputation score
- **Maximum Concurrent Loans**: 5 per user

## Security Considerations

### Implemented Safeguards

- ✅ Comprehensive input validation
- ✅ Overflow/underflow protection
- ✅ Access control mechanisms
- ✅ Collateral lock guarantees
- ✅ Automated default detection

### Risk Management

- **Collateral Liquidation**: Automatic on default
- **Reputation Penalties**: Significant score reduction for defaults
- **Portfolio Limits**: Maximum 5 concurrent loans
- **Time-based Validation**: Loan duration limits

## Testing

The protocol includes comprehensive test coverage:

```bash
# Run test suite
npm test

# Generate coverage report
npm run test:report
```

Test coverage includes:

- User score initialization and management
- Loan request validation and processing
- Repayment workflows and reputation updates
- Default handling and liquidation
- Edge cases and error conditions

## Deployment

### Testnet Deployment

```bash
# Deploy to Stacks testnet
clarinet deployments generate --testnet
clarinet deployments apply --testnet
```

### Mainnet Deployment

```bash
# Deploy to Stacks mainnet
clarinet deployments generate --mainnet
clarinet deployments apply --mainnet
```

## API Reference

### Error Codes

| Code | Description |
|------|-------------|
| `u1` | Unauthorized access |
| `u2` | Insufficient balance |
| `u3` | Invalid amount |
| `u4` | Loan not found |
| `u5` | Loan defaulted |
| `u6` | Insufficient reputation score |
| `u7` | Too many active loans |
| `u8` | Loan not yet due |
| `u9` | Invalid duration |
| `u10` | Invalid loan ID |

### Events

The contract emits events for:

- Loan origination
- Repayment processing
- Default marking
- Score updates

## Contributing

We welcome contributions to VaultForge Protocol! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## Roadmap

### Phase 1 - Core Protocol ✅

- [x] Reputation engine implementation
- [x] Adaptive collateral system
- [x] Basic loan operations
- [x] Test suite development

### Phase 2 - Advanced Features 🚧

- [ ] Cross-collateral support
- [ ] Governance token integration
- [ ] Advanced analytics dashboard
- [ ] Mobile wallet integration

### Phase 3 - Ecosystem Expansion 📋

- [ ] Partner protocol integrations
- [ ] Institutional lending features
- [ ] Layer 2 scaling solutions
- [ ] Multi-asset support

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Disclaimer

VaultForge Protocol is experimental software. Use at your own risk. This software is provided "as is" without warranty of any kind. Please review the code thoroughly before using in production.

## Contact

- **Website**: [vaultforge.finance](https://vaultforge.finance)
- **Documentation**: [docs.vaultforge.finance](https://docs.vaultforge.finance)
- **Discord**: [Join our community](https://discord.gg/vaultforge)
- **Twitter**: [@VaultForgeHQ](https://twitter.com/VaultForgeHQ)

---

Built with ❤️ on Stacks | Powered by Bitcoin
