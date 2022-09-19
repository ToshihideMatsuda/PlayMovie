//
//  ViewController.swift
//  PlayMovie
//
//  Created by 松田敏秀 on 2022/03/27.
//

import UIKit
import AVKit

enum PlayMode {
    case select
    case random
}

class ViewController: UIViewController {
    
    
    @IBOutlet weak var prevGoButton: UIButton!
    @IBOutlet weak var nextGoButton: UIButton!
    @IBOutlet weak var repeateButton: UIButton!
    @IBOutlet weak var movieView: UIView!
    @IBOutlet weak var movieContainer: UIView!
    
    
    private var player:AVPlayer?;
    weak private var playerVc:AVPlayerViewController?
    fileprivate var table:UITableViewController?
    private var _selectManager:SelectVideoShowManager? = nil
    private var selectManager:SelectVideoShowManager? {
        get {
            if _selectManager == nil { _selectManager = SelectVideoShowManager(mainVc: self) }
            return _selectManager
        }
    }
    fileprivate var mode:PlayMode = .select
    fileprivate var playIndx:Int = 0 {
        didSet {
            if playIndx < 0 || videoUrlList.count <= playIndx {
                self.playIndx = (self.playIndx + videoUrlList.count) % videoUrlList.count
            } else if playIndx == 0 {
                self.videoUrlListRandom = videoUrlList.shuffled()
            }
        }
    }
    
    fileprivate let videoNames:[(title:String,ext:String)] = [
        ("もいもい_なーんだ", "mov"),
        ("もいもい", "mov"),
        ("タチウオバンザイ", "mov"),
        ("シナぷしゅオープニング", "mov"),
        ("シナぷしゅ_いないいないばぁ", "mov"),
        ("シナぷしゅ_幼児", "mov"),
        ("シナぷしゅ_幼児２", "mov"),
        ("シナぷしゅ_幼児エンディング", "mov"),
        ("シナぷしゅ_お侍", "mov"),
        ("シナぷしゅ猫回", "mov"),
        ("あべこべ", "mov"),
    ]
    
    private lazy var videoUrlList:[URL] = videoNames.compactMap {  Bundle.main.url(forResource: $0.title, withExtension: $0.ext) };
    private var videoUrlListRandom:[URL] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SceneDelegate.shared.mainVc = self
        
        tapRandomShow(self)
    }
    
    @IBAction func tapRepeate(_ sender: Any) {
        self.repeateButton.isSelected.toggle()
    }
    
    @IBAction func tapClose(_ sender: Any) {
        self.movieView.isHidden = true
        self.player?.pause()
        self.movieContainer.subviews.forEach{ $0.removeFromSuperview() }
        self.playerVc?.removeFromParent()
    }
    
    @IBAction func tapGoButton(_ sender: Any) {
        guard let btn = sender as? UIButton else { return }
        self.playIndx = self.playIndx + btn.tag
        showVideo();
    }
    
    @IBAction func tapRandomShow(_ sender: Any) {
        self.mode = .random
        self.playIndx = 0
        self.playerVc = nil
        showVideo();
    }
    
    @IBAction func tapSelectVideo(_ sender: Any) {
        self.mode = .select
        self.table = UITableViewController();
        self.playerVc = nil
        
        table?.tableView.delegate = self.selectManager
        table?.tableView.dataSource = self.selectManager
        table?.title = "動画選択"
        table?.modalPresentationStyle = .formSheet
        self.present(table!, animated: true, completion: nil)
    }
    
    fileprivate func showVideo(_ no : Int = -1, showPlayer:Bool = true) {
        guard let url = (mode == .select) ? videoUrlList[no] :
                        (mode == .random) ? videoUrlListRandom[self.playIndx] :
                        /* invalid mode */ nil else { return }
        
        self.player?.pause()
        self.player = AVPlayer(url: url)
        
        self.movieView.isHidden = false
        if mode == .select {
            self.nextGoButton.isHidden = true
            self.prevGoButton.isHidden = true
            self.repeateButton.isHidden = true
        } else if mode == .random {
            self.nextGoButton.isHidden = false
            self.prevGoButton.isHidden = false
            self.repeateButton.isHidden = false
        }
        
        if let playerVc = self.playerVc {
            playerVc.player = self.player
        } else {
            let playerVc = AVPlayerViewController()
            playerVc.player = self.player
            playerVc.modalPresentationStyle = .overFullScreen
            self.playerVc = playerVc
            self.addChild(playerVc)
            self.movieContainer.addSubview(playerVc.view)
        }
        self.player?.play()
    }
    
    @objc private func playerItemDidReachEnd(_ notification: Notification) {
        // 動画を最初に巻き戻す
        self.player?.currentItem?.seek(to: CMTime.zero, completionHandler: { _ in
            if self.mode == .select || self.repeateButton.isSelected {
                self.player?.play()
            } else if self.mode == .random {
                self.playIndx += 1;
                self.showVideo(showPlayer: false);
            }
        })
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

class SelectVideoShowManager: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    private let mainVc:ViewController
    
    init(mainVc:ViewController) {
        self.mainVc = mainVc;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mainVc.videoNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var conf = cell.defaultContentConfiguration()
        conf.text = self.mainVc.videoNames[indexPath.row].title
        cell.contentConfiguration = conf
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.mainVc.table?.dismiss(animated: true, completion: {
            self.mainVc.showVideo(indexPath.row)
        })
    }
    
}

