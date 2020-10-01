//
//  DetailedListingViewController.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-10-01.
//

import UIKit

class DetailedListingViewController: UIViewController {
    struct Item: Hashable {
        private let identifier = UUID()
    }
    
    enum Section: Int, Hashable, CaseIterable, CustomStringConvertible {
        case images = 0, overview, vehicleInfo, popularFeatures, ownerHistory, monthlyPaymentEstimate, dealer
        
        var description: String {
            switch self {
            case .overview:                 return "Overview"
            case .vehicleInfo:              return "Vehicle Info"
            case .popularFeatures:          return "Popular Features"
            case .ownerHistory:             return "Owner History"
            case .monthlyPaymentEstimate:   return "Monthly Payment Estimate"
            case .dealer:                   return "Dealer"
            case .images:                   return "Images"
            }
        }
        var numberOfRows: Int {
            switch self {
            case .overview:                 return 4
            case .vehicleInfo:              return 13
            case .popularFeatures:          return 0
            case .ownerHistory:             return 4
            case .monthlyPaymentEstimate:   return 7
            case .dealer:                   return 6
            case .images:                   return 0
            }
        }
    }
    
    // MARK: Main
    private var collectionView: CFCollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var snapshot: NSDiffableDataSourceSnapshot<Section, Item>!
    
    private var listing: Listing!
    private var numberOfPopularFeatures: Int {
        return listing.topOptions.count + listing.newTopOptions.count
    }
    
    init(listing: Listing) {
        super.init(nibName: nil, bundle: nil)
        self.listing = listing
    }
    required init?(coder: NSCoder) { fatalError("") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureNavigationBar()
        configureDataSource()
        print(numberOfPopularFeatures)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let sectionKind = Section(rawValue: sectionIndex) else { return nil }
            let section: NSCollectionLayoutSection
            
            switch sectionKind {
            case .images:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.85), heightDimension: .estimated(300))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                
            default:
                let layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                section = NSCollectionLayoutSection.list(using: layoutConfig, layoutEnvironment: layoutEnvironment)
                
            }
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    private func configureHierarchy() {
        collectionView = CFCollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    private func configureNavigationBar() {
        let year = String(listing.year)
        let title = "\(year) \(listing.make.rawValue) \(listing.model)"
        navigationItem.title = title
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
    private func setupSnapshot(animated: Bool = false) {
        snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)
        
        DispatchQueue.main.async {
            self.dataSource.apply(self.snapshot, animatingDifferences: animated)
        }
        
        for section in Section.allCases {
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
            let headerItem = Item()
            sectionSnapshot.append([headerItem])
            
            switch section {
            case .popularFeatures:
                let rows = Array(1..<self.numberOfPopularFeatures).map { _ in Item()}
                sectionSnapshot.append(rows, to: headerItem)
                sectionSnapshot.expand([headerItem])
            case .images:
                let rows = Array(1..<self.listing.imageCount).map { _ in Item()}
                sectionSnapshot.append(rows, to: headerItem)
                sectionSnapshot.expand([headerItem])
            default:
                let rows = Array(0..<section.numberOfRows).map { _ in Item()}
                sectionSnapshot.append(rows, to: headerItem)
                sectionSnapshot.expand([headerItem])
            }
            
            DispatchQueue.main.async {
                self.dataSource.apply(sectionSnapshot, to: section, animatingDifferences: animated)
            }
        }
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown section") }
            
            switch section {
            case .images:
                return collectionView.dequeueConfiguredReusableCell(using: self.configureImageCell(), for: indexPath, item: self.listing)
                
            case .overview:
                switch indexPath.item {
                case 0:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configureHeaderCell(), for: indexPath, item: "Overview")
                case 1:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Accident Summary": self.listing.accidentHistory.accidentSummary?.first?.rawValue ?? ""])
                case 2:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Owner Summary": self.listing.onePriceArrows[1].text.rawValue])
                case 3:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Type": self.listing.onePriceArrows[2].text.rawValue])
                case 4:
                    let summary = "\(self.listing.serviceHistory.history?.first?.historyDescription ?? "") on \(self.listing.serviceHistory.history?.first?.date ?? "")"
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Service History": summary])
                default: return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: [:])
                }
            case .vehicleInfo:
                switch indexPath.item {
                case 0:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configureHeaderCell(), for: indexPath, item: "Vehicle Info")
                case 1:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Price": self.listing.currentPrice.currency()])
                case 2:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Mileage": self.listing.mileage.withComma()])
                case 3:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Location": "\(self.listing.dealer.city), \(self.listing.dealer.state.rawValue)"])
                case 4:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Exterior Color": self.listing.exteriorColor])
                case 5:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Interior Color": self.listing.interiorColor])
                case 6:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Drive Type": self.listing.drivetype.rawValue])
                case 7:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Transmission": self.listing.transmission.rawValue])
                case 8:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Body Style": self.listing.bodytype.rawValue])
                case 9:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Engine": "\(self.listing.engine.rawValue) \(self.listing.displacement)"])
                case 10:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Fuel": self.listing.fuel.rawValue])
                case 11:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["MPG City/Hwy": "\(self.listing.mpgCity)/\(self.listing.mpgHighway)"])
                case 12:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["VIN": self.listing.vin])
                case 13:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Stock #": self.listing.stockNumber])
                default: return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: [:])
                }
                
            case .popularFeatures:
                switch indexPath.item {
                case 0: return collectionView.dequeueConfiguredReusableCell(using: self.configureHeaderCell(), for: indexPath, item: "Popular Features")
                default: return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: [:])
                }
                
            case .ownerHistory:
                guard let history = self.listing.ownerHistory.history?.first else { return nil }
                switch indexPath.item {
                case 0:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configureHeaderCell(), for: indexPath, item: "Owner History")
                case 1:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Location": "\(history.city ?? ""), \(history.state ?? "")"])
                case 2:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Number of Owners": String(history.ownerNumber)])
                case 3:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Ownership End Date": history.endOwnershipDate ?? ""])
                case 4:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Purchase Date": history.purchaseDate ?? ""])
                default: return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: [:])
                }
                
            case .monthlyPaymentEstimate:
                let monthlyPaymentEstimate = self.listing.monthlyPaymentEstimate
                switch indexPath.item {
                case 0:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configureHeaderCell(), for: indexPath, item: "Monthly Payment Estimate")
                case 1:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Downpayment Amount": monthlyPaymentEstimate.downPaymentAmount.currency()])
                case 2:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Downpayment %": String(monthlyPaymentEstimate.downPaymentPercent)])
                case 3:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Interest Rate": String(monthlyPaymentEstimate.interestRate)])
                case 4:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Loan Amount": monthlyPaymentEstimate.loanAmount.currency()])
                case 5:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Monthly Payment": monthlyPaymentEstimate.monthlyPayment.currency()])
                case 6:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Price": monthlyPaymentEstimate.price.currency()])
                case 7:
                    return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Term (in months)": String(monthlyPaymentEstimate.termInMonths)])
                default: return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: [:])
                }
                
            case .dealer:
                let dealer = self.listing.dealer
                switch indexPath.item {
                case 0: return collectionView.dequeueConfiguredReusableCell(using: self.configureHeaderCell(), for: indexPath, item: "Dealer Info")
                case 1: return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Name": dealer.name])
                case 2: return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["CARFAX ID": dealer.carfaxID])
                case 3: return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["CARFAX URL": dealer.cfxMicrositeURL])
                case 4: return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Dealer Website": dealer.dealerInventoryURL])
                case 5: return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Dealer Average Rating": String(dealer.dealerAverageRating)])
                case 6: return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: ["Dealer Review Count": String(dealer.dealerReviewCount)])
                default: return collectionView.dequeueConfiguredReusableCell(using: self.configuredListCell(), for: indexPath, item: [:])
                }
            }
        }
        self.setupSnapshot()
    }
}


