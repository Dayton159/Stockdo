//
//  DailyAdjustedViewController.swift
//  Stockdo
//
//  Created by Dayton on 24/02/21.
//

import UIKit

class DailyAdjustedViewController: UIViewController {
   
    //MARK: - Properties
    private var firstSymbolStock = [DailyAdjusted]()
    private var secondSymbolStock = [DailyAdjusted]()
    private var thirdSymbolStock = [DailyAdjusted]()
    
    private let dailyAdjustedMain = DailyAdjustedMain.allCases
    private let symbolAvailability = SymbolAvailability.allCases
    
    private var activeTextfieldIndex = [Int]()
    
    var keyChainValue:String? {
        do {
            return try KeyChainStore.APIServices.getValue(for: AppData.accounts)
        } catch {
            showError(error.localizedDescription)
        }
        return nil
    }
    
    private var existNumber:Int {
        get {
            let arrays = [firstSymbolStock.count, secondSymbolStock.count, thirdSymbolStock.count]
            var existNumber = 0
            // if true
            arrays.forEach { array in
                if array != 0 {
                    existNumber += 1
                    
                }
            }
            return existNumber
        }
    }
    
    private lazy var dailyFormatter = DateFormatter().with {
        $0.dateFormat = "yyyy-MM-dd"
        $0.locale = Locale(identifier: "en_US_POSIX")
    }
    private let firstSymbolTable = UITableView().with {
        $0.backgroundColor = UIColor(named: "appColor2")
        
        $0.tableFooterView = UIView()
        $0.register(DailyAdjustedCell.self, forCellReuseIdentifier: DailyAdjustedCell.reuseIdentifier)
    }

    private let firstSymbolLabel = UILabel().with {
        $0.font = .systemFont(ofSize: 14, weight: .bold)
        $0.textColor = .white
        $0.textAlignment = .left
        $0.text = "Enter First Symbol "
        $0.numberOfLines = 0
        $0.adjustsFontForContentSizeCategory = true
    }
    private let secondSymbolLabel = UILabel().with {
        $0.font = .systemFont(ofSize: 14, weight: .bold)
        $0.textColor = .white
        $0.textAlignment = .left
        $0.text = "Enter Second Symbol"
        $0.numberOfLines = 0
        $0.adjustsFontForContentSizeCategory = true
    }
    private let thirdSymbolLabel = UILabel().with {
        $0.font = .systemFont(ofSize: 14, weight: .bold)
        $0.textColor = .white
        $0.textAlignment = .left
        $0.text = "Enter Third Symbol"
        $0.numberOfLines = 0
        $0.adjustsFontForContentSizeCategory = true
    }
    
    private let firstSymbolKeyboard = CustomTextfield(placeholder: "First Symbol").with {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.textAlignment = .right
    }
    
    private let secondSymbolKeyboard = CustomTextfield(placeholder: "Second Symbol").with {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.textAlignment = .right
    }
    
    private let thirdSymbolKeyboard = CustomTextfield(placeholder: "Third Symbol").with {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.textAlignment = .right
    }
    
    private lazy var firstContainerView = InputContainerView(label: firstSymbolLabel, textField: firstSymbolKeyboard).with { _ in }
    private lazy var secondContainerView = InputContainerView(label: secondSymbolLabel, textField: secondSymbolKeyboard).with { _ in }
    private lazy var thirdContainerView = InputContainerView(label: thirdSymbolLabel, textField: thirdSymbolKeyboard).with { _ in }
    
