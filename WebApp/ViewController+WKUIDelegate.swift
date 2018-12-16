import WebKit

extension ViewController: WKUIDelegate {
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {

        // JS window open or target="_blank" tag
        // If it's not being handle in decidePolicyFor navigationAction
        if let url = navigationAction.request.url {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:]) { result in
                    // whether the URL was opened successfully
                    print(result)
                }
            }
        }
        
        return nil
    }
}
