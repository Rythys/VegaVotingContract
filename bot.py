import time
from web3 import Web3
import json

# --- НАСТРОЙКИ ---
RPC_URL = "http://127.0.0.1:8545" 
CONTRACT_ADDRESS = "0xТВОЙ_АДРЕС_КОНТРАКТА"
PRIVATE_KEY = "0xТВОЙ_ПРИВАТНЫЙ_КЛЮЧ"
ACCOUNT_ADDRESS = "0xТВОЙ_ПУБЛИЧНЫЙ_АДРЕС"

# Время ожидания в секундах (например, 3600 секунд = 1 час)
VOTING_DURATION = 3600 

# Подключение
w3 = Web3(Web3.HTTPProvider(RPC_URL))

# Загрузка ABI (убедись, что путь верный после forge build)
with open("out/YourContract.sol/YourContract.json") as f:
    abi = json.load(f)["abi"]

contract = w3.eth.contract(address=CONTRACT_ADDRESS, abi=abi)

def send_status_transaction(status_index):
    """Отправляет транзакцию в блокчейн для смены статуса"""
    nonce = w3.eth.get_transaction_count(ACCOUNT_ADDRESS)
    
    # Собираем транзакцию
    tx = contract.functions.setVotingStatus(status_index).build_transaction({
        'from': ACCOUNT_ADDRESS,
        'nonce': nonce,
        'gas': 200000,
        'gasPrice': w3.eth.gas_price # Берем актуальную цену газа из сети
    })

    # Подписываем и отправляем
    signed_tx = w3.eth.account.sign_transaction(tx, private_key=PRIVATE_KEY)
    tx_hash = w3.eth.send_raw_transaction(signed_tx.raw_transaction)
    
    print(f"Транзакция отправлена! Ждем подтверждения... (Hash: {tx_hash.hex()})")
    return w3.eth.wait_for_transaction_receipt(tx_hash)

def start_automated_voting():
    try:
        # 1. Открываем голосование (статус 0 - Open)
        print("--- Шаг 1: Открываем голосование ---")
        send_status_transaction(0)
        print("Голосование официально ОТКРЫТО.")

        # 2. Ждем
        print(f"--- Шаг 2: Таймер запущен на {VOTING_DURATION} сек. ---")
        # Для теста можешь поставить здесь 10-20 секунд
        time.sleep(VOTING_DURATION) 

        # 3. Закрываем голосование (статус 1 - Closed)
        print("--- Шаг 3: Время вышло! Закрываем голосование ---")
        send_status_transaction(1)
        print("Голосование официально ЗАКРЫТО.")

    except Exception as e:
        print(f"Произошла ошибка: {e}")

if __name__ == "__main__":
    if w3.is_connected():
        print("Бот запущен и подключен к сети.")
        start_automated_voting()
    else:
        print("Ошибка: Нет соединения с RPC")