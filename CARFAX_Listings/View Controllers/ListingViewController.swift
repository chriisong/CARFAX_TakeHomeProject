//
//  ListingViewController.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-09-30.
//

import Contacts
import CoreData
import MapKit
import UIKit

class ListingViewController: CFDataLoadingViewController {
    enum Section {
        case main
    }
    
    // MARK: Collection View Related
    private var collectionView: CFCollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Listing>!
    private var snapshot: NSDiffableDataSourceSnapshot<Section, Listing>!
    private var listings: [Listing] = []
    
    // MARK: Saved List Core Data Provider
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
    
    // MARK: Loading View
    var loadingContainerView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchListings()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureDataSource()
        configureNavigationBar()
        configureSearchController()
    }
}

extension ListingViewController {
    private func fetchListings(animated: Bool = false) {
        showLoadingView()
        NetworkManager.shared.getListing { result in
            self.dismissLoadingView()
            switch result {
            case .failure(let error): print(error.rawValue)
            case .success(let data):
                self.listings = data.listings
                self.setupSnapshot(filter: data.listings, animated: animated)
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
        navigationItem.title = "Listings"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        let sortByPriceHighAction = UIAction(title: SortOptions.priceHigh.title, image: Image.dollarSignSquareFill, handler: sortAction)
        let sortByPriceLowAction = UIAction(title: SortOptions.priceLow.title, image: Image.dollarSignSquareFill, handler: sortAction)
        
        let sortByMileageHighAction = UIAction(title: SortOptions.mileHigh.title, image: Image.arrowUpArrowDownSquareFill, handler: sortAction)
        let sortByMileageLowAction = UIAction(title: SortOptions.mileLow.title, image: Image.arrowUpArrowDownSquareFill, handler: sortAction)
        let sortByMileageDeferredMenu = UIDeferredMenuElement({ completion in
            completion([UIMenu(title: "", options: .displayInline, children: [sortByMileageHighAction, sortByMileageLowAction])])
        })
        
        let sortByBaseAction = UIAction(title: SortOptions.baseTrim.title, image: Image.baseTrimIcon, handler: sortAction)
        let sortByAdvAction = UIAction(title: SortOptions.advTrim.title, image: Image.advTrimIcon, handler: sortAction)
        let sortByTechAction = UIAction(title: SortOptions.techTrim.title, image: Image.techTrimIcon, handler: sortAction)
        let sortByUnspecAction = UIAction(title: SortOptions.unspecTrim.title, image: Image.unspecTrimIcon, handler: sortAction)
        let sortByTrimDeferredMenu = UIDeferredMenuElement({ completion in
            completion([UIMenu(title: "", options: .displayInline, children: [sortByBaseAction, sortByAdvAction, sortByTechAction, sortByUnspecAction])])
        })
        
        let resetAction = UIAction(title: SortOptions.reset.title, attributes: .destructive, handler: sortAction)
        let resetDeferredMenu = UIDeferredMenuElement({ completion in
            completion([UIMenu(title: "", options: .displayInline, children: [resetAction])])
        })
        
        let moreButton = UIBarButtonItem(image: Image.ellipsisCircleFill,
                                         menu: UIMenu(title: "Sort Options",
                                                      children: [
                                                        sortByPriceHighAction,
                                                        sortByPriceLowAction,
                                                        sortByMileageDeferredMenu,
                                                        sortByTrimDeferredMenu,
                                                        resetDeferredMenu]))
        navigationItem.rightBarButtonItem = moreButton
    }
    
    private func sortAction(action: UIAction) {
        switch action.title {
        case SortOptions.priceHigh.title:
            self.listings.sort {$0.currentPrice > $1.currentPrice}
            
        case SortOptions.priceLow.title:
            self.listings.sort {$0.currentPrice < $1.currentPrice}
            
        case SortOptions.mileHigh.title:
            self.listings.sort {$0.mileage > $1.mileage}
            
        case SortOptions.mileLow.title:
            self.listings.sort {$0.mileage < $1.mileage}
            
        case SortOptions.baseTrim.title:
            let filtered = self.listings.filter { $0.trim == .base }
            self.setupSnapshot(filter: filtered, animated: true)
            return
            
        case SortOptions.advTrim.title:
            let filtered = self.listings.filter { $0.trim == .advance }
            self.setupSnapshot(filter: filtered, animated: true)
            return
            
        case SortOptions.techTrim.title:
            let filtered = self.listings.filter { $0.trim == .technology }
            self.setupSnapshot(filter: filtered, animated: true)
            return
            
        case SortOptions.unspecTrim.title:
            let filtered = self.listings.filter { $0.trim == .unspecified }
            self.setupSnapshot(filter: filtered, animated: true)
            return
            
        case SortOptions.reset.title:
            self.fetchListings(animated: true)
            return
            
        default: break
        }
        
        self.setupSnapshot(filter: self.listings, animated: true)
    }
    
    private func configureCell() -> UICollectionView.CellRegistration<ListingCollectionViewCell, Listing> {
        return UICollectionView.CellRegistration<ListingCollectionViewCell, Listing> { cell, indexPath, listing in
            cell.set(with: listing)
            cell.phoneButton.buttonAction {
                self.phoneButtonPressed(for: listing, at: indexPath)
            }
            cell.mapButton.buttonAction {
                self.mapButtonPressed(for: listing, at: indexPath)
            }
        }
    }
    
    private func phoneButtonPressed(for listing: Listing, at indexPath: IndexPath) {
        let phoneNumber = listing.dealer.phone
        guard let url = URL(string: "tel://\(phoneNumber)") else {
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    private func mapButtonPressed(for listing: Listing, at indexPath: IndexPath) {
        let address = CNMutablePostalAddress()
        address.street = listing.dealer.address
        address.city = listing.dealer.city
        address.state = listing.dealer.state.rawValue
        address.postalCode = listing.dealer.zip
        address.country = "USA"
        
        let geoloc = CLGeocoder()
        
        geoloc.geocodePostalAddress(address) { placemarks, _ in
            guard let placemark = placemarks?.first else {
                return
            }
            let mkPlacemark = MKPlacemark(placemark: placemark)
            let mapItem = MKMapItem(placemark: mkPlacemark)
            mapItem.openInMaps(launchOptions: nil)
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

extension ListingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let selectedListing = dataSource.itemIdentifier(for: indexPath) else { return }
        let vc = DetailedListingViewController(listing: selectedListing)
        let navigationController = UINavigationController(rootViewController: vc)
        present(navigationController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions -> UIMenu? in
            let saveAction = UIAction(title: "Save", image: Image.arrowDownHeartFill) { (action) in
                guard let selectedListing = self.dataSource.itemIdentifier(for: indexPath) else { return }
                guard let contains = self.savedListingDataProvider.fetchedResultsController.fetchedObjects?.contains(where: { $0.id == selectedListing.id }),
                      contains == false else {
                    self.presentCFAlert(title: "Save Error", message: "You have already saved this listing.", buttonTitle: "OK")
                    return
                }
                self.savedListingDataProvider.saveListing(listing: selectedListing) {
                    self.presentCFAlert(title: "Saved!", message: "Successfully saved this listing 🎉", buttonTitle: "OK")
                }
            }
            let children: [UIMenuElement] = [saveAction]
            let menu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: children)
            return menu
        }
    }
}
extension ListingViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            filteredListings.removeAll()
            setupSnapshot(filter: self.listings)
            isSearching = false
            return
        }
        
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

extension ListingViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        savedListingDataProvider.configureFetchedResultsController()
    }
}


