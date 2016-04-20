//
//  PlayerViewController.swift
//  Play
//
//  Created by Gene Yoo on 11/26/15.
//  Copyright © 2015 cs198-1. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    var tracks: [Track]!
    var scAPI: SoundCloudAPI!
    
    var currentIndex: Int!
    var player: AVPlayer!
    var trackImageView: UIImageView!
    
    var playPauseButton: UIButton!
    var nextButton: UIButton!
    var previousButton: UIButton!
    
    var artistLabel: UILabel!
    var titleLabel: UILabel!
    
    var scrubber: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = UIView(frame: UIScreen.mainScreen().bounds)
        view.backgroundColor = UIColor.whiteColor()

        scAPI = SoundCloudAPI()
        scAPI.loadTracks(didLoadTracks)
        currentIndex = 0
        
        player = AVPlayer()
        
        loadVisualElements()
        loadPlayerButtons()
    }
    
    func loadVisualElements() {
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        let offset = height - width
        
    
        trackImageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0,
            width: width, height: width))
        trackImageView.contentMode = UIViewContentMode.ScaleAspectFill
        trackImageView.clipsToBounds = true
        view.addSubview(trackImageView)
        
        titleLabel = UILabel(frame: CGRect(x: 0.0, y: width + offset * 0.15,
            width: width, height: 20.0))
        titleLabel.textAlignment = NSTextAlignment.Center
        view.addSubview(titleLabel)

        artistLabel = UILabel(frame: CGRect(x: 0.0, y: width + offset * 0.25,
            width: width, height: 20.0))
        artistLabel.textAlignment = NSTextAlignment.Center
        artistLabel.textColor = UIColor.grayColor()
        view.addSubview(artistLabel)
        
        scrubber = UISlider(frame: CGRect(x: 0.0, y: width + offset * 0.75, width: width, height: 20.0))
        scrubber.addTarget(self, action: #selector(PlayerViewController.sliderValueDidChange(_:)), forControlEvents: .ValueChanged)
        scrubber.tintColor = UIColor.blueColor()
        view.addSubview(scrubber)
    }
    
    func sliderValueDidChange(sender:UISlider!) {
        player.seekToTime(CMTimeMake(Int64(scrubber.value), 1))
        if player.rate == 1.0 {
            if player.currentItem!.status == .ReadyToPlay {
                player.play()
            }
        }
    }
    
    func timerAction() {
        scrubber.value = Float(CMTimeGetSeconds(player.currentTime()))
    }
    
    func loadPlayerButtons() {
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        let offset = height - width
    
        let playImage = UIImage(named: "play")?.imageWithRenderingMode(.AlwaysTemplate)
        let pauseImage = UIImage(named: "pause")?.imageWithRenderingMode(.AlwaysTemplate)
        let nextImage = UIImage(named: "next")?.imageWithRenderingMode(.AlwaysTemplate)
        let previousImage = UIImage(named: "previous")?.imageWithRenderingMode(.AlwaysTemplate)
        
        playPauseButton = UIButton(type: UIButtonType.Custom)
        playPauseButton.frame = CGRectMake(width / 2.0 - width / 30.0,
                                           width + offset * 0.5,
                                           width / 15.0,
                                           width / 15.0)
        playPauseButton.setImage(playImage, forState: UIControlState.Normal)
        playPauseButton.setImage(pauseImage, forState: UIControlState.Selected)
        playPauseButton.addTarget(self, action: #selector(PlayerViewController.playOrPauseTrack(_:)),
            forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(playPauseButton)
        
        previousButton = UIButton(type: UIButtonType.Custom)
        previousButton.frame = CGRectMake(width / 2.0 - width / 30.0 - width / 5.0,
                                          width + offset * 0.5,
                                          width / 15.0,
                                          width / 15.0)
        previousButton.setImage(previousImage, forState: UIControlState.Normal)
        previousButton.addTarget(self, action: #selector(PlayerViewController.previousTrackTapped(_:)),
            forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(previousButton)

        nextButton = UIButton(type: UIButtonType.Custom)
        nextButton.frame = CGRectMake(width / 2.0 - width / 30.0 + width / 5.0,
                                      width + offset * 0.5,
                                      width / 15.0,
                                      width / 15.0)
        nextButton.setImage(nextImage, forState: UIControlState.Normal)
        nextButton.addTarget(self, action: #selector(PlayerViewController.nextTrackTapped(_:)),
            forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(nextButton)

    }

    
    func loadTrackElements() {
        let track = tracks[currentIndex]
        asyncLoadTrackImage(track)
        titleLabel.text = track.title
        artistLabel.text = track.artist
    }
    
    /* 
     *  This Method should play or pause the song, depending on the song's state
     *  It should also toggle between the play and pause images by toggling
     *  sender.selected
     * 
     *  If you are playing the song for the first time, you should be creating 
     *  an AVPlayerItem from a url and updating the player's currentitem 
     *  property accordingly.
     */
    func playOrPauseTrack(sender: UIButton) {
        let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist")
        let clientID = NSDictionary(contentsOfFile: path!)?.valueForKey("client_id") as! String
        let track = tracks[currentIndex]
        let url = NSURL(string: "https://api.soundcloud.com/tracks/\(track.id)/stream?client_id=\(clientID)")!
        // FILL ME IN
        if player.status == .Unknown {
            let song = AVPlayerItem(URL: url)
            player = AVPlayer(playerItem: song)
        }
        scrubber.maximumValue = Float(CMTimeGetSeconds(player.currentItem!.asset.duration))
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        if player.rate == 0.0 {
            if player.currentItem!.status == .ReadyToPlay {
                player.play()
                sender.selected = !sender.selected
            }
        } else if player.rate == 1.0 {
            player.pause()
            sender.selected = !sender.selected
        }
    }
    
    /* 
     * Called when the next button is tapped. It should check if there is a next
     * track, and if so it will load the next track's data and
     * automatically play the song if a song is already playing
     * Remember to update the currentIndex
     */
    func nextTrackTapped(sender: UIButton) {
        let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist")
        let clientID = NSDictionary(contentsOfFile: path!)?.valueForKey("client_id") as! String
        if currentIndex < tracks.count - 1 {
            scrubber.value = 0.0
            currentIndex = currentIndex + 1
            let track = tracks[currentIndex]
            let url = NSURL(string: "https://api.soundcloud.com/tracks/\(track.id)/stream?client_id=\(clientID)")!
            let song = AVPlayerItem(URL: url)
            player.replaceCurrentItemWithPlayerItem(song)
            if player.rate == 1.0 {
                if player.currentItem!.status == .ReadyToPlay {
                    player.play()
                }
            }
            loadTrackElements()
            scrubber.maximumValue = Float(CMTimeGetSeconds(player.currentItem!.asset.duration))
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }
    }

    /*
     * Called when the previous button is tapped. It should behave in 2 possible
     * ways:
     *    a) If a song is more than 3 seconds in, seek to the beginning (time 0)
     *    b) Otherwise, check if there is a previous track, and if so it will 
     *       load the previous track's data and automatically play the song if
     *      a song is already playing
     *  Remember to update the currentIndex if necessary
     */

    func previousTrackTapped(sender: UIButton) {
        let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist")
        let clientID = NSDictionary(contentsOfFile: path!)?.valueForKey("client_id") as! String
        if CMTimeGetSeconds(player.currentTime()) > 3.0 {
            player.seekToTime(CMTimeMakeWithSeconds(0.0, 1))
        } else {
            if currentIndex > 0 {
                currentIndex = currentIndex - 1
                let track = tracks[currentIndex]
                let url = NSURL(string: "https://api.soundcloud.com/tracks/\(track.id)/stream?client_id=\(clientID)")!
                let song = AVPlayerItem(URL: url)
                player.replaceCurrentItemWithPlayerItem(song)
                if player.rate == 1.0 {
                    if player.currentItem!.status == .ReadyToPlay {
                        player.play()
                    }
                }
                loadTrackElements()
            } else {
                player.seekToTime(CMTimeMakeWithSeconds(0.0, 1))
            }
        }
        scrubber.value = 0.0
        scrubber.maximumValue = Float(CMTimeGetSeconds(player.currentItem!.asset.duration))
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    
    func asyncLoadTrackImage(track: Track) {
        let url = NSURL(string: track.artworkURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if error == nil {
                let image = UIImage(data: data!)
                let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                dispatch_async(dispatch_get_global_queue(priority, 0)) {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.trackImageView.image = image
                    }
                }
            }
        }
        task.resume()
    }
    
    func didLoadTracks(tracks: [Track]) {
        self.tracks = tracks
        loadTrackElements()
        let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist")
        let clientID = NSDictionary(contentsOfFile: path!)?.valueForKey("client_id") as! String
        let track = tracks[currentIndex]
        let url = NSURL(string: "https://api.soundcloud.com/tracks/\(track.id)/stream?client_id=\(clientID)")!
        if player.status == .Unknown {
            let song = AVPlayerItem(URL: url)
            player = AVPlayer(playerItem: song)
        }
    }
}

