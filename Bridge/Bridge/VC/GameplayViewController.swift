//
//  GameplayViewController.swift
//  Bridge
//
//  Created by Zhao on 2025/11/29.
//

import UIKit

class GameplayViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    var leftTileEntities: [MahjongTileEntity] = []
    var rightTileEntities: [MahjongTileEntity] = []
    var connections: [(Int, Int)] = [] // (leftIndex, rightIndex)
    var currentScore: Int = 0
    var consecutiveCorrect: Int = 0
    
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
    let hintButton: StylizedButton = {
        let button = StylizedButton(title: "Hint", variant: .secondary)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = .mahjongTitle(size: 24)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let leftTilesContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear // Changed to clear for better appearance
        container.isUserInteractionEnabled = true
        return container
    }()
    
    let rightTilesContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear // Changed to clear for better appearance
        container.isUserInteractionEnabled = true
        return container
    }()
    
    let connectionCanvas: UIView = {
        let canvas = UIView()
        canvas.backgroundColor = .clear
        canvas.isUserInteractionEnabled = false
        canvas.translatesAutoresizingMaskIntoConstraints = false
        return canvas
    }()
    
    let verificationButton: StylizedButton = {
        let button = StylizedButton(title: "Verify Connections", variant: .primary)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let resetButton: StylizedButton = {
        let button = StylizedButton(title: "Reset", variant: .secondary)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var leftTileViews: [TileInteractiveView] = []
    var rightTileViews: [TileInteractiveView] = []
    var connectionLayers: [CAShapeLayer] = []
    
    var selectedLeftIndex: Int?
    var selectedRightIndex: Int?
    var hasShownTutorial = false
    var isMemoryModeEnabled: Bool = false
    
    private var memoryPreviewInProgress = false
    private var memoryPreviewWorkItem: DispatchWorkItem?
    private let memoryPreviewDuration: TimeInterval = 5.0
    private var memoryCountdownTimer: Timer?
    private var memoryCountdownRemaining: Int = 0
    private var memoryCountdownOverlay: UIView?
    private var memoryCountdownContainer: UIView?
    private var memoryCountdownLabel: UILabel?
    private var hintRevealWorkItem: DispatchWorkItem?
    private let hintRevealDuration: TimeInterval = 3.0
    private var hintPreviouslyHiddenTiles: [TileInteractiveView] = []
    
    private static let tutorialShownKey = "hasShownGameplayTutorial"
    
    // Touch tracking for drawing
    var isDrawing = false
    var currentDrawingLayer: CAShapeLayer?
    var drawingStartPoint: CGPoint?
    var drawingStartTileIndex: Int?
    var drawingStartIsLeft: Bool?
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        hasShownTutorial = UserDefaults.standard.bool(forKey: Self.tutorialShownKey)
        configureInterface()
        establishConstraints()
        initializeGameSession()
        updateScoreDisplay()
        setupGestureRecognizers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Layout tiles after constraints are set
        if !leftTileViews.isEmpty && leftTileViews[0].frame.size.width == 0 {
            layoutTileViews()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !hasShownTutorial {
            hasShownTutorial = true
            UserDefaults.standard.set(true, forKey: Self.tutorialShownKey)
            showTutorialAnimation()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cancelMemoryPreview()
    }
    
    // MARK: - Gesture Handling for Drawing
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: view)
        
        if isMemoryModeEnabled && memoryPreviewInProgress {
            return
        }
        
        if isMemoryModeEnabled && hintRevealWorkItem != nil {
            return
        }
        
        switch gesture.state {
        case .began:
            
            // Check if pan started on a tile
            if let (tileIndex, isLeft) = findTileAt(location: location) {
                
                // Check if already connected
                if isLeft && connections.contains(where: { $0.0 == tileIndex }) {
                    return
                }
                if !isLeft && connections.contains(where: { $0.1 == tileIndex }) {
                    return
                }
                
                isDrawing = true
                drawingStartTileIndex = tileIndex
                drawingStartIsLeft = isLeft
                
                let tileView = isLeft ? leftTileViews[tileIndex] : rightTileViews[tileIndex]
                drawingStartPoint = tileView.convert(CGPoint(x: tileView.bounds.midX, y: tileView.bounds.midY), to: connectionCanvas)
                
                
                // Create initial drawing layer
                currentDrawingLayer = CAShapeLayer()
                currentDrawingLayer?.strokeColor = UIColor.mahjongSecondary.withAlphaComponent(0.6).cgColor
                currentDrawingLayer?.lineWidth = 3
                currentDrawingLayer?.lineCap = .round
                currentDrawingLayer?.fillColor = UIColor.clear.cgColor
                connectionCanvas.layer.addSublayer(currentDrawingLayer!)
                
            } else {
            }
            
        case .changed:
            guard isDrawing, let startPoint = drawingStartPoint else {
                return
            }
            
            let canvasLocation = gesture.location(in: connectionCanvas)
            
            // Update drawing path
            let path = UIBezierPath()
            path.move(to: startPoint)
            path.addLine(to: canvasLocation)
            currentDrawingLayer?.path = path.cgPath
            
        case .ended:
            guard isDrawing else {
                return
            }
            
            
            // Check if pan ended on a tile
            if let (endTileIndex, isLeft) = findTileAt(location: location) {
                
                // Must be on opposite side
                guard let startIsLeft = drawingStartIsLeft, startIsLeft != isLeft else {
                    cleanupDrawing()
                    return
                }
                
                guard let startIndex = drawingStartTileIndex else {
                    cleanupDrawing()
                    return
                }
                
                // Check if end tile is already connected
                if isLeft && connections.contains(where: { $0.0 == endTileIndex }) {
                    cleanupDrawing()
                    return
                }
                if !isLeft && connections.contains(where: { $0.1 == endTileIndex }) {
                    cleanupDrawing()
                    return
                }
                
                // Create connection
                let leftIndex = startIsLeft ? startIndex : endTileIndex
                let rightIndex = startIsLeft ? endTileIndex : startIndex
                
                createConnection(leftIndex: leftIndex, rightIndex: rightIndex)
            } else {
            }
            
            cleanupDrawing()
            
        case .cancelled, .failed:
            cleanupDrawing()
            
        default:
            break
        }
    }
    
    // Allow pan gesture and tap gesture to work together
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func findTileAt(location: CGPoint) -> (index: Int, isLeft: Bool)? {
        
        // Expand hit area for easier interaction
        let hitExpansion: CGFloat = 20
        
        // Check left tiles - convert each tile's frame to view coordinates
        for (index, tileView) in leftTileViews.enumerated() {
            let tileFrameInView = tileView.convert(tileView.bounds, to: view)
            let expandedFrame = tileFrameInView.insetBy(dx: -hitExpansion, dy: -hitExpansion)
            if expandedFrame.contains(location) {
                return (index, true)
            }
        }
        
        // Check right tiles
        for (index, tileView) in rightTileViews.enumerated() {
            let tileFrameInView = tileView.convert(tileView.bounds, to: view)
            let expandedFrame = tileFrameInView.insetBy(dx: -hitExpansion, dy: -hitExpansion)
            if expandedFrame.contains(location) {
                return (index, false)
            }
        }
        
        return nil
    }
    
    func cleanupDrawing() {
        currentDrawingLayer?.removeFromSuperlayer()
        currentDrawingLayer = nil
        isDrawing = false
        drawingStartPoint = nil
        drawingStartTileIndex = nil
        drawingStartIsLeft = nil
    }
}

