import UIKit
import SnapKit

class LockViewController: UIViewController {

    enum LockType {
        case badRequest
        case forbidden
        case unprocessableEntity
        case notFound

        var title: String {
            switch self {
            case .badRequest: return "Bad Request"
            case .forbidden: return "Forbidden"
            case .unprocessableEntity: return "Unprocessable Entity"
            case .notFound: return "Not Found"
            }
        }

        var url: String {
            return "https://github.com/ShoMasegi/git-push-hackathon"
        }
    }

    private let type: LockType

    init(type: LockType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func appDidBecomeActive() {
        Application.shared.rootViewController.animateFadeTransition(to: SplashViewController())
    }
}
