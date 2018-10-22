import RxCocoa
import RxSwift
import UIKit

final class FilledTextFieldDelegateProxy:
        DelegateProxy<FilledTextField, FilledTextFieldDelegate>,
        FilledTextFieldDelegate,
DelegateProxyType {

    init(filledTextField: FilledTextField) {
        super.init(parentObject: filledTextField, delegateProxy: FilledTextFieldDelegateProxy.self)
    }

    static func registerKnownImplementations() {
        register { FilledTextFieldDelegateProxy(filledTextField: $0) }
    }
    
    static func currentDelegate(for object: FilledTextField) -> FilledTextFieldDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: FilledTextFieldDelegate?, to object: FilledTextField) {
        object.delegate = delegate
    }
}

extension Reactive where Base: FilledTextField {
    var delegate: DelegateProxy<FilledTextField, FilledTextFieldDelegate> {
        return FilledTextFieldDelegateProxy.proxy(for: base)
    }

    var didEndFocusing: ControlEvent<String?> {
        let source = delegate.methodInvoked(#selector(FilledTextFieldDelegate.filledTextFieldDidEndFocusing(_:)))
                .map { params -> String? in
                    let textField = try castOrThrow(FilledTextField.self, params[0])
                    return textField.textField.text
                }
        return ControlEvent(events: source)
    }

    var textDidChange: ControlProperty<String?> {
        let source = delegate.methodInvoked(#selector(FilledTextFieldDelegate.filledTextField(_:textFieldTextDidChange:)))
                .map { params -> String? in
                    let text = try castOrThrow(String.self, params[1])
                    return text
                }
        let bindingObserver = Binder(base) { (filledTextField, text: String?) in
            filledTextField.textField.text = text
        }
        return ControlProperty(values: source, valueSink: bindingObserver)
    }

    var didReturn: ControlEvent<String?> {
        let source = delegate.methodInvoked(#selector(FilledTextFieldDelegate.filledTextFieldDidReturn(_:)))
                .map { params -> String? in
                    let textField = try castOrThrow(FilledTextField.self, params[0])
                    return textField.textField.text
                }
        return ControlEvent(events: source)
    }
}

func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    return returnValue
}