// MARK: - Configuration
extension GameplayViewController {
    
    func configureInterface() {
        
        view.addSubview(backgroundImagery)
        view.addSubview(overlayDimmer)
        view.addSubview(leftTilesContainer)
        view.addSubview(rightTilesContainer)
        view.addSubview(connectionCanvas) // place canvas above tiles for visibility
        view.addSubview(returnButton)
        view.addSubview(scoreLabel)
        view.addSubview(hintButton)
        view.addSubview(verificationButton)
        view.addSubview(resetButton)
        
        connectionCanvas.isUserInteractionEnabled = false
        view.bringSubviewToFront(connectionCanvas)
        view.bringSubviewToFront(returnButton)
        view.bringSubviewToFront(scoreLabel)
        
     
        
        returnButton.addTarget(self, action: #selector(handleReturnAction), for: .touchUpInside)
        hintButton.addTarget(self, action: #selector(handleHintAction), for: .touchUpInside)
        verificationButton.addTarget(self, action: #selector(handleVerificationAction), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(handleResetAction), for: .touchUpInside)
        
        updateHintButtonState()
    }
    
    func setupGestureRecognizers() {
        
        // Add pan gesture for drawing connections
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
        
    }
    
    func establishConstraints() {
        backgroundImagery.anchorToSuperview()
        overlayDimmer.anchorToSuperview()
        
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            returnButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            returnButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            scoreLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scoreLabel.heightAnchor.constraint(equalToConstant: 44),
            scoreLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
            
            hintButton.centerYAnchor.constraint(equalTo: scoreLabel.centerYAnchor),
            hintButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            hintButton.widthAnchor.constraint(equalToConstant: 90),
            hintButton.heightAnchor.constraint(equalToConstant: 40),
            
            leftTilesContainer.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 40),
            leftTilesContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            leftTilesContainer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.35),
            leftTilesContainer.bottomAnchor.constraint(equalTo: verificationButton.topAnchor, constant: -30),
            
            rightTilesContainer.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 40),
            rightTilesContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            rightTilesContainer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.35),
            rightTilesContainer.bottomAnchor.constraint(equalTo: verificationButton.topAnchor, constant: -30),
            
