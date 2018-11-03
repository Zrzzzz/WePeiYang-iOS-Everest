//
//  PracticeHistoryViewController.swift
//  WePeiYang
//
//  Created by JasonEWNL on 2018/9/11.
//  Copyright © 2018年 twtstudio. All rights reserved.
//

import UIKit
import MJRefresh

// MARK: UIViewController
class PracticeHistoryViewController: UIViewController {
    
    /* 历史模型 */
    var practiceHistory: PracticeHistoryModel!
    
    /* 历史列表视图 */
    let practiceHistoryTableView = UITableView(frame: CGRect(), style: .grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        practiceHistoryTableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            self.reloadDataAndView()
            self.practiceHistoryTableView.mj_header.endRefreshing()
        })
        
        // 加载数据与视图 //
        self.reloadDataAndView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /* 导航栏 */
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.setBackgroundImage(UIImage(color: .practiceBlue), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
        
        /* 刷新 */
        let practiceRefresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshDataAndView))
        navigationItem.rightBarButtonItem = practiceRefresh
        
        /* 历史列表视图 */
        practiceHistoryTableView.frame = self.view.bounds
        practiceHistoryTableView.backgroundColor = .clear
        practiceHistoryTableView.delegate = self
        practiceHistoryTableView.dataSource = self
        self.view.addSubview(practiceHistoryTableView)
    }
    
    // 加载标题 //
    func reloadTitleView() {
        let titleLabel = UILabel(text: "我的历史", color: .white)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 21)
        
        // 错题不为零时显示错题数
        if practiceHistory.data.count != 0 { titleLabel.text = "我的历史 (\(practiceHistory.data.count))" }
        
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
    }
    
    // 加载数据与视图 //
    func reloadDataAndView() {
        PracticeHistoryHelper.getHistory(success: { practiceHistory in
            self.practiceHistory = practiceHistory
            self.reloadTitleView()
            self.practiceHistoryTableView.reloadData()
        }) { _ in
        }
    }
    
    // 刷新数据与视图 //
    @objc func refreshDataAndView() {
        navigationItem.rightBarButtonItem?.isEnabled = false
        practiceHistoryTableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            self.reloadDataAndView()
            self.practiceHistoryTableView.mj_header.endRefreshing()
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        })
        practiceHistoryTableView.mj_header.beginRefreshing()
    }
    
}

// MARK: - UITableView
/* 表单视图数据 */
extension PracticeHistoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if practiceHistory == nil { return 0 }
        return practiceHistory.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if practiceHistory == nil { return UITableViewCell() }
        
        let historyViewCell = HistoryViewCell(byModel: practiceHistory, withIndex: indexPath.row)
        
        historyViewCell.selectionStyle = .none
        
        return historyViewCell
    }
    
}

/* 表单视图代理 */
extension PracticeHistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HistoryViewCell(byModel: practiceHistory, withIndex: indexPath.row).cellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: 进入练习历史
        let historyData = practiceHistory.data[indexPath.row]
        // PracticeFigure.practiceType = historyData.type
        PracticeFigure.classID = historyData.classID
        PracticeFigure.courseID = historyData.courseID
        switch historyData.type {
        case "0":
            PracticeFigure.questionType = historyData.quesType!
            PracticeFigure.currentCourseIndex = historyData.doneIndex
            self.navigationController?.pushViewController(ExerciseCollectionViewController(), animated: true)
        case "1":
            self.navigationController?.pushViewController(QuizCollectionViewController(), animated: true)
        default:
            return
        }
        // 就很辣的动画
        // tableView.cellForRow(at: indexPath)?.contentView.setBounceAnimation()
        // for view in (tableView.cellForRow(at: indexPath)?.contentView.subviews)! {
        //     view.setBounceAnimation()
        // }
    }
    
}