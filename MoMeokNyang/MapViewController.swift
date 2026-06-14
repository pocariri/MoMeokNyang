import UIKit
import MapKit
import CoreLocation
import FirebaseFirestore
import FirebaseAuth

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var searchQuery: String?
    
    private var currentSearchMenu: String = "랜덤추천"
    
    private let locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        setupMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let query = searchQuery {
            self.currentSearchMenu = query
            self.searchQuery = nil
            
            if self.currentCoordinate != nil {
                print("변수 진입 타이밍 성공: '\(self.currentSearchMenu)' 검색 시작!")
                self.searchLocalRestaurants(keyword: self.currentSearchMenu)
                locationManager.stopUpdatingLocation()
            }
        }
    }
    
    // 지도 기본 세팅
    private func setupMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    // 위치 매니저 권한 요청
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.currentCoordinate = location.coordinate
            
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
            
            if self.currentSearchMenu != "랜덤추천" {
                print("내 위치 확보 및 검색어 확보 완료! 이제 '\(self.currentSearchMenu)' 맛집을 검색합니다.")
                self.searchLocalRestaurants(keyword: self.currentSearchMenu)
                
                locationManager.stopUpdatingLocation()
            } else {
                print("위치는 잡았지만 진짜 메뉴 이름이 넘어오기를 기다리는 중입니다.")
            }
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    private func searchLocalRestaurants(keyword: String) {
        mapView.removeAnnotations(mapView.annotations)
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = keyword
        
        if let currentRegion = currentCoordinate {
            searchRequest.region = MKCoordinateRegion(center: currentRegion, latitudinalMeters: 2000, longitudinalMeters: 2000)
        }
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { [weak self] (response, error) in
            if let error = error {
                print("맛집 검색 에러")
                return
            }
            
            guard let response = response else { return }
            print("근처에서 총 \(response.mapItems.count)개의 가게를 찾았습니다")
            
            for item in response.mapItems {
                let annotation = MKPointAnnotation()
                annotation.title = item.name
                annotation.subtitle = item.placemark.title
                annotation.coordinate = item.placemark.coordinate
                
                self?.mapView.addAnnotation(annotation)
            }
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        print("지도 위에 핀을 그립니다")
        let identifier = "RestaurantPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.markerTintColor = .systemTeal
            
            let favoriteButton = UIButton(type: .custom)
            favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            favoriteButton.tintColor = .systemRed
            favoriteButton.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
            annotationView?.rightCalloutAccessoryView = favoriteButton
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation else { return }
        
        let restaurantName = (annotation.title ?? nil) ?? "이름 없는 식당"
        let address = (annotation.subtitle ?? nil) ?? "주소 불명"
        let lat = annotation.coordinate.latitude
        let lng = annotation.coordinate.longitude
        
        print("가게를 찜하는 데 성공했습니다.")
        
        saveFavoriteRestaurant(
            name: restaurantName,
            address: address,
            category: "추천메뉴",
            menuName: self.currentSearchMenu,
            latitude: lat,
            longitude: lng
        )
        
        // 찜 완료 알림창 띄워주기
        let alert = UIAlertController(title: "찜 완료!", message: "내 찜 목록에 새로운 가게가추가되었습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true)
    }
    
    private func saveFavoriteRestaurant(name: String, address: String, category: String, menuName: String, latitude: Double, longitude: Double) {
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
