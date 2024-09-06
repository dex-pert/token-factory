// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct TokenInitializeParams {
    string name;
    string symbol;
    uint8 decimals;
    uint256 totalSupply;
    string description;
    string logoLink;
    string twitterLink;
    string telegramLink;
    string discordLink;
    string websiteLink;
}

struct TokenMetaData {
    string description;
    string logoLink;
    string twitterLink;
    string telegramLink;
    string discordLink;
    string websiteLink;
}