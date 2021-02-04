//
//  DetailViewController.swift
//  NewsfeedMVVM
//
//  Created by Alexander Milgunov on 03.02.2021.
//  Copyright © 2021 Alexander Milgunov. All rights reserved.
//

import UIKit
import RxSwift

class DetailViewController: UIViewController {
    
    private var disposeBag = DisposeBag()
    
    var viewModel: CellViewModelType? {
        didSet {
            bindingViewModel()
        }
    }
    
    private lazy var newsImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 30
        image.clipsToBounds = true
        return image
    }()
    
    private lazy var newsTitleLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(30)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var newsContentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .gray
        return label
    }()
    
    private lazy var newsAuthorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .lightGray
        return label
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    func setupIU() {
        
        view.backgroundColor = .white
        
        view.addSubview(newsImageView)
        view.addSubview(newsTitleLabel)
        view.addSubview(newsContentLabel)
        view.addSubview(newsAuthorLabel)
        view.addSubview(activityIndicator)
        
        newsImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(30)
            make.left.right.equalToSuperview().inset(10)
            make.height.equalTo(view.frame.height/3)
        }
        
        newsTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(newsImageView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(10)
        }
        
        newsContentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(newsTitleLabel.snp.bottom)
            make.left.right.equalToSuperview().inset(10)
        }
        
        newsAuthorLabel.snp.makeConstraints { (make) in
            make.top.equalTo(newsContentLabel.snp.bottom).offset(30)
            make.bottom.equalToSuperview().inset(80)
            make.left.right.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalTo(newsImageView)
        }
    }
    
    func bindingViewModel() {
    
        viewModel?.title
            .drive(newsTitleLabel.rx.text)
            .disposed(by: disposeBag)
    
        viewModel?.author
            .drive(newsAuthorLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel?.content
            .drive(newsContentLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel?.image
            .map { _ in true }
            .asDriver()
            .drive(activityIndicator.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel?.image
            .drive(newsImageView.rx.image)
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupIU()
    }
}
