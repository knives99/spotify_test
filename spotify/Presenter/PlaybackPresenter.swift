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
    

    
    var currentTrack :AudioTrack?{
        if let track = track, tracks.isEmpty{
            return track
        }else if let player = self.playerQueue, !tracks.isEmpty{
            let item = player.currentItem
            let items = player.items()
            guard let index = items.firstIndex(where: {$0 == item}) else {return nil}
            return tracks[index]
        }
        return nil
    }
    
    var player : AVPlayer?
    var playerQueue :AVQueuePlayer?
    
    func startPlayback (form controller:UIViewController, track :AudioTrack){
        guard let url = URL(string: track.preview_url ?? "") else {return}
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
    }
    
    func startPlayback (form controller:UIViewController, tracks :[AudioTrack]){
        let vc = PlayerViewController()
        let items : [AVPlayerItem] = tracks.compactMap({
            guard let url = URL(string: $0.preview_url ?? "") else {return nil}
            return AVPlayerItem(url: url)
        })
        self.playerQueue = AVQueuePlayer(items: items)
        self.playerQueue?.volume = 0
        self.playerQueue?.play()
        self.tracks = tracks
        self.track = nil
        vc.dataSource = self
        vc.delegate = self
        controller.present(vc, animated: true, completion: nil)
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
        }else if let firstItem = playerQueue?.items().first{
            playerQueue?.pause()
            playerQueue?.removeAllItems()
            playerQueue = AVQueuePlayer(items: [firstItem])
            playerQueue?.play()
            playerQueue?.volume = 0
        }
    }
    
    func didTapBackward() {
        if tracks.isEmpty{
            player?.pause()
            player?.play()
        }else if let player = playerQueue{
            player.advanceToNextItem()
            
        }
    }
    
    func didSlideSlider(_ value: Float) {
        player?.volume = value
    }
    
    
    
}
