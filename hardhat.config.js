import "dotenv/config";
import hardhatBlockhertz from "hardhat-blockhertz";

export default {
  solidity: "0.8.20",
  plugins: [hardhatBlockhertz],
  blockhertz: {
    apiKey: process.env.BLOCKHERTZ_API_KEY,
    model: "claude-sonnet-4-5",
  }
};