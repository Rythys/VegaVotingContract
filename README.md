# 🗳️ VegaVote DAO

Децентрализованная система голосования на базе смарт-контрактов Ethereum (Sepolia Testnet). 

## 🏗️ Архитектура системы

Проект состоит из трех ключевых смарт-контрактов:

1.  **VegaVoteToken (VVT):** ERC-20 токен. Твои «права голоса». Чем больше токенов, тем весомее твой голос.
2.  **VegaVoting:** Логический центр. Здесь создаются предложения, принимаются голоса и проверяются дедлайны.
3.  **VegaVoteResults (VVR):** Архив результатов. После завершения голосования в `VegaVoting`, результат фиксируется здесь в виде неизменяемого NFT.

## 🚀 Ссылки на контракты (Sepolia Testnet)

* **VegaVoteToken (VVT):** [`0xCdc24e2a7732a31E05943B06f866A23f7A475357`](https://sepolia.etherscan.io/address/0xCdc24e2a7732a31E05943B06f866A23f7A475357) — ✅ Verified
* **VegaVoteResults (VVR):** [`0xb210210c4C5C404047bcd4408128c05bD61E144e`](https://sepolia.etherscan.io/address/0xb210210c4C5C404047bcd4408128c05bD61E144e) — ✅ Verified
* **VegaVoting:** 

## 🛠️ Технологии

* **Solidity 0.8.33**
* **Foundry** (Development, Testing & Deployment)
* **OpenZeppelin** (Standards: ERC-20, ERC-721, AccessControl)

## 📥 Установка и запуск

1. **Клонируйте репозиторий:**
   ```bash
   git clone [https://github.com/ТВОЙ_ЛОГИН/vega-vote-dao.git](https://github.com/ТВОЙ_ЛОГИН/vega-vote-dao.git)
   cd vega-vote-dao
