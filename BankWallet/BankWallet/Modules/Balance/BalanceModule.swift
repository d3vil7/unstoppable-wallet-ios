import Foundation
import DeepDiff
import XRatesKit
import CurrencyKit

protocol IBalanceView: class {
    func set(headerViewItem: BalanceHeaderViewItem?, viewItems: [BalanceViewItem])
    func showSortType(selectedSortType: BalanceSortType)
    func showBackupRequired(coin: Coin, predefinedAccountType: PredefinedAccountType)
    func hideRefresh()
}

protocol IBalanceViewDelegate {
    func onLoad()
    func onAppear()
    func onDisappear()

    func onTriggerRefresh()

    func onTap(viewItem: BalanceViewItem)
    func onTapReceive(viewItem: BalanceViewItem)
    func onTapPay(viewItem: BalanceViewItem)
    func onTapChart(viewItem: BalanceViewItem)

    func onTapAddCoin()

    func onTapSortType()
    func onSelect(sortType: BalanceSortType)

    func onTapHideBalance()
    func onTapShowBalance()

    func onRequestBackup()
}

protocol IBalanceInteractor: AnyObject {
    var wallets: [Wallet] { get }
    var baseCurrency: Currency { get }

    func marketInfo(coinCode: CoinCode, currencyCode: String) -> MarketInfo?
    func balance(wallet: Wallet) -> Decimal?
    func balanceLocked(wallet: Wallet) -> Decimal?
    func state(wallet: Wallet) -> AdapterState?

    func subscribeToWallets()
    func subscribeToBaseCurrency()
    func subscribeToAdapters(wallets: [Wallet])

    func subscribeToMarketInfo(currencyCode: String)

    var sortType: BalanceSortType? { get set }
    var balanceHidden: Bool { get set }
    var chartBlockedCoinCodes: Set<String> { get }

    func refresh()
    func predefinedAccountType(wallet: Wallet) -> PredefinedAccountType?

    func notifyAppear()
    func notifyDisappear()
}

protocol IBalanceInteractorDelegate: class {
    func didUpdate(wallets: [Wallet])
    func didPrepareAdapters()
    func didUpdate(balance: Decimal, balanceLocked: Decimal?, wallet: Wallet)
    func didUpdate(state: AdapterState, wallet: Wallet)

    func didUpdate(currency: Currency)
    func didUpdate(marketInfos: [CoinCode: MarketInfo])

    func didRefresh()
}

protocol IBalanceRouter {
    func openReceive(for wallet: Wallet)
    func openSend(wallet: Wallet)
    func showChart(for coinCode: CoinCode)
    func openManageWallets()
    func openBackup(wallet: Wallet, predefinedAccountType: PredefinedAccountType)
}

protocol IBalanceViewItemFactory {
    func viewItem(item: BalanceItem, currency: Currency, balanceHidden: Bool, expanded: Bool) -> BalanceViewItem
    func headerViewItem(items: [BalanceItem], currency: Currency, sortingOnThreshold: Int) -> BalanceHeaderViewItem
}

protocol IBalanceSorter {
    func sort(items: [BalanceItem], sort: BalanceSortType) -> [BalanceItem]
}

enum BalanceSortType: Int, CaseIterable {
    case value
    case name
    case percentGrowth

    var title: String {
        switch self {
        case .value: return "balance.sort.valueHighToLow".localized
        case .name: return "balance.sort.az".localized
        case .percentGrowth: return "balance.sort.24h_change".localized
        }
    }

}
