//
//  CellViewController.swift
//  TochkaNews
//
//  Created by Alexander Milgunov on 30.07.2020.
//  Copyright © 2020 Alexander Milgunov. All rights reserved.
//

import UIKit
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
    
    var newsImageView: UIImageView!
    var newsTitleLabel: UILabel!
    var newsAuthorLabel: UILabel!
    
    func bindingViewModel() {
    
        viewModel?.title
            .drive(newsTitleLabel.rx.text)
            .disposed(by: disposeBag)
    
        viewModel?.author
            .drive(newsAuthorLabel.rx.text)
            .disposed(by: disposeBag)
    
        viewModel?.urlToImage
            .subscribe(onNext: { [unowned self] url in
                self.newsImageView.loadImage(from: url, defaultImage: UIImage(named: "defaultImage"))
            })
            .disposed(by: disposeBag)
    }
    
    func setupIU() {
        
        newsImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            
            return imageView
        }()
        
        newsTitleLabel = {
            let title = UILabel()
            title.numberOfLines = 0
            title.textAlignment = .center
            return title
        }()
        
        newsAuthorLabel = {
            let author = UILabel()
            author.numberOfLines = 0
            author.textAlignment = .center
            author.textColor = .lightGray
            return author
        }()
            
        addSubview(newsImageView)
        addSubview(newsTitleLabel)
        addSubview(newsAuthorLabel)
        
        newsImageView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview().inset(10)
            make.height.equalTo(180)
        }
        
        newsTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(newsImageView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(10)
        }
        
        newsAuthorLabel.snp.makeConstraints { (make) in
            make.top.equalTo(newsTitleLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview().inset(20)
            make.left.right.equalToSuperview()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        newsImageView.image = UIImage()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupIU()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
