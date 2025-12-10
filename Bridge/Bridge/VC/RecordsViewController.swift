//
//  RecordsViewController.swift
//  Bridge
//
//  Created by Zhao on 2025/11/29.
//

import UIKit

class RecordsViewController: UIViewController {
    
    // MARK: - Properties
    var records: [GameRecordEntity] = []
    
    // MARK: - UI Components
    let backgroundImagery: UIImageView = {
        let imagery = UIImageView()
        imagery.image = UIImage(named: "bridgeImage")
        imagery.contentMode = .scaleAspectFill
        imagery.translatesAutoresizingMaskIntoConstraints = false
        return imagery
    }()
    
    let overlayDimmer: UIView = {
        let dimmer = UIView()
        dimmer.backgroundColor = UIColor.mahjongOverlay
        dimmer.translatesAutoresizingMaskIntoConstraints = false
        return dimmer
    }()
    
    let returnButton = NavigationReturnButton()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Game Records"
        label.font = .mahjongTitle(size: 28)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let statisticsContainer: UIView = {
        let container = UIView()
        container.backgroundColor = UIColor(red: 0.08, green: 0.12, blue: 0.22, alpha: 0.9)
        container.layer.borderWidth = 1.5
        container.layer.borderColor = UIColor.mahjongSecondary.withAlphaComponent(0.6).cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    let highScoreLabel: UILabel = {
        let label = UILabel()
        label.font = .mahjongBody(size: 16)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let averageScoreLabel: UILabel = {
        let label = UILabel()
        label.font = .mahjongBody(size: 16)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let totalGamesLabel: UILabel = {
        let label = UILabel()
        label.font = .mahjongBody(size: 16)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No game records yet.\nStart playing to see your records here!"
        label.font = .mahjongBody(size: 18)
        label.textColor = UIColor(white: 1.0, alpha: 0.7)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    let clearAllButton: StylizedButton = {
        let button = StylizedButton(title: "Clear All Records", variant: .accent)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
        establishConstraints()
        configureTableView()
        loadRecords()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        loadRecords()
    }
}

// MARK: - Configuration
extension RecordsViewController {
    
    func configureInterface() {
        view.addSubview(backgroundImagery)
        view.addSubview(overlayDimmer)
        view.addSubview(returnButton)
        view.addSubview(titleLabel)
        view.addSubview(statisticsContainer)
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        view.addSubview(clearAllButton)
        
        statisticsContainer.addSubview(highScoreLabel)
        statisticsContainer.addSubview(averageScoreLabel)
        statisticsContainer.addSubview(totalGamesLabel)
        
        statisticsContainer.applyCornerRadius(12)
        view.bringSubviewToFront(emptyStateLabel)
        
        returnButton.addTarget(self, action: #selector(handleReturnAction), for: .touchUpInside)
        clearAllButton.addTarget(self, action: #selector(handleClearAllAction), for: .touchUpInside)
    }
    
    func establishConstraints() {
        backgroundImagery.anchorToSuperview()
        overlayDimmer.anchorToSuperview()
        
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            returnButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            returnButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            statisticsContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            statisticsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statisticsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            statisticsContainer.heightAnchor.constraint(equalToConstant: 100),
            
            highScoreLabel.topAnchor.constraint(equalTo: statisticsContainer.topAnchor, constant: 15),
            highScoreLabel.leadingAnchor.constraint(equalTo: statisticsContainer.leadingAnchor, constant: 15),
            highScoreLabel.trailingAnchor.constraint(equalTo: statisticsContainer.trailingAnchor, constant: -15),
            
            averageScoreLabel.topAnchor.constraint(equalTo: highScoreLabel.bottomAnchor, constant: 10),
            averageScoreLabel.leadingAnchor.constraint(equalTo: statisticsContainer.leadingAnchor, constant: 15),
            averageScoreLabel.trailingAnchor.constraint(equalTo: statisticsContainer.trailingAnchor, constant: -15),
            
            totalGamesLabel.topAnchor.constraint(equalTo: averageScoreLabel.bottomAnchor, constant: 10),
            totalGamesLabel.leadingAnchor.constraint(equalTo: statisticsContainer.leadingAnchor, constant: 15),
            totalGamesLabel.trailingAnchor.constraint(equalTo: statisticsContainer.trailingAnchor, constant: -15),
            
            tableView.topAnchor.constraint(equalTo: statisticsContainer.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: clearAllButton.topAnchor, constant: -20),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            clearAllButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            clearAllButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            clearAllButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20),
            clearAllButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RecordTableCell.self, forCellReuseIdentifier: "RecordCell")
    }
    
    func loadRecords() {
        records = GameRecordManager.shared.fetchAllRecords()
        updateStatistics()
        tableView.reloadData()
        
        let hasRecords = !records.isEmpty
        emptyStateLabel.isHidden = hasRecords
        tableView.isHidden = records.isEmpty
        clearAllButton.isHidden = !hasRecords
        

    }
    
    func updateStatistics() {
        let highScore = GameRecordManager.shared.calculateHighestScore()
        let averageScore = GameRecordManager.shared.calculateAverageScore()
        let totalGames = records.count
        
        highScoreLabel.text = "Highest Score: \(highScore)"
        averageScoreLabel.text = String(format: "Average Score: %.1f", averageScore)
        totalGamesLabel.text = "Total Games: \(totalGames)"
        

    }
}

// MARK: - Actions
extension RecordsViewController {
    
    @objc func handleReturnAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleClearAllAction() {
        let alert = UIAlertController(title: "Clear All Records", message: "Are you sure you want to delete all game records? This action cannot be undone.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
            GameRecordManager.shared.purgeAllRecords()
            self?.loadRecords()
            self?.view.animateBounce()
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource
extension RecordsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell", for: indexPath) as! RecordTableCell
        cell.configure(with: records[indexPath.row], rank: indexPath.row + 1)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            GameRecordManager.shared.removeRecord(at: indexPath.row)
            loadRecords()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
}

// MARK: - Record Table Cell
class RecordTableCell: UITableViewCell {
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let rankLabel: UILabel = {
        let label = UILabel()
        label.font = .mahjongTitle(size: 24)
        label.textColor = .mahjongSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = .mahjongTitle(size: 22)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .mahjongBody(size: 14)
        label.textColor = UIColor(white: 1.0, alpha: 0.7)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureAppearance() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(rankLabel)
        containerView.addSubview(scoreLabel)
        containerView.addSubview(dateLabel)
        
        containerView.applyCornerRadius(12)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            rankLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            rankLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 40),
            
            scoreLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 15),
            scoreLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            
            dateLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 15),
            dateLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 5),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15)
        ])
    }
    
    func configure(with record: GameRecordEntity, rank: Int) {
        rankLabel.text = "\(rank)"
        scoreLabel.text = "Score: \(record.score)"
        dateLabel.text = record.formattedDate
    }
}

