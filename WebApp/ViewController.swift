import UIKit
import WebKit

let defaultUrl = URL(string: "https://www.nerdwallet.com/blog/how-we-make-money/")!

class ViewController: UIViewController {
    private let url: URL
    private lazy var webView: WKWebView = createWebView()
    private var observers = [NSKeyValueObservation]()
    private var progressView = UIProgressView(progressViewStyle: .bar)

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

        configureWebView()

        // Loading remote content
        webView.load(url)
    }

    deinit {
        observers.forEach { observer in
            observer.invalidate()
        }
    }

    // MARK: - private

    private func createWebView() -> WKWebView {
        let config = WKWebViewConfiguration()

        // The name of the application as used in the user agent string
        config.applicationNameForUserAgent = "AwesomeApp"
        // Don't suppresses content rendering
        config.suppressesIncrementalRendering = false
        // enable all data detectors
        config.dataDetectorTypes = [.all]

        return WKWebView(frame: .zero, configuration: config)
    }

    private func configureWebView() {
        webView.navigationDelegate = self
        webView.uiDelegate = self

        // horizontal swipe gestures will trigger back-forward navigation
        webView.allowsBackForwardNavigationGestures = true

        observers = [
            // Observe loading progress
            webView.observe(\WKWebView.estimatedProgress, options: .new) { [weak self] webView, _ in
                print("\(String(format: "%.2f", webView.estimatedProgress * 100))%")
                self?.progressView.progress = Float(webView.estimatedProgress)
            },
            // Reading the web page’s title as it changes
            webView.observe(\WKWebView.title, options: .new) { [weak self] webView, _ in
                self?.title = webView.title
            },
        ]

        // custom user agent string
        webView.customUserAgent = "NerdWallet/1.0.0"

        if let navBar = navigationController?.navigationBar {
            progressView.translatesAutoresizingMaskIntoConstraints = false
            navBar.addSubview(progressView)
            NSLayoutConstraint.activate([
                progressView.topAnchor.constraint(equalTo: navBar.bottomAnchor),
                progressView.leftAnchor.constraint(equalTo: navBar.leftAnchor),
                progressView.rightAnchor.constraint(equalTo: navBar.rightAnchor),
                progressView.heightAnchor.constraint(equalToConstant: 1),
            ])
        }
    }
}

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

extension ViewController: WKUIDelegate {
    func webView(_: WKWebView,
                 createWebViewWith _: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures _: WKWindowFeatures) -> WKWebView? {
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
