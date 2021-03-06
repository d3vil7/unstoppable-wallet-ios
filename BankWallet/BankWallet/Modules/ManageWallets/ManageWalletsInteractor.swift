import RxSwift

class ManageWalletsInteractor {
    weak var delegate: IManageWalletsInteractorDelegate?

    private let disposeBag = DisposeBag()

    private let appConfigProvider: IAppConfigProvider
    private let walletManager: IWalletManager
    private let walletFactory: IWalletFactory
    private let accountManager: IAccountManager
    private let accountCreator: IAccountCreator
    private let predefinedAccountTypeManager: IPredefinedAccountTypeManager
    private let derivationSettingsManager: IDerivationSettingsManager

    init(appConfigProvider: IAppConfigProvider, walletManager: IWalletManager, walletFactory: IWalletFactory, accountManager: IAccountManager, accountCreator: IAccountCreator, predefinedAccountTypeManager: IPredefinedAccountTypeManager, derivationSettingsManager: IDerivationSettingsManager) {
        self.appConfigProvider = appConfigProvider
        self.walletManager = walletManager
        self.walletFactory = walletFactory
        self.accountManager = accountManager
        self.accountCreator = accountCreator
        self.predefinedAccountTypeManager = predefinedAccountTypeManager
        self.derivationSettingsManager = derivationSettingsManager

        accountManager.accountsObservable
                .subscribeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] _ in
                    self?.delegate?.didUpdateAccounts()
                })
                .disposed(by: disposeBag)
    }

}

extension ManageWalletsInteractor: IManageWalletsInteractor {

    var coins: [Coin] {
        appConfigProvider.coins
    }

    var featuredCoins: [Coin] {
        appConfigProvider.featuredCoins
    }

    var accounts: [Account] {
        accountManager.accounts
    }

    var wallets: [Wallet] {
        walletManager.wallets
    }

    func save(wallet: Wallet) {
        walletManager.save(wallets: [wallet])
    }

    func delete(wallet: Wallet) {
        walletManager.delete(wallets: [wallet])
    }

    func createAccount(predefinedAccountType: PredefinedAccountType) throws -> Account {
        try accountCreator.newAccount(predefinedAccountType: predefinedAccountType)
    }

    func createRestoredAccount(accountType: AccountType) -> Account {
        accountCreator.restoredAccount(accountType: accountType)
    }

    func save(account: Account) {
        accountManager.save(account: account)
    }

    func derivationSetting(coinType: CoinType) -> DerivationSetting? {
        derivationSettingsManager.setting(coinType: coinType)
    }

    func save(derivationSetting: DerivationSetting) {
        derivationSettingsManager.save(setting: derivationSetting)
    }

}
