import Foundation

public protocol NetworkUseCaseProvider {
    func makeLoginUseCase() -> LoginUseCase
    func makeGistUseCase() -> GistUseCase
}
