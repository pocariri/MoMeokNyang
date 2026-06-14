import UIKit
import CoreLocation
import FirebaseFirestore
import FirebaseAuth

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    var searchQuery: String?
    
    let locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let query = searchQuery {
            searchLocalRestaurants(around: currentCoordinate, keyword: query)
            
            searchQuery = nil
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.currentCoordinate = location.coordinate
        }
    }

    private func searchLocalRestaurants(around coordinate: CLLocationCoordinate2D?, keyword: String) {
        guard let coord = coordinate else {
            print("아직 내 위치 정보를 받아오지 못했습니다")
            return
        }
        print("내 위치(\(coord.latitude), \(coord.longitude)) 기준으로 \(keyword) 검색 중...")
        
        // TODO: 네이버 지도, 카카오 지도, 혹은 애플 MapKit의 검색 API 연동하기!
    }
    
    private func saveFavoriteRestaurant(
        name: String,
        address: String,
        category: String,
        menuName: String,
        latitude: Double,
        longitude: Double
    ) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        
        let favoriteData: [String: Any] = [
            "userId": currentUser.uid,
            "restaurantName": name,
            "address": address,
            "category": category,
            "menuName": menuName,
            "latitude": latitude,
            "longitude": longitude,
            "savedAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("SavedRestaurants").addDocument(data: favoriteData) { error in
            if let error = error {
                print("맛집 찜하기 실패")
            } else {
                print("맛집 찜하기 성공")
            }
        }
    }
}
