import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // 뒤로가기 버튼
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // UI 셋업
    private func setupUI() {
        // 이메일 입력창
        emailTextField.layer.cornerRadius = 15
        emailTextField.clipsToBounds = true
        
        // 비밀번호 입력창
        passwordTextField.layer.cornerRadius = 15
        passwordTextField.clipsToBounds = true
    }
    
    // 로그인 버튼
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("이메일과 비밀번호를 모두 입력해주세요!")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResults, error in
            if let error = error {
                print("로그인 실패")
                return
            }
            
            print("로그인 성공")
            
            self?.dismiss(animated: true, completion: nil)
        }
    }
}
