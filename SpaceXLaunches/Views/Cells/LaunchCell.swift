import UIKit

class LaunchCell: UICollectionViewCell {

    private enum Constants {
        static let reuseID = "LaunchCell"
        static let accessibilityId = "LaunchCellAccessibilityId"
        static let placeholderImage = UIImage(named: "PlaceholderImage")
        static let checkmarkImage = UIImage(systemName: "checkmark")
        static let xmarkImage = UIImage(systemName: "xmark")

        static let topPadding: CGFloat = 20.0
        static let xsPadding: CGFloat = 4.0
        static let smallPadding: CGFloat = 8.0
        static let padding: CGFloat = 12.0

        static let textSize: CGFloat = 15.0

        static let patchImageDimensions: CGFloat = 75.0
        static let statusImageDimensions: CGFloat = 32.0
    }

    static let reuseID = Constants.reuseID

    var viewModel: MainViewModel?

    private lazy var patchImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        view.image = Constants.placeholderImage
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var statusImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        view.image = Constants.placeholderImage
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .equalSpacing
        view.isBaselineRelativeArrangement = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var informationStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .equalSpacing
        view.isBaselineRelativeArrangement = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var containerStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.spacing = 4
        view.isBaselineRelativeArrangement = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        accessibilityIdentifier = Constants.accessibilityId
        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        while informationStackView.arrangedSubviews.count >= 1 {
            informationStackView.arrangedSubviews[0].removeFromSuperview()
        }
        while titleStackView.arrangedSubviews.count >= 1 {
            titleStackView.arrangedSubviews[0].removeFromSuperview()
        }
        statusImageView.image = nil
        patchImageView.image = nil
    }

    private func configureView() {
        addSubview(patchImageView)
        addSubview(containerStackView)
        addSubview(statusImageView)

        backgroundColor = .systemGray3

        containerStackView.addArrangedSubview(titleStackView)
        containerStackView.addArrangedSubview(informationStackView)

        NSLayoutConstraint.activate([
            patchImageView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.topPadding),
            patchImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.xsPadding),
            patchImageView.heightAnchor.constraint(equalToConstant: Constants.patchImageDimensions),
            patchImageView.widthAnchor.constraint(equalToConstant: Constants.patchImageDimensions),

            statusImageView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.topPadding),
            statusImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.xsPadding),
            statusImageView.heightAnchor.constraint(equalToConstant: Constants.statusImageDimensions),
            statusImageView.widthAnchor.constraint(equalToConstant: Constants.statusImageDimensions),

            containerStackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.topPadding),
            containerStackView.leadingAnchor.constraint(equalTo: patchImageView.trailingAnchor, constant: Constants.smallPadding),
            containerStackView.trailingAnchor.constraint(equalTo: statusImageView.leadingAnchor, constant: -Constants.smallPadding),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.padding)
        ])

        configureTitleStackView()
    }

    func configureTitleStackView() {
        guard let viewModel = viewModel else { return }

        for index in 0...2 {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: Constants.textSize, weight: .light)
            label.text = viewModel.launchTitles[index]
            titleStackView.addArrangedSubview(label)
        }
    }

    func configureLaunchDetails(with launch: Launch) {
        guard let viewModel = viewModel else { return }

        let nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: Constants.textSize, weight: .regular)
        nameLabel.text = launch.name
        informationStackView.addArrangedSubview(nameLabel)

        let dateLabel = UILabel()
        dateLabel.font = UIFont.systemFont(ofSize: Constants.textSize, weight: .regular)
        viewModel.formatLaunchDate(date: launch.dateUtc) { formattedDate in
            dateLabel.text = formattedDate
        }
        informationStackView.addArrangedSubview(dateLabel)

        let rocketLabel = UILabel()
        rocketLabel.font = UIFont.systemFont(ofSize: Constants.textSize, weight: .regular)
        rocketLabel.lineBreakMode = .byTruncatingTail
        rocketLabel.text = launch.rocket
        informationStackView.addArrangedSubview(rocketLabel)

        let timeDistanceLabel = UILabel()
        viewModel.determineTimeDistanceInLaunch(date: launch.dateUnix) { timeDistance, timeDistanceText in
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: Constants.textSize, weight: .light)
            label.text = timeDistanceText
            self.titleStackView.insertArrangedSubview(label, at: 3)
            timeDistanceLabel.text = timeDistance
        }
        timeDistanceLabel.font = UIFont.systemFont(ofSize: Constants.textSize, weight: .regular)
        informationStackView.addArrangedSubview(timeDistanceLabel)

        guard let launchStatus = launch.success else { return }
        if launchStatus == true {
            self.statusImageView.image = Constants.checkmarkImage
        } else {
            self.statusImageView.image = Constants.xmarkImage
        }

        guard let imageLink = launch.links.patch?.small else { return }
        viewModel.setLaunchImage(imageUrlString: imageLink) { image in
            DispatchQueue.main.async { self.patchImageView.image = image }
        }
    }
}
