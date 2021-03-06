import Foundation
import RxSwift

class SendBitcoinHandler {
    weak var delegate: ISendHandlerDelegate?

    private let interactor: ISendBitcoinInteractor

    private let amountModule: ISendAmountModule
    private let addressModule: ISendAddressModule
    private let feeModule: ISendFeeModule
    private let feePriorityModule: ISendFeePriorityModule
    private let hodlerModule: ISendHodlerModule?

    private var pluginData = [UInt8: IBitcoinPluginData]()

    init(interactor: ISendBitcoinInteractor, amountModule: ISendAmountModule, addressModule: ISendAddressModule,
         feeModule: ISendFeeModule, feePriorityModule: ISendFeePriorityModule, hodlerModule: ISendHodlerModule?) {
        self.interactor = interactor

        self.amountModule = amountModule
        self.addressModule = addressModule
        self.feeModule = feeModule
        self.feePriorityModule = feePriorityModule
        self.hodlerModule = hodlerModule
    }

    private func syncValidation() {
        do {
            _ = try amountModule.validAmount()
            try addressModule.validateAddress()

            delegate?.onChange(isValid: true)
        } catch {
            delegate?.onChange(isValid: false)
        }
    }

    private func syncMaximumAmount() {
        interactor.fetchMaximumAmount(pluginData: pluginData)
    }

    private func syncMinimumAmount() {
        interactor.fetchMinimumAmount(address: addressModule.currentAddress)
    }

    private func syncState() {
        let loading = feePriorityModule.feeRateState.isLoading

        amountModule.set(loading: loading)

        guard !loading else {
            return
        }

        if case let .error(error) = feePriorityModule.feeRateState {
            feeModule.set(fee: 0)
            feeModule.set(externalError: error)
        } else if case let .value(feeRateValue) = feePriorityModule.feeRateState {
            interactor.fetchAvailableBalance(feeRate: feeRateValue, address: addressModule.currentAddress, pluginData: pluginData)

            feeModule.set(externalError: nil)
            interactor.fetchFee(amount: amountModule.currentAmount, feeRate: feeRateValue, address: addressModule.currentAddress, pluginData: pluginData)
        }
    }

}

extension SendBitcoinHandler: ISendHandler {

    func onViewDidLoad() {
        feePriorityModule.fetchFeeRate()

        syncState()
        syncMinimumAmount()
    }

    func showKeyboard() {
        amountModule.showKeyboard()
    }

    func confirmationViewItems() throws -> [ISendConfirmationViewItemNew] {
        var items: [ISendConfirmationViewItemNew] = [
            SendConfirmationAmountViewItem(primaryInfo: try amountModule.primaryAmountInfo(), secondaryInfo: try amountModule.secondaryAmountInfo(), receiver: try addressModule.validAddress()),
            SendConfirmationFeeViewItem(primaryInfo: feeModule.primaryAmountInfo, secondaryInfo: feeModule.secondaryAmountInfo),
        ]
        if let duration = feePriorityModule.duration {
            items.append(SendConfirmationDurationViewItem(timeInterval: duration))
        }
        if let lockValue = hodlerModule?.lockTimeInterval?.title {
            items.append(SendConfirmationLockUntilViewItem(lockValue: lockValue))
        }
        return items
    }

    func sync() {
        if feePriorityModule.feeRateState.isError {
            feePriorityModule.fetchFeeRate()
            syncState()
            syncValidation()
        }
    }

    func sync(rateValue: Decimal?) {
        amountModule.set(rateValue: rateValue)
        feeModule.set(rateValue: rateValue)
    }

    func sync(inputType: SendInputType) {
        amountModule.set(inputType: inputType)
        feeModule.update(inputType: inputType)
    }

    func sendSingle() throws -> Single<Void> {
        guard let feeRate = feePriorityModule.feeRate else {
            throw SendTransactionError.noFee
        }
        return interactor.sendSingle(amount: try amountModule.validAmount(), address: try addressModule.validAddress(), feeRate: feeRate, pluginData: pluginData)
    }

}

extension SendBitcoinHandler: ISendBitcoinInteractorDelegate {

    func didFetch(availableBalance: Decimal) {
        amountModule.set(availableBalance: availableBalance)
        syncValidation()
    }

    func didFetch(maximumAmount: Decimal?) {
        amountModule.set(maximumAmount: maximumAmount)
        syncValidation()
    }

    func didFetch(minimumAmount: Decimal) {
        amountModule.set(minimumAmount: minimumAmount)
        syncValidation()
    }

    func didFetch(fee: Decimal) {
        feeModule.set(fee: fee)
    }

}

extension SendBitcoinHandler: ISendAmountDelegate {

    func onChangeAmount() {
        syncState()
        syncValidation()
    }

    func onChange(inputType: SendInputType) {
        feeModule.update(inputType: inputType)
    }

}

extension SendBitcoinHandler: ISendAddressDelegate {

    func validate(address: String) throws {
        try interactor.validate(address: address, pluginData: pluginData)
    }

    func onUpdateAddress() {
        syncMinimumAmount()
        syncState()
    }

    func onUpdate(amount: Decimal) {
        amountModule.set(amount: amount)
    }

}

extension SendBitcoinHandler: ISendFeePriorityDelegate {

    func onUpdateFeePriority() {
        syncState()
    }

}

extension SendBitcoinHandler: ISendHodlerDelegate {

    func onUpdateLockTimeInterval() {
        guard let hodlerModule = hodlerModule else {
            return
        }

        pluginData = hodlerModule.pluginData
        syncValidation()
        syncMaximumAmount()
        syncState()
    }

}
