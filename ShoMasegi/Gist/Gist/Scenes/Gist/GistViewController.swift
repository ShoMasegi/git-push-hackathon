import UIKit
import SnapKit
import MaterialComponents.MaterialBottomAppBar
import MaterialComponents.MaterialBottomAppBar_ColorThemer
import MaterialComponents.MaterialButtons_ButtonThemer

class GistViewController: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .primary_main
        setupSubviews()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutBottomAppBar()
    }

    @available(iOS 11, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        layoutBottomAppBar()
    }

    private lazy var bottomBarView: MDCBottomAppBarView = {
        let view = MDCBottomAppBarView()
        view.floatingButtonPosition = .center
        view.autoresizingMask = [ .flexibleWidth, .flexibleTopMargin ]
        let image = UIImage(named: "add")?.withRenderingMode(.alwaysOriginal)
        view.floatingButton.setImage(image, for: .normal)
        view.trailingBarButtonItems = [ barButtonTrailingItem ]
        view.leadingBarButtonItems = [ barButtonLeadingItem ]
        let buttonScheme = MDCButtonScheme()
        buttonScheme.colorScheme = colorScheme
        MDCFloatingActionButtonThemer.applyScheme(buttonScheme, to: view.floatingButton)
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
        view.image = UIImage(named: "menu")?.withRenderingMode(.alwaysOriginal)
        return view
    }()

    private lazy var barButtonTrailingItem: UIBarButtonItem = {
        let view = UIBarButtonItem()
        view.image = UIImage(named: "search")?.withRenderingMode(.alwaysOriginal)
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
        [bottomBarView].forEach(view.addSubview)
    }
}