            connectionCanvas.topAnchor.constraint(equalTo: leftTilesContainer.topAnchor),
            connectionCanvas.leadingAnchor.constraint(equalTo: leftTilesContainer.leadingAnchor),
            connectionCanvas.trailingAnchor.constraint(equalTo: rightTilesContainer.trailingAnchor),
            connectionCanvas.bottomAnchor.constraint(equalTo: leftTilesContainer.bottomAnchor),
            
            verificationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            verificationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            verificationButton.bottomAnchor.constraint(equalTo: resetButton.topAnchor, constant: -15),
            verificationButton.heightAnchor.constraint(equalToConstant: 55),
            
            resetButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            resetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            resetButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20),
            resetButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func initializeGameSession() {
        let repository = MahjongTileRepository.shared
        
        // Generate matching pairs with same magnitude but different categories
        leftTileEntities.removeAll()
        rightTileEntities.removeAll()
        
        let tileCount = 6
        var usedPairs: Set<String> = [] // Track used combinations to avoid duplicates
        
        for _ in 0..<tileCount {
            var leftTile: MahjongTileEntity!
            var rightTile: MahjongTileEntity!
            var pairKey: String
            
            repeat {
                // Randomly select magnitude (1-9)
                let magnitude = Int.random(in: 1...9)
                
                // Randomly select two different categories
                let allCategories = MahjongCategory.allCases
                let shuffledCategories = allCategories.shuffled()
                let leftCategory = shuffledCategories[0]
                let rightCategory = shuffledCategories[1]
                
                pairKey = "\(magnitude)-\(leftCategory.rawValue)-\(rightCategory.rawValue)"
                
                if !usedPairs.contains(pairKey) {
                    // Get tiles from repository
                    let leftCollection = repository.fetchTiles(for: leftCategory)
                    let rightCollection = repository.fetchTiles(for: rightCategory)
                    
                    if let left = leftCollection.first(where: { $0.magnitude == magnitude }),
                       let right = rightCollection.first(where: { $0.magnitude == magnitude }) {
                        leftTile = left
                        rightTile = right
                        usedPairs.insert(pairKey)
                        break
                    }
                }
            } while true
            
            leftTileEntities.append(leftTile)
            rightTileEntities.append(rightTile)
        }
        
        // Shuffle right tiles to make it challenging
        rightTileEntities.shuffle()
        

        for (index, tile) in leftTileEntities.enumerated() {
        }
        for (index, tile) in rightTileEntities.enumerated() {
        }
        
        populateTileViews()
        prepareMemoryModeIfNeeded()
    }
    
    func populateTileViews() {
        // Clear existing views
        leftTileViews.forEach { $0.removeFromSuperview() }
        rightTileViews.forEach { $0.removeFromSuperview() }
        leftTileViews.removeAll()
        rightTileViews.removeAll()
        
        // Create left tiles
        for (index, entity) in leftTileEntities.enumerated() {
            let tileView = TileInteractiveView(entity: entity, index: index)
            tileView.tapHandler = { [weak self] idx in
                self?.handleLeftTileSelection(at: idx)
            }
            leftTilesContainer.addSubview(tileView)
            leftTileViews.append(tileView)
        }
        
        // Create right tiles
        for (index, entity) in rightTileEntities.enumerated() {
            let tileView = TileInteractiveView(entity: entity, index: index)
            tileView.tapHandler = { [weak self] idx in
                self?.handleRightTileSelection(at: idx)
            }
            rightTilesContainer.addSubview(tileView)
            rightTileViews.append(tileView)
        }
    }
    
    func layoutTileViews() {
        guard !leftTileViews.isEmpty else {
            return
        }
        
        let containerHeight = leftTilesContainer.bounds.height
        guard containerHeight > 0 else {
            return
        }
        
        let containerWidth = leftTilesContainer.bounds.width
        let canvasFrame = connectionCanvas.frame
        
        let spacing: CGFloat = 12
        let tileCount = CGFloat(leftTileViews.count)
        let totalSpacing = spacing * (tileCount - 1)
        let tileHeight = (containerHeight - totalSpacing) / tileCount
        let tileWidth = tileHeight / 1.455
        
        
        // Layout left tiles
        for (index, tileView) in leftTileViews.enumerated() {
            let yPosition = CGFloat(index) * (tileHeight + spacing)
            tileView.frame = CGRect(x: 0, y: yPosition, width: tileWidth, height: tileHeight)
            
            if tileView.alpha == 0 {
                tileView.animateFadeIn(duration: 0.3)
            }
        }
        
        // Layout right tiles
        for (index, tileView) in rightTileViews.enumerated() {
            let yPosition = CGFloat(index) * (tileHeight + spacing)
            let xPosition = rightTilesContainer.bounds.width - tileWidth
            tileView.frame = CGRect(x: xPosition, y: yPosition, width: tileWidth, height: tileHeight)
            
            if tileView.alpha == 0 {
                tileView.animateFadeIn(duration: 0.3)
            }
        }
        
    }
    
    func updateScoreDisplay() {
        scoreLabel.text = "Score: \(currentScore)"
    }
    
    func prepareMemoryModeIfNeeded() {
        cancelMemoryPreview()
        
        guard isMemoryModeEnabled else {
            memoryPreviewInProgress = false
            setTilesRevealed(true, animated: false)
            hideMemoryCountdownOverlay(animated: false)
            updateHintButtonState()
            return
        }
        
        memoryPreviewInProgress = true
        setTilesRevealed(true, animated: false)
        updateHintButtonState()
        startMemoryCountdown(seconds: Int(memoryPreviewDuration))
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.completeMemoryPreview()
        }
        
        memoryPreviewWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + memoryPreviewDuration, execute: workItem)
    }
    
    func cancelMemoryPreview() {
        memoryPreviewWorkItem?.cancel()
        memoryPreviewWorkItem = nil
        memoryPreviewInProgress = false
        memoryCountdownTimer?.invalidate()
        memoryCountdownTimer = nil
        hideMemoryCountdownOverlay(animated: true)
        cancelHintReveal()
        updateHintButtonState()
    }
    
    func setTilesRevealed(_ revealed: Bool, animated: Bool) {
        leftTileViews.forEach { $0.setRevealed(revealed, animated: animated) }
        rightTileViews.forEach { $0.setRevealed(revealed, animated: animated) }
    }
    
    func updateHintButtonState() {
        let shouldShow = isMemoryModeEnabled
        hintButton.isHidden = !shouldShow
        let enabled = shouldShow && !memoryPreviewInProgress && hintRevealWorkItem == nil
        hintButton.isEnabled = enabled
        hintButton.alpha = enabled ? 1.0 : 0.5
    }
    
    func startMemoryCountdown(seconds: Int) {
        memoryCountdownTimer?.invalidate()
        memoryCountdownRemaining = max(seconds, 1)
        showMemoryCountdownOverlay(startingFrom: memoryCountdownRemaining)
        
        memoryCountdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.memoryCountdownRemaining -= 1
            if self.memoryCountdownRemaining <= 0 {
                timer.invalidate()
                self.hideMemoryCountdownOverlay(animated: true)
            } else {
                self.memoryCountdownLabel?.text = "\(self.memoryCountdownRemaining)"
            }
        }
    }
    
    func completeMemoryPreview() {
        guard memoryPreviewInProgress else { return }
        memoryPreviewInProgress = false
        memoryCountdownTimer?.invalidate()
        memoryCountdownTimer = nil
        hideMemoryCountdownOverlay(animated: true)

        setTilesRevealed(false, animated: true)
        updateHintButtonState()
    }
    
    func showMemoryCountdownOverlay(startingFrom seconds: Int) {
        if memoryCountdownOverlay == nil {
            let overlay = UIView(frame: view.bounds)
            overlay.backgroundColor = .clear
            overlay.translatesAutoresizingMaskIntoConstraints = false
            overlay.isUserInteractionEnabled = false
            
            let container = UIView()
            container.backgroundColor = UIColor(red: 0.05, green: 0.08, blue: 0.15, alpha: 0.85)
            container.translatesAutoresizingMaskIntoConstraints = false
            container.layer.cornerRadius = 24
            container.layer.borderWidth = 2
            container.layer.borderColor = UIColor.mahjongSecondary.withAlphaComponent(0.6).cgColor
            
            let label = UILabel()
            label.font = .mahjongTitle(size: 56)
            label.textColor = UIColor.mahjongSecondary
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(overlay)
            overlay.anchorToSuperview()
            overlay.addSubview(container)
            container.addSubview(label)
            
            NSLayoutConstraint.activate([
                container.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
                container.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
                container.widthAnchor.constraint(equalToConstant: 150),
                container.heightAnchor.constraint(equalToConstant: 150),
                
                label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])
            
            memoryCountdownOverlay = overlay
            memoryCountdownContainer = container
            memoryCountdownLabel = label
        }
        
        memoryCountdownLabel?.text = "\(seconds)"
        memoryCountdownOverlay?.alpha = 1
        memoryCountdownOverlay?.isHidden = false
        memoryCountdownContainer?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        memoryCountdownContainer?.alpha = 0
        
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.memoryCountdownContainer?.transform = .identity
            self.memoryCountdownContainer?.alpha = 1
        }
    }
    
    func hideMemoryCountdownOverlay(animated: Bool) {
        guard let overlay = memoryCountdownOverlay, !overlay.isHidden else { return }
        let completion = {
            overlay.isHidden = true
            self.memoryCountdownContainer?.transform = .identity
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.memoryCountdownContainer?.alpha = 0
            }, completion: { _ in
                overlay.alpha = 0
                completion()
            })
        } else {
            overlay.alpha = 0
            memoryCountdownContainer?.alpha = 0
            completion()
        }
    }
    
    func triggerHintReveal() {
        guard isMemoryModeEnabled else { return }
        guard !memoryPreviewInProgress else {
            return
        }
        guard hintRevealWorkItem == nil else {
            return
        }
        
        let hiddenTiles = (leftTileViews + rightTileViews).filter { !$0.isRevealed }
        guard !hiddenTiles.isEmpty else {
            return
        }
        
        hintPreviouslyHiddenTiles = hiddenTiles
        setTilesRevealed(true, animated: true)
        updateHintButtonState()
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.endHintReveal()
        }
        hintRevealWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + hintRevealDuration, execute: workItem)
    }
    
    func endHintReveal() {
        guard isMemoryModeEnabled else {
            hintPreviouslyHiddenTiles.removeAll()
            hintRevealWorkItem = nil
            updateHintButtonState()
            return
        }
        
        for tile in hintPreviouslyHiddenTiles {
            tile.setRevealed(false, animated: true)
        }
        hintPreviouslyHiddenTiles.removeAll()
        hintRevealWorkItem = nil
        updateHintButtonState()
    }
    
    func cancelHintReveal() {
        guard hintRevealWorkItem != nil else { return }
        hintRevealWorkItem?.cancel()
        hintRevealWorkItem = nil
        if isMemoryModeEnabled && !memoryPreviewInProgress {
            for tile in hintPreviouslyHiddenTiles {
                tile.setRevealed(false, animated: false)
            }
        }
        hintPreviouslyHiddenTiles.removeAll()
        updateHintButtonState()
    }
}

