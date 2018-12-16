import WebKit

extension ViewController: WKNavigationDelegate {

    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        // reset the progress view value after each request
        progressView.setProgress(0.0, animated: false)
    }
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        print("webView decidePolicyFor: ", url.absoluteString.truncated())
        
        if navigationAction.navigationType == .linkActivated {
            // use external browser for external urls
            if url.host != defaultUrl.host {
                UIApplication.shared.open(url, options: [:])
                decisionHandler(.cancel)
                return
            }
            
            // JS window open or target="_blank" tag
            if navigationAction.targetFrame == nil ||
                !(navigationAction.targetFrame?.isMainFrame ?? false) {
                // 1. open url in Safari
                UIApplication.shared.open(url, options: [:])
                
                // 2. or load url in current webView
                // webView.load(navigationAction.request)
                
                // 3. or make new WKWebView and open the url
                // let vc = ViewController(url: url)
                // navigationController?.pushViewController(vc, animated: true)
                
                decisionHandler(.cancel)
                return
            }
        }
        
        decisionHandler(.allow)
    }
}
