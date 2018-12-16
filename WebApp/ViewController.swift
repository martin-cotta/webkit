import UIKit
import WebKit

let defaultUrl = URL(string: "https://www.nerdwallet.com/blog/how-we-make-money/")!

class ViewController: UIViewController {
    private let url: URL
    private lazy var webView: WKWebView = createWebView()
    private var observers = [NSKeyValueObservation]()
    var progressView = UIProgressView(progressViewStyle: .bar)

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