// MARK: - Game Logic
extension GameplayViewController {
    
    func handleLeftTileSelection(at index: Int) {
        
        if isMemoryModeEnabled {
            guard !memoryPreviewInProgress else {
                return
            }
            guard hintRevealWorkItem == nil else {
                return
            }
        }
        
        // Check if already connected
        if connections.contains(where: { $0.0 == index }) {
            return
        }
        
        selectedLeftIndex = index
        leftTileViews[index].animatePulse()
        
   
        
        // If right tile also selected, create connection
        if let rightIndex = selectedRightIndex {
            createConnection(leftIndex: index, rightIndex: rightIndex)
            selectedLeftIndex = nil
            selectedRightIndex = nil
        }
    }
    
    func handleRightTileSelection(at index: Int) {
   
        if isMemoryModeEnabled {
            guard !memoryPreviewInProgress else {
                return
            }
            guard hintRevealWorkItem == nil else {
                return
            }
        }
        
        // Check if already connected
        if connections.contains(where: { $0.1 == index }) {
            return
        }
        
        selectedRightIndex = index
        rightTileViews[index].animatePulse()
        
      
        // If left tile also selected, create connection
        if let leftIndex = selectedLeftIndex {
            createConnection(leftIndex: leftIndex, rightIndex: index)
            selectedLeftIndex = nil
            selectedRightIndex = nil
        }
    }
    
