protocol SignInView: BaseView {
  var onComplete: (() -> ())? { get set }
}
