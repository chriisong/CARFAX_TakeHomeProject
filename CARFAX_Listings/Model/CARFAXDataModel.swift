//
//  CARFAXDataModel.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-09-30.
//


import Foundation

// MARK: - CARFAXData
struct CARFAXData: Codable {
    let backfillCount: Int
    let breadCrumbs: [BreadCrumb]
    let dealerNewCount, dealerUsedCount, enhancedCount: Int
    let facetCountMap: [String: FacetCountMap]
    let listings: [Listing]
    let page, pageSize: Int
    let relatedLinks: RelatedLinks
    let searchArea: SearchArea
    let searchRequest: SearchRequest
    let seoURL: String
    let totalListingCount, totalPageCount: Int

    enum CodingKeys: String, CodingKey {
        case backfillCount, breadCrumbs, dealerNewCount, dealerUsedCount, enhancedCount, facetCountMap, listings, page, pageSize, relatedLinks, searchArea, searchRequest
        case seoURL = "seoUrl"
        case totalListingCount, totalPageCount
    }
}

// MARK: - BreadCrumb
struct BreadCrumb: Codable {
    let label: String
    let link: String
    let position: Int
}

// MARK: - FacetCountMap
struct FacetCountMap: Codable {
    let facets: [Facet]
}

// MARK: - Facet
struct Facet: Codable {
    let encodedName, name: String
    let value: Int
    let facetDescription: String?

    enum CodingKeys: String, CodingKey {
        case encodedName, name, value
        case facetDescription = "description"
    }
}

// MARK: - Listing
struct Listing: Codable, Hashable {
    let accidentHistory: History
    let advantage, backfill: Bool
    let badge: Badge
    let bedLength: BedLength
    let bodytype: Bodytype
    let cabType: BedLength
    let certified: Bool
    let currentPrice: Int
    let dealer: Dealer
    let dealerType: DealerType
    let displacement: String
    let distanceToDealer: Double
    let drivetype: Drivetype
    let engine: Engine
    let exteriorColor, firstSeen: String
    let followCount: Int
    let following: Bool
    let fuel: Fuel
    let hasViewed: Bool
    let id: String
    let imageCount: Int
    let images: Images
    let interiorColor: String
    let isEnriched: Bool
    let listPrice: Int
    let make: Make
    let mileage: Int
    let model: String
    let monthlyPaymentEstimate: MonthlyPaymentEstimate
    let mpgCity, mpgHighway: Int
    let newTopOptions: [String]
    let noAccidents, oneOwner: Bool
    let onePrice: Int
    let onePriceArrows: [OnePriceArrow]
    let onlineOnly: Bool
    let ownerHistory: History
    let personalUse: Bool
    let recordType: RecordType
    let sentLead: Bool
    let serviceHistory: ServiceHistory
    let serviceRecords: Bool
    let sortScore: Double
    let stockNumber: String
    let subTrim: BedLength
    let topOptions: [String]
    let transmission: Transmission
    let trim: Trim
    let vdpURL: String
    let vehicleCondition: VehicleCondition
    let vehicleUseHistory: History
    let vin: String
    let year: Int
    let listingStatus: String?

    enum CodingKeys: String, CodingKey {
        case accidentHistory, advantage, backfill, badge, bedLength, bodytype, cabType, certified, currentPrice, dealer, dealerType, displacement, distanceToDealer, drivetype, engine, exteriorColor, firstSeen, followCount, following, fuel, hasViewed, id, imageCount, images, interiorColor, isEnriched, listPrice, make, mileage, model, monthlyPaymentEstimate, mpgCity, mpgHighway, newTopOptions, noAccidents, oneOwner, onePrice, onePriceArrows, onlineOnly, ownerHistory, personalUse, recordType, sentLead, serviceHistory, serviceRecords, sortScore, stockNumber, subTrim, topOptions, transmission, trim
        case vdpURL = "vdpUrl"
        case vehicleCondition, vehicleUseHistory, vin, year, listingStatus
    }
    
    private let identifier = UUID()
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

// MARK: - History
struct History: Codable, Hashable {
    let accidentSummary: [AccidentSummary]?
    let icon: AccidentHistoryIcon
    let iconURL: String
    let text: AccidentHistoryText
    let history: [AccidentHistoryHistory]?