    func createConnection(leftIndex: Int, rightIndex: Int) {
        connections.append((leftIndex, rightIndex))
        drawConnectionLine(from: leftIndex, to: rightIndex)
    }
    
    func drawConnectionLine(from leftIndex: Int, to rightIndex: Int) {
        guard leftIndex < leftTileViews.count, rightIndex < rightTileViews.count else {
            return
        }
        
        let leftView = leftTileViews[leftIndex]
        let rightView = rightTileViews[rightIndex]
        
        let canvasFrame = connectionCanvas.frame
        let canvasBounds = connectionCanvas.bounds
        
        
        let leftCenter = leftView.convert(CGPoint(x: leftView.bounds.midX, y: leftView.bounds.midY), to: connectionCanvas)
        let rightCenter = rightView.convert(CGPoint(x: rightView.bounds.midX, y: rightView.bounds.midY), to: connectionCanvas)
   
        
        let path = UIBezierPath()
        path.move(to: leftCenter)
        path.addLine(to: rightCenter)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.mahjongSecondary.cgColor
        shapeLayer.lineWidth = 3
        shapeLayer.lineCap = .round
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        
        connectionCanvas.layer.addSublayer(shapeLayer)
        connectionLayers.append(shapeLayer)
      
        // Animate line drawing
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 0.3
        shapeLayer.add(animation, forKey: "drawLine")
    }
    
