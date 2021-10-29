from brownie import network, config, accounts, MockV3Aggregator
from web3 import Web3
import os
from os import getenv

LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-local"]
FORKED_LOCAL_ENVIRONNEMENTS = ["mainnet-fork-dev"]

DECIMALS = 8
STARTING_VALUE = 200000000000


def get_account():
    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS
        or network.show_active() in FORKED_LOCAL_ENVIRONNEMENTS
    ):
        return accounts[0]
    else:
        return accounts.add(os.getenv("private_key"))


def deploy_mocks():
    print(f"The active network is {network.show_active()}")
    print("Deploying Mocks...")
    if len(MockV3Aggregator) <= 0:
        MockV3Aggregator.deploy(DECIMALS, STARTING_VALUE, {"from": get_account()})
    print("Mocks Deployed!")