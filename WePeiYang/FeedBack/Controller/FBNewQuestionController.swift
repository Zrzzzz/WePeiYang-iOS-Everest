//
//  FBNewQuestionViewController.swift
//  WePeiYang
//
//  Created by 于隆祎 on 2020/9/14.
//  Copyright © 2020 twtstudio. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire
import DynamicBlurView
import Lottie

class FBNewQuestionViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
     
     var titleField: UITextField!
     var confirmButton: UIButton!
     var contentField: UITextView!
     
     var titleLabel: UILabel!
     var classLabel: UILabel!
     var contentsLabel: UILabel!
     var photoLabel: UILabel!
     
     var images = [UIImage]() {
          didSet {
               photoCollectionView.reload(images)
          }
     }
     var imageViews = [UIImageView]()
     
     var photoCollectionView: FBPhotoCollectionView!
     var tagCollectionView: FBTagCollectionView?
     let collectionViewCellId = "feedBackCollectionViewCellID"
     
     // MARK: - Data
     var selectedTags = [TagModel]() {
          didSet {
               tagCollectionView?.tagSelectedCollectionView.reloadData()
          }
     }
     var willSelectedTags = [TagModel]() {
          didSet {
               tagCollectionView?.tagWillSeletedCollectionView.reloadData()
          }
     }
     
     override func viewDidLoad() {
          super.viewDidLoad()
          setUp()
          loadData()
     }
     
     override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
          confirmButton.addShadow(UIColor(hex6: 0x00a1e9), sRadius: 2, sOpacity: 0.2, offset: (3, 3))
     }
}

//MARK: - UI
extension FBNewQuestionViewController {
     func setUp() {
          view.backgroundColor = .white
          
          tagCollectionView = FBTagCollectionView(frame: .zero, itemSize: CGSize(width: 200, height: 25))
          view.addSubview(tagCollectionView!)
          tagCollectionView!.snp.makeConstraints { (make) in
               make.right.equalTo(-SCREEN.width / 15)
               make.width.equalTo(SCREEN.width * 0.7)
               make.top.equalTo(view).offset(20)
               make.height.equalTo(65)
          }
          
          classLabel = UILabel()
          view.addSubview(classLabel)
          classLabel.text = "分类: "
          classLabel.font = .systemFont(ofSize: 12)
          classLabel.snp.makeConstraints { (make) in
               make.centerY.equalTo(tagCollectionView!)
               make.left.equalTo(SCREEN.width / 12)
          }
          
          titleField = UITextField()
          titleField.placeholder = "20字以内"
          titleField.delegate = self
          titleField.borderStyle = .roundedRect
          titleField.returnKeyType = .done
          titleField.font = .systemFont(ofSize: 14)
//          titleField.max
          // adding padding
          titleField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 30))
          titleField.leftViewMode = .always
          
          view.addSubview(titleField)
          titleField.snp.makeConstraints{ (make) in
               make.right.equalTo(-SCREEN.width / 15)
               make.height.equalTo(30)
               make.width.equalTo(SCREEN.width * 0.7)
               make.top.equalTo(tagCollectionView!.snp.bottom).offset(20)
          }
          
          titleLabel = UILabel()
          titleLabel.text = "标题: "
          titleLabel.font = .systemFont(ofSize: 12)
          view.addSubview(titleLabel)
          titleLabel.snp.makeConstraints { (make) in
               make.centerY.equalTo(titleField)
               make.left.equalTo(classLabel)
          }
          
          contentField = UITextView()
          contentField.layer.borderWidth = 1
          contentField.layer.cornerRadius = 5
          contentField.layer.masksToBounds = true
          contentField.delegate = self
          contentField.text = "不超过200字"
          contentField.textColor = UIColor(hex6: 0xd3d3d3)
          contentField.layer.borderColor = UIColor(hex6: 0xf4f4f4).cgColor
          contentField.textContainerInset = UIEdgeInsets(top: 5, left: 7, bottom: 5, right: 5)
          contentField.font = .systemFont(ofSize: 14)
          view.addSubview(contentField)
          contentField.snp.makeConstraints{ (make) in
               make.top.equalTo(titleField.snp.bottom).offset(20)
               make.height.equalTo(100)
               make.width.equalTo(SCREEN.width * 0.7)
               make.right.equalTo(-SCREEN.width / 15)
          }
          
          contentsLabel = UILabel()
          contentsLabel.text = "正文: "
          contentsLabel.textColor = UIColor.black
          contentsLabel.font = .systemFont(ofSize: 12)
          view.addSubview(contentsLabel)
          contentsLabel.snp.makeConstraints { (make) in
               make.top.equalTo(contentField.snp.top).offset(5)
               make.left.equalTo(classLabel)
          }
          
          let photoW = SCREEN.width * 0.7 / 3
          photoCollectionView = FBPhotoCollectionView(size: CGSize(width: photoW, height: photoW))
          view.addSubview(photoCollectionView)
          photoCollectionView.snp.makeConstraints { (make) in
               make.width.equalTo(SCREEN.width * 0.7 + 1)
               make.top.equalTo(contentField.snp.bottom).offset(20)
               make.height.equalTo(photoW)
               make.right.equalTo(-SCREEN.width / 15)
          }
          
          photoLabel = UILabel()
          photoLabel.text = "图片: "
          photoLabel.textColor = UIColor.black
          photoLabel.font = .systemFont(ofSize: 12)
          view.addSubview(photoLabel)
          photoLabel.snp.makeConstraints { (make) in
               make.top.equalTo(photoCollectionView.snp.top).offset(5)
               make.left.equalTo(classLabel)
          }
          
          
          confirmButton = UIButton()
          confirmButton.backgroundColor = UIColor(hex6: 0x00a1e9)
          confirmButton.addTarget(self, action: #selector(postQues), for: .touchUpInside)
          confirmButton.setTitle("确认提交", for: .normal)
          confirmButton.layer.cornerRadius = 15
          confirmButton.layer.masksToBounds = true
          view.addSubview(confirmButton)
          confirmButton.snp.makeConstraints { (make) in
               make.centerX.equalTo(view.bounds.width/2)
               make.top.equalTo(photoCollectionView.snp.bottom).offset(50)
               make.height.equalTo(50)
               make.width.equalTo(150)
          }
     }
}

