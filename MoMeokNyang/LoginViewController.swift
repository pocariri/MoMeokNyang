import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupUI() {
        // 이메일 입력창
        emailTextField.layer.cornerRadius = 15
        emailTextField.clipsToBounds = true
        
        // 비밀번호 입력창
        passwordTextField.layer.cornerRadius = 15
        passwordTextField.clipsToBounds = true
    }
}
