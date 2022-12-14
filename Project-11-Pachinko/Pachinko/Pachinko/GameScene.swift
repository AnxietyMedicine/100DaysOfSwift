//
//  GameScene.swift
//  Pachinko
//
//  Created by Matt X on 11/30/22.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    enum NodeName: String {
        case bad, ball, box, good
    }
    
    enum BallColor: String, CaseIterable {
        case blue = "ballBlue"
        case cyan = "ballCyan"
        case green = "ballGreen"
        case grey = "ballGrey"
        case purple = "ballPurple"
        case red = "ballRed"
        case yellow = "ballYellow"
    }
    
    var editLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!
    
    var ballCount = 5
    
    var editingMode = false {
        didSet {
            editLabel.text = editingMode ? "Done" : "Edit"
        }
    }
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        var isGoodSlot = true
        for xPos in stride(from: 128, through: 896, by: 256) {
            makeSlot(at: CGPoint(x: xPos, y: 0), isGood: isGoodSlot)
            isGoodSlot.toggle()
        }
        
        for xPos in stride(from: 0, through: 1024, by: 256) {
            makeBouncer(at: CGPoint(x: xPos, y: 0))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let objects = nodes(at: location)
        
        if objects.contains(editLabel) {
            editingMode.toggle()
        } else {
            if editingMode {
                makeBox(at: location)
            } else {
                if ballCount > 0 {
                    makeRandomBall(at: location)
                    ballCount -= 1
                }
            }
        }
    }
    
    func makeBox(at position: CGPoint) {
        let randomWidth = Int.random(in: 16...128)
        let randomColor = UIColor(
            red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: 1
        )
        let randomRotation = CGFloat.random(in: 0...3)
        let size = CGSize(width: randomWidth, height: 16)
        
        let box = SKSpriteNode(color: randomColor, size: size)
        box.zRotation = randomRotation
        box.position = position
        box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
        box.physicsBody?.isDynamic = false
        box.name = NodeName.box.rawValue
        addChild(box)
    }
    
    func makeRandomBall(at position: CGPoint) {
        let randomBallColor = BallColor.allCases.randomElement()?.rawValue ?? "ballRed"
        let ball = SKSpriteNode(imageNamed: randomBallColor)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody?.restitution = 0.4
        ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
        ball.position = CGPoint(x: position.x, y: 748) // Force balls to top of screen
        ball.name = NodeName.ball.rawValue
        addChild(ball)
    }
    
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        let slotBase: SKSpriteNode
        let slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotBase.name = NodeName.good.rawValue
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotBase.name = NodeName.bad.rawValue
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collision(between ball: SKNode, object: SKNode) {
        switch object.name {
        case NodeName.good.rawValue:
            destroy(ball: ball)
            score += 1
            ballCount += 1
        case NodeName.bad.rawValue:
            destroy(ball: ball)
            score -= 1
        case NodeName.box.rawValue:
            destroy(box: object)
        default:
            break
        }
        
//        if object.name == NodeName.good.rawValue {
//            destroy(ball: ball)
//            score += 1
//            ballCount += 1
//        } else if object.name == NodeName.bad.rawValue {
//            destroy(ball: ball)
//            score -= 1
//        } else if object.name == NodeName.box.rawValue {
//            print("HIT BOX!")
//        }
    }
    
    func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        
        ball.removeFromParent()
    }
    
    func destroy(box: SKNode) {
        box.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == NodeName.ball.rawValue {
            collision(between: nodeA, object: nodeB)
        } else if nodeB.name == NodeName.ball.rawValue {
            collision(between: nodeB, object: nodeA)
        }
    }
}
