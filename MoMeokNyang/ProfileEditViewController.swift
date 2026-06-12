import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileEditViewController: UIViewController {
    @IBOutlet weak var newNicknameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCurrentNickname()
    }
    
    // 뒤로가기 버튼
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // 닉네임 변경 버튼
    @IBAction func changeNicknameButtonTapped(_ sender: UIButton) {
        guard let newNickname = newNicknameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !newNickname.isEmpty else {
            alertMessage(title: "경고", message: "새로운 닉네임을 입력해주세요")
            return
        }
            
        guard let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
                
        db.collection("Users").document(currentUser.uid).updateData(["nickName": newNickname]) { [weak self] error in
            if let error = error {
                self?.alertMessage(title: "실패", message: "닉네임 변경에 실패했습니다.")
                return
            }
                    
            let alert = UIAlertController(title: "성공", message: "닉네임이 성공적으로 변경되었습니다", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                    self?.navigationController?.popViewController(animated: true)
            }
            alert.addAction(okAction)
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    // 비밀번호 재설정 이메일 전송 버튼
    @IBAction func resetPasswordButtonTapped(_ sender: UIButton) {
    }
    
    // 현재 닉네임 불러오기
    private func fetchCurrentNickname() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
            
        db.collection("Users").document(currentUser.uid).getDocument { [weak self] (document, error) in
            if let document = document, document.exists, let data = document.data() {
                let currentNickname = data["nickName"] as? String ?? ""
                    
                DispatchQueue.main.async {
                    self?.newNicknameTextField.text = currentNickname
                }
            }
        }
    }
    
    private func alertMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