//MARK: - Data
extension FBNewQuestionViewController {
     private func loadData() {
          tagCollectionView?.tagSelectedCollectionView.reloadData()
          tagCollectionView?.tagWillSeletedCollectionView.reloadData()
          self.tagCollectionView?.addDelegate(delegate: self, dataSource: self)
     }
     
     @objc func postQues() {
          if let title = titleField.text, let content = contentField.text {
               guard title != "" && content != "" else {
                    let alert = UIAlertController(title: "提示", message: "请填写完整信息", preferredStyle: .alert)
                    let action1 = UIAlertAction(title: "好的", style: .cancel, handler: nil)
                    alert.addAction(action1)
                    self.present(alert, animated: true)
                    return
               }
               guard selectedTags.count >= 3 || selectedTags[1].name == "其他" else {
                    let alert = UIAlertController(title: "提示", message: "请在“分类”中至少选择三个标签。如不确定问题归属，请选择“其他”。", preferredStyle: .alert)
                    let action1 = UIAlertAction(title: "好的", style: .cancel, handler: nil)
                    alert.addAction(action1)
                    self.present(alert, animated: true)
                    return
               }
               
               let blurView = DynamicBlurView(frame: SCREEN)
               blurView.blurRadius = 10
               UIView.transition(with: self.view, duration: 0.2, options: [.transitionCrossDissolve]) {
                    self.view.addSubview(blurView)
               }

               let animationView = AnimationView(name: "feedback_add_question_load_animation")
               animationView.frame.size = CGSize(width: SCREEN.width / 3, height: SCREEN.width / 3)
               animationView.center = blurView.center
               animationView.loopMode = .repeat(10)
               blurView.addSubview(animationView)
               animationView.play()
               
               QuestionHelper.postQuestion(title: title, content: content, tagList: selectedTags.map{ $0.id ?? 0 }.filter{ $0 != 0 }) { (result) in
                    switch result {
                    case .success(let questionId):
                         if let imgs = self.photoCollectionView.images {
                              guard imgs.count != 1 else {
                                   self.dismiss(animated: true)
                                   return
                              }
                              let cnt = imgs.count
                              
                              let group = DispatchGroup()
                              
                              for i in 0..<cnt - 1 {
                                   group.enter()
                                   QuestionHelper.postImg(img: imgs[i], question_id: questionId) { (result) in
                                        switch result {
                                        case .success(let str):
                                             print(str)
                                             group.leave()
                                        case .failure(let err):
                                             print(err)
                                             group.leave()
                                        }
                                   }
                              }
                              group.notify(queue: .main) {
                                   animationView.stop()
                                   self.dismiss(animated: true)
                              }
                         }
                    case .failure(let err):
                         print(err)
                    }
               }
          }
     }
}

//MARK: - Delegate
extension FBNewQuestionViewController {
     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
          self.view.endEditing(true)
     }
     
     override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
          self.view.endEditing(true)
     }
     
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          view.endEditing(true)
     }
     
     func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
          let maxLength = 20
          let currentString: NSString = textField.text! as NSString
          let newString: NSString =
               currentString.replacingCharacters(in: range, with: string) as NSString
          return newString.length <= maxLength
     }
     
     func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
          let maxLength = 200
          let currentString: NSString = textView.text! as NSString
          let newString: NSString =
               currentString.replacingCharacters(in: range, with: text) as NSString
          return newString.length <= maxLength
     }
     
     func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
          if textView.text == "不超过200字" {
               textView.text = ""
               textView.textColor = .black
          }
          return true
     }
     
     func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
          if textView.text == "" {
               textView.text = "不超过200字"
               textView.textColor = UIColor(hex6: 0xdbdbdb)
          }
          return true
     }
}


extension FBNewQuestionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
          return collectionView.tag == 0 ? selectedTags.count : willSelectedTags.count
     }
     
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewCellId, for: indexPath) as! FBTagCollectionViewCell
          cell.update(by: collectionView.tag == 0 ? selectedTags[indexPath.row] : willSelectedTags[indexPath.row], selected: collectionView.tag == 0)
          return cell
     }
     
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
          if collectionView.tag == 0 {
               willSelectedTags = selectedTags[indexPath.row].children ?? []
               selectedTags = Array(selectedTags[0...indexPath.row])
          } else {
               selectedTags.append(willSelectedTags[indexPath.row])
               willSelectedTags = selectedTags.last!.children ?? []
          }
     }
}
