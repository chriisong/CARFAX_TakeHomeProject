//
//  HomeViewController.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-09-30.
//

import UIKit

class HomeViewController: UIViewController {
    enum Section {
        case main
    }
    
    enum SortOptions {
        case priceHigh, priceLow
        var title: String {
            switch self {
            case .priceHigh: return "Price High to Low"
            case .priceLow: return "Price Low to High"
            }
        }
    }
    
    private var collectionView: CFCollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Listing>!
    private var snapshot: NSDiffableDataSourceSnapshot<Section, Listing>!
    
    private var listings: [Listing] = []
    
    // MARK: Search
    private var isSearching: Bool = false
    private var filteredListings: [Listing] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchListings()
        configureHierarchy()
        configureDataSource()
        configureNavigationBar()
        configureSearchController()

    }
    
}

extension HomeViewController {
    private func fetchListings() {
        NetworkManager.shared.getListing { result in
            switch result {
            case .failure(let error): print(error.rawValue)
            case .success(let data):
                self.listings = data.listings
                self.setupSnapshot(filter: data.listings)
            }
        }
    }
    private func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let section: NSCollectionLayoutSection
            
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300))
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
        let sortByPriceHighAction = UIAction(title: SortOptions.priceHigh.title, image: Image.arrowUpArrowDownSquareFill, handler: sortAction)
        let sortByPriceLowAction = UIAction(title: SortOptions.priceLow.title, image: Image.arrowUpArrowDownSquareFill, handler: sortAction)
        let moreButton = UIBarButtonItem(title: "", image: Image.ellipsisCircleFill, menu: UIMenu(title: "Sort Options", children: [sortByPriceHighAction, sortByPriceLowAction]))
        navigationItem.rightBarButtonItem = moreButton
    }
    
    private func sortAction(action: UIAction) {
        switch action.title {
        case SortOptions.priceHigh.title:
            self.listings.sort {$0.listPrice > $1.listPrice}
            
        default: break
        }
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

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
extension HomeViewController: UISearchResultsUpdating {
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
