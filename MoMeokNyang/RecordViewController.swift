import UIKit
import FirebaseAuth
import FirebaseFirestore

struct EatingRecord {
    let menuName: String
    let category: String
    let timestamp: Date?
}

class RecordViewController: UIViewController {
    
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var topHeaderView: UIView!
    @IBOutlet weak var recordSegmentedControl: UISegmentedControl!
    @IBOutlet weak var recordTableView: UITableView!
    
    private var eatingRecords: [EatingRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        recordTableView.delegate = self
        recordTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                guard let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
                    loginVC.modalPresentationStyle = .fullScreen
                    self.present(loginVC, animated: false, completion: nil)
            }
        } else {
            fetchUserProfile()
            fetchEatingRecords()
        }
    }
    
    // 유저 닉네임 불러오기
    private func fetchUserProfile() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        
        db.collection("Users").document(currentUser.uid).getDocument { [weak self] (document, error) in
            if let document = document, document.exists, let data = document.data() {
                let nickname = data["nickName"] as? String ?? "사용자"
                
                DispatchQueue.main.async {
                    self?.nicknameLabel.text = "\(nickname)님"
                }
            }
        }
    }
    
    // 메뉴 결정 기록 데이터 가져오기
    private func fetchEatingRecords() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        
        db.collection("EatingRecords")
            .whereField("userId", isEqualTo: currentUser.uid)
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] (querySnapshot, error) in
                
                if let error = error {
                    print("기록 로드 실패")
                    return
                }
                
                var fetchedRecords: [EatingRecord] = []
                
                if let documents = querySnapshot?.documents {
                    for document in documents {
                        let data = document.data()
                        let menuName = data["menuName"] as? String ?? "맛있는 음식"
                        let category = data["category"] as? String ?? "미분류"
                        let timestamp = (data["timestamp"] as? Timestamp)?.dateValue()
                        
                        let record = EatingRecord(menuName: menuName, category: category, timestamp: timestamp)
                        fetchedRecords.append(record)
                    }
                }
                
                self?.eatingRecords = fetchedRecords
                
                DispatchQueue.main.async {
                    self?.recordTableView.reloadData()
                }
            }
    }
    
    // 세그먼트 값이 바뀔 때마다 실행되는 함수
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("최근 기록 탭")
            fetchEatingRecords()
        case 1:
            print("찜 목록 탭")
            recordTableView.reloadData()
        default:
            break
        }
        
        recordTableView.reloadData()
    }
    private func setupUI() {
        topHeaderView.layer.cornerRadius = 15
        topHeaderView.clipsToBounds = true
    }
}

// TableView 임시 설정
extension RecordViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 우선 화면이 잘 돌아가는지 확인하기 위해 임시로 5개만 띄웁니다.
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 스토리보드에서 생성할 셀 ID를 임시로 "RecordCell"로 지정해 둡니다.
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell") ?? UITableViewCell(style: .default, reuseIdentifier: "RecordCell")
        
        // 지금 어떤 탭이 켜져 있느냐에 따라 셀에 보일 텍스트를 다르게 처리합니다!
        if recordSegmentedControl.selectedSegmentIndex == 0 {
            cell.textLabel?.text = "최근 기록 데이터 자리 #\(indexPath.row + 1)"
        } else {
            cell.textLabel?.text = "찜한 식당 데이터 자리 #\(indexPath.row + 1)"
        }
        
        return cell
    }
}
