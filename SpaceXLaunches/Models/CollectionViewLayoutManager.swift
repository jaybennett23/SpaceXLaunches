import UIKit

struct CollectionViewLayoutManager {
    static var sectionHeader: NSCollectionLayoutBoundarySupplementaryItem {
        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .absolute(CGFloat.headerViewHeight))

        return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize,
                                                           elementKind: UICollectionView.elementKindSectionHeader,
                                                           alignment: .top)
    }

    static var launchSection: NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(.estimatedHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(.estimatedHeight))

        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .none, top: .fixed(.padding), trailing: .none, bottom: .none)
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [CollectionViewLayoutManager.sectionHeader]
        section.interGroupSpacing = .paddingSmall

        return section
    }
}

private extension CGFloat {
    static let headerViewHeight: CGFloat = 90.0
    static let estimatedHeight: CGFloat = 200.0
    static let paddingSmall: CGFloat = 4.0
    static let padding: CGFloat = 10.0
}
