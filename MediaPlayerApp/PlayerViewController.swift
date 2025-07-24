import Cocoa
import AVFoundation

protocol TrackSelectionDelegate: AnyObject {
    func didSelectTrack(_ track: Track)
}

class PlayerViewController: NSViewController {
    
    private var audioPlayer: AVAudioPlayer?
    private let trackLabel: NSTextField = {
        let label = NSTextField(labelWithString: "🎛 Сейчас ничего не играет")
        label.font = .systemFont(ofSize: 18)
        label.alignment = .center
        return label
    }()

    private let playButton: NSButton = {
        let button = NSButton(title: "▶️ Play", target: nil, action: nil)
        button.bezelStyle = .rounded
        return button
    }()

    private var isPlaying = false
    private var currentTrack: String?

    override func loadView() {
        self.view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.systemBlue.withAlphaComponent(0.05).cgColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Действие на кнопку
        playButton.target = self
        playButton.action = #selector(didTapPlayPause)

        // StackView
        let stack = NSStackView(views: [trackLabel, playButton])
        stack.orientation = .vertical
        stack.alignment = .centerX
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func updateTrack(_ track: Track) {
        currentTrack = track.name
        trackLabel.stringValue = "🎛 Сейчас играет: \(track.name)"
        isPlaying = false
        playButton.title = "▶️ Play"

        playTrack(at: track.url)
    }

    private func playTrack(at url: URL) {
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("❌ Файл не существует по пути: \(url.path)")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            print("✅ Загружен трек: \(url.lastPathComponent)")
        } catch {
            print("❌ Ошибка загрузки аудио: \(error.localizedDescription)")
        }
    }

    @objc private func didTapPlayPause() {
        guard audioPlayer != nil else { return }

        isPlaying.toggle()
        playButton.title = isPlaying ? "⏸ Pause" : "▶️ Play"

        if isPlaying {
            audioPlayer?.play()
            print("▶️ Воспроизведение")
        } else {
            audioPlayer?.pause()
            print("⏸ Пауза")
        }
    }
}

extension PlayerViewController: TrackSelectionDelegate {
    func didSelectTrack(_ track: Track) {
        updateTrack(track)
    }
}
