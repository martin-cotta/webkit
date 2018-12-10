import UIKit
import WebKit

let defaultUrl = URL(string: "https://www.nerdwallet.com/blog/how-we-make-money/")!

class ViewController: UIViewController {
    private lazy var webView: WKWebView = createWebView()
    private let url: URL

    // MARK: - initializer

    init(url: URL? = nil) {
        self.url = url ?? defaultUrl
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        // Making the web view fill the screen
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        webView.allowsBackForwardNavigationGestures = true

        webView.navigationDelegate = self
        webView.uiDelegate = self

        // Reading the web page’s title as it changes
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)

        // Loading remote content
        webView.load(url)
    }

    // MARK: -

    override func observeValue(forKeyPath keyPath: String?,
                               of _: Any?,
                               change _: [NSKeyValueChangeKey: Any]?,
                               context _: UnsafeMutableRawPointer?) {
        if keyPath == "title" {
            if let title = webView.title {
                self.title = title
            }
        }
    }

    // MARK: - private

    private func createWebView() -> WKWebView {
        let config = WKWebViewConfiguration()
        config.applicationNameForUserAgent = "AwesomeApp"
        // enable all data detectors
        config.dataDetectorTypes = [.all]

        return WKWebView(frame: .zero, configuration: config)
    }
}

extension ViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        print("webView decidePolicyFor: ", navigationAction.request.url?.absoluteString.truncated() ?? "")

        // JS window open or target="_blank" tag
        if navigationAction.navigationType == .linkActivated {
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
