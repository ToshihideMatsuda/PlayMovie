//
//  ViewController.swift
//  PlayMovie
//
//  Created by 松田敏秀 on 2022/03/27.
//

import UIKit
import AVKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    private var player:AVPlayer?;
    private var table:UITableViewController?
    private let videoNames:[(title:String,ext:String)] = [
        ("もいもい_なーんだ", "mov"),
        ("もいもい", "mov"),
        ("シナぷしゅオープニング", "mov"),
        ("シナぷしゅ猫回", "mov"),
        ("シナぷしゅ_いないいないばぁ", "mov"),
        ("あべこべ", "mov"),
    ]
    
    private lazy var videoUrlList:[URL] = videoNames.compactMap {  Bundle.main.url(forResource: $0.title, withExtension: $0.ext) };

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tapSelectVideo(self)
    }
    
    @IBAction func tapSelectVideo(_ sender: Any) {
        self.table = UITableViewController();
        table?.tableView.delegate = self
        table?.tableView.dataSource = self
        table?.title = "動画選択"
        table?.modalPresentationStyle = .formSheet
        self.present(table!, animated: true, completion: nil)
    }
    
    fileprivate func showVideo(_ no : Int) {
        let playerViewController = AVPlayerViewController()
        self.player = AVPlayer(url: videoUrlList[no])
        playerViewController.player = self.player
        playerViewController.modalPresentationStyle = .overFullScreen
        self.present(playerViewController, animated: true, completion: { self.player?.play() })
        
    }
    
    @objc private func playerItemDidReachEnd(_ notification: Notification) {
        // 動画を最初に巻き戻す
        self.player?.currentItem?.seek(to: CMTime.zero, completionHandler: { _ in self.player?.play() })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var conf = cell.defaultContentConfiguration()
        conf.text = videoNames[indexPath.row].title
        cell.contentConfiguration = conf
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table?.dismiss(animated: true, completion: {
            self.showVideo(indexPath.row)
        })
    }
}

