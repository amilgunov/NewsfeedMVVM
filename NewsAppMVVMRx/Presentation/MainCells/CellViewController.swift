//
//  CellViewController.swift
//  NewsAppMVVMRx
//
//  Created by Alexander Milgunov on 30.07.2020.
//  Copyright © 2020 Alexander Milgunov. All rights reserved.
//

import RxSwift
import SnapKit

class CellViewController: UITableViewCell {

    static let cellIdentifier = "Cell"
    
    private var disposeBag = DisposeBag()
    
    var viewModel: CellViewModel? {
        didSet {
            bindingViewModel()
        }
    }
    
    private lazy var newsImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 20
        image.clipsToBounds = true
        return image
    }()
    
    private lazy var newsTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
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
        return activityIndicator
    }()
    
    func setupIU() {
            
        addSubview(newsImageView)
        addSubview(newsTitleLabel)
        addSubview(newsAuthorLabel)
        addSubview(activityIndicator)
        
        newsImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(15)
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(180)
        }
        
        newsTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(newsImageView.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(10)
        }
        
        newsAuthorLabel.snp.makeConstraints { (make) in
            make.top.equalTo(newsTitleLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview().inset(20)
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
        
        viewModel?.image
            .map { _ in true }
            .asDriver()
            .drive(activityIndicator.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel?.image
            .drive(newsImageView.rx.image)
            .disposed(by: disposeBag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        activityIndicator.startAnimating()
        newsImageView.image = nil
        disposeBag = DisposeBag()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupIU()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
