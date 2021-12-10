//
//  ActionLabelView.swift
//  spotify
//
//  Created by Bryan on 2021/12/9.
//

import UIKit

struct ActionLabelViewModel {
    let text :String
    let actionTitle:String
}

protocol ActionLabelViewDelegate:AnyObject{
    func ActionLabelViewDidTapButton(_ actionView:ActionLabelView)
}

class ActionLabelView: UIView {
    
    weak var delegate:ActionLabelViewDelegate?
    
    private let label :UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let button : UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.link, for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemBackground
        addSubview(label)
        addSubview(button)
        isHidden = true
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    @objc private func didTapButton(){
        delegate?.ActionLabelViewDidTapButton(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        button.frame = CGRect(x: 0, y: height - 40, width: width, height: 40)
        label.frame = CGRect(x: 0, y: 0, width: width, height: height - 45)
    }

    func configure(with viewModel:ActionLabelViewModel){
        label.text = viewModel.text
        button.setTitle(viewModel.actionTitle, for: .normal)
    }
    
    
}
