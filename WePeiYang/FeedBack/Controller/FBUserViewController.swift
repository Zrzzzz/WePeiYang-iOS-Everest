//
//  FBUserViewController.swift
//  WePeiYang
//
//  Created by Zr埋 on 2020/9/29.
//  Copyright © 2020 twtstudio. All rights reserved.
//

import UIKit
import IGIdenticon

class FBUserViewController: UIViewController {
     
     var userImg: UIImageView! // 头像
     var detialLabel: UILabel! // 信息
     
     var stackView: UIStackView! // 信息列表
     private let cellID = "FBUSCVCell"
     var collectionView: UICollectionView!
     
     var myQBtn: UIButton! // 我发布的问题
     var myTQBtn: UIButton! // 我点赞过的问题
     
     var posted, thumbed, replied: Int!
     
     var detailViews: [UIStackView] = []
     var user: FBUserModel! {
          didSet {
               for i in stackView.arrangedSubviews {
                    stackView.removeArrangedSubview(i)
               }
               detailViews.append(getDetailView(title: "发布", num: user.myQuestionNum))
               detailViews.append(getDetailView(title: "点赞", num: user.myLikedQuestionNum))
               detailViews.append(getDetailView(title: "已回复", num: user.mySolvedQuestionNum))

               for i in detailViews {
                    stackView.addArrangedSubview(i)
               }
          }
     }
     
     
     override func viewDidLoad() {
          super.viewDidLoad()
          setUp()
          loadData()
     }
}

//MARK: - UI & Data
extension FBUserViewController {
     private func setUp() {
          view.backgroundColor = UIColor(hex6: 0xf6f6f6)
          navigationItem.title = "个人中心"
          
          userImg = UIImageView()
          view.addSubview(userImg)
          userImg.backgroundColor = .white
          let imageGenerator = Identicon()
          userImg.image = imageGenerator.icon(from: arc4random(), size: CGSize(width: 88, height: 88))
          userImg.addCornerRadius(44)
//          userImg.sd_setImage(with: URL(string: TwTUser.shared.avatarURL ?? "")!, completed: nil)
          userImg.snp.makeConstraints { (make) in
               make.centerX.equalTo(view)
               make.centerY.equalTo(SCREEN.height * 0.2)
               make.width.height.equalTo(88)
          }
          
          detialLabel = UILabel()
          view.addSubview(detialLabel)
          detialLabel.backgroundColor = UIColor(hex6: 0xf6f6f6)
          detialLabel.text = (TwTUser.shared.schoolID ?? "") + "  " + (TwTUser.shared.realname ?? "")
          detialLabel.snp.makeConstraints { (make) in
               make.centerX.equalTo(userImg)
               make.top.equalTo(userImg.snp.bottom).offset(5)
          }
          
          stackView = UIStackView()
          stackView.distribution = .fillEqually
          stackView.spacing = 1
          stackView.backgroundColor = .black
          stackView.addArrangedSubview(getDetailView(title: "发布", num: 0))
          stackView.addArrangedSubview(getDetailView(title: "点赞", num: 0))
          stackView.addArrangedSubview(getDetailView(title: "已回复", num: 0))
          stackView.addCornerRadius(15)
          view.addSubview(stackView)
          stackView.snp.makeConstraints { (make) in
               make.top.equalTo(detialLabel.snp.bottom).offset(10)
               make.centerX.equalTo(view)
               make.width.equalTo(SCREEN.width * 0.8)
               make.height.equalTo(80)
          }
          
          myQBtn = UIButton()
          view.addSubview(myQBtn)
          myQBtn.tag = 0
          myQBtn.backgroundColor = .white
          myQBtn.setTitle("我发布的问题", for: .normal)
          myQBtn.setTitleColor(.black, for: .normal)
          myQBtn.addTarget(self, action: #selector(loadData(btn:)), for: .touchUpInside)
          myQBtn.layer.cornerRadius = 15
          myQBtn.layer.masksToBounds = true
          myQBtn.snp.makeConstraints { (make) in
               make.centerX.equalTo(view)
               make.top.equalTo(stackView.snp.bottom).offset(30)
               make.width.equalTo(SCREEN.width * 0.7)
               make.height.equalTo(60)
          }
          
          myTQBtn = UIButton()
          view.addSubview(myTQBtn)
          myTQBtn.tag = 1
          myTQBtn.backgroundColor = .white
          myTQBtn.setTitle("我点赞的问题", for: .normal)
          myTQBtn.setTitleColor(.black, for: .normal)
          myTQBtn.addTarget(self, action: #selector(loadData(btn:)), for: .touchUpInside)
          myTQBtn.layer.cornerRadius = 15
          myTQBtn.layer.masksToBounds = true
          myTQBtn.snp.makeConstraints { (make) in
               make.centerX.equalTo(view)
               make.top.equalTo(myQBtn.snp.bottom).offset(10)
               make.width.equalTo(SCREEN.width * 0.7)
               make.height.equalTo(60)
          }
          
     }
//
//     override func viewWillLayoutSubviews() {
//          stackView.addShadow(.black, sRadius: 10, sOpacity: 1, offset: (0, 0))
//     }
     
     override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
          userImg.addShadow(.black, sRadius: 5, sOpacity: 0.2, offset: (0, 0))
//          stackView.addCornerRadius(15)
//          stackView.addShadow(.black, sRadius: 10, sOpacity: 1, offset: (0, 0))
          myQBtn.addShadow(.black, sRadius: 5, sOpacity: 0.2, offset: (0, 0))
          myTQBtn.addShadow(.black, sRadius: 5, sOpacity: 0.2, offset: (0, 0))
     }
     
     fileprivate func getDetailView(title: String, num: Int?) -> UIStackView {
          let titleLabel = UILabel()
          titleLabel.text = title
          
          let numLabel = UILabel()
          numLabel.text = num?.description
          
          let stackView = UIStackView()
          stackView.frame.size = CGSize(width: SCREEN.width / 5, height: 50)
          stackView.axis = .vertical
          stackView.alignment = .center
          stackView.backgroundColor = UIColor(hex6: arc4random())
          
          stackView.addArrangedSubview(titleLabel)
          stackView.addArrangedSubview(numLabel)
          
          NSLayoutConstraint.activate([
               titleLabel.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 20),
               numLabel.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: -20)
          ])
          return stackView
     }
     
     func loadData() {
          UserHelper.getDetail { (result) in
               switch result {
               case .success(let user):
                    self.user = user
                    self.detailViews.last?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.pushVC)))
//                    self.collectionView.reloadData()
               case .failure(let err):
                    print(err)
               }
          }
     }
     
     @objc fileprivate func pushVC() {
//          QuestionHelper.getQuestions(type: .solved) { (result) in
//               switch result {
//               case .success(let questions):
//                    let vc = FBReplyDetailTVController(replys: questions.filter{ $0.solved == 1 })
//                    navigationController?.pushViewController(vc, animated: true)
//               case .failure(let err):
//                    print(err)
//               }
//          }
     }
     
     @objc func loadData(btn: UIButton) {
          let qvc = FBQuestionTableViewController()
          qvc.title = btn.tag == 0 ? "我发布的问题" : "我点赞的问题"
          qvc.type = btn.tag == 0 ? .posted : .thumbed
          navigationController?.pushViewController(qvc, animated: true)
     }
}

