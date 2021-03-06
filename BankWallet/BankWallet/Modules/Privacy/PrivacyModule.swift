protocol IPrivacyRouter {

}

protocol IPrivacyInteractor {
    var syncSettings: [(setting: InitialSyncSetting, coins: [Coin])] { get }
    var sortMode: TransactionDataSortMode { get }
    var ethereumConnection: EthereumRpcMode { get }
    func save(syncSetting: InitialSyncSetting)
    func save(connectionSetting: EthereumRpcMode)
    func save(sortSetting: TransactionDataSortMode)
}

protocol IPrivacyView: class {
    func updateUI()
    func set(sortMode: String)
    func set(connectionItems: [PrivacyViewItem])
    func set(syncModeItems: [PrivacyViewItem])
    func showSyncModeAlert(itemIndex: Int, coinName: String, iconName: String, items: [PrivacySyncSelectViewItem])
    func showConnectionModeAlert(itemIndex: Int, coinName: String, iconName: String, items: [PrivacyConnectionSelectViewItem])
    func showSortModeAlert(items: [PrivacySortSelectViewItem])
}

protocol IPrivacyViewDelegate {
    func onLoad()
    func onSelectSortMode()
    func onSelectConnection(index: Int)
    func onSelectSync(index: Int)
    func onSelectSyncSetting(itemIndex: Int, settingIndex: Int)
    func onSelectConnectionSetting(itemIndex: Int, settingIndex: Int)
    func onSelectSortSetting(settingIndex: Int)
}
