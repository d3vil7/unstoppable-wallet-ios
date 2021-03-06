platform :ios, '12'
use_modular_headers!

inhibit_all_warnings!

project 'BankWallet/BankWallet'

def appPods
  pod 'BitcoinKit.swift', '0.14.1'
  pod 'LitecoinKit.swift', '0.14.1'
  pod 'BitcoinCashKit.swift', '0.14.1'
  pod 'DashKit.swift', '0.14.1'
  pod 'Hodler.swift', '0.14.1'

  pod 'BitcoinCore.swift', '0.14.1'

  pod 'EthereumKit.swift', '0.9.1'
  pod 'Erc20Kit.swift', '0.9.1'

  pod 'EosKit.swift', '0.3.3'
  pod 'EosioSwiftAbieosSerializationProvider', git: 'https://github.com/horizontalsystems/eosio-swift-abieos-serialization-provider.git'

  pod 'BinanceChainKit.swift', '0.3.2'

  pod 'HdWalletKit.swift', git: 'https://github.com/horizontalsystems/hd-wallet-kit-ios'

  pod 'XRatesKit.swift', git: 'https://github.com/horizontalsystems/xrates-kit-ios/'
  # pod 'XRatesKit.swift', path: '../xrates-kit-ios/'
  pod 'FeeRateKit.swift', git: 'https://github.com/horizontalsystems/blockchain-fee-rate-kit-ios'
  # pod 'FeeRateKit.swift', path: '../blockchain-fee-rate-kit-ios/'

  pod 'UIExtensions.swift', git: 'https://github.com/horizontalsystems/gui-kit/'
  # pod 'UIExtensions.swift', path: '../gui-kit/'
  pod 'ThemeKit.swift', git: 'https://github.com/horizontalsystems/component-kit-ios/'
  # pod 'ThemeKit.swift', path: '../component-kit-ios/'
  pod 'LanguageKit.swift', git: 'https://github.com/horizontalsystems/component-kit-ios/'
  # pod 'LanguageKit.swift', path: '../component-kit-ios/'
  pod 'StorageKit.swift', git: 'https://github.com/horizontalsystems/component-kit-ios/'
  # pod 'StorageKit.swift', path: '../component-kit-ios/'
  pod 'PinKit.swift', git: 'https://github.com/horizontalsystems/component-kit-ios/'
  # pod 'PinKit.swift', path: '../component-kit-ios/'
  pod 'CurrencyKit.swift', git: 'https://github.com/horizontalsystems/component-kit-ios/'
  # pod 'CurrencyKit.swift', path: '../component-kit-ios/'

  pod 'ActionSheet.swift', git: 'https://github.com/horizontalsystems/gui-kit/'
 pod 'HUD.swift', git: 'https://github.com/horizontalsystems/gui-kit/'
  # pod 'HUD.swift', path: '../gui-kit/'
  pod 'Chart.swift', git: 'https://github.com/horizontalsystems/gui-kit/'
  # pod 'Chart.swift', path: '../gui-kit/'
  pod 'SectionsTableView.swift'

  pod 'Alamofire'
  pod 'AlamofireImage'
  pod 'ObjectMapper'

  pod 'GRDB.swift'

  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxGRDB'

  pod 'BigInt'
  pod 'KeychainAccess'
  pod 'SnapKit'
  pod 'DeepDiff'
end

target 'Bank Dev T' do
  appPods
end

target 'Bank Dev' do
  appPods
end

target 'Bank' do
  appPods
end

target 'Bank Tests' do
  pod 'DeepDiff'
  pod 'RxSwift'
  pod 'Cuckoo'
  pod 'Quick'
  pod 'Nimble'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