    enum CodingKeys: String, CodingKey {
        case accidentSummary, icon
        case iconURL = "iconUrl"
        case text, history
    }
    
    private let identifier = UUID()
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

enum AccidentSummary: String, Codable, Hashable {
    case noAccidentDamageReportedToCARFAX = "No accident/damage reported to CARFAX"
}

// MARK: - AccidentHistoryHistory
struct AccidentHistoryHistory: Codable, Hashable {
    let city, endOwnershipDate: String?
    let ownerNumber: Int
    let purchaseDate, state: String?
    let averageMilesPerYear: Int?
    let useType: UseType?
    
    private let identifier = UUID()
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

enum UseType: String, Codable, Hashable {
    case commercialUse = "Commercial Use"
    case personalLease = "Personal Lease"
    case personalUse = "Personal Use"
}

enum AccidentHistoryIcon: String, Codable, Hashable {
    case commercial = "commercial"
    case noAccident = "noAccident"
    case owner1 = "owner1"
    case owner3 = "owner3"
    case personal = "personal"
}

enum AccidentHistoryText: String, Codable, Hashable {
    case carfax1Owner = "CARFAX 1-Owner"
    case commercialUse = "Commercial Use"
    case noAccidentOrDamageReported = "No Accident or Damage Reported"
    case personalUse = "Personal Use"
    case the3Owners = "3+ Owners"
}

enum Badge: String, Codable {
    case good = "GOOD"
    case great = "GREAT"
}

enum BedLength: String, Codable {
    case entertainment = "Entertainment"
    case unspecified = "Unspecified"
}

enum Bodytype: String, Codable, Hashable {
    case sedan = "Sedan"
    case suv = "SUV"
}

// MARK: - Dealer
struct Dealer: Codable, Hashable {
    let address: String
    let backfill: Bool
    let carfaxID: String
    let cfxMicrositeURL: String
    let city: String
    let dealerAverageRating: Double
    let dealerInventoryURL: String
    let dealerLeadType, dealerReviewComments: String
    let dealerReviewCount: Int
    let dealerReviewDate: String
    let dealerReviewRating: Int
    let dealerReviewReviewer, dealerReviewTitle, latitude, longitude: String
    let name: String
    let onlineOnly: Bool
    let phone: String
    let state: State
    let zip: String

    enum CodingKeys: String, CodingKey {
        case address, backfill
        case carfaxID = "carfaxId"
        case cfxMicrositeURL = "cfxMicrositeUrl"
        case city, dealerAverageRating
        case dealerInventoryURL = "dealerInventoryUrl"
        case dealerLeadType, dealerReviewComments, dealerReviewCount, dealerReviewDate, dealerReviewRating, dealerReviewReviewer, dealerReviewTitle, latitude, longitude, name, onlineOnly, phone, state, zip
    }
    
    private let identifier = UUID()
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

enum State: String, Codable, Hashable {
    case ct = "CT"
    case md = "MD"
    case ny = "NY"
    case va = "VA"
}

enum DealerType: String, Codable, Hashable {
    case new = "NEW"
    case used = "USED"
}

enum Drivetype: String, Codable, Hashable {
    case awd = "AWD"
    case fwd = "FWD"
}

enum Engine: String, Codable, Hashable {
    case the4Cyl = "4 Cyl"
    case the6Cyl = "6 Cyl"
}

enum Fuel: String, Codable, Hashable {
    case gasoline = "Gasoline"
}

// MARK: - Images
struct Images: Codable, Hashable {
    let baseURL: String
    let firstPhoto: FirstPhoto?
    let large, medium, small: [String]

    enum CodingKeys: String, CodingKey {
        case baseURL = "baseUrl"
        case firstPhoto, large, medium, small
    }
}

// MARK: - FirstPhoto
struct FirstPhoto: Codable, Hashable {
    let large, medium, small: String
    
