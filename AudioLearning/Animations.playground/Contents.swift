//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

extension UIView {
    func addPulseAnimation() {
        guard layer.animation(forKey: "pulse") == nil else { return }
        let pulseAnimation = CASpringAnimation(keyPath: "transform.scale")
        pulseAnimation.mass = 10 // 值越大，動畫時間越長
        pulseAnimation.stiffness = 50 // 彈簧鋼度係數 0~100
        pulseAnimation.damping = 10.0 // 反彈次數
        pulseAnimation.initialVelocity = 0.5 // 初始速度
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatDuration = Double.infinity
        pulseAnimation.fromValue = 0.75
        pulseAnimation.toValue = 1.0
//        pulseAnimation.repeatCount = 2
//        pulseAnimation.duration = 10
        layer.add(pulseAnimation, forKey: "pulse")
    }
}

class MyViewController: UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .black
        
        let side: CGFloat = 100
//        let ball = UIButton(frame: CGRect(x: 150, y: 200, width: side, height: side))
        let ball = UIView(frame: CGRect(x: 150, y: 200, width: side, height: side))
        ball.backgroundColor = UIColor.yellow
        ball.layer.cornerRadius = side / 2
        ball.clipsToBounds = true
        view.addSubview(ball)
        ball.addPulseAnimation()
        self.view = view
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
