import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var nickNameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // 뒤로가기 버튼
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 회원가입 버튼
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let nickName = nickNameTextField.text, !nickName.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("모든 칸을 채워주세요!")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                print("계정 생성 실패")
                return
            }
            
            guard let user = authResult?.user else { return }
            print("계정 생성 성공")
            
            let db = Firestore.firestore()
            
            let userData: [String: Any] = [
                "uid": user.uid,
                "email": user.email,
                "nickName": nickName,
                "createAt": FieldValue.serverTimestamp()
            ]
            
            db.collection("Users").document(user.uid).setData(userData) { error in
                if let error = error {
                    print("Firestore 저장 실패")
                    return
                }
                
                print("Firestore 저장 성공")
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // UI 셋업
    private func setupUI() {
        // 이메일 입력창
        emailTextField.layer.cornerRadius = 15
        emailTextField.clipsToBounds = true
        
        // 닉네임 입력창
        nickNameTextField.layer.cornerRadius = 15
        nickNameTextField.clipsToBounds = true
        
        // 비밀번호 입력창
        passwordTextField.layer.cornerRadius = 15
        passwordTextField.clipsToBounds = true
    }
    
}
