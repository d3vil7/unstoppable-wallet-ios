import XRatesKit
import CurrencyKit

class BalancePresenter {
    private static let sortingOnThreshold: Int = 5

    weak var view: IBalanceView?

    private var interactor: IBalanceInteractor
    private let router: IBalanceRouter
    private let factory: IBalanceViewItemFactory
    private let sorter: IBalanceSorter
    private let sortingOnThreshold: Int

    private var walletToBackup: Wallet?
    private var expandedWallet: Wallet?

    private var items = [BalanceItem]()
    private var viewItems = [BalanceViewItem]()
    private var headerViewItem: BalanceHeaderViewItem?
    private var currency: Currency
    private var sortType: BalanceSortType
    private var balanceHidden: Bool

    private let queue = DispatchQueue(label: "io.horizontalsystems.unstoppable.balance_presenter", qos: .userInteractive)

    init(interactor: IBalanceInteractor, router: IBalanceRouter, factory: IBalanceViewItemFactory, sorter: IBalanceSorter, sortingOnThreshold: Int = BalancePresenter.sortingOnThreshold) {
        self.interactor = interactor
        self.router = router
        self.factory = factory
        self.sorter = sorter
        self.sortingOnThreshold = sortingOnThreshold

        currency = interactor.baseCurrency
        sortType = interactor.sortType ?? .name
        balanceHidden = interactor.balanceHidden
    }

    private func handleUpdate(wallets: [Wallet]) {
        items = wallets.map { BalanceItem(wallet: $0) }

        handleAdaptersReady()
        fillLatestRates()
    }

    private func handleAdaptersReady() {
        interactor.subscribeToAdapters(wallets: items.map { $0.wallet })

        items.forEach { item in
            item.balance = interactor.balance(wallet: item.wallet)
            item.balanceLocked = interactor.balanceLocked(wallet: item.wallet)
            item.state = interactor.state(wallet: item.wallet)
        }
    }

    private func subscribeRates() {
        interactor.subscribeToMarketInfo(currencyCode: currency.code)
    }

    private func fillLatestRates() {
        for item in items {
            item.marketInfo = interactor.marketInfo(coinCode: item.wallet.coin.code, currencyCode: currency.code)
        }
    }

    private func updateItem(wallet: Wallet, updateBlock: (BalanceItem) -> ()) {
        guard let index = items.firstIndex(where: { $0.wallet == wallet }) else {
            return
        }

        let item = items[index]
        updateBlock(item)
        viewItems[index] = viewItem(item: item)
    }

    private func updateViewItems() {
        items = sorter.sort(items: items, sort: sortType)

        viewItems = items.map {
            viewItem(item: $0)
        }
    }

    private func updateHeaderViewItem() {
        if balanceHidden {
            headerViewItem = nil
        } else {
            headerViewItem = factory.headerViewItem(items: items, currency: currency, sortingOnThreshold: sortingOnThreshold)
        }
    }

    private func viewItem(item: BalanceItem) -> BalanceViewItem {
        factory.viewItem(item: item, currency: currency, balanceHidden: balanceHidden, expanded: item.wallet == expandedWallet)
    }

    private func refreshView() {
        view?.set(headerViewItem: headerViewItem, viewItems: viewItems)
    }

    private func handle(balanceHidden: Bool) {
        queue.async {
            self.balanceHidden = balanceHidden
            self.interactor.balanceHidden = balanceHidden

            self.updateViewItems()
            self.updateHeaderViewItem()
            self.refreshView()
        }
    }

}

extension BalancePresenter: IBalanceViewDelegate {

    func onLoad() {
        queue.async {
            self.interactor.subscribeToWallets()
            self.interactor.subscribeToBaseCurrency()

            self.handleUpdate(wallets: self.interactor.wallets)
            self.subscribeRates()
            self.fillLatestRates()

            self.updateViewItems()
            self.updateHeaderViewItem()
            self.refreshView()
        }
    }

    func onAppear() {
        interactor.notifyAppear()
    }

    func onDisappear() {
        interactor.notifyDisappear()
    }

    func onTriggerRefresh() {
        interactor.refresh()
    }

