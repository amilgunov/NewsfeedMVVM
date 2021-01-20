//
//  MainViewController.swift
//  NewsAppMVVMRx
//
//  Created by Alexander Milgunov on 30.07.2020.
//  Copyright © 2020 Alexander Milgunov. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

typealias Section = AnimatableSectionModel<String, CellViewModel>

class MainViewController: UIViewController {
    
    private var viewModel: MainViewModel?
    private var tableView: UITableView
    private var refreshControl: UIRefreshControl
    
    private let disposeBag = DisposeBag()
    
    private let dataSource = RxTableViewSectionedAnimatedDataSource<Section>(configureCell: { (_, tableView, _, cellViewModel) in
        
            let cell = tableView.dequeueReusableCell(withIdentifier: CellViewController.cellIdentifier)
            (cell as? CellViewController)?.viewModel = cellViewModel
            return cell ?? UITableViewCell()
        }
    )
    
    private func setupUI() {

        tableView.refreshControl = refreshControl
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.register(CellViewController.self, forCellReuseIdentifier: CellViewController.cellIdentifier)

        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.size.equalToSuperview()
        }
    }
    
    private func bindViewModel() {
        
        guard let viewModel = viewModel else { return }
        
        let appearObservable = rx.viewWillAppear.asObservable()
        let refreshObservable = refreshControl.rx.controlEvent(UIControl.Event.valueChanged).asObservable()
        
        let sourse = Observable.of(appearObservable, refreshObservable).merge().asDriver(onErrorJustReturn: ())
            
        let input = MainViewModel.Input(fetchTrigger: sourse , reachedBottomTrigger: tableView.rx.reachedBottom.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.title.asObservable()
            .subscribe(onNext: { [weak self] title in
                self?.title = title
            })
            .disposed(by: disposeBag)
        
        output.cells
            .map { cellViewModels -> [Section] in
                [Section(model: "1", items: cellViewModels)]
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.isLoading
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
    }

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        self.tableView = UITableView()
        self.refreshControl = UIRefreshControl()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainViewController: UITableViewDelegate {
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offsetY = scrollView.contentOffset.y
//        let contentHeight = scrollView.contentSize.height
//        let diff = contentHeight - scrollView.frame.height

//        if offsetY > 0 && offsetY > (diff + 100) && viewModel?.state == .completed {
//            viewModel?.fetchTrigger.onNext(.update(.nextPage))
//        }
//    }
}

extension Reactive where Base: UIViewController {
    var viewWillAppear: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewWillAppear(_:))).map { _ in }
        return ControlEvent(events: source)
    }
}

extension Reactive where Base: UIScrollView {
    var reachedBottom: ControlEvent<Void> {
        let observable = contentOffset
            .flatMap { [weak base] contentOffset -> Observable<Void> in
                guard let scrollView = base else { return Observable.empty() }

                let visibleHeight = scrollView.frame.height - scrollView.contentInset.top - scrollView.contentInset.bottom
                let y = contentOffset.y + scrollView.contentInset.top
                let threshold = max(0.0, scrollView.contentSize.height - visibleHeight)

                return y > threshold ? Observable.just(()) : Observable.empty()
        }
        return ControlEvent(events: observable)
    }
}
