protocol AuthCoordinatorOutput: class {
  var onFinishFlow: (() -> Void)? { get set }
}
