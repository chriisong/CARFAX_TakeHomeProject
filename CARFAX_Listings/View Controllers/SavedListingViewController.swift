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
    
    private var collectionView: CFCollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Listing>!
    private var snapshot: NSDiffableDataSourceSnapshot<Section, Listing>!
    
    private var listings: [Listing] = []
    
    private lazy var savedListingDataProvider: SavedListingDataProvider = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let provider = SavedListingDataProvider(
            with: appDelegate.coreDataStack.persistentContainer,
            fetchedResultsControllerDelegate: self)
        return provider
    }()
    
    // MARK: Search
    private var isSearching: Bool = false
    private var filteredListings: [Listing] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchListings(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureDataSource()
        configureNavigationBar()
        configureSearchController()
    }
    
}

extension SavedListingViewController {
    private func fetchListings(animated: Bool = false) {
        NetworkManager.shared.getListing { result in
            switch result {
            case .failure(let error): print(error.rawValue)
            case .success(let data):
                DispatchQueue.main.async {
                    self.listings.removeAll()
                    guard let savedListings = self.savedListingDataProvider.fetchedResultsController.fetchedObjects else { return }
                    for listing in savedListings {
                        if let fetchedListing = data.listings.first(where: { $0.id == listing.id }) {
                            self.listings.append(fetchedListing)
                        }
                    }
                    self.setupSnapshot(filter: self.listings, animated: animated)
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
        collectionView = CFCollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Saved Listings"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        let sortByPriceHighAction = UIAction(title: SortOptions.priceHigh.title, image: Image.dollarSignSquareFill, handler: sortAction)
        let sortByPriceLowAction = UIAction(title: SortOptions.priceLow.title, image: Image.dollarSignSquareFill, handler: sortAction)
        let sortByMileHighAction = UIAction(title: SortOptions.mileHigh.title, image: Image.arrowUpArrowDownSquareFill, handler: sortAction)
        let sortByMileLowAction = UIAction(title: SortOptions.mileLow.title, image: Image.arrowUpArrowDownSquareFill, handler: sortAction)
        let moreButton = UIBarButtonItem(image: Image.ellipsisCircleFill,
                                         menu: UIMenu(title: "Sort Options",
                                                      children: [
                                                        sortByPriceHighAction,
                                                        sortByPriceLowAction,
                                                        sortByMileHighAction,
                                                        sortByMileLowAction]))
        navigationItem.rightBarButtonItem = moreButton
    }
    
    private func sortAction(action: UIAction) {
        switch action.title {
        case SortOptions.priceHigh.title:
            self.listings.sort {$0.listPrice > $1.listPrice}
        case SortOptions.priceLow.title:
            self.listings.sort {$0.listPrice < $1.listPrice}
        case SortOptions.mileHigh.title:
            self.listings.sort {$0.mileage > $1.mileage}
        case SortOptions.mileLow.title:
            self.listings.sort {$0.mileage < $1.mileage}
        default: break
        }
        self.setupSnapshot(filter: self.listings, animated: true)
    }
    
    private func configureCell() -> UICollectionView.CellRegistration<ListingCollectionViewCell, Listing> {
        return UICollectionView.CellRegistration<ListingCollectionViewCell, Listing> { cell, indexPath, listing in
            cell.set(with: listing)
        }
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Listing>(collectionView: collectionView) { collectionView, indexPath, listing -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: self.configureCell(), for: indexPath, item: listing)
        }
        setupSnapshot(filter: self.listings)
    }
    
    private func setupSnapshot(filter: [Listing], animated: Bool = false) {
        snapshot = NSDiffableDataSourceSnapshot<Section, Listing>()
        snapshot.appendSections([.main])
        snapshot.appendItems(filter)
        DispatchQueue.main.async {
            self.dataSource.apply(self.snapshot, animatingDifferences: animated)
        }
    }
    
    private func configureSearchController() {
        let searchController = CFSearchController(placeHolder: "Year, model, location or dealer name", textFieldBackgroundColor: UIColor.white.withAlphaComponent(0.1))
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
    }
}

extension SavedListingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions -> UIMenu? in
            let removeAction = UIAction(title: "Remove", image: Image.trashCircleFill) { (action) in
                guard let selectedListing = self.dataSource.itemIdentifier(for: indexPath) else { return }
                if let savedListing = self.savedListingDataProvider.fetchedResultsController.fetchedObjects?.first(where: { $0.id == selectedListing.id }) {
                    self.savedListingDataProvider.removeListing(listingToRemove: savedListing) {
                        self.fetchListings(animated: true)
                        print("removed!")
                    }
                }
            }
            let children: [UIMenuElement] = [removeAction]
            let menu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: children)
            return menu
        }
    }
}
extension SavedListingViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            filteredListings.removeAll()
            setupSnapshot(filter: self.listings)
            isSearching = false
            
            return }
        isSearching = true
        
        filteredListings = listings.filter {
                String($0.year).lowercased().contains(filter.lowercased())
                || $0.model.lowercased().contains(filter.lowercased())
                || $0.dealer.state.rawValue.lowercased().contains(filter.lowercased())
                || $0.dealer.city.lowercased().contains(filter.lowercased())
                || $0.dealer.name.lowercased().contains(filter.lowercased())
        }
        setupSnapshot(filter: filteredListings, animated: true)
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