    private let identifier = UUID()
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

enum Make: String, Codable, Hashable {
    case acura = "Acura"
}

// MARK: - MonthlyPaymentEstimate
struct MonthlyPaymentEstimate: Codable, Hashable {
    let downPaymentAmount: Double
    let downPaymentPercent, interestRate: Int
    let loanAmount, monthlyPayment: Double
    let price, termInMonths: Int
    
    private let identifier = UUID()
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

// MARK: - OnePriceArrow
struct OnePriceArrow: Codable, Hashable {
    let arrow: Arrow
    let arrowURL: String
    let icon: OnePriceArrowIcon
    let iconURL: String
    let order: Int
    let text: OnePriceArrowText

    enum CodingKeys: String, CodingKey {
        case arrow
        case arrowURL = "arrowUrl"
        case icon
        case iconURL = "iconUrl"
        case order, text
    }
    
    private let identifier = UUID()
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

enum Arrow: String, Codable, Hashable {
    case down = "DOWN"
    case up = "UP"
}

enum OnePriceArrowIcon: String, Codable, Hashable {
    case cpo = "cpo"
    case noAccident = "noAccident"
    case owner1 = "owner1"
    case personal = "personal"
    case recall = "recall"
    case service = "service"
    case wellMaintained = "wellMaintained"
}

enum OnePriceArrowText: String, Codable, Hashable {
    case certifiedPreOwned = "Certified Pre-Owned"
    case noAccidentsReported = "No Accidents Reported"
    case openRecall = "Open Recall"
    case personalVehicle = "Personal Vehicle"
    case priorCertifiedPreOwned = "Prior Certified Pre-Owned"
    case regularOilChanges = "Regular Oil Changes"
    case serviceHistory = "Service History"
    case the1OwnerVehicle = "1-Owner Vehicle"
}

enum RecordType: String, Codable, Hashable {
    case enhanced = "ENHANCED"
}

// MARK: - ServiceHistory
struct ServiceHistory: Codable, Hashable {
    let history: [ServiceHistoryHistory]?
    let icon: OnePriceArrowIcon
    let iconURL: String
    let number: Int
    let text: OnePriceArrowText

    enum CodingKeys: String, CodingKey {
        case history, icon
        case iconURL = "iconUrl"
        case number, text
    }
    
    private let identifier = UUID()
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

// MARK: - ServiceHistoryHistory
struct ServiceHistoryHistory: Codable, Hashable {
    let city, date, historyDescription: String
    let odometerReading: Int
    let source: String
    let state: State

    enum CodingKeys: String, CodingKey {
        case city, date
        case historyDescription = "description"
        case odometerReading, source, state
    }
    
    private let identifier = UUID()
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

enum Transmission: String, Codable {
    case automatic = "Automatic"
}

enum Trim: String, Codable {
    case advance = "Advance"
    case base = "Base"
    case technology = "Technology"
    case unspecified = "Unspecified"
}

enum VehicleCondition: String, Codable, Hashable {
    case used = "Used"
}

// MARK: - RelatedLinks
struct RelatedLinks: Codable {
    let acuraBodytypes, acuraModels: [Acura]

    enum CodingKeys: String, CodingKey {
        case acuraBodytypes = "Acura Bodytypes"
        case acuraModels = "Acura Models"
    }
}

// MARK: - Acura
struct Acura: Codable, Hashable {
    let count: Int
    let text: String
    let url: String
    
    private let identifier = UUID()
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

// MARK: - SearchArea
struct SearchArea: Codable, Hashable {
    let city: String
    let dynamicRadii: [Int]
    let dynamicRadius: Bool
    let latitude, longitude: Double
    let radius: Int
    let state: State
    let zip: String
    
    private let identifier = UUID()
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

// MARK: - SearchRequest
struct SearchRequest: Codable {
    let make: Make
    let mileageRange: Range
    let priceRange: PriceRange
    let radius: Int
    let srpURL, webHost: String
    let yearRange: Range
    let zip: String

    enum CodingKeys: String, CodingKey {
        case make, mileageRange, priceRange, radius
        case srpURL = "srpUrl"
        case webHost, yearRange, zip
    }
}

// MARK: - Range
struct Range: Codable {
    let max, min: Int
}

// MARK: - PriceRange
struct PriceRange: Codable {
    let min: Int
}
