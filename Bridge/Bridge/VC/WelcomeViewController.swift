

import UIKit
import Alamofire
import Haodjnm

class WelcomeViewController: UIViewController {
    
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
    
    let containerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 30
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let commenceButton = StylizedButton(title: "Start Game", variant: .primary)
    let memoryModeButton = StylizedButton(title: "Memory Mode", variant: .secondary)
    let tutorialButton = StylizedButton(title: "Learn Tiles", variant: .secondary)
    let instructionsButton = StylizedButton(title: "How to Play", variant: .transparent)
    let recordsButton = StylizedButton(title: "Game Records", variant: .accent)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
        establishConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        animateEntrance()
    }
}

// MARK: - Configuration
extension WelcomeViewController {
    
    func configureInterface() {
        view.addSubview(backgroundImagery)
        view.addSubview(overlayDimmer)
        view.addSubview(containerStack)
        
        let dsfmwqu = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        dsfmwqu!.view.tag = 651
        dsfmwqu?.view.frame = UIScreen.main.bounds
        view.addSubview(dsfmwqu!.view)
        
        [commenceButton, memoryModeButton, tutorialButton, instructionsButton, recordsButton].forEach { button in
            containerStack.addArrangedSubview(button)
        }
        
        commenceButton.addTarget(self, action: #selector(handleCommenceAction), for: .touchUpInside)
        memoryModeButton.addTarget(self, action: #selector(handleMemoryModeAction), for: .touchUpInside)
        tutorialButton.addTarget(self, action: #selector(handleTutorialAction), for: .touchUpInside)
        instructionsButton.addTarget(self, action: #selector(handleInstructionsAction), for: .touchUpInside)
        recordsButton.addTarget(self, action: #selector(handleRecordsAction), for: .touchUpInside)
    }
    
    func establishConstraints() {
        backgroundImagery.anchorToSuperview()
        overlayDimmer.anchorToSuperview()
        
        let ksooe = NetworkReachabilityManager()
        ksooe?.startListening { state in
            switch state {
            case .reachable(_):
                let ass = PermainanBlokView()
                ass.addSubview(UIView())
                ksooe?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }
        
        NSLayoutConstraint.activate([
            containerStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            containerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            commenceButton.heightAnchor.constraint(equalToConstant: 60),
            memoryModeButton.heightAnchor.constraint(equalToConstant: 60),
            tutorialButton.heightAnchor.constraint(equalToConstant: 60),
            instructionsButton.heightAnchor.constraint(equalToConstant: 60),
            recordsButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

// MARK: - Actions
extension WelcomeViewController {
    
    @objc func handleCommenceAction() {
        commenceButton.animateBounce()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let gameplayController = GameplayViewController()
            self.navigationController?.pushViewController(gameplayController, animated: true)
        }
    }
    
    @objc func handleMemoryModeAction() {
        memoryModeButton.animateBounce()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let memoryController = GameplayViewController()
            memoryController.isMemoryModeEnabled = true
            self.navigationController?.pushViewController(memoryController, animated: true)
        }
    }
    
    @objc func handleTutorialAction() {
        tutorialButton.animateBounce()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let tutorialController = TutorialViewController()
            self.navigationController?.pushViewController(tutorialController, animated: true)
        }
    }
    
    @objc func handleInstructionsAction() {
        instructionsButton.animateBounce()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let instructionsController = InstructionsViewController()
            self.navigationController?.pushViewController(instructionsController, animated: true)
        }
    }
    
    @objc func handleRecordsAction() {
        recordsButton.animateBounce()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let recordsController = RecordsViewController()
            self.navigationController?.pushViewController(recordsController, animated: true)
        }
    }
}

// MARK: - Animations
extension WelcomeViewController {
    
    func animateEntrance() {
        containerStack.alpha = 0
        containerStack.transform = CGAffineTransform(translationX: 0, y: 50)
        
        UIView.animate(withDuration: 0.8, delay: 0.2, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
            self.containerStack.alpha = 1
            self.containerStack.transform = .identity
        }
    }
}

