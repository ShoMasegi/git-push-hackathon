import UIKit

protocol FadeTransitionable: class {
    var current: UIViewController? { get set }
}

extension FadeTransitionable where Self: UIViewController {
    func setupCurrent() {
        guard let current = self.current else {
            return
        }
        addChild(current)
        current.view.frame = view.bounds
        view.addSubview(current.view)
        current.didMove(toParent: self)
    }

    func animateFadeTransition(to toViewController: UIViewController, completion: (() -> Void)? = nil) {
        guard let current = self.current else {
            return
        }
        current.willMove(toParent: nil)
        addChild(toViewController)
        transition(
            from: current,
            to: toViewController,
            duration: 0.3,
            options: [.transitionCrossDissolve, .curveEaseOut],
            animations: nil,
            completion: { [weak self] _ in
                guard let `self` = self else { return }
                self.current?.removeFromParent()
                toViewController.didMove(toParent: self)
                self.current = toViewController
                self.setNeedsStatusBarAppearanceUpdate()
                completion?()
        })
    }
}
