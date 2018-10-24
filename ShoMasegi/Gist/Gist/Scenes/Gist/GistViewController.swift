import UIKit
import SnapKit
import RxCocoa
import RxSwift
import Domain
import MaterialComponents.MaterialAppBar
import MaterialComponents.MaterialBottomAppBar
import MaterialComponents.MaterialBottomAppBar_ColorThemer
import MaterialComponents.MaterialButtons_ButtonThemer

class GistViewController: UIViewController {

    private let viewModel: GistViewModel
    private let bag = DisposeBag()

    init(viewModel: GistViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .primary_main
        setupSubviews()
        bind()
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

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .primary_main
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
        tableView.separatorColor = .primary_900
        tableView.refreshControl = refreshControl
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomBarView.floatingButton.bounds.height, right: 0)
        tableView.tableFooterView = UIView()
        tableView.register(GistTableViewCell.self)
        return tableView
    }()
    private let refreshControl = UIRefreshControl()

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
        [tableView, bottomBarView].forEach(view.addSubview)
        tableView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            if #available(iOS 11, *) {
                $0.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            } else {
                $0.top.equalToSuperview()
            }
            $0.bottom.equalTo(bottomBarView.snp.top).offset(bottomBarView.floatingButton.bounds.height)
        }
    }

    private func bind() {
        let trigger: PublishSubject<Void> = PublishSubject<Void>()
        defer { trigger.onNext(()) }
        let initTrigger = trigger.asDriver(onErrorJustReturn: ())
        let refreshTrigger = refreshControl.rx.controlEvent(.valueChanged).asDriver()
        let loadNextPageTrigger = tableView.rx.reachedBottom.asDriverOnErrorJustComplete()
        let input = GistViewModel.Input(
                initTrigger:  initTrigger,
                refreshTrigger: refreshTrigger,
                loadNextPageTrigger: loadNextPageTrigger,
                modelSelected: tableView.rx.modelSelected(Gist.self).asDriver()
        )
        let output = viewModel.transform(input: input)
        output.gists.drive(tableView.rx.items(cellIdentifier: GistTableViewCell.reuseIdentifier, cellType: GistTableViewCell.self)) { _, element, cell in
            cell.gist = element
        }.disposed(by: bag)
        output.refreshing.drive(onNext: { [weak self] fetching in
            guard let `self` = self else { return }
            if fetching {
                self.refreshControl.beginRefreshing()
            } else {
                self.refreshControl.endRefreshing()
            }
        }).disposed(by: bag)
        output.isNavigated.drive().disposed(by: bag)
        output.error.drive(onNext: { error in
            if let apiError = error as? APIError {
                self.presentAlert(title: "Error", message: apiError.message)
            } else {
                print(error.localizedDescription)
            }
        }).disposed(by: bag)
        tableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            guard let `self` = self else { return }
            self.tableView.deselectRow(at: indexPath, animated: true)
        }).disposed(by: bag)
    }
}
