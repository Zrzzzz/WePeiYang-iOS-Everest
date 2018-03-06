//
//  TodayViewController.swift
//  WePeiYangWidget
//
//  Created by Halcao on 2018/2/16.
//  Copyright © 2018年 twtstudio. All rights reserved.
//

import UIKit
import NotificationCenter
import ObjectMapper

let ClassTableKey = "ClassTableKey"

class TodayViewController: UIViewController, NCWidgetProviding {
    var tableView: UITableView!
    var imgView: UIImageView!
    var hintLabel: UILabel!
    var messageLabel: UILabel!
    var dayLabel: UILabel!
    var activeDisplayMode = 0

    var classes: [ClassModel] = [] {
        willSet {
            if newValue.count == 0 {
                messageLabel.isHidden = false
            } else {
                messageLabel.isHidden = true
                nextClass = newValue.first(where: { model in
                    let arrange = model.arrange.first!
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm:ss"
                    let time = formatter.string(from: Date())
                    return time < arrange.startTime
                })
            }
        }
    }

    var nextClass: ClassModel?


    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOSApplicationExtension 10.0, *) {
            extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }

        let width = UIScreen.main.bounds.width
        dayLabel = UILabel(frame: CGRect(x: 70, y: 20, width: width - 70 - 20, height: 20))
        dayLabel.textAlignment = .center
        dayLabel.font = UIFont.preferredFont(forTextStyle: .body)
//        dayLabel.text = ""
        dayLabel.textColor = .gray
        self.view.addSubview(dayLabel)

        let tableViewHeight = 50 as CGFloat
        self.preferredContentSize = CGSize(width: width, height: tableViewHeight + 20)

        tableView = UITableView(frame: CGRect(x: 70, y: 50, width: width - 70, height: 50))
        tableView.rowHeight = tableViewHeight
        tableView.allowsSelection = false
        imgView = UIImageView(frame: CGRect(x: 20, y: 20, width: 40, height: 40))
        imgView.image = #imageLiteral(resourceName: "ic_wifi-1")
        // imgView.image = #imageLiteral(resourceName: "bicycleBtn")

        hintLabel = UILabel(frame: CGRect(x: 20, y: 65, width: 40, height: 15))
        hintLabel.textColor = .gray
        hintLabel.textAlignment = .center
        hintLabel.font = UIFont.systemFont(ofSize: 10)
        hintLabel.text = "请稍候"

        messageLabel = UILabel(frame: CGRect(x: 70, y: 50, width: width - 70, height: 50))
        messageLabel.font = UIFont.preferredFont(forTextStyle: .body)
        messageLabel.textAlignment = .center
        messageLabel.textColor = .gray
        messageLabel.text = "今天没有课，做点有趣的事情吧！"
        self.view.addSubview(messageLabel)
        messageLabel.isHidden = true

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none

        self.view.addSubview(tableView)
        self.view.addSubview(imgView)
        self.view.addSubview(hintLabel)
        layout()
    }

    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        switch activeDisplayMode {
        case .compact:
            tableView.frame.size.height = tableView.rowHeight + 20
            self.preferredContentSize.height = tableView.rowHeight + 20 + 20
        case .expanded:
            tableView.frame.size.height = CGFloat(classes.count) * tableView.rowHeight + 20
            self.preferredContentSize.height = CGFloat(classes.count) * tableView.rowHeight + 20 + 20 + 20
        }
        layout()
    }

    func layout() {

    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
//        if let dic = CacheManager.loadGroupCache(withKey: ClassTableKey) as? [String: Any], let table = Mapper<ClassTableModel>().map(JSON: dic) {
//            self.classes = table.classes.filter { model in
//                return model.arrange.count > 0
//            }
//            tableView.reloadData()
//            completionHandler(NCUpdateResult.newData)
//        }

        if let termStart = CacheManager.loadGroupCache(withKey: "TermStart") as? Date {
            let now = Date()
            let week = Int(now.timeIntervalSince(termStart)/(7.0*24*60*60) + 1)
            let cal = Calendar.current
            let weekday = DateTool.getChineseWeekDay()
            let formatter = NumberFormatter()
            formatter.locale = Locale(identifier: "zh_CN")
            formatter.numberStyle = .spellOut
            let comps = cal.dateComponents([.month, .day], from: now)

            dayLabel.text = weekday + " \(comps.month!)月\(comps.day!)日 " + "第\(week)周"
        }


        TwTUser.shared.load(success: {
            CacheManager.retreive("classtable/classtable.json", from: .group, as: String.self, success: { string in
                if let table = Mapper<ClassTableModel>().map(JSONString: string) {
                    self.classes = ClassTableHelper.getTodayCourse(table: table).filter { course in
                        return course.courseName != "" && course.arrange.count > 0
                    }
                    self.tableView.reloadData()
                    completionHandler(NCUpdateResult.newData)
                }
            }, failure: {
                completionHandler(NCUpdateResult.failed)
            })
        }, failure: {
            completionHandler(NCUpdateResult.failed)
        })
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
//        completionHandler(NCUpdateResult.newData)
//        completionHandler(NCUpdateResult.failed)
    }

    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return .zero
    }
}

extension TodayViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ClassWidgetCell(style: .default, reuseIdentifier: "ClassWidgetCell")
        let model = classes[indexPath.row]
        let arrange = model.arrange.first!
        cell.coursenameLabel.text = model.courseName
        cell.coursenameLabel.frame.size.width = UIScreen.main.bounds.width - 120
        let rangeText = "\(arrange.start)-\(arrange.end)节"
        var timeText = ""
//        if arrange.start <= timeArray.count && arrange.end <= timeArray.count {
//            let timeStart = timeArray[arrange.start-1].start
//            let timeEnd = timeArray[arrange.end-1].end
            timeText = arrange.startTime + "-" + arrange.endTime
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            let time = formatter.string(from: Date())
            if time >= arrange.startTime && time <= arrange.endTime {
                cell.coursenameLabel.text = model.courseName + " (当前课程)"
            }
//        }
        cell.infoLabel.text = rangeText + " " + timeText

        if arrange.room != "" && arrange.room != "无" {
            let text = cell.infoLabel.text!
            cell.infoLabel.text = text + " @" + arrange.room
        }
        cell.infoLabel.sizeToFit()
        
        return cell
    }
}

extension TodayViewController: UITableViewDelegate {

}
