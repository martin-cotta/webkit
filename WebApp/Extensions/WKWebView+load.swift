import WebKit

extension WKWebView {
    func load(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            load(request)
        }
    }

    func load(_ url: URL) {
        let request = URLRequest(url: url)
        load(request)
    }
}
