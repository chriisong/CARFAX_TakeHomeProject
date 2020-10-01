//
//  SavedListingViewController.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-09-30.
//

import CoreData
import UIKit

class SavedListingViewController: UIViewController {
    enum Section {
        case main
    }
    
    // MARK: Header cell data type
    struct HeaderItem: Hashable {
        let title: String
        let listing: [ListingItem]
    }
    
    // MARK: Listing cell data type
    struct ListingItem: Hashable {
        let name: String
        let price: Int
        let mileage: Int
        let location: String
        let year: Int
        let id: String
        
        init(name: String, price: Int, mileage: Int, location: String, year: Int, id: String) {
            self.name = name
            self.price = price
            self.mileage = mileage
            self.location = location
            self.year = year
            self.id = id
        }
    }
    
    // MARK: Saved Listing View Controller's Diffable Data Source Item Types
    enum SavedListItem: Hashable {
        case header(HeaderItem)
        case listing(ListingItem)
    }
    
    // MARK: Main
    private var collectionView: CFCollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<HeaderItem, SavedListItem>!
    private var snapshot: NSDiffableDataSourceSnapshot<HeaderItem, SavedListItem>!
    
    private var listings: [Listing] = []
    private var headerData: [HeaderItem] = []
    
    // MARK: Saved Listing Core Data Provider
    private lazy var savedListingDataProvider: SavedListingDataProvider = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let provider = SavedListingDataProvider(
            with: appDelegate.coreDataStack.persistentContainer,
            fetchedResultsControllerDelegate: self)
        return provider
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchListings(animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureDataSource()
        configureNavigationBar()
    }
}

extension SavedListingViewController {
    private func fetchListings(animated: Bool = false) {
        NetworkManager.shared.getListing { result in
            switch result {
            case .failure(let error): print(error.rawValue)
            case .success(let data):
                DispatchQueue.main.async {
                    // Remove all listings before each fetch to prevent duplicate data
                    self.listings.removeAll()
                    guard let savedListings = self.savedListingDataProvider.fetchedResultsController.fetchedObjects else { return }
                    for listing in savedListings {
                        if let fetchedListing = data.listings.first(where: { $0.id == listing.id }) {
                            self.listings.append(fetchedListing)
                        }
                    }
                    self.configureHeaderData(with: self.listings)
                }
            }
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let section: NSCollectionLayoutSection

            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(400))
            let item = NSCollectionLayoutItem(layoutSize: size)

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)
            section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 15
            section.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 10, trailing: 20)

            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    private func configureHierarchy() {
        let layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)

        collectionView = CFCollectionView(frame: view.bounds, collectionViewLayout: listLayout)
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Saved Listings"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureHeaderCell() -> UICollectionView.CellRegistration<UICollectionViewListCell, HeaderItem> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, HeaderItem> { cell, indexPath, headerItem in
            var content = cell.defaultContentConfiguration()
            content.text = headerItem.title
            cell.contentConfiguration = content
            let headerDisclosureOption = UICellAccessory.OutlineDisclosureOptions(style: .header)
            cell.accessories = [.outlineDisclosure(options: headerDisclosureOption)]
        }
    }
    
    private func configureSavedListingCell() -> UICollectionView.CellRegistration<UICollectionViewListCell, ListingItem> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, ListingItem> { cell, indexPath, savedListing in
            var content = cell.defaultContentConfiguration()
            content.text = savedListing.name
            content.secondaryText = savedListing.price.currency()
            cell.contentConfiguration = content
        }
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<HeaderItem, SavedListItem>(collectionView: collectionView) { collectionView, indexPath, listing -> UICollectionViewCell? in
            switch listing {
            case .header(let headerItem):
                let cell = collectionView.dequeueConfiguredReusableCell(using: self.configureHeaderCell(), for: indexPath, item: headerItem)
                return cell
                
            case .listing(let listing):
                let cell = collectionView.dequeueConfiguredReusableCell(using: self.configureSavedListingCell(), for: indexPath, item: listing)
                return cell
            }
        }
        
    }
    
    private func setupSnapshot(headerItems: [HeaderItem], animated: Bool = false) {
        snapshot = NSDiffableDataSourceSnapshot<HeaderItem, SavedListItem>()
        // Append main sections
        snapshot.appendSections(headerItems)
        DispatchQueue.main.async {
            self.dataSource.apply(self.snapshot, animatingDifferences: animated)
        }
        
        for headerItem in headerItems {
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<SavedListItem>()
            let headerListItem = SavedListItem.header(headerItem)
            sectionSnapshot.append([headerListItem])
            
            let savedListItemArray = headerItem.listing.map { SavedListItem.listing($0) }
            
            if savedListItemArray.isEmpty {
                continue
            } else {
                sectionSnapshot.append(savedListItemArray, to: headerListItem)
                sectionSnapshot.expand([headerListItem])
            }
            DispatchQueue.main.async {
                self.dataSource.apply(sectionSnapshot, to: headerItem, animatingDifferences: animated)
            }
        }
    }
    
    private func configureHeaderData(with listings: [Listing]) {
        self.headerData.removeAll()
        var listingItems: [ListingItem] = []
        for listing in listings {
            let name = "\(listing.make.rawValue) \(listing.model)"
            let location = "\(listing.dealer.city), \(listing.dealer.state.rawValue)"
            let listingItem = ListingItem(
                name: name,
                price: listing.listPrice,
                mileage: listing.mileage,
                location: location,
                year: listing.year,
                id: listing.id)
            
            listingItems.append(listingItem)
        }
        
        // group the listings by year
        let groupedListingItems = Dictionary(grouping: listingItems, by: { $0.year })

        
        for (_, filteredListingItems) in groupedListingItems.enumerated() {
            // exit out of the for loop if the grouped listing is empty so that the `headerData` section is not appended
            if filteredListingItems.value.isEmpty { continue }
            let year = filteredListingItems.key
            let headerItem = HeaderItem(title: String(year), listing: filteredListingItems.value)
            headerData.append(headerItem)
        }
        
        headerData.sort(by: { $0.title > $1.title })
  
        self.setupSnapshot(headerItems: headerData, animated: true)
    }
}

extension SavedListingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions -> UIMenu? in
            guard let selectedListing = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
            switch selectedListing {
            case .header(_): return nil
            case .listing(let listing):
                let removeAction = UIAction(title: "Remove", image: Image.trashCircleFill) { (action) in
                    if let savedListing = self.savedListingDataProvider.fetchedResultsController.fetchedObjects?.first(where: { $0.id == listing.id }) {
                        self.savedListingDataProvider.removeListing(listingToRemove: savedListing) {
                            self.fetchListings(animated: true)
                            self.presentCFAlert(title: "Removed!", message: "Successfully removed this listing 🎉", buttonTitle: "OK")
                        }
                    }
                }
                let children: [UIMenuElement] = [removeAction]
                let menu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: children)
                return menu
            }
        }
    }
}

extension SavedListingViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete, .insert, .move:
            fetchListings(animated: true)
        case .update:
            fetchListings()
        default: break
        }
    }
}
