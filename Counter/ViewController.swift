//
//  ViewController.swift
//  Counter
//
//  Created by Vsevolod Oplachko on 09.01.2026.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var decreaseButton: UIButton!
    @IBOutlet weak var increaseButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var historyTextView: UITextView!
    
    private var counter: Int = 0 {
        didSet { updateUI() }
    }
    
    private var history: [HistoryRecord] = [] {
        didSet { renderHistory() }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    private func makeTimestamp() -> String {
        dateFormatter.string(from: Date())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bootstrap()
    }
    
    @IBAction func decreaseButtonTapped(_ sender: Any) {
        perform(.decrease)
    }
    
    @IBAction func increaseButtonTapped(_ sender: Any) {
        perform(.increase)
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        perform(.reset)
    }
}

private extension ViewController {
    func configureUI() {
        historyTextView.isEditable = false
        historyTextView.isSelectable = false
    }

    func bootstrap() {
        updateUI()
        log(.appLaunched)
    }

    func updateUI() {
        counterLabel.text = "\(counter)"
        decreaseButton.isEnabled = counter > 0
    }
}

private extension ViewController {
    enum Action {
        case increase
        case decrease
        case reset
    }

    func perform(_ action: Action) {
        switch action {
        case .increase:
            counter += 1
            log(.changed(delta: +1))

        case .decrease:
            guard counter > 0 else {
                log(.attemptBelowZero)
                return
            }
            counter -= 1
            log(.changed(delta: -1))

        case .reset:
            guard counter != 0 else { return }
            counter = 0
            log(.reset)
        }
    }
}

private extension ViewController {

    struct HistoryRecord {
        let date: Date
        let event: HistoryEvent
    }

    enum HistoryEvent {
        case appLaunched
        case changed(delta: Int)
        case reset
        case attemptBelowZero

        var message: String {
            switch self {
            case .appLaunched:
                return "Приложение запущено"
            case .changed(let delta):
                return "значение изменено на \(delta > 0 ? "+\(delta)" : "\(delta)")"
            case .reset:
                return "значение сброшено"
            case .attemptBelowZero:
                return "попытка уменьшить значение счётчика ниже 0"
            }
        }
    }

    func log(_ event: HistoryEvent) {
        history.append(HistoryRecord(date: Date(), event: event))
    }

    func renderHistory() {
        let text = history
            .map { record in
                let ts = dateFormatter.string(from: record.date)
                return "[\(ts)]: \(record.event.message)"
            }
            .joined(separator: "\n")

        historyTextView.text = text
        scrollHistoryToBottom()
    }

    func scrollHistoryToBottom() {
        guard !historyTextView.text.isEmpty else { return }
        let end = NSRange(location: historyTextView.text.count - 1, length: 1)
        historyTextView.scrollRangeToVisible(end)
    }
}
