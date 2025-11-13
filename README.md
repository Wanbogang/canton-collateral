# 🗺️ Daml Collateral Mobility

**Problem Statement:** Collateral in financial institutions is often locked within a single entity, making it difficult to transfer and reuse efficiently. The process is manual, slow, and prone to settlement risks.

**Solution:** This project builds a prototype for collateral mobility using Daml and the Canton Network. We create digitized assets (tokenized collateral) that can be securely and transparently moved (pledged/released) between three parties (Custodian, Bank, Broker) via smart contracts, automating the entire workflow.

## 🏗️ Architecture

*(Diagram will be added here)*

## ⚙️ How to Run (Setup)

**Prerequisites:**
- Daml SDK 3.4.7
- Python 3 with the `PyJWT` library
- `curl`

1.  **Start the Ledger and JSON API:**
    ```bash
    nohup daml start < /dev/null > daml.start.log 2>&1 &
    ```

2.  **Populate Initial Data:**
    This script creates the initial parties and a sample `PledgeAgreement` contract.
    ```bash
    daml script --dar .daml/dist/collateral-project-0.0.1.dar --script-name Main:setup --ledger-host localhost --ledger-port 6865
    ```

3.  **Run the Demo CLI:**
    This script demonstrates the full pledge/release lifecycle via the JSON API.
    ```bash
    chmod +x demo.sh
    ./demo.sh
    ```

## 🎬 Demo (Pledge/Release Workflow)

The `demo.sh` script demonstrates the full lifecycle:
1.  **Pledge:** `BankA` creates a `PledgeAgreement` for `BrokerB`.
2.  **Release:** `BrokerB` exercises the `Release` choice on the agreement.
3.  **Verify:** The system queries the ledger to confirm the contract is archived.

## 📁 Project Structure
.
├── daml/ # Daml source code
│ ├── Main.daml # Setup script
│ ├── PledgeAgreement.daml # Core contract template
│ └── CollateralToken.daml # Tokenized asset template
├── demo.sh # Automated demo script
├── daml.yaml # Daml project configuration
└── README.md # This documentation



## 🚀 Hackathon Submission

This project fulfills the following deliverables:
- ✅ **Minimal Working Demo:** The `demo.sh` script provides a full CLI demo of the pledge/release cycle.
- ✅ **JSON API:** All contract actions can be executed via REST API calls.
- ✅ **Well-Documented:** This `README.md` explains the setup, architecture, and workflow.
