import Foundation

extension String {
  
  func stringByTrimingWhitespace() -> String {
    return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    
  }
}
