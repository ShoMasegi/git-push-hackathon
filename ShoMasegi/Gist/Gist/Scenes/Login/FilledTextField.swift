import UIKit
import RxCocoa
import RxSwift
import SnapKit

@objc protocol FilledTextFieldDelegate: class {
    @objc optional func filledTextFieldDidBeginFocusing(_ textField: FilledTextField)
    @objc optional func filledTextFieldDidEndFocusing(_ textField: FilledTextField)
    @objc optional func filledTextField(_ filledTextField: FilledTextField, textFieldTextDidChange _: String?)
    @objc optional func filledTextFieldDidReturn(_ filledTextField: FilledTextField)
}

class FilledTextField: UIView {

    weak var delegate: FilledTextFieldDelegate?

    var defaultPlaceholderText = "Placeholder" {
        didSet {
            placeholderLabel.text = defaultPlaceholderText
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder _: NSCoder) { fatalError() }

    // Fixed ios11 bugs https://stackoverflow.com/a/44932834
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }

    private let bag = DisposeBag()

    lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        return view
    }()
    lazy var textField: UITextField = {
        let view = UITextField()
        view.font = UIFont.systemFont(ofSize: 18)
        view.textColor = .white
        view.backgroundColor = .clear
        view.delegate = self
        view.rx.controlEvent([.editingChanged]).subscribe(onNext: { [unowned self, view] in
            self.delegate?.filledTextField?(self, textFieldTextDidChange: view.text)
        }).disposed(by: bag)
        return view
    }()
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.backgroundColor = UIColor(hex: "27272F")
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe(onNext: { [unowned self] _ in
            self.textField.becomeFirstResponder()
        }).disposed(by: bag)
        view.addGestureRecognizer(tap)
        return view
    }()
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = defaultPlaceholderText
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.primary_400
        return label
    }()

    private func setupSubviews() {
        addSubview(backgroundView)
        [iconImageView, placeholderLabel, textField].forEach(backgroundView.addSubview)
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        iconImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.height.width.equalTo(24)
            $0.top.left.bottom.equalToSuperview().inset(16)
        }
        textField.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(iconImageView.snp.right).offset(16)
            $0.right.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview().inset(8)
        }
        placeholderLabel.snp.makeConstraints {
            $0.edges.equalTo(textField)
        }
    }

    private func changeBackgroundColor(isFocused: Bool) {
        backgroundView.backgroundColor = isFocused ? UIColor(hex: "43434C") : UIColor(hex: "27272F")
    }
}

extension FilledTextField: UITextFieldDelegate {
    func textField(_: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let isEmpty = range.location == 0 && (string.isEmpty || string == "\n")
        if isEmpty {
            placeholderLabel.text = defaultPlaceholderText
        }
        placeholderLabel.isHidden = !isEmpty
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        let isHidden = textField.text?.isEmpty == false
        placeholderLabel.isHidden = isHidden
        self.delegate?.filledTextFieldDidBeginFocusing?(self)
        changeBackgroundColor(isFocused: true)
    }

    func textFieldShouldClear(_: UITextField) -> Bool {
        placeholderLabel.isHidden = false
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        let isEmpty = textField.text?.isEmpty ?? false
        placeholderLabel.isHidden = !isEmpty
        changeBackgroundColor(isFocused: !isEmpty)
        placeholderLabel.text = defaultPlaceholderText
        delegate?.filledTextFieldDidEndFocusing?(self)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.textField {
            textField.resignFirstResponder()
            delegate?.filledTextFieldDidReturn?(self)
            return false
        }
        return true
    }
}
