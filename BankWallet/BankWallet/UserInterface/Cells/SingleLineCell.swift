import UIKit
import SnapKit

class SingleLineCell: AppCell {
    private let leftView = SingleLineCellView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(leftView)
        leftView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(text: String?, last: Bool = false) {
        super.bind(last: last)

        leftView.bind(text: text)
    }

}
