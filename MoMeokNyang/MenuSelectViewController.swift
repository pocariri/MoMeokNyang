import UIKit
import FirebaseFirestore

class MenuSelectViewController: UIViewController {
    @IBOutlet weak var selectCategoryButton: UIButton!
    @IBOutlet weak var quickRandomButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // 뒤로가기 버튼
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // 바로 랜덤 추천 버튼
    @IBAction func quickRandomButtonTapped(_ sender: UIButton) {
        fetchRandomMenuAndPresent()
    }
    
    // UI 셋업
    private func setupUI() {
        // 바로 랜덤 추천 버튼
        var config = quickRandomButton.configuration ?? UIButton.Configuration.filled()
        
        var titleAttr = AttributedString("바로 랜덤 추천")
        titleAttr.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleAttr.foregroundColor = UIColor.white
        config.attributedTitle = titleAttr
        
        var subtitleAttr = AttributedString("별도의 설정 없이 메뉴를 추천합니다.")
        subtitleAttr.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleAttr.foregroundColor = UIColor.lightText
        config.attributedSubtitle = subtitleAttr
        
        config.titleAlignment = .center
        config.titlePadding = 10
        
        quickRandomButton.configuration = config
        
        // 카테고리 설정 버튼
        var categoryConfig = selectCategoryButton.configuration ?? UIButton.Configuration.filled()
        
        var categoryTitleAttr = AttributedString("카테고리 설정")
        categoryTitleAttr.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        categoryTitleAttr.foregroundColor = UIColor.white
        categoryConfig.attributedTitle = categoryTitleAttr
        
        var categorySubtitleAttr = AttributedString("원하는 카테고리를 설정합니다")
        categorySubtitleAttr.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        categorySubtitleAttr.foregroundColor = UIColor.lightText
        categoryConfig.attributedSubtitle = categorySubtitleAttr
        
        categoryConfig.titleAlignment = .center
        categoryConfig.titlePadding = 10
        
        selectCategoryButton.configuration = categoryConfig
        
    }
    
    // 메뉴 랜덤 추출
    private func fetchRandomMenuAndPresent() {
        let db = Firestore.firestore()
        
        db.collection("Menus").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("메뉴 로드 실패")
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else { return }
            guard let randomDocument = documents.randomElement() else { return }
            let menuData = randomDocument.data()
            
            let menuName = menuData["name"] as? String ?? "맛있는 음식"
            let category = menuData["category"] as? String ?? "미분류"
            
            DispatchQueue.main.async {
                self?.presentResultViewController(menuName: menuName, category: category)
            }
        }
    }
    
    private func presentResultViewController(menuName: String, category: String) {
        guard let resultVC = self.storyboard?.instantiateViewController(withIdentifier: "RecommendationResultViewController") as? RecommendationResultViewController else { return }
        
        resultVC.recommendedMenuName = menuName
        resultVC.recommendedCategory = category
        
        resultVC.modalPresentationStyle = .fullScreen
        self.present(resultVC, animated: true, completion: nil)
    }
}
