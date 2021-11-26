import UIKit

class CompanyInfoHeaderView: UICollectionReusableView {

    private enum Constants {
        static let reuseID = "CompanyInfoHeaderView"
        static let fontSize: CGFloat = 17.0
    }

    static let reuseID = Constants.reuseID

    private lazy var companyInfoLabel: UILabel = {
        let label = UILabel()
        label.font.withSize(Constants.fontSize)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var viewModel: MainViewModel? {
        didSet {
            configureViewWithCompanyInfo()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureView() {
        backgroundColor = .systemGray3

        addSubview(companyInfoLabel)
        NSLayoutConstraint.activate([
            companyInfoLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            companyInfoLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            companyInfoLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor)
        ])
    }

    private func configureViewWithCompanyInfo() {
        guard let viewModel = viewModel else { return }

        viewModel.fetchCompanyInfo(completed: { [weak self] companyInfo in
            guard let self = self else { return }
            let companyInfoParentText = "\(companyInfo.name) was founded by \(companyInfo.founder) in \(companyInfo.founded). It has now \(companyInfo.employees) employees, \(companyInfo.launchSites) launch sites, and is valued at USD \(viewModel.formattedCompanyValuation)."
            DispatchQueue.main.async { self.companyInfoLabel.text = companyInfoParentText }
        })
    }
}
