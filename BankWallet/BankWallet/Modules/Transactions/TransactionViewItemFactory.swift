import Foundation
import CurrencyKit

class TransactionViewItemFactory: ITransactionViewItemFactory {
    private let feeCoinProvider: IFeeCoinProvider

    init(feeCoinProvider: IFeeCoinProvider) {
        self.feeCoinProvider = feeCoinProvider
    }

    func viewItem(fromRecord record: TransactionRecord, wallet: Wallet, lastBlockInfo: LastBlockInfo? = nil, threshold: Int? = nil, rate: CurrencyValue? = nil) -> TransactionViewItem {
        let coin = wallet.coin
        var status: TransactionStatus = .pending

        if record.failed {
            status = .failed
        } else if let blockHeight = record.blockHeight, let lastBlockHeight = lastBlockInfo?.height {
            let threshold = threshold ?? 1
            let confirmations = lastBlockHeight - blockHeight + 1

            if confirmations >= threshold {
                status = .completed
            } else {
                status = .processing(progress: Double(confirmations) / Double(threshold))
            }
        }

        let currencyValue = rate.map {
            CurrencyValue(currency: $0.currency, value: $0.value * record.amount)
        }
        let coinValue = CoinValue(coin: coin, value: record.amount)
        let feeCoinValue: CoinValue? = record.fee.map {
            let feeCoin = feeCoinProvider.feeCoin(coin: coin) ?? coin
            return CoinValue(coin: feeCoin, value: $0)
        }

        var unlocked = record.lockInfo == nil

        if let lastBlockTimestamp = lastBlockInfo?.timestamp, let lockedUntil = record.lockInfo?.lockedUntil.timeIntervalSince1970 {
            unlocked = Double(lastBlockTimestamp) > lockedUntil
        }

        return TransactionViewItem(
                wallet: wallet,
                record: record,
                transactionHash: record.transactionHash,
                coinValue: coinValue,
                feeCoinValue: feeCoinValue,
                currencyValue: currencyValue,
                from: showFromAddress(for: coin.type) ? record.from : nil,
                to: record.to,
                type: record.type,
                date: record.date,
                status: status,
                rate: rate,
                lockInfo: record.lockInfo,
                unlocked: unlocked,
                conflictingTxHash: record.conflictingHash
        )
    }

    private func showFromAddress(for type: CoinType) -> Bool {
        !(type == .bitcoin || type == .litecoin || type == .bitcoinCash || type == .dash)
    }

    func viewStatus(adapterStates: [Coin: AdapterState], transactionsCount: Int) -> TransactionViewStatus {
        let noTransactions = transactionsCount == 0
        var upToDate = true

        adapterStates.values.forEach {
            if case .syncing = $0 {
                upToDate = false
            }
        }

        return TransactionViewStatus(showProgress: !upToDate, showMessage: noTransactions)
    }

}
