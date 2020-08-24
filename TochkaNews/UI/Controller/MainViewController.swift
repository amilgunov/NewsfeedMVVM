//
//  MainViewController.swift
//  TochkaNews
//
//  Created by Alexander Milgunov on 30.07.2020.
//  Copyright © 2020 Alexander Milgunov. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxDataSources

typealias Section = AnimatableSectionModel<String, CellViewModel>

class MainViewController: UIViewController {
    
    private var viewModel: MainViewModelType?
    private var table: UITableView
    private let disposeBag = DisposeBag()
    
    private let dataSource = RxTableViewSectionedAnimatedDataSource<Section>(configureCell: { (_, tableView, _, cellViewModel) in
        
            let cell = tableView.dequeueReusableCell(withIdentifier: CellViewController.cellIdentifier)
            (cell as? CellViewController)?.viewModel = cellViewModel
            return cell ?? UITableViewCell()
        }
    )
    
    private func setupUI() {
        
        let refreshControl: UIRefreshControl = {
            let refreshControl = UIRefreshControl()
            refreshControl
                .rx.controlEvent(UIControl.Event.valueChanged)
                .subscribe(onNext: { [unowned self] in
                    self.viewModel?.fetchTrigger.onNext(.initial)
                    refreshControl.endRefreshing()
                    })
                .disposed(by: disposeBag)
            return refreshControl
        }()
        
        table = {
            let table = UITableView()
            table.refreshControl = refreshControl
            table.delegate = self
            table.allowsSelection = false
            table.register(CellViewController.self, forCellReuseIdentifier: CellViewController.cellIdentifier)
            
            return table
        }()

        view.addSubview(table)
        table.snp.makeConstraints { (make) in
            make.size.equalToSuperview()
        }
    }
    
    private func bindingViewModel() {
        
        viewModel?.title
            .subscribe(onNext: { [unowned self] text in
                self.title = text
            })
            .disposed(by: disposeBag)
        
        viewModel?.cells
            .map { cellViewModels -> [Section] in
                [Section(model: "1", items: cellViewModels)]
            }
            .bind(to: table.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindingViewModel()
        viewModel?.fetchTrigger.onNext(.initial)
    }

    init(viewModel: MainViewModelType) {
        self.viewModel = viewModel
        self.table = UITableView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let diff = contentHeight - scrollView.frame.height

        if offsetY > 0 && offsetY > (diff + 100) && viewModel?.state == .completed {
            viewModel?.fetchTrigger.onNext(.update(.nextPage))
        }
    }
}