extension DetailedListingViewController {
    // MARK: Cell Configurations
    private func configureImageCell() -> UICollectionView.CellRegistration<DetailedListingImageViewCell, Listing> {
        return UICollectionView.CellRegistration<DetailedListingImageViewCell, Listing> { cell, indexPath, listing in
            cell.setImage(for: self.listing, indexPath)
        }
    }
    
    private func configureHeaderCell() -> UICollectionView.CellRegistration<UICollectionViewListCell, String> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, title in
            var content = cell.defaultContentConfiguration()
            content.text = title
            cell.contentConfiguration = content
            cell.accessories = [.outlineDisclosure(options: UICellAccessory.OutlineDisclosureOptions(style: .header))]
        }
    }
    
    private func configuredListCell() -> UICollectionView.CellRegistration<UICollectionViewListCell, [String: String]> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, [String: String]> { cell, indexPath, item in
            guard let section = Section(rawValue: indexPath.section) else { return }
            
            var content = UIListContentConfiguration.valueCell()
            
            if section == .popularFeatures {
                var features: [String] = []
                features.append(contentsOf: self.listing.topOptions)
                features.append(contentsOf: self.listing.newTopOptions)
                content.text = features[indexPath.item]
            } else {
                content.text = item.keys.first
            }
            content.secondaryText = item.values.first
            
            cell.contentConfiguration = content
        }
    }
}

extension DetailedListingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sections = Section(rawValue: indexPath.section) else { return }
        switch sections {
        case .dealer: break
        default: break
        }
    }
}
