const hre = require("hardhat");
const ethers = hre.ethers;
const fs = require("fs");
const path = require("path");
const { network } = require("hardhat");
// const { Contract } = require("ethers");

async function main() {
  if (network.name === "hardhat") {
    console.warn(
      `You are tryng to deploy a contract to the Hardhat
                option '--network localhost'
            `
    );
  }

  const [deployer] = await ethers.getSigners();
  console.log("Deploying with", await deployer.getAddress());
  const DutchAuction = await ethers.getContractFactory(
    "DutchAuction",
    deployer
  );

  const auction = await DutchAuction.deploy(
    ethers.utils.parseEther("2.0"),
    1,
    "Motorbike"
  );

  await auction.deployed();

  saveFrontendFiles({ DutchAuction: auction });
}

function saveFrontendFiles(contracts) {
  const contractsDir = path.join(__dirname, "../", "frontend/contracts");

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }

  Object.entries(contracts).forEach((item) => {
    const [name, contract] = item;

    if (contract) {
      fs.writeFileSync(
        path.join(contractsDir, "/", name + "-contract-address.json"),
        JSON.stringify({ [name]: contract.address }, undefined, 2)
      );
    }

    const ContractArtifact = hre.artifacts.readArtifactSync(name);

    fs.writeFileSync(
      path.join(contractsDir, "/", name + ".json"),
      JSON.stringify(ContractArtifact, null, 2)
    );
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
