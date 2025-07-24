import Cocoa

class TrackListViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    weak var delegate: TrackSelectionDelegate?
    
    private let addButton: NSButton = {
       let button = NSButton(title: "Добавить трек", target: nil, action: nil)
        button.bezelStyle = .recessed
        return button
    }()

    private let label: NSTextField = {
        let label = NSTextField(labelWithString: "🎵 Список треков")
        label.font = .systemFont(ofSize: 24)
        label.alignment = .center
        return label
    }()
    
    private lazy var tableView: NSTableView = {
        let tableView = NSTableView()
        tableView.delegate = self
        tableView.dataSource = self

        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("TrackColumn"))
        column.title = "Треки"
        column.width = 300
        tableView.addTableColumn(column)

        tableView.headerView = nil
        tableView.usesAlternatingRowBackgroundColors = true
        return tableView
    }()

    private let scrollView: NSScrollView = {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        return scrollView
    }()

    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.systemGray.withAlphaComponent(0.05).cgColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.documentView = tableView
        addButton.target = self
        addButton.action = #selector(didTapAddTrack)
        
        view.addSubview(addButton)
        view.addSubview(label)
        view.addSubview(scrollView)

        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            scrollView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            
            addButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        loadTracks()
    }

    private var tracks: [Track] = []

    private func loadTracks() {
        if let resourcePath = Bundle.main.resourcePath {
            let tracksPath = "\(resourcePath)/Tracks1"
            print("📁 Путь к папке Tracks1: \(tracksPath)")
            
            do {
                let fileNames = try FileManager.default.contentsOfDirectory(atPath: tracksPath)
                print("🔍 Содержимое Tracks1: \(fileNames)")
                
                // Преобразуем файлы в Track
                tracks = fileNames.filter { $0.hasSuffix(".mp3") }.map { fileName in
                    let url = URL(fileURLWithPath: "\(tracksPath)/\(fileName)")
                    return Track(name: fileName, url: url)
                }
                
                tableView.reloadData()
            } catch {
                print("❌ Не удалось прочитать содержимое Tracks1: \(error)")
            }
        }
    }
    
    @objc private func didTapAddTrack() {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["mp3"]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.title = "Выберите MP3-файлы"

        panel.begin { [weak self] result in
            guard result == .OK, let self = self else { return }

            for url in panel.urls {
                let name = url.lastPathComponent
                let newTrack = Track(name: name, url: url)
                self.tracks.append(newTrack)
            }

            self.tableView.reloadData()
        }
    }


    // MARK: - TableView DataSource

    func numberOfRows(in tableView: NSTableView) -> Int {
        return tracks.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let identifier = NSUserInterfaceItemIdentifier("TrackCell")

        if let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = tracks[row].name
            return cell
        }

        let cell = NSTableCellView()
        let textField = NSTextField(labelWithString: tracks[row].name)
        textField.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(textField)
        cell.textField = textField
        cell.identifier = identifier

        NSLayoutConstraint.activate([
            textField.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            textField.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 8)
        ])

        return cell
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = tableView.selectedRow
        guard selectedRow >= 0 && selectedRow < tracks.count else { return }
        let selectedTrack = tracks[selectedRow]
        delegate?.didSelectTrack(selectedTrack)
    }
}
