import UIKit
import ThemeKit
import SnapKit

class BalanceCell: UICollectionViewCell {
    private static let insets = UIEdgeInsets(top: .margin2x, left: .margin2x, bottom: .margin2x, right: .margin2x)

    private let cardView = CardView(insets: BalanceCell.insets)

    private let topView = BalanceTopView()
    private let separatorView = BalanceSeparatorView()
    private let amountView = BalanceAmountView()
    private let lockedAmountView = SecondaryBalanceDoubleRowView()
    private let buttonsView = DoubleRowButtonView(leftButton: .appGreen, rightButton: .appYellow)

    private var onPay: (() -> ())?
    private var onReceive: (() -> ())?

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(cardView)
        cardView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        cardView.contentView.addSubview(topView)
        topView.snp.makeConstraints { maker in
            maker.leading.top.trailing.equalToSuperview()
            maker.height.equalTo(BalanceTopView.height)
        }

        cardView.contentView.addSubview(separatorView)
        separatorView.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview()
            maker.top.equalTo(topView.snp.bottom)
            maker.height.equalTo(BalanceSeparatorView.height)
        }

        cardView.contentView.addSubview(amountView)
        amountView.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview()
            maker.top.equalTo(separatorView.snp.bottom)
            maker.height.equalTo(BalanceAmountView.height)
        }

        cardView.contentView.addSubview(lockedAmountView)
        lockedAmountView.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview()
            maker.top.equalTo(amountView.snp.bottom)
            maker.height.equalTo(SecondaryBalanceDoubleRowView.height)
        }

        cardView.contentView.addSubview(buttonsView)
        buttonsView.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview()
            maker.top.equalTo(lockedAmountView.snp.bottom)
            maker.height.equalTo(DoubleRowButtonView.height)
        }

        buttonsView.bind(leftTitle: "balance.deposit".localized, rightTitle: "balance.send".localized)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }

    func bind(viewItem: BalanceViewItem, animated: Bool = false, duration: TimeInterval = 0.2, onReceive: @escaping () -> (), onPay: @escaping () -> (), onChart: @escaping () -> ()) {
        self.onPay = onPay
        self.onReceive = onReceive

        topView.bind(viewItem: viewItem.topViewItem, onTapRateDiff: onChart)

        separatorView.set(hidden: !viewItem.separatorVisible, animated: animated, duration: duration)

        amountView.bind(viewItem: viewItem.amountViewItem, animated: animated, duration: duration)
        amountView.layoutIfNeeded()
        amountView.snp.updateConstraints { maker in
            maker.height.equalTo(viewItem.amountViewItem != nil ? BalanceAmountView.height : 0)
        }

        if let viewItem = viewItem.lockedAmountViewItem {
            lockedAmountView.bind(image: UIImage(named: "Transaction Lock Icon"), coinValue: viewItem.lockedCoinValue, currencyValue: viewItem.lockedCurrencyValue)
            lockedAmountView.layoutIfNeeded()
        }
        lockedAmountView.set(hidden: viewItem.lockedAmountViewItem == nil, animated: animated, duration: duration)
        lockedAmountView.snp.updateConstraints { maker in
            maker.height.equalTo(viewItem.lockedAmountViewItem != nil ? SecondaryBalanceDoubleRowView.height : 0)
        }

        if let viewItem = viewItem.buttonsViewItem {
            buttonsView.bind(leftEnabled: viewItem.receiveButtonEnabled, rightEnabled: viewItem.sendButtonEnabled, leftAction: onReceive, rightAction: onPay)
        }
        buttonsView.set(hidden: viewItem.buttonsViewItem == nil, animated: animated, duration: duration)
    }

    static func height(viewItem: BalanceViewItem) -> CGFloat {
        var height: CGFloat = BalanceCell.insets.height

        height += BalanceTopView.height

        if viewItem.separatorVisible {
            height += BalanceSeparatorView.height
        }

        if viewItem.amountViewItem != nil {
            height += BalanceAmountView.height
        }

        if viewItem.lockedAmountViewItem != nil {
            height += SecondaryBalanceDoubleRowView.height
        }

        if viewItem.buttonsViewItem != nil {
            height += DoubleRowButtonView.height
        }

        return height
    }

}
