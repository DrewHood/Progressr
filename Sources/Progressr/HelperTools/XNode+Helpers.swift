import PerfectXML

extension XNode {
  func childNode(_ nodeName: String) -> XElement? {
    return self.childNodes.filter({$0.nodeName == nodeName}).first as? XElement
  }

  func childValue(_ nodeName: String) -> String? {
    return self.childNodes.filter({$0.nodeName == nodeName}).first?.nodeValue
  }
}
