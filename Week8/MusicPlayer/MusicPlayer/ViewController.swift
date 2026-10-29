//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Жантөре Оразымбетов on 29.10.2026.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!

    // MARK: - State (всё состояние экрана в одном месте)

    private let tracks = TrackLibrary.tracks
    private var currentIndex = 0
    private var isPlaying = false

   
    private var player: AVAudioPlayer?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAudioSession()
        loadTrack(at: currentIndex)
        updateUI()
    }

    // MARK: - Actions

    @IBAction func previousTapped(_ sender: UIButton) {
        changeTrack(by: -1)
    }

    @IBAction func playPauseTapped(_ sender: UIButton) {
        guard let player else {
            print("⚠️ Нечего воспроизводить: текущий трек не загружен")
            return
        }
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
        updateUI()
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        changeTrack(by: 1)
    }

    // MARK: - Playback

    
    private func changeTrack(by step: Int) {
        guard !tracks.isEmpty else { return }
        let wasPlaying = isPlaying

       
        currentIndex = (currentIndex + step + tracks.count) % tracks.count
        loadTrack(at: currentIndex)

        if wasPlaying, let player {
            player.play()
            isPlaying = true
        } else {
            isPlaying = false
        }
        updateUI()
    }

    
    private func loadTrack(at index: Int) {
        player?.stop()
        player = nil

        guard tracks.indices.contains(index) else { return }
        let track = tracks[index]

        guard let url = Bundle.main.url(forResource: track.resourceName,
                                        withExtension: track.fileExtension) else {
            print("⚠️ Файл не найден в приложении: \(track.fileName). Проверь Target Membership.")
            return
        }

        do {
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.delegate = self
            player = newPlayer
        } catch {
            print("⚠️ Не удалось открыть \(track.fileName): \(error.localizedDescription)")
        }
    }

    
    private func configureAudioSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(.playback, mode: .default)
                try session.setActive(true)
            } catch {
                print("⚠️ Не удалось настроить аудиосессию: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - UI

    
    private func updateUI() {
        guard tracks.indices.contains(currentIndex) else { return }
        let track = tracks[currentIndex]

        titleLabel.text = track.title
        artistLabel.text = track.artist
        coverImageView.image = UIImage(named: track.coverImageName) ?? UIImage(systemName: "music.note")

        let icon = UIImage(systemName: isPlaying ? "pause.fill" : "play.fill")
        if playPauseButton.configuration != nil {
            // Кнопка со стилем Plain: меняем картинку в конфигурации, размер символа из IB сохраняется
            playPauseButton.configuration?.image = icon
        } else {
            playPauseButton.setImage(icon, for: .normal)
        }
    }
}

// MARK: - AVAudioPlayerDelegate

extension ViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        changeTrack(by: 1)
    }
}
