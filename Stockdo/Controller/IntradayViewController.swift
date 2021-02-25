//
//  IntradayViewController.swift
//  Stockdo
//
//  Created by Dayton on 24/02/21.
//

import UIKit

class IntradayViewController: UIViewController {
   
    //MARK: - Properties
    private var intradayStock = [Intraday]()
    private var modalTransitioningDelegate: InteractiveModalTransitioningDelegate!
    private let searchController = UISearchController(searchResultsController: nil)
    
    var keyChainValue:String? {
        do {
            return try KeyChainStore.APIServices.getValue(for: AppData.accounts)
        } catch {
            print(error)
        }
        return nil
    }
    
    private lazy var hourFormatter = DateFormatter().with {
        $0.dateFormat = "yyyy-MM-dd HH:mm:ss"
        $0.locale = Locale(identifier: "en_US_POSIX")
    }
 
    private let tableView = UITableView().with {
        $0.tableFooterView = UIView()
        $0.register(IntradayCell.self, forCellReuseIdentifier: IntradayCell.reuseIdentifier)
    }
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        
        fetchStock()
        configureUI()
        configureTable()
        configureNavigationBar(withTitle: "Intraday", prefersLargeTitles: true)
        configureSearchController()
    }
    
   //MARK: - Helpers
    private func fetchStock(keyChain:String? = nil, symbol:String? = nil) {
        Service.fetchIntradayStock(keyChain, symbol, hourFormatter) { intradays in
            self.intradayStock = intradays
            self.sortStock(key: AppData.sortBy)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    private func configureUI() {
        view.addSubview(tableView)
        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
    private func configureTable() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func configureSearchController() {
        searchController.searchBar.showsCancelButton = false
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Enter Symbol"
        definesPresentationContext = false
        
        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = .systemPurple
            textfield.backgroundColor = .white
            textfield.delegate = self
           
        }
        let image = UIImage(named: "funnel")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(goToSortPicker))
    }
    
    private func sortStock(key: String) {
        switch key {
        case "date":
            dateSort()
        case "open":
            openSort()
        case "low":
            lowSort()
        case "high":
            highSort()
        default:
            return
        }
    }
    
    private func dateSort() {
        self.intradayStock = intradayStock.sorted{$0.date > $1.date}
        
    }
    private func openSort() {
        self.intradayStock = intradayStock.sorted{$0.open > $1.open}
       
    }
    
    private func lowSort() {
        self.intradayStock = intradayStock.sorted{$0.low > $1.low}
      
    }
    
    private func highSort() {
        self.intradayStock = intradayStock.sorted{$0.high > $1.high}
        
    }
    
    //MARK: - Selectors
    
    @objc func goToSortPicker() {
        let controller = SortPickerView()
        controller.modalPresentationStyle = .custom
        modalTransitioningDelegate = InteractiveModalTransitioningDelegate(from: self, to: controller)
        controller.transitioningDelegate = modalTransitioningDelegate
        controller.selectedSortMethod = AppData.sortBy
        controller.delegate = self
        
        self.present(controller, animated: true, completion: nil)
    }
   
}


extension IntradayViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return intradayStock.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: IntradayCell.reuseIdentifier, for: indexPath) as? IntradayCell else { fatalError("Could not create new cell") }
        
        cell.viewModel = IntradayViewModel(intraday: intradayStock[indexPath.row])
        return cell
    }
    
    
}

extension IntradayViewController: SettingConfiguration {
    func saveToUserDefault(value:String, key: String) {
        if key == "sortBy" {
            AppData.sortBy = value
            sortStock(key: value)
            self.tableView.reloadData()
        }
    }
}

extension IntradayViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        if textField.text != "" {
            return true
            
        } else {
            textField.placeholder = "Type something here"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let safeText = textField.text {
            self.fetchStock(keyChain: keyChainValue,symbol: safeText)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
            let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string) as String
            return checkLimitValue(key: newText, upperLimit: 12)
    }
    
    func checkLimitValue(key: String, upperLimit: Int) -> Bool {
        if key == "" {
            return true
        } else {
            if key.count <= upperLimit {
                
                return true
            } else {
                
                return false
            }
        }
    }
}
