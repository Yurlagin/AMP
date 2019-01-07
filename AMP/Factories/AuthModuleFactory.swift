protocol AuthModuleFactory {
  func makeSignInOutput() -> (SignInView, SignInModuleOutput)
}
