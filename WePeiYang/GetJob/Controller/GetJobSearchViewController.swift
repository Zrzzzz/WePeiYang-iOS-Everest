//
//  GetJobSearchViewController.swift
//  WePeiYang
//
//  Created by 王春杉 on 2019/2/12.
//  Copyright © 2019 twtstudio. All rights reserved.
//  ok

import UIKit
import Alamofire
import MJRefresh

struct SearchHistory {
    static var userDefaults = UserDefaults.standard
    static var historyData: [String]?
}
class GetJobSearchViewController: UIViewController {

    let searchResultNum: Int = 14
    var serchHistoryTableView: UITableView!
    var searchResultTableView: UITableView!
    var didSearch: Bool! = false
    var firstSearch: Bool = false
    var resultInfo: RecruitInfo! = RecruitInfo()
    lazy var searchBar: UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 320, height: 20))
    lazy var noResultImageView = UIImageView()
    lazy var noResultLable = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        self.didSearch = false
        self.firstSearch = false
        setUserDefaults()
        setSerchHistoryTableView()
        setSearchBar()
    }

    //    override func viewDidAppear(_ animated: Bool) {
    //        self.didSearch = false
    //    }

    func setUserDefaults() {
        SearchHistory.historyData = SearchHistory.userDefaults.array(forKey: "GetJobSearchHistory") as? [String]
        if SearchHistory.historyData != nil {
            let count = SearchHistory.historyData!.count
            var j = 0
            for i in 0..<count {
                if SearchHistory.historyData![j] == "" {
                    SearchHistory.historyData?.remove(at: j)
                }else {
                    j += 1
                }
            }
        }
    }

    // MARK: - 设置搜索历史的TableView
    func setSerchHistoryTableView() {
        var searchHistoryTableViewHeight: CGFloat = 0
        if SearchHistory.historyData == nil || SearchHistory.historyData?.count == 0{
            searchHistoryTableViewHeight = 0
        }else {
            searchHistoryTableViewHeight = CGFloat((SearchHistory.historyData!.count+1)*55)
        }
        let serchHistoryTableViewFrame = CGRect(x: 0, y: 60, width: self.view.frame.width, height: searchHistoryTableViewHeight)
        self.serchHistoryTableView = UITableView(frame: serchHistoryTableViewFrame, style: .plain)
        serchHistoryTableView.delegate = self
        serchHistoryTableView.dataSource = self
        self.view.addSubview(serchHistoryTableView)


    }
    // MARK: - 设置搜索栏
    func setSearchBar() {
        let lefNavBarBtn = UIBarButtonItem(customView: searchBar)
        self.navigationItem.rightBarButtonItem = lefNavBarBtn
        searchBar.placeholder = "请输入关键字"
        searchBar.enablesReturnKeyAutomatically = true
        searchBar.tintColor = .black
        self.searchBar.delegate = self
    }
    // MARK: - 设置搜索结果的 TableView
    func setSearchResultTableView() {
        if firstSearch == false {
            searchResultTableView = UITableView(frame: view.bounds, style: .plain)
            searchResultTableView.separatorStyle = .none  // 去掉系统分割线
            view.addSubview(searchResultTableView)
            searchResultTableView.delegate = self
            searchResultTableView.dataSource = self
            self.firstSearch = true
        }else {
            searchResultTableView.reloadData()
        }
    }
}
extension GetJobSearchViewController: UITableViewDelegate, UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if didSearch == false {
            if SearchHistory.historyData == nil || SearchHistory.historyData?.count == 0 {
                return 0
            }else {
                return SearchHistory.historyData!.count+1
            }
        }else {
            return searchResultNum
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if didSearch == false {
            return SerchHistoryTableViewCell(historyData: SearchHistory.historyData!.reversed(), indexPath: indexPath, tableView: tableView)
        }else {
            if indexPath.row < 7 {
                return RecruitmentInfoTableViewCell(recruitmentInfo: resultInfo, index: indexPath.row, isSearch: true)
            }else {
                return JobFairTableViewCell(recruitmentInfo: resultInfo, index: indexPath.row, isSearch: true)
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if didSearch == true {
            if indexPath.row < 7 {
                return 130
            }else {
                return 210
            }
        }else {
            return 44
        }

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if didSearch == true {
            if indexPath.row < 7 {
                didSelectCell.id = resultInfo.imporant[indexPath.row].id
                self.navigationController?.pushViewController(RecruitmentInfoDetailController(), animated: true)
            }else {
                didSelectCell.id = resultInfo.commons[indexPath.row-7].id
                self.navigationController?.pushViewController(JobFireDetaileController(), animated: true)
            }
        }else {
            let historyCount = SearchHistory.historyData!.count
            let historySelected: String = SearchHistory.historyData![historyCount-1-indexPath.row]
            self.searchBar.text = historySelected
        }

    }
}
extension GetJobSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchBarText = searchBar.text {
            if SearchHistory.historyData == nil {
                SearchHistory.historyData = [searchBarText]
            }else {
                SearchHistory.historyData?.append(searchBarText)
            }
            searchBar.resignFirstResponder()
            SearchHistory.userDefaults.set(SearchHistory.historyData, forKey: "GetJobSearchHistory")
            SearchHistory.userDefaults.synchronize()
            // 搜索后对 searchResultTableView 的操作
            self.serchHistoryTableView.isHidden = true
            self.didSearch = true
            // 使用Alamofire 加载 DetailMusic
            let searchUrl = "http://job.api.twtstudio.com/api/recruit/search?title=\(searchBar.text!)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            SearchUrl.url = searchUrl!
            self.resultInfo = RecruitInfo()
            SearchResultHelper.getSearchResult(success: { searchResult in
                if (searchResult.data?.info?.count)! <= 6 || (searchResult.data?.meeting?.count)! <= 6 {
                    if self.searchResultTableView != nil {
                        self.searchResultTableView.isHidden = true
                    }
                    if self.noResultImageView != nil {
                        self.noResultImageView.isHidden = false
                        self.noResultLable.isHidden = false
                    }
                    self.noResultImageView.image = UIImage(named: "搜索无结果")
                    self.noResultImageView.frame = CGRect(x: (Device.width - 200)/2, y: 200, width: 200, height: 200)
                    self.view.addSubview(self.noResultImageView)
                    
                    self.noResultLable.frame = CGRect(center: CGPoint(x: self.noResultImageView.center.x, y: self.noResultImageView.y+self.noResultImageView.height+20), size: CGSize(width: 300, height: 30))
                    self.noResultLable.textAlignment = .center
                    self.noResultLable.textColor = UIColor(hex6: 0x48b28a)
                    self.noResultLable.text = "没有找到关于 ”\(searchBar.text!)“ 的就业信息"
                    self.view.addSubview(self.noResultLable)
                }else {
                    if self.searchResultTableView != nil {
                        self.searchResultTableView.isHidden = false
                    }
                    if self.noResultImageView != nil {
                        self.noResultImageView.isHidden = true
                        self.noResultLable.isHidden = true
                    }
                    for i in 0..<7 {
                        self.resultInfo.imporant.append(Imporant())
                        self.resultInfo.imporant[i].id = (searchResult.data?.info![i].id)!
                        self.resultInfo.imporant[i].date = (searchResult.data?.info![i].date)!
                        self.resultInfo.imporant[i].title = (searchResult.data?.info![i].title)!
                        self.resultInfo.imporant[i].click = (searchResult.data?.info![i].click)!
                    }
                    for i in 0..<7 {
                        self.resultInfo.commons.append(Commons())
                        self.resultInfo.commons[i].id = (searchResult.data?.meeting![i].id)!
                        self.resultInfo.commons[i].date = (searchResult.data?.meeting![i].date)!
                        self.resultInfo.commons[i].title = (searchResult.data?.meeting![i].title)!
                        self.resultInfo.commons[i].click = (searchResult.data?.meeting![i].click)!
                        self.resultInfo.commons[i].place = (searchResult.data?.meeting![i].place)!
                        self.resultInfo.commons[i].heldDate = (searchResult.data?.meeting![i].heldDate)!
                        self.resultInfo.commons[i].heldTime = (searchResult.data?.meeting![i].heldTime)!
                    }
                    self.setSearchResultTableView()
                    
                }
                
            }) { _ in
                
            }
            

        }

    }
}
