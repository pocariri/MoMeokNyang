import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {

    @IBOutlet weak var topHeaderView: UIView!
    @IBOutlet weak var nicknameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Auth.auth().currentUser == nil {
            guard let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
            
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true, completion: nil)
        } else {
            fetchUserProfile()
        }
    }
    
    // Firebase 서버에서 유저 데이터를 실시간으로 불러오는 함수
    private func fetchUserProfile() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        let userUID = currentUser.uid
        
        db.collection("Users").document(userUID).getDocument { [weak self] (document, error) in
            
            if let error = error {
                print("유저 정보 로드 실패")
                return
            }
            
            if let document = document, document.exists, let data = document.data() {
                let nickname = data["nickName"] as? String ?? "사용자"
                
                DispatchQueue.main.async {
                    self?.nicknameLabel.text = "\(nickname)님"
                }
            }
        }
    }
    
    @IBAction func editProfileButtonTapped(_ sender: UIButton) {
    }
    
    // 로그아웃 버튼
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            print("로그아웃 성공")
            
            guard let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true, completion: nil)
        } catch let signOutError as NSError {
            print("로그아웃 실패")
        }
    }
    
    private func setupUI() {
        topHeaderView.layer.cornerRadius = 15
        topHeaderView.clipsToBounds = true
    }
}
