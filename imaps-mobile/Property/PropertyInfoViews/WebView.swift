import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let request: URLRequest

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(request)
    }
    
    // Coordinator to handle navigation
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if UIDevice.current.userInterfaceIdiom == .pad {
                let javascript = """
                var viewportMeta = document.querySelector('meta[name=viewport]');
                if (!viewportMeta) {
                    var newMeta = document.createElement('meta');
                    newMeta.name = 'viewport';
                    newMeta.content = 'width=device-width, initial-scale=1.0';
                    document.getElementsByTagName('head')[0].appendChild(newMeta);
                }
                """
                webView.evaluateJavaScript(javascript, completionHandler: nil)
            }

        }
    }
}


#if DEBUG
struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