    func onTap(viewItem: BalanceViewItem) {
        queue.async {
            if self.expandedWallet == viewItem.wallet, let index = self.items.firstIndex(where: { $0.wallet == viewItem.wallet }) {
                self.expandedWallet = nil
                self.viewItems[index] = self.viewItem(item: self.items[index])
            } else {
                var oldIndex: Int?
                var newIndex: Int?

                for (index, item) in self.items.enumerated() {
                    if item.wallet == self.expandedWallet {
                        oldIndex = index
                    }
                    if item.wallet == viewItem.wallet {
                        newIndex = index
                    }
                }

                self.expandedWallet = viewItem.wallet

                if let oldIndex = oldIndex {
                    self.viewItems[oldIndex] = self.viewItem(item: self.items[oldIndex])
                }

                if let newIndex = newIndex {
                    self.viewItems[newIndex] = self.viewItem(item: self.items[newIndex])
                }
            }

            self.refreshView()
        }
    }

    func onTapReceive(viewItem: BalanceViewItem) {
        let wallet = viewItem.wallet

        if wallet.account.backedUp {
            router.openReceive(for: wallet)
        } else if let predefinedAccountType = interactor.predefinedAccountType(wallet: wallet) {
            walletToBackup = wallet
            view?.showBackupRequired(coin: wallet.coin, predefinedAccountType: predefinedAccountType)
        }
    }

    func onTapPay(viewItem: BalanceViewItem) {
        router.openSend(wallet: viewItem.wallet)
    }

    func onTapChart(viewItem: BalanceViewItem) {
        let coinCode = viewItem.wallet.coin.code

        guard !interactor.chartBlockedCoinCodes.contains(coinCode) else {
            return
        }

        router.showChart(for: coinCode)
    }

    func onTapAddCoin() {
        router.openManageWallets()
    }

    func onTapSortType() {
        view?.showSortType(selectedSortType: sortType)
    }

    func onSelect(sortType: BalanceSortType) {
        queue.async {
            self.sortType = sortType
            self.interactor.sortType = sortType

            self.updateViewItems()
            self.refreshView()
        }
    }

    func onTapHideBalance() {
        handle(balanceHidden: true)
    }

    func onTapShowBalance() {
        handle(balanceHidden: false)
    }

    func onRequestBackup() {
        guard let wallet = walletToBackup, let predefinedAccountType = interactor.predefinedAccountType(wallet: wallet) else {
            return
        }

        router.openBackup(wallet: wallet, predefinedAccountType: predefinedAccountType)
    }

}

extension BalancePresenter: IBalanceInteractorDelegate {

    func didUpdate(wallets: [Wallet]) {
        queue.async {
            self.handleUpdate(wallets: wallets)

            self.updateViewItems()
            self.updateHeaderViewItem()
            self.refreshView()
        }
    }

    func didPrepareAdapters() {
        queue.async {
            self.handleAdaptersReady()

            self.updateViewItems()
            self.updateHeaderViewItem()
            self.refreshView()
        }
    }

    func didUpdate(balance: Decimal, balanceLocked: Decimal?, wallet: Wallet) {
        queue.async {
            self.updateItem(wallet: wallet) { item in
                item.balance = balance
                item.balanceLocked = balanceLocked
            }

            self.updateHeaderViewItem()
            self.refreshView()
        }
    }

    func didUpdate(state: AdapterState, wallet: Wallet) {
        queue.async {
            self.updateItem(wallet: wallet) { item in
                item.state = state
            }

            self.updateHeaderViewItem()
            self.refreshView()
        }
    }

    func didUpdate(currency: Currency) {
        queue.async {
            self.currency = currency

            self.subscribeRates()
            self.fillLatestRates()

            self.updateViewItems()
            self.updateHeaderViewItem()
            self.refreshView()
        }
    }

    func didUpdate(marketInfos: [CoinCode: MarketInfo]) {
        queue.async {
            for (coinCode, marketInfo) in marketInfos {
                for (index, item) in self.items.enumerated() {
                    if item.wallet.coin.code == coinCode {
                        item.marketInfo = marketInfo
                        self.viewItems[index] = self.viewItem(item: item)
                    }
                }
            }

            self.updateHeaderViewItem()
            self.refreshView()
        }
    }

    func didRefresh() {
        view?.hideRefresh()
    }

}