    private lazy var displayInputView = UIView(frame: .init(x: 0, y: 0, width: view.frame.width, height: 170)).with {
        let stackview = UIStackView(arrangedSubviews: [firstContainerView, secondContainerView, thirdContainerView])
        stackview.axis = .vertical
        stackview.spacing = 16
        $0.addSubview(stackview)
        stackview.anchor(top: $0.topAnchor, left: $0.leftAnchor, right: $0.rightAnchor,paddingTop: 15 ,paddingLeft: 20, paddingRight: 20)
    }
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar(withTitle: "Daily Adjusted", prefersLargeTitles: true)
        configureUI()
        configureTable()
        configureTextField()
        
    }
    
    //MARK: - Helpers
    
    private func fetchDailyStock(key:String,symbol:String,index:Int,to dailyAdjusted: Int) {
        Service.fetchDailyStock(key, symbol, dailyFormatter) { dailyStocks in
            print(dailyStocks.count)
            
            self.setStockValue(on: dailyAdjusted, from: dailyStocks)
            DispatchQueue.main.async {
                self.setTextFieldIndex(index:index)
                self.firstSymbolTable.reloadData()
            }
        }
    }
    
    private func configureUI() {
       
        view.addSubview(firstSymbolTable)
        firstSymbolTable.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
    private func configureTable() {
        firstSymbolTable.tableHeaderView = displayInputView
        firstSymbolTable.delegate = self
        firstSymbolTable.dataSource = self
    }
    
    private func configureTextField() {
        firstSymbolKeyboard.delegate = self
        secondSymbolKeyboard.delegate = self
        thirdSymbolKeyboard.delegate = self
    }
    
    private func setTextFieldIndex(index:Int) {
        if activeTextfieldIndex.contains(index) {
            if let activeIndex = activeTextfieldIndex.firstIndex(of: index) {
                activeTextfieldIndex[activeIndex] = index
        }
        } else {
            activeTextfieldIndex.append(index)
        }
    }
    
    private func getNumberOfRow(to existNumber:Int) -> Int {
        switch symbolAvailability[existNumber] {
        case .zeroValueExist:
            return 0
        case .oneValueExist:
           return oneValueRow()
        case .twoValueExist:
           return twoValueRow()
        case .threeValueExist:
           return threeValueRow()
        }
    }
    
    private func oneValueRow() ->Int {
        let arrays = [firstSymbolStock.count, secondSymbolStock.count, thirdSymbolStock.count]
       
        var returnedInt = Int()
        arrays.forEach { array in
            if array != 0 {
                returnedInt = array
            }
        }
        return returnedInt
    }
    
    private func twoValueRow() ->Int {
        let arrays = [firstSymbolStock.count, secondSymbolStock.count, thirdSymbolStock.count]
      
        var returnedInt = [Int]()
        arrays.forEach { array in
            if array != 0 {
                returnedInt.append(array)
            }
        }
        return min(returnedInt[0], returnedInt[1])
    }
    
    private func threeValueRow() ->Int {
        let arrays = [firstSymbolStock.count, secondSymbolStock.count, thirdSymbolStock.count]
       
        var returnedInt = [Int]()
        arrays.forEach { array in
            if array != 0 {
                returnedInt.append(array)
            }
        }
        return min(returnedInt[0], returnedInt[1], returnedInt[2])
    }
    
   private func setStockValue(on destinationTarget: Int, from: [DailyAdjusted]) {
        let dailyAdjustedKind = self.dailyAdjustedMain[destinationTarget]
        switch dailyAdjustedKind {
        case .firstSymbol:
            self.firstSymbolStock = from.sorted{$0.date > $1.date}
        case .secondSymbol:
            self.secondSymbolStock = from.sorted{$0.date > $1.date}
        case .thirdSymbol:
            self.thirdSymbolStock = from.sorted{$0.date > $1.date}
        }
    }
}


extension DailyAdjustedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return getNumberOfRow(to: existNumber)

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DailyAdjustedCell.reuseIdentifier, for: indexPath) as? DailyAdjustedCell else { fatalError("Could not create new cell") }
        
        let index = indexPath.row
        
        switch symbolAvailability[activeTextfieldIndex.count] {
        case .zeroValueExist:
            cell.viewModel = DailyAdjustedViewModel()
        case .oneValueExist:
            if activeTextfieldIndex.first == 1 {
                cell.viewModel = DailyAdjustedViewModel(firstSymbol: firstSymbolStock[index])
            } else if activeTextfieldIndex.first == 2 {
                cell.viewModel = DailyAdjustedViewModel(secondSymbol: secondSymbolStock[index])
            }else {
                cell.viewModel = DailyAdjustedViewModel(thirdSymbol: thirdSymbolStock[index])
            }
        case .twoValueExist:
            let sortedArray = activeTextfieldIndex.sorted() { $0 < $1}
            let firstIndex = sortedArray[0]
            let secondIndex = sortedArray[1]
            
            if firstIndex == 1 {
                if secondIndex == 2 {
                    cell.viewModel = DailyAdjustedViewModel(firstSymbol: firstSymbolStock[index], secondSymbol: secondSymbolStock[index])
                }else if secondIndex == 3 {
                    cell.viewModel = DailyAdjustedViewModel(firstSymbol: firstSymbolStock[index], thirdSymbol: thirdSymbolStock[index])
                }
            }else if firstIndex == 2{
                if secondIndex == 3 {
                    cell.viewModel = DailyAdjustedViewModel(secondSymbol: secondSymbolStock[index], thirdSymbol: thirdSymbolStock[index])
                }
            }
        case .threeValueExist:
            cell.viewModel = DailyAdjustedViewModel(firstSymbol: firstSymbolStock[index], secondSymbol: secondSymbolStock[index], thirdSymbol: thirdSymbolStock[index])
        }
        return cell
    }
}

extension DailyAdjustedViewController: UITextFieldDelegate {
    
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
        if let safeText = textField.text?.uppercased(), let keyChain = keyChainValue {
            if textField == firstSymbolKeyboard {
                fetchDailyStock(key: keyChain, symbol: safeText,index: 1, to: 0)
            } else if textField == secondSymbolKeyboard {
                fetchDailyStock(key: keyChain, symbol: safeText, index: 2, to: 1)
            } else {
                fetchDailyStock(key: keyChain, symbol: safeText, index: 3, to: 2)
            }
        } else {
            showError("You need to configure your API Key first")
            textField.text = nil
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
