import UIKit
import SnapKit
import RxSwift
import RxCocoa
import SVProgressHUD
import MaterialComponents.MaterialBottomAppBar
import MaterialComponents.MaterialBottomAppBar_ColorThemer
import MaterialComponents.MaterialButtons_ButtonThemer

protocol WebViewControllerDelegate: class {
    func callback(in: WebViewController, code: String)
}

class WebViewController: UIViewController {

    private let bag = DisposeBag()
    private let url: URL
    private weak var delegate: WebViewControllerDelegate?


    init(url: URL, delegate: WebViewControllerDelegate?) {
        self.url = url
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .primary_main
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        webView.loadRequest(request)
        setupSubviews()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutBottomAppBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SVProgressHUD.dismiss()
    }

    @available(iOS 11, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        layoutBottomAppBar()
    }

    private lazy var webView: UIWebView = {
        let view = UIWebView()
        view.delegate = self
        return view
    }()

    private lazy var bottomBarView: MDCBottomAppBarView = {
        let view = MDCBottomAppBarView()
        view.isFloatingButtonHidden = true
        view.leadingBarButtonItems = [ barButtonLeadingItem ]
        MDCBottomAppBarColorThemer.applySurfaceVariant(withSemanticColorScheme: colorScheme, to: view)
        return view
    }()

    private lazy var colorScheme: MDCSemanticColorScheme = {
        let scheme = MDCSemanticColorScheme()
        scheme.primaryColor = .secondary_main
        scheme.surfaceColor = .primary_main
        return scheme
    }()

    private lazy var barButtonLeadingItem: UIBarButtonItem = {
        let view = UIBarButtonItem()
        view.image = UIImage(named: "close")?.withRenderingMode(.alwaysOriginal)
        view.rx.tap.subscribe(onNext: { [weak self] in
            self?.dismiss(animated: true)
        }).disposed(by: bag)
        return view
    }()

    private func layoutBottomAppBar() {
        let size = bottomBarView.sizeThatFits(view.bounds.size)
        let bottomBarViewFrame = CGRect(
                x: 0,
                y: view.bounds.size.height - size.height,
                width: size.width,
                height: size.height
        )
        bottomBarView.frame = bottomBarViewFrame
    }

    private func setupSubviews() {
        [webView, bottomBarView].forEach(view.addSubview)
        webView.snp.makeConstraints {
            if #available(iOS 11, *) {
                $0.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            } else {
                $0.top.equalToSuperview()
            }
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(bottomBarView.snp.top).offset(56)
        }
    }
}

extension WebViewController: UIWebViewDelegate {

    func webViewDidStartLoad(_ webView: UIWebView) {
        SVProgressHUD.show()
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        guard let url = request.url else { return true }
        if url.scheme == "gist", url.host == "github.login" {
            guard let urlComponents = URLComponents(string: url.absoluteString),
                    let code = urlComponents.queryItems?.first(where: { $0.name == "code" })?.value else {
                return true
            }
            delegate?.callback(in: self, code: code)
            dismiss(animated: true)
            return false
        }
        return true
    }
}
