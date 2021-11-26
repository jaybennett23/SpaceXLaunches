import Foundation
import UIKit

enum Section {
    case companyInfo
    case launchInfo
}

enum FilterType {
    case asc
    case desc
}

class MainViewModel {

    private enum Constants {
        static let mission = "Mission:"
        static let dateTime = "Date/Time:"
        static let rocket = "Rocket:"
        static let timeDistance = "Days:"
        static let daysSince = "Days Since:"
        static let daysFrom = "Days From:"
    }

    var launchTitles = [
        Constants.mission,
        Constants.dateTime,
        Constants.rocket,
        Constants.timeDistance
    ]

    var page = 1
    var isLoadingMoreLaunches = false
    var isFiltering = false
    var launchDetails: [Launch] = []
    var filteredLaunchDetails = [Launch]()
    var formattedCompanyValuation = String()

    private let networkManager: NetworkManager
    private var datasource: UICollectionViewDiffableDataSource<Section, Launch>?

    init(networkManager: NetworkManager = ConcreteNetworkManager()) {
        self.networkManager = networkManager
    }

    func createAndFetchDataSource(with collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Section, Launch> {
        let datasource = UICollectionViewDiffableDataSource<Section, Launch>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, launch) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LaunchCell.reuseID, for: indexPath) as? LaunchCell
            cell?.viewModel = self
            cell?.configureTitleStackView()
            cell?.configureLaunchDetails(with: launch)
            return cell
        })

        datasource.supplementaryViewProvider = { (collectionView: UICollectionView,
                                                  kind: String,
                                                  indexPath: IndexPath) -> UICollectionReusableView? in


            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                                   withReuseIdentifier: CompanyInfoHeaderView.reuseID,
                                                                                   for: indexPath) as? CompanyInfoHeaderView else { return UICollectionReusableView() }
            headerView.viewModel = self
            return headerView
        }
        self.datasource = datasource
        setupSections()

        return datasource
    }

    private func setupSections() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Launch>()
        snapshot.appendSections([.launchInfo])
        snapshot.appendItems(launchDetails, toSection: .launchInfo)

        self.datasource?.apply(snapshot, animatingDifferences: true)
    }

    func updateCollectionViewData(with launchDetails: [Launch]) {
        guard let datasource = datasource else { return }
        var snapshot = NSDiffableDataSourceSnapshot<Section, Launch>()
        snapshot.appendSections([.launchInfo])
        snapshot.appendItems(launchDetails, toSection: .launchInfo)
        DispatchQueue.main.async { datasource.apply(snapshot, animatingDifferences: true) }
    }

    func fetchCompanyInfo(completed: @escaping (CompanyInfo) -> Void) {
        networkManager.fetchCompanyInfo { [weak self] companyInfo in
            guard let self = self else { return }
            guard let companyInfo = companyInfo else { return }

            let companyValutation = NSNumber(value: companyInfo.valuation)
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            self.formattedCompanyValuation = numberFormatter.string(from: companyValutation) ?? String(companyInfo.valuation)
            completed(companyInfo)
        }
    }

    func fetchLaunchDetails(page: Int, filterType: FilterType?, completed: @escaping(String) -> Void) {
        isLoadingMoreLaunches = true
        networkManager.fetchLaunchDetails(page: page) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let launches):
                guard let launches = launches else { return }
                self.launchDetails.append(contentsOf: launches.docs)

                if self.isFiltering == true {
                    self.filterLaunchDetails(by: filterType)
                } else {
                    self.updateCollectionViewData(with: self.launchDetails)
                }
            case .failure(let error):
                completed(error.rawValue)
            }
            self.isLoadingMoreLaunches = false
        }
    }

    func formatLaunchDate(date: String, completed: @escaping(String) -> Void) {
        let formattedDate = date.formatLaunchDateString()
        completed(formattedDate)
    }

    func determineTimeDistanceInLaunch(date: Double, completed: @escaping(String, String) -> Void) {
        var timeDistanceLabelText = String()

        let formattedTime = Date(timeIntervalSince1970: date)
        let timeDistance = Date().offsetFrom(date: formattedTime)

        if Date() > formattedTime {
            timeDistanceLabelText = Constants.daysSince
            completed(timeDistance, timeDistanceLabelText)
        } else {
            timeDistanceLabelText = Constants.daysFrom
            completed(timeDistance, timeDistanceLabelText)
        }
    }

    func setLaunchImage(imageUrlString: String, completed: @escaping(UIImage) -> Void) {
        networkManager.setAndCacheLaunchImage(urlString: imageUrlString) { image in
            completed(image)
        }
    }

    func filterLaunchDetails(by filterType: FilterType?) {

        guard let filterType = filterType else {
            return
        }

        isFiltering = true
        filteredLaunchDetails = launchDetails.filter { $0.success == true }

        switch filterType {
        case .asc:
            updateCollectionViewData(with: filteredLaunchDetails.sorted(by: {$0.dateUtc < $1.dateUtc}))
        case .desc:
            updateCollectionViewData(with: filteredLaunchDetails.sorted(by: {$0.dateUtc > $1.dateUtc}))
        }
    }
}
