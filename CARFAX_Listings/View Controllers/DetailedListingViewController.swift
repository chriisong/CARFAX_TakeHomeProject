//
//  DetailedListingViewController.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-10-01.
//

import CoreData
import UIKit
import SafariServices

class DetailedListingViewController: UIViewController {
    struct Item: Hashable {
        private let identifier = UUID()
    }
    
    enum ListingSavedState {
        case saved, unsaved
        
        var buttonTitle: String {
            switch self {
            case .saved: return "Remove Listing"
            case .unsaved: return "Save Listing"
            }
        }
        
        var buttonImage: UIImage {
            switch self {
            case .saved: return Image.trashCircleFill
            case .unsaved: return Image.arrowDownHeartFill
            }
        }
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
    
    // MARK: Saved Listing Core Data Provider
    private lazy var savedListingDataProvider: SavedListingDataProvider = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let provider = SavedListingDataProvider(
            with: appDelegate.coreDataStack.persistentContainer,
            fetchedResultsControllerDelegate: self)
        return provider
    }()
    
    private var listingSavedState: ListingSavedState!
    
    init(listing: Listing) {
        super.init(nibName: nil, bundle: nil)
        self.listing = listing
    }
    required init?(coder: NSCoder) { fatalError("") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSavedState()
        configureHierarchy()
        configureNavigationBar()
        configureDataSource()
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
    
    private func configureSavedState() {
        guard let contains = self.savedListingDataProvider.fetchedResultsController.fetchedObjects?.contains(where: { $0.id == self.listing.id }) else {
            return
        }
        listingSavedState = contains ? .saved : .unsaved
    }
    
    private func configureNavigationBar() {
        let year = String(listing.year)
        let title = "\(year) \(listing.make.rawValue) \(listing.model)"
        navigationItem.title = title
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        let saveAction = UIAction(title: listingSavedState.buttonTitle, image: listingSavedState.buttonImage, handler: saveButtonHandler)
        let websiteAction = UIAction(title: "Visit Listing Website", image: Image.network, handler: websiteButtonHandler)
        let moreButton = UIBarButtonItem(image: Image.ellipsisCircleFill, menu: UIMenu(title: "", children: [saveAction, websiteAction]))
        navigationItem.rightBarButtonItem = moreButton
    }
    
    private func websiteButtonHandler(action: UIAction) {
        guard let url = URL(string: self.listing.vdpURL) else {
            presentCFAlert(title: "Invalid URL", message: CFError.invalidURL.rawValue, buttonTitle: "OK")
            return
        }
        presentSafariVC(with: url)
    }
    
    private func saveButtonHandler(action: UIAction) {
        switch listingSavedState {
        case .saved:
            guard let listing = self.savedListingDataProvider.fetchedResultsController.fetchedObjects?.first(where: { $0.id == self.listing.id }) else { return }
            self.savedListingDataProvider.removeListing(listingToRemove: listing) {
                self.presentCFAlert(title: "Removed!", message: "Successfully removed this listing 🎉", buttonTitle: "OK")
            }
        case .unsaved:
            self.savedListingDataProvider.saveListing(listing: self.listing) {
                self.presentCFAlert(title: "Saved!", message: "Successfully saved this listing 🎉", buttonTitle: "OK")
            }
        default: break
        }
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
                sectionSnapshot.collapse([headerItem])
            case .images:
                let rows = Array(1..<self.listing.imageCount).map { _ in Item()}
                sectionSnapshot.append(rows, to: headerItem)
                sectionSnapshot.expand([headerItem])
            default:
                let rows = Array(0..<section.numberOfRows).map { _ in Item()}
                sectionSnapshot.append(rows, to: headerItem)
                sectionSnapshot.collapse([headerItem])
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
                    let history = self.listing.serviceHistory.history?.first?.historyDescription ?? "No information"
                    let wordsToRemove = "<span class='bullet' style='font-weight: bold;'>&#8226;</span>"
                    let cleanedString = history.replacingOccurrences(of: wordsToRemove, with: "\n", options: .regularExpression, range: nil)
                    let summary = "\(cleanedString) on \(self.listing.serviceHistory.history?.first?.date ?? "")"
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
            content.textProperties.font = UIFont.preferredFont(forTextStyle: .title3).bold()
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
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let sections = Section(rawValue: indexPath.section) else { return }
        switch sections {
        case .dealer:
            switch indexPath.item {
            case 3:
                guard let url = URL(string: self.listing.dealer.cfxMicrositeURL) else {
                    presentCFAlert(title: "Invalid URL", message: CFError.invalidURL.rawValue, buttonTitle: "OK")
                    return
                }
                presentSafariVC(with: url)
            case 4:
                guard let url = URL(string: self.listing.dealer.dealerInventoryURL) else {
                    presentCFAlert(title: "Invalid URL", message: CFError.invalidURL.rawValue, buttonTitle: "OK")
                    return
                }
                presentSafariVC(with: url)
            default: break
            }
        default: break
        }
    }
}

extension DetailedListingViewController {
    func presentSafariVC(with url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = DeviceTypes.isiPad ? .overFullScreen : .formSheet
        safariVC.preferredControlTintColor = .systemPink
        present(safariVC, animated: true)
    }
}


extension DetailedListingViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        savedListingDataProvider.configureFetchedResultsController()
        configureSavedState()
        configureNavigationBar()
    }
}
