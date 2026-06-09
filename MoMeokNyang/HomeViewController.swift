import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var topHeaderView: UIView!
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var exploreButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        // 상단 바
        topHeaderView.layer.cornerRadius = 15
        topHeaderView.clipsToBounds = true
        
        // 음식 이미지
        foodImageView.layer.cornerRadius = 30
        foodImageView.clipsToBounds = true
        
        // 메뉴 탐색 버튼
        exploreButton.layer.cornerRadius = 10
        exploreButton.clipsToBounds = true
        exploreButton.titleEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)  
    }
}
