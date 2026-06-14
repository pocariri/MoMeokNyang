import UIKit
import FirebaseFirestore

class CategorySelectViewController: UIViewController {
    
    @IBOutlet weak var categoryPickerView: UIPickerView!
    
    let categories = ["한식", "일식", "중식", "양식", "분식", "아시안", "패스트푸드"]
    private var selectedCategory: String = "한식"
    

    override func viewDidLoad() {
        super.viewDidLoad()

        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
    }
    
    // 뒤로가기 버튼
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // 메뉴 랜덤 추천 버튼
    @IBAction func randomMenuButtonTapped(_ sender: UIButton) {
        fetchMenuAndPresent(category: selectedCategory)
    }
    
    // 설정한 카테고리에 따라 메뉴를 랜덤으로 추천
    private func fetchMenuAndPresent(category: String) {
        let db = Firestore.firestore()
        
        db.collection("Menus")
            .whereField("category", isEqualTo: category)
            .getDocuments { [weak self] (querySnapshot, error) in
                
                if let error = error {
                    print("메뉴 로드 실패")
                    return
                }
                
                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                    print("해당 카테고리에 메뉴가 없습니다.")
                    return
                }
                
                guard let randomDocument = documents.randomElement() else { return }
                let menuData = randomDocument.data()
                
                let menuName = menuData["name"] as? String ?? "맛있는 음식"
                let menuCategory = menuData["category"] as? String ?? "미분류"
                
                DispatchQueue.main.async {
                    self?.presentResultViewController(menuName: menuName, category: menuCategory)
                }
            }
    }
    
    // 결과 화면을 띄우기
    private func presentResultViewController(menuName: String, category: String) {
        guard let resultVC = self.storyboard?.instantiateViewController(withIdentifier: "RecommendationResultViewController") as? RecommendationResultViewController else { return }
        
        resultVC.recommendedMenuName = menuName
        resultVC.recommendedCategory = category
        
        resultVC.modalPresentationStyle = .fullScreen
        
        if let presentingVC = self.presentingViewController {
            self.dismiss(animated: true) {
                presentingVC.present(resultVC, animated: true, completion: nil)
            }
        }
    }
}

extension CategorySelectViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = categories[row]
    }
}
