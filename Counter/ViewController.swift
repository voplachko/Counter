//
//  ViewController.swift
//  Counter
//
//  Created by Vsevolod Oplachko on 09.01.2026.
//

import UIKit

final class ViewController: UIViewController {
    
    @IBOutlet private weak var decreaseButton: UIButton!
    @IBOutlet private weak var increaseButton: UIButton!
    @IBOutlet private weak var resetButton: UIButton!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var historyTextView: UITextView!
    
    private var counterValue: Int = 0 {
        didSet { updateUI() }
    }
    
    private var historyRecords: [HistoryRecord] = [] {
        didSet { renderHistory() }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bootstrap()
    }
    
    @IBAction private func decreaseButtonTapped(_ sender: Any) {
        applyCounterAction(.decrease)
    }
    
    @IBAction private func increaseButtonTapped(_ sender: Any) {
        applyCounterAction(.increase)
    }
    
    @IBAction private func resetButtonTapped(_ sender: Any) {
        applyCounterAction(.reset)
    }
}

private extension ViewController {
    
    func configureUI() {
        historyTextView.isEditable = false
        historyTextView.isSelectable = false
    }
    
    func bootstrap() {
        updateUI()
        addHistoryEvent(.appLaunched)
    }
    
    func updateUI() {
        counterLabel.text = "\(counterValue)"
    }
}

private extension ViewController {
    
    enum CounterAction {
        case increase
        case decrease
        case reset
    }
    
    func applyCounterAction(_ action: CounterAction) {
        switch action {
        case .increase:
            counterValue += 1
            addHistoryEvent(.changed(delta: +1))
            
        case .decrease:
            guard counterValue > 0 else {
                addHistoryEvent(.attemptBelowZero)
                return
            }
            counterValue -= 1
            addHistoryEvent(.changed(delta: -1))
            
        case .reset:
            guard counterValue != 0 else { return }
            counterValue = 0
            addHistoryEvent(.reset)
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
    
    func addHistoryEvent(_ event: HistoryEvent) {
        historyRecords.append(HistoryRecord(date: Date(), event: event))
    }
    
    func renderHistory() {
        let text = historyRecords
            .map { record in
                "[\(dateFormatter.string(from: record.date))]: \(record.event.message)"
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
