//
//  InstructionsViewController.swift
//  Bridge
//
//  Created by Zhao on 2025/11/29.
//

import UIKit

class InstructionsViewController: UIViewController {
    
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
    
    let scrollContainer: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = true
        return scroll
    }()
    
    let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let returnButton = NavigationReturnButton()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
        establishConstraints()
        populateInstructions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

// MARK: - Configuration
extension InstructionsViewController {
    
    func configureInterface() {
        view.addSubview(backgroundImagery)
        view.addSubview(overlayDimmer)
        view.addSubview(scrollContainer)
        view.addSubview(returnButton)
        
        scrollContainer.addSubview(contentStack)
        
        returnButton.addTarget(self, action: #selector(handleReturnAction), for: .touchUpInside)
    }
    
    func establishConstraints() {
        backgroundImagery.anchorToSuperview()
        overlayDimmer.anchorToSuperview()
        
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            returnButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            returnButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            scrollContainer.topAnchor.constraint(equalTo: returnButton.bottomAnchor, constant: 20),
            scrollContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollContainer.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollContainer.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollContainer.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollContainer.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollContainer.widthAnchor, constant: -40)
        ])
    }
    
    func populateInstructions() {
        let titleLabel = createTitleLabel(text: "How to Play")
        contentStack.addArrangedSubview(titleLabel)
        
        let instructions = [
            ("Objective", "Connect matching mahjong tiles from the left column to the right column. Tiles simply need to share the same number value to form a valid pair."),
            ("Connecting Tiles", "Tap a tile on the left side, then tap its matching tile on the right side to create a connection. Or drag from one tile to another. A line will appear between the connected tiles."),
            ("Verification", "Once you've connected all tiles, tap the 'Verify Connections' button to check your answers. Correct connections will be marked with a green checkmark, incorrect ones with a red X."),
            ("Scoring", "Each correct connection earns you 10 points. Complete all connections correctly to advance to the next round with new tiles."),
            ("Reset", "Use the 'Reset' button to clear all connections and start over."),
            ("Learning", "Visit the 'Learn Tiles' section to familiarize yourself with the three mahjong tile categories: Bamboo, Character, and Dots."),
            ("Records", "Your game scores are automatically saved. View your performance history in the 'Game Records' section.")
        ]
        
        for (title, description) in instructions {
            let instructionView = createInstructionSection(title: title, description: description)
            contentStack.addArrangedSubview(instructionView)
            instructionView.animateFadeIn(duration: 0.5)
        }
        
        let tipsLabel = createTitleLabel(text: "Tips")
        contentStack.addArrangedSubview(tipsLabel)
        
        let tips = [
            "• Pay attention to the numerical values on the tiles",
            "• Different categories can have the same value",
            "• Take your time - there's no time limit",
            "• Use the Learn Tiles section to memorize tile patterns"
        ]
        
        for tip in tips {
            let tipLabel = createDescriptionLabel(text: tip)
            contentStack.addArrangedSubview(tipLabel)
        }
    }
    
    func createTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .mahjongTitle(size: 26)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func createDescriptionLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .mahjongBody(size: 16)
        label.textColor = UIColor(white: 1.0, alpha: 0.9)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func createInstructionSection(title: String, description: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
        container.applyCornerRadius(12)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .mahjongTitle(size: 20)
        titleLabel.textColor = .mahjongSecondary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.font = .mahjongBody(size: 16)
        descriptionLabel.textColor = UIColor(white: 1.0, alpha: 0.9)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        container.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -15),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15),
            descriptionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -15),
            descriptionLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -15)
        ])
        
        return container
    }
}

// MARK: - Actions
extension InstructionsViewController {
    
    @objc func handleReturnAction() {
        navigationController?.popViewController(animated: true)
    }
}

