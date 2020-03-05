//
//  ViewController.swift
//  LayerTest
//
//  Created by Dung Vu on 3/4/20.
//  Copyright © 2020 Dung Vu. All rights reserved.
//

import UIKit

final class PieView: UIView {
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    private lazy var mLayer: CAShapeLayer? = {
        return self.layer as? CAShapeLayer
    }()
    
    var fillColor: UIColor = .black {
        didSet { setNeedsDisplay() }
    }
    
    var progress: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        common()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        common()
    }
    
    private func common() {
        backgroundColor = .clear
        self.isOpaque = false
        self.layer.contentsScale = UIScreen.main.scale
        mLayer?.shouldRasterize = true
    }
    
    private func generatePath() -> CGPath {
        let circleRect = self.bounds
        let path = UIBezierPath()
        let radius = min(circleRect.midX, circleRect.midY)
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * CGFloat.pi * progress
        path.move(to: CGPoint(x:center.x , y: center.y))
        path.addArc(withCenter: CGPoint(x: circleRect.midX, y: circleRect.midY), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.close()
        path.fill()
        return path.cgPath
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        mLayer?.fillColor = fillColor.cgColor
        mLayer?.path = generatePath()
    }
}

final class MaskedPieView: UIView {
    private lazy var pieView = PieView(frame: .zero)
    var progress: CGFloat = 0 {
        didSet { pieView.progress = progress }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        common()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        common()
    }
    
    private func common() {
        self.mask = pieView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pieView.frame = bounds
    }
}

typealias DisplayLinkHandler = (_ display: CADisplayLink?) -> ()
final class DisplayLinkBlock: NSObject {
    private let handler: DisplayLinkHandler
    private var displayLink: CADisplayLink?
    init(use handler: @escaping DisplayLinkHandler) {
        self.handler = handler
        super.init()
    }
    
    func start() {
        self.displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .current, forMode: .common)
    }
    
    @objc private func update() {
        handler(displayLink)
    }
}


class ViewController: UIViewController {
    @IBOutlet var progressLayer : UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        let time: TimeInterval = 30
        var progress: CGFloat = 0
        progressLayer.backgroundColor = .clear
        
        let pieView = MaskedPieView(frame: progressLayer.bounds)
        pieView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2)
        progressLayer.addSubview(pieView)
        let label = UILabel(frame: progressLayer.bounds)
        label.textAlignment = .center
        progressLayer.addSubview(label)
//        Timer.scheduledTimer(withTimeInterval: time / 100, repeats: true) { (timer) in
//            progress += 0.01
//            pieView.progress = min(progress, 1)
//            guard progress >= 1 else {
//                return
//            }
//            timer.invalidate()
//        }
        let delta: CGFloat = CGFloat(1 / (time * 60))
        let date = Date()
        let item = DisplayLinkBlock { (display) in
            progress += delta
            print("\(progress)")
            let result = min(progress, 1)
            pieView.progress = result
            label.text = String(format: "%.0f s", abs(date.timeIntervalSinceNow))
            guard progress >= 1 else {
                return
            }
            display?.invalidate()
        }
        item.start()
        
    }


}

