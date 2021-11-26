import UIKit
import SafariServices

class MainViewController: UIViewController {

    private enum Constants {
        static let filterImage = UIImage(systemName: "line.horizontal.3.decrease.circle")
        static let filterButtonAccessibilityId = "filterButtonAccessibilityId"
        static let collectionViewAccessibilityId = "collectionViewAccessibilityId"
        static let navBarTitle = "SpaceX"
        static let filterScreenTitle = "Filter"
        static let filterScreenMessage = "Filter successful launches by ascending or descending date."
        static let filterByAscending = "Ascending"
        static let filterByDescending = "Descending"
        static let cancel = "Cancel"
        static let errorTitle = "Something went wrong!"
    }

    private let viewModel: MainViewModel

    private lazy var filterButton: UIBarButtonItem = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(Constants.filterImage, for: .normal)
        button.accessibilityIdentifier = Constants.filterButtonAccessibilityId
        button.translatesAutoresizingMaskIntoConstraints = false
        return UIBarButtonItem(customView: button)
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.register(CompanyInfoHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: CompanyInfoHeaderView.reuseID)
        collectionView.register(LaunchCell.self, forCellWithReuseIdentifier: LaunchCell.reuseID)
        collectionView.delegate = self
        collectionView.accessibilityIdentifier = Constants.collectionViewAccessibilityId
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private lazy var collectionViewFlowLayout: UICollectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
            return CollectionViewLayoutManager.launchSection
        }
        return layout
    }()

    private lazy var datasource: UICollectionViewDiffableDataSource<Section, Launch> = {
        self.viewModel.createAndFetchDataSource(with: collectionView)
    }()

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        viewModel.fetchLaunchDetails(page: viewModel.page, filterType: nil) { result in
            DispatchQueue.main.async { self.presentAlert(title: Constants.errorTitle, message: result, buttonTitle: nil) }
        }
    }

    private func configureView() {
        title = Constants.navBarTitle
        navigationItem.rightBarButtonItem = filterButton
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshCollectionView))


        collectionView.dataSource = datasource
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func refreshCollectionView() {
        viewModel.isFiltering = false
        viewModel.fetchCompanyInfo { _ in }
        viewModel.fetchLaunchDetails(page: viewModel.page, filterType: nil) { result in
            DispatchQueue.main.async { self.presentAlert(title: Constants.errorTitle, message: result, buttonTitle: nil) }
        }
    }

    @objc private func filterButtonTapped() {
        let alertController = UIAlertController(title: Constants.filterScreenTitle,
                                                message: Constants.filterScreenMessage,
                                                preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: Constants.filterByAscending, style: .default, handler: { _ in
            self.viewModel.filterLaunchDetails(by: .asc)
        }))
        alertController.addAction(UIAlertAction(title: Constants.filterByDescending, style: .default, handler: { _ in
            self.viewModel.filterLaunchDetails(by: .desc)
        }))
        alertController.addAction(UIAlertAction(title: Constants.cancel, style: .cancel, handler: nil))

        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = filterButton
        }

        present(alertController, animated: true)
    }
}

extension MainViewController: UICollectionViewDelegate, SFSafariViewControllerDelegate {

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height {
            guard !viewModel.isLoadingMoreLaunches else { return }

            viewModel.fetchLaunchDetails(page: viewModel.page, filterType: nil) { _ in
            }
            viewModel.page = viewModel.page + 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let wikiString = viewModel.launchDetails[indexPath.row].links.wikipedia else { return }
        guard let wikiUrl = URL(string: wikiString) else { return }

        let webController = SFSafariViewController(url: wikiUrl)
        webController.delegate = self

        present(webController, animated: true)
    }
}
