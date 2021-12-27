//
//  PlaybackPresenter.swift
//  spotify
//
//  Created by Bryan on 2021/12/7.
//

import Foundation
import UIKit
import AVFoundation

protocol PlayerDataSource :AnyObject{
    var songName: String?{get }
    var subtiltle:String?{get }
    var imageURL:URL?{get }
    
}


final class PlaybackPresenter {
    
    static let shared = PlaybackPresenter()
    private var track :AudioTrack?
    private var tracks = [AudioTrack]()
    
    var index = 0
    
    var items  = [AVPlayerItem]()
    

    
    var currentTrack :AudioTrack?{
        if let track = track, tracks.isEmpty{
            return track
        }else if let player = self.playerQueue, !tracks.isEmpty{
//
            if index == items.count {
                index = 0
            }
            return tracks[index]
        }
        return nil
    }
    
    var playerVC : PlayerViewController?
    var player : AVPlayer?
    var playerQueue :AVQueuePlayer?
    
    func startPlayback (form controller:UIViewController, track :AudioTrack){
        if playerQueue != nil {
            playerQueue = nil
        }
        guard let url = URL(string: track.preview_url ?? "") else {
            let alert = UIAlertController(title: "Can not play", message: "No music for preview", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            controller.present(alert, animated: true, completion: nil)
            return}
        player = AVPlayer(url: url)
        player?.volume = 0.1
        let vc = PlayerViewController()
        vc.title = track.name
        vc.dataSource = self
        vc.delegate = self
        self.track = track
        self.tracks = []
//        print(track)
        controller.present(UINavigationController(rootViewController: vc), animated: true) {
            [weak self]  in
            self?.player?.play()
        }
        self.playerVC = vc
    }
    
    func startPlayback (form controller:UIViewController, tracks :[AudioTrack]){
        if player != nil{
            player = nil
        }
        self.tracks = tracks
        self.track = nil
        DispatchQueue.global().async {
            let items : [AVPlayerItem] = tracks.compactMap({
                guard let url = URL(string: $0.preview_url ?? "") else {return nil}

                return AVPlayerItem(url: url)
            })
            self.items = items
     
        }

        DispatchQueue.main.async {

            self.playerQueue = AVQueuePlayer(items: self.items)
            self.playerQueue?.play()
            let vc = PlayerViewController()
            vc.dataSource = self
            vc.delegate = self
            controller.present(vc, animated: true, completion: nil)
            self.playerVC = vc
        }
    }
    
}


extension PlaybackPresenter : PlayerDataSource{

    var songName: String?  {
        return currentTrack?.name
    }
    
    var subtiltle: String? {
        return currentTrack?.artists.first?.name
    }
    
    var imageURL: URL? {
        return URL(string: currentTrack?.album?.images.first?.url ?? "")
    }
    
    
}

extension PlaybackPresenter:  PlayerViewControllerDelegate{

    func didTapPlayPause() {
        if let player = player{
           if  player.timeControlStatus == .playing{
                player.pause()
           }else if player.timeControlStatus == .paused{
               player.play()
           }
        }else if let player = playerQueue{
            if player.timeControlStatus == .playing{
                player.pause()
            }else if player.timeControlStatus == .paused{
                player.play()
            }
        }
    }
    
    func didTapForward() {
        if tracks.isEmpty{
            player?.pause()
        }else if let  player = playerQueue {
            player.advanceToNextItem()
            index = index + 1
            print(index)
            playerVC?.refreshUI()
        }
    }
    
    func didTapBackward() {
        if tracks.isEmpty{
            player?.pause()
            player?.play()
        }else if let firstItem = playerQueue?.items().first{
//            playerQueue?.pause()
//            playerQueue?.removeAllItems()
//            playerQueue = AVQueuePlayer(items: [firstItem])
//            playerQueue?.play()
//            playerQueue?.volume = 0
            
            if index != 0{
                index -= 1
                print(index)
                playerQueue?.replaceCurrentItem(with: items[index])
                playerVC?.refreshUI()
            }else {
                print("00")
                playerQueue?.replaceCurrentItem(with: items[0])
                
            }

            
            
        }
    }
    
    func didSlideSlider(_ value: Float) {
        
        if let player = player {
            player.volume = value
        }
        
        if let player = playerQueue {
            player.volume = value
        }
    
    }
    
    
    
}
