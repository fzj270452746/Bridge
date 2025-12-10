//
//  TutorialViewController.swift
//  Bridge
//
//  Created by Zhao on 2025/11/29.
//

import UIKit

class TutorialViewController: UIViewController {
    
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
        stack.spacing = 30
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Mahjong Tiles Guide"
        label.font = .mahjongTitle(size: 28)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Match tiles that share the same value"
        label.font = .mahjongBody(size: 16)
        label.textColor = UIColor(white: 1.0, alpha: 0.9)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let returnButton = NavigationReturnButton()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
        establishConstraints()
        populateCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

// MARK: - Configuration
extension TutorialViewController {
    
    func configureInterface() {
        view.addSubview(backgroundImagery)
        view.addSubview(overlayDimmer)
        view.addSubview(scrollContainer)
        view.addSubview(returnButton)
        
        scrollContainer.addSubview(contentStack)
        
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(descriptionLabel)
        
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
    
    func populateCategories() {
        let repository = MahjongTileRepository.shared
        let categories = repository.fetchAllCategories()
        
        for category in categories {
            let categoryView = createCategorySection(for: category)
            contentStack.addArrangedSubview(categoryView)
            categoryView.animateFadeIn(duration: 0.5)
        }
    }
    
    func createCategorySection(for category: MahjongCategory) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
        container.applyCornerRadius(16)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = category.displayTitle
        titleLabel.font = .mahjongTitle(size: 22)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let gridStack = UIStackView()
        gridStack.axis = .vertical
        gridStack.spacing = 12
        gridStack.translatesAutoresizingMaskIntoConstraints = false
        
        let repository = MahjongTileRepository.shared
        let tiles = repository.fetchTiles(for: category)
        
        let tilesPerRow = 3
        var currentRowStack: UIStackView?
        
        for (index, tile) in tiles.enumerated() {
            if index % tilesPerRow == 0 {
                currentRowStack = UIStackView()
                currentRowStack?.axis = .horizontal
                currentRowStack?.spacing = 10
                currentRowStack?.distribution = .fillEqually
                if let rowStack = currentRowStack {
                    gridStack.addArrangedSubview(rowStack)
                }
            }
            
            let tileView = createTileView(with: tile)
            currentRowStack?.addArrangedSubview(tileView)
        }
        
        // Fill remaining spaces to keep grid aligned
        for case let rowStack as UIStackView in gridStack.arrangedSubviews {
            while rowStack.arrangedSubviews.count < tilesPerRow {
                let spacer = UIView()
                spacer.translatesAutoresizingMaskIntoConstraints = false
                rowStack.addArrangedSubview(spacer)
            }
        }
        
        container.addSubview(titleLabel)
        container.addSubview(gridStack)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
            
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            
            gridStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            gridStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            gridStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            gridStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20)
        ])
        
        return container
    }
    
    func createTileView(with tile: MahjongTileEntity) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.image = tile.imagery
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .white
        imageView.applyCornerRadius(6)
        imageView.applyBorderStyling(width: 2, color: UIColor(white: 0.9, alpha: 1.0))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = "\(tile.magnitude)"
        valueLabel.font = .mahjongButton(size: 16)
        valueLabel.textColor = .white
        valueLabel.textAlignment = .center
        valueLabel.backgroundColor = UIColor(white: 0.0, alpha: 0.6)
        valueLabel.applyCornerRadius(12)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(imageView)
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.4),
            
            valueLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            valueLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            valueLabel.widthAnchor.constraint(equalToConstant: 32),
            valueLabel.heightAnchor.constraint(equalToConstant: 24),
            valueLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
}

// MARK: - Actions
extension TutorialViewController {
    
    @objc func handleReturnAction() {
        navigationController?.popViewController(animated: true)
    }
}