    func clearConnections() {
        connections.removeAll()
        connectionLayers.forEach { $0.removeFromSuperlayer() }
        connectionLayers.removeAll()
        selectedLeftIndex = nil
        selectedRightIndex = nil
    }
}

// MARK: - Tutorial Animation
extension GameplayViewController {
    
    func showTutorialAnimation() {
        // Wait for layout to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.performTutorialAnimation()
        }
    }
    
    func performTutorialAnimation() {
        guard leftTileViews.count >= 2 && rightTileViews.count >= 2 else { return }
        
        // Find matching tiles for demo (same magnitude)
        var demoLeftIndex = 0
        var demoRightIndex = 0
        
        for (leftIdx, leftEntity) in leftTileEntities.enumerated() {
            for (rightIdx, rightEntity) in rightTileEntities.enumerated() {
                if leftEntity.magnitude == rightEntity.magnitude {
                    demoLeftIndex = leftIdx
                    demoRightIndex = rightIdx
                    break
                }
            }
        }
        
        // Create tutorial overlay
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        overlayView.alpha = 0
        view.addSubview(overlayView)
        
        // Create instruction label
        let instructionLabel = UILabel()
        instructionLabel.text = "Connect tiles that share the same number"
        instructionLabel.font = .mahjongTitle(size: 20)
        instructionLabel.textColor = .white
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(instructionLabel)
        
        NSLayoutConstraint.activate([
            instructionLabel.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            instructionLabel.topAnchor.constraint(equalTo: overlayView.safeAreaLayoutGuide.topAnchor, constant: 100),
            instructionLabel.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 40),
            instructionLabel.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -40)
        ])
        
        // Fade in overlay
        UIView.animate(withDuration: 0.3) {
            overlayView.alpha = 1
        }
        
        // Animate demo connection
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.animateDemoConnection(leftIndex: demoLeftIndex, rightIndex: demoRightIndex, overlayView: overlayView)
        }
    }
    
    func animateDemoConnection(leftIndex: Int, rightIndex: Int, overlayView: UIView) {
        let leftView = leftTileViews[leftIndex]
        let rightView = rightTileViews[rightIndex]
        
        // Highlight left tile
        let leftHighlight = UIView(frame: leftView.frame)
        leftHighlight.backgroundColor = .clear
        leftHighlight.layer.borderColor = UIColor.yellow.cgColor
        leftHighlight.layer.borderWidth = 3
        leftHighlight.layer.cornerRadius = 6
        leftHighlight.alpha = 0
        leftTilesContainer.addSubview(leftHighlight)
        
        UIView.animate(withDuration: 0.3) {
            leftHighlight.alpha = 1
        }
        
        // Highlight right tile after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let rightHighlight = UIView(frame: rightView.frame)
            rightHighlight.backgroundColor = .clear
            rightHighlight.layer.borderColor = UIColor.yellow.cgColor
            rightHighlight.layer.borderWidth = 3
            rightHighlight.layer.cornerRadius = 6
            rightHighlight.alpha = 0
            self.rightTilesContainer.addSubview(rightHighlight)
            
            UIView.animate(withDuration: 0.3) {
                rightHighlight.alpha = 1
            }
            
            // Draw demo line
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.drawDemoLine(from: leftView, to: rightView, on: overlayView)
                
                // Remove tutorial after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    UIView.animate(withDuration: 0.3, animations: {
                        overlayView.alpha = 0
                    }) { _ in
                        overlayView.removeFromSuperview()
                        leftHighlight.removeFromSuperview()
                        rightHighlight.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    func drawDemoLine(from leftView: UIView, to rightView: UIView, on overlayView: UIView) {
        let leftCenter = leftView.convert(CGPoint(x: leftView.bounds.midX, y: leftView.bounds.midY), to: overlayView)
        let rightCenter = rightView.convert(CGPoint(x: rightView.bounds.midX, y: rightView.bounds.midY), to: overlayView)
        
        let path = UIBezierPath()
        path.move(to: leftCenter)
        path.addLine(to: rightCenter)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.yellow.cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.lineCap = .round
        
        overlayView.layer.addSublayer(shapeLayer)
        
        // Animate line drawing
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 0.5
        shapeLayer.add(animation, forKey: "drawLine")
    }
}

