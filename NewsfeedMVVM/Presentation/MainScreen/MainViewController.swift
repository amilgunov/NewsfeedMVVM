//
//  MainViewController.swift
//  NewsfeedMVVM
//
//  Created by Alexander Milgunov on 30.07.2020.
//  Copyright © 2020 Alexander Milgunov. All rights reserved.
//

import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

typealias Section = AnimatableSectionModel<String, CellViewModel>

class MainViewController: UIViewController, UITableViewDelegate {
    
    var coordinator: DetailFlow?
    private var viewModel: MainViewModel?

    private lazy var refreshControl: UIRefreshControl = {
        return UIRefreshControl()
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.refreshControl = refreshControl
        tableView.delegate = self
        tableView.register(CellViewController.self, forCellReuseIdentifier: CellViewController.cellIdentifier)
        
        tableView.rx.itemSelected
            .asObservable()
            .subscribe(onNext: { indexPath in
                guard let cell = tableView.dataSource?.tableView(tableView, cellForRowAt: indexPath) as? CellViewController, let viewModel = cell.viewModel else { return }
                self.coordinator?.coordinateToDetail(viewModel: viewModel)
            })
            .disposed(by: disposeBag)
        
        return tableView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.startAnimating()
        indicator.isHidden = true
        return indicator
    }()
    
    private var itemsCount: Int = 0
    
    private let disposeBag = DisposeBag()
   
    private lazy var dataSource: RxTableViewSectionedAnimatedDataSource<Section> = {
        let dataSource = RxTableViewSectionedAnimatedDataSource<Section>(configureCell: { (_, tableView, target, cellViewModel) in
                let cell = tableView.dequeueReusableCell(withIdentifier: CellViewController.cellIdentifier)
                cell?.selectionStyle = UITableViewCell.SelectionStyle.none
                (cell as? CellViewController)?.viewModel = cellViewModel
                return cell ?? UITableViewCell()
            }
        )
        return dataSource
    }()
    
    private func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        //MARK: - ViewModel Inputs
        let appearObservable = rx.viewWillAppear.asDriver()
        let refreshObservable = refreshControl.rx.controlEvent(UIControl.Event.valueChanged).asDriver()
        
        let fetchTopTrigger = Driver.of(appearObservable, refreshObservable).merge()
        let reachedBottomTrigger = tableView.rx.reachedBottom.asDriver()
            
        let input = MainViewModel.Input(fetchTopTrigger: fetchTopTrigger , reachedBottomTrigger: reachedBottomTrigger)
        
        //MARK: - ViewModel Outputs
        let output = viewModel.transform(input: input)
        
        output.isLoading
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        output.isLoading
            .map { !$0 }
            .drive(activityIndicator.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.title
            .drive(rx.title)
            .disposed(by: disposeBag)
        
        output.cells.asObservable()
            .map { cellViewModels -> [Section] in
                [Section(model: "1", items: cellViewModels)]
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    
        output.cells.asObservable()
            .map { $0.count }
            .subscribe(onNext: { [unowned self] cellsCount in
                if self.itemsCount < cellsCount {
                    self.tableView.scrollToRow(at: IndexPath(item: self.itemsCount, section: 0), at: .bottom, animated: true)
                }
                self.itemsCount = cellsCount
            })
            .disposed(by: disposeBag)
        
        output.alert.asObservable()
            .subscribe(onNext: {
                self.showAlert(alertText: "Data error", alertMessage: $0)
            })
            .disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return activityIndicator
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.size.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        setupUI()
        bindViewModel()
        viewModel?.startUp()
    }

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
