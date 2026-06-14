import UIKit
import FirebaseAuth
import FirebaseFirestore

class RecommendationResultViewController: UIViewController {
    @IBOutlet weak var menuNameLabel: UILabel!
    @IBOutlet weak var menuImageView: UIImageView!
    
    var recommendedMenuName: String = ""
    var recommendedCategory: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLabel()
    }
    
    // 라벨 텍스트를 새로고침하는 함수
    private func updateLabel() {
        menuNameLabel.text = recommendedMenuName
        
        if let foodImage = UIImage(named: recommendedMenuName) {
            menuImageView.image = foodImage
        }
    }
    
    // 뒤로가기 버튼
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 한 번 더 랜덤 버튼
    @IBAction func retryButtonTapped(_ sender: UIButton) {
        let db = Firestore.firestore()
        
        db.collection("Menus").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("메뉴 재로드 실패")
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else { return }
            guard let randomDocument = documents.randomElement() else { return }
            let menuData = randomDocument.data()
            
            self?.recommendedMenuName = menuData["name"] as? String ?? "맛있는 음식"
            
            DispatchQueue.main.async {
                self?.updateLabel()
            }
        }
    }
    
    // 이 메뉴로 결정 버튼
    @IBAction func decisionButtonTapped(_ sender: UIButton) {
        guard let currentUser = Auth.auth().currentUser else {
            alertMessage(title: "안내", message: "로그인 후 기록을 저장할 수 있습니다냥!")
            return
        }
        
        let db = Firestore.firestore()
        let userUID = currentUser.uid
        let recordData: [String: Any] = [
            "userId": userUID,
            "menuName": recommendedMenuName,
            "category": recommendedCategory,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("EatingRecords").addDocument(data: recordData) { [weak self] error in
            if let error = error {
                self?.alertMessage(title: "실패", message: "기록 저장 중 에러 발생")
                return
            }
            
            let alert = UIAlertController(title: "결정 완료!", message: "오늘의 메뉴가 기록에 저장되었습니다.\n지도 화면으로 이동할까요?", preferredStyle: .alert)
            
            let mapAction = UIAlertAction(title: "지도 보기", style: .default) { _ in
                guard let currentVC = self else { return }
                
                currentVC.dismiss(animated: true) {
                    if let tabBarController = UIApplication.shared.windows.first?.rootViewController as? UITabBarController,
                       let viewControllers = tabBarController.viewControllers {
                        
                        let targetVC = viewControllers[1]
                        let mapVC = (targetVC as? UINavigationController)?.topViewController as? MapViewController ?? (targetVC as? MapViewController)
                        
                        mapVC?.searchQuery = currentVC.recommendedMenuName
                        
                        tabBarController.selectedIndex = 1
                    }
                }
            }
            
            let closeAction = UIAlertAction(title: "홈으로", style: .cancel) { _ in
                self?.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(mapAction)
            alert.addAction(closeAction)
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    // 알림창 헬퍼 함수
    private func alertMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