// MARK: - Actions
extension GameplayViewController {
    
    @objc func handleReturnAction() {

        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleHintAction() {
        guard isMemoryModeEnabled else { return }
        guard hintRevealWorkItem == nil else {

            return
        }
        hintButton.animateBounce()
        triggerHintReveal()
    }
    
    @objc func handleVerificationAction() {
        verificationButton.animateBounce()

        
        guard !connections.isEmpty else {
            showAlert(message: "Please connect the tiles first!")

            return
        }
        
        var correctCount = 0
        var incorrectCount = 0
        
        // Verify each connection
        for (index, connection) in connections.enumerated() {
            let leftEntity = leftTileEntities[connection.0]
            let rightEntity = rightTileEntities[connection.1]
            
            // Correct answer: same magnitude (category no longer matters)
            let isCorrect = leftEntity.magnitude == rightEntity.magnitude
            

            
            if isCorrect {
                correctCount += 1
                // Change line color to green
                connectionLayers[index].strokeColor = UIColor.mahjongSuccess.cgColor
                addVerificationIcon(at: connection, isCorrect: true)
            } else {
                incorrectCount += 1
                // Change line color to red
                connectionLayers[index].strokeColor = UIColor.mahjongAccent.cgColor
                addVerificationIcon(at: connection, isCorrect: false)
            }
        }
        
        // Update score
        let points = correctCount * 10
        currentScore += points
        updateScoreDisplay()
        
        if isMemoryModeEnabled {
            hintRevealWorkItem?.cancel()
            hintRevealWorkItem = nil
            hintPreviouslyHiddenTiles.removeAll()
            setTilesRevealed(true, animated: true)
            updateHintButtonState()
        }
        
        if incorrectCount == 0 {
            consecutiveCorrect += 1
        } else {
            consecutiveCorrect = 0
        }
        
        verificationButton.isEnabled = false
        verificationButton.alpha = 0.5
        
        // Persist record for this round
        saveGameRecord()
        
        // Automatically start next round after a short delay
        let isPerfectRound = incorrectCount == 0
        let nextRoundDelay: TimeInterval = isPerfectRound ? 1.8 : 2.5
        
        DispatchQueue.main.asyncAfter(deadline: .now() + nextRoundDelay) {
            self.startNewRound()
        }
    }
    
    @objc func handleResetAction() {
        resetButton.animateBounce()
        clearConnections()
        verificationButton.isEnabled = true
        verificationButton.alpha = 1.0
        
        // Remove verification icons
        connectionCanvas.subviews.forEach { $0.removeFromSuperview() }
        prepareMemoryModeIfNeeded()
    }
    
    func addVerificationIcon(at connection: (Int, Int), isCorrect: Bool) {
        let leftView = leftTileViews[connection.0]
        let rightView = rightTileViews[connection.1]
        
        let leftCenter = leftView.convert(CGPoint(x: leftView.bounds.midX, y: leftView.bounds.midY), to: connectionCanvas)
        let rightCenter = rightView.convert(CGPoint(x: rightView.bounds.midX, y: rightView.bounds.midY), to: connectionCanvas)
        
        let midPoint = CGPoint(x: (leftCenter.x + rightCenter.x) / 2, y: (leftCenter.y + rightCenter.y) / 2)
        
        let iconView = UIImageView()
        let configuration = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        iconView.image = UIImage(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill", withConfiguration: configuration)
        iconView.tintColor = isCorrect ? UIColor.mahjongSuccess : UIColor.mahjongAccent
        iconView.frame = CGRect(x: midPoint.x - 15, y: midPoint.y - 15, width: 30, height: 30)
        iconView.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        iconView.applyCornerRadius(15)
        
        connectionCanvas.addSubview(iconView)
        iconView.animateBounce()
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func startNewRound() {
        clearConnections()
        connectionCanvas.subviews.forEach { $0.removeFromSuperview() }
        initializeGameSession()
        verificationButton.isEnabled = true
        verificationButton.alpha = 1.0
        
        // Force layout for new tiles
        view.layoutIfNeeded()
        layoutTileViews()
    }
    
    func saveGameRecord() {
        let record = GameRecordEntity(score: currentScore, timestamp: Date())
        GameRecordManager.shared.appendRecord(record)
    }
}

// MARK: - Tile Interactive View
class TileInteractiveView: UIView, UIGestureRecognizerDelegate {
    
    let entity: MahjongTileEntity
    let index: Int
    var tapHandler: ((Int) -> Void)?
    private(set) var isRevealed: Bool = true
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.backgroundColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let coverView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.05, alpha: 0.92)
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor(white: 1.0, alpha: 0.2).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private let coverLabel: UILabel = {
        let label = UILabel()
        label.text = "?"
        label.font = .mahjongTitle(size: 26)
        label.textColor = UIColor(white: 1.0, alpha: 0.9)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    init(entity: MahjongTileEntity, index: Int) {
        self.entity = entity
        self.index = index
        super.init(frame: .zero)
        configureAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureAppearance() {
        // Enable user interaction
        isUserInteractionEnabled = true
        
        addSubview(imageView)
        imageView.image = entity.imagery
        imageView.anchorToSuperview()
        imageView.isUserInteractionEnabled = false // Image view doesn't need interaction
        
        addSubview(coverView)
        coverView.anchorToSuperview()
        coverView.layer.cornerRadius = 6
        coverView.layer.masksToBounds = true
        coverView.alpha = 0
        
        coverView.addSubview(coverLabel)
        NSLayoutConstraint.activate([
            coverLabel.centerXAnchor.constraint(equalTo: coverView.centerXAnchor),
            coverLabel.centerYAnchor.constraint(equalTo: coverView.centerYAnchor)
        ])
        
        // Apply corner radius and clipping
        layer.cornerRadius = 6
        layer.masksToBounds = true
        clipsToBounds = true
        
        applyBorderStyling(width: 2, color: UIColor(white: 0.9, alpha: 1.0))
        
        // Shadow needs to be on parent or separate view since clipsToBounds conflicts with shadow
        backgroundColor = .white
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.delegate = self
        tapGesture.cancelsTouchesInView = false // Allow touch events to propagate
        addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap() {

        tapHandler?(index)
    }
    
    func setRevealed(_ revealed: Bool, animated: Bool) {
        isRevealed = revealed
        let updates = {
            self.coverView.alpha = revealed ? 0 : 1
        }
        if animated {
            UIView.transition(with: coverView, duration: 0.25, options: .transitionCrossDissolve, animations: updates)
        } else {
            updates()
        }
    }
    
    // Allow gesture recognizer to work with others
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

