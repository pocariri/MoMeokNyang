import UIKit
import FirebaseAuth
import FirebaseFirestore

struct EatingRecord {
    let menuName: String
    let category: String
    let timestamp: Date?
    
    var formattedDate: String {
        guard let date = timestamp else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
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

extension RecordViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if recordSegmentedControl.selectedSegmentIndex == 0 {
            return eatingRecords.count
        } else {
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "RecordCell")
        
        cell.accessoryView = nil
        
        if recordSegmentedControl.selectedSegmentIndex == 0 {
            let currentRecord = eatingRecords[indexPath.row]
            cell.textLabel?.text = currentRecord.menuName
            cell.detailTextLabel?.text = "카테고리: \(currentRecord.category)"
            cell.textLabel?.textColor = .black
            
            let dateLabel = UILabel()
            dateLabel.text = currentRecord.formattedDate
            dateLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            dateLabel.textColor = .lightGray
            dateLabel.sizeToFit()
            
            cell.accessoryView = dateLabel
            
        } else {
            // 찜 목록 탭 (임시)
            cell.textLabel?.text = "찜한 식당 데이터 자리 #\(indexPath.row + 1)"
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
}
