import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import 'core/app_config.dart';

class WebGLWebViewScreen extends StatefulWidget {
  final String initialUrl;

  const WebGLWebViewScreen({
    super.key,
    this.initialUrl = 'https://flutter.dev',
  });

  @override
  State<WebGLWebViewScreen> createState() => _WebGLWebViewScreenState();
}

class UrlLauncherService {
  static Future<void> launchInBrowser({
    required String url,
    //required BuildContext context,
  }) async {
    try {
      final Uri uri = Uri.parse(url);

      // if (!await canLaunchUrl(uri)) {
      //   //  _showErrorSnackbar(context, 'Не удалось открыть ссылку');
      //   return;
      // }

      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // _showErrorSnackbar(context, 'Ошибка: $e');
    }
  }

  static void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

Future<void> _launchURL(String url) async {
  // NativeMethodCaller.callSwiftMethodWithParams({'url': url});
  // await LaunchApp.openApp(
  //   iosUrlScheme: url, // Example for Instagram
  // );
  UrlLauncherService.launchInBrowser(url: url);

  // if (await canLaunchUrl(Uri.parse(url))) {
  //   await launchUrl(
  //     Uri.parse(url),
  //     mode: LaunchMode.externalApplication, // Or other modes as needed
  //   );
  // } else {
  //   throw 'Could not launch $url';
  // }
}

class _WebGLWebViewScreenState extends State<WebGLWebViewScreen> {
  late final PlatformWebViewController controller;
  bool isLoading = true;
  String currentUrl = '';

  bool get kDebugMode => true;
  bool isFirstLoad = true;
  @override
  void initState() {
    super.initState();

    // Проверяем, есть ли сохраненная ссылка в хранилище
    String urlToLoad = AppConfig.webGLEndpoint;
    controller =
        WebKitWebViewController(
            WebKitWebViewControllerCreationParams(
              mediaTypesRequiringUserAction: const {},
              allowsInlineMediaPlayback: true,
            ),
          )
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..enableZoom(false)
          ..setPlatformNavigationDelegate(
            WebKitNavigationDelegate(
                const PlatformNavigationDelegateCreationParams(),
              )
              ..setOnPageStarted((String url) {
                setState(() {
                  isLoading = true;
                  currentUrl = url;
                });
              })
              ..setOnPageFinished((String url) async {
                if (isFirstLoad) {
                  await Future.delayed(const Duration(seconds: 6));
                  isFirstLoad = false;
                }
                setState(() {
                  isLoading = false;
                  currentUrl = url;
                });
              })
              ..setOnHttpError((HttpResponseError error) {
                debugPrint(
                  'Error occurred on page: ${error.response?.statusCode}',
                );
              })
              ..setOnWebResourceError((WebResourceError error) {
                // print(
                //   "error " +
                //       error.errorCode.toString() +
                //       "   url " +
                //       error.url!,
                // );
                if (error.errorCode == -1007 ||
                    error.errorCode == -9 ||
                    error.errorCode == -0) {
                  if (error.url != null) {
                    controller.loadRequest(
                      LoadRequestParams(uri: Uri.parse(error.url!)),
                    );
                    return;
                  }
                }
                // if (error.url!.contains("http://")) return;
                // if (error.url!.contains("https://")) return;
                // _launchURL(error.url!);
              })
              ..setOnUrlChange((UrlChange change) {
                //  debugPrint('url change to ${change.url}');
                if (change.url!.contains("http://")) return;
                if (change.url!.contains("https://")) return;
                print(change.url);
                _launchURL(change.url!); //change.url!);
              }),
          )
          ..setOnCanGoBackChange((onCanGoBackChangeCallback) {
            controller.canGoBack().then((onValue) {
              if (kDebugMode) {
                // print(
                //   "onValue " +
                //       onValue.toString() +
                //       " onCanGoBackChangeCallback " +
                //       onCanGoBackChangeCallback.toString(),
                // );
              }
              onCanGoBackChangeCallback = onValue;
            });
          })
          ..setOnPlatformPermissionRequest((
            PlatformWebViewPermissionRequest request,
          ) {
            debugPrint(
              'requesting permissions for ${request.types.map((WebViewPermissionResourceType type) => type.name)}',
            );
            request.grant();
          })
          ..setAllowsBackForwardNavigationGestures(true)
          ..getUserAgent().then((String? userAgent) {
            controller.setUserAgent(
              userAgent?.replaceAll("; wv", "").replaceAll("; wv", ""),
            );

            controller.loadRequest(
              LoadRequestParams(uri: Uri.parse(urlToLoad)),
            );
          });

    //controller.getSettings().setMediaPlaybackRequiresUserGesture(false);

    // Создаем контроллер WebView
    // controller = PlatformWebViewController(
    //   WebKitWebViewControllerCreationParams(allowsInlineMediaPlayback: true),
    // );

    //   controller
    //   controller

    //     ..setJavaScriptMode(JavaScriptMode.unrestricted)
    //     // ..setAllowsBackForwardNavigationGestures(true)
    //     ..setPlatformNavigationDelegate(
    //       const PlatformNavigationDelegateCreationParams(),
    //     )
    //     ..setOnPageStarted((String url) {})
    //     ..setOnPageFinished((String url) {})
    //     ..setOnWebResourceError((WebResourceError error) {
    //       // print('Ошибка WebView: ${error.description}');
    //     })
    //     ..loadRequest(Uri.parse(urlToLoad));
    // });

    // if (controller is WebKitWebViewController) {
    //   (controller as WebKitWebViewController)
    //       .setAllowsBackForwardNavigationGestures(true);
    // }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.width;
    final logoSize = screenHeight * 0.8; // Адаптивный размер логотипа
    SystemChrome.setPreferredOrientations(AppConfig.webGLAllowedOrientations);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // The WebView is mounted immediately so it can start/continue loading.
          Positioned.fill(
            child: PlatformWebViewWidget(
              PlatformWebViewWidgetCreationParams(controller: controller),
            ).build(context),
          ),

          // Loading overlay — shown while `isLoading` is true.
          if (isLoading)
            Positioned.fill(
              child: Container(
                decoration: AppConfig
                    .webGLLoadingDecoration, // const BoxDecoration(gradient: AppConfig.splashGradient),
                child: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Image.asset(
                            AppConfig.logoPath,
                            height: logoSize,
                            width: logoSize,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: AppConfig.webGLSpinerColor,
                              strokeWidth: 4,
                            ),
                            SizedBox(height: 8),
                            Text(
                              AppConfig.webGLLoadingText,
                              style: TextStyle(
                                color: AppConfig.webGLLoadingTextColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget that preloads a WebView offstage and notifies when the page is fully loaded.
class PreloadWebView extends StatefulWidget {
  final String initialUrl;
  final VoidCallback onLoaded;

  const PreloadWebView({
    super.key,
    required this.initialUrl,
    required this.onLoaded,
  });

  @override
  State<PreloadWebView> createState() => _PreloadWebViewState();
}

class _PreloadWebViewState extends State<PreloadWebView> {
  late final PlatformWebViewController _controller;
  bool _notified = false;

  @override
  void initState() {
    super.initState();

    _controller =
        WebKitWebViewController(
            WebKitWebViewControllerCreationParams(
              mediaTypesRequiringUserAction: const {},
              allowsInlineMediaPlayback: true,
            ),
          )
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..enableZoom(false)
          ..setPlatformNavigationDelegate(
            WebKitNavigationDelegate(
                const PlatformNavigationDelegateCreationParams(),
              )
              ..setOnPageFinished((String url) {
                if (!_notified) {
                  _notified = true;
                  widget.onLoaded();
                }
              })
              ..setOnWebResourceError((WebResourceError error) {
                // ignore
              }),
          )
          ..setAllowsBackForwardNavigationGestures(true)
          ..getUserAgent().then((String? userAgent) {
            _controller.setUserAgent(
              userAgent?.replaceAll("; wv", "").replaceAll("; wv", ""),
            );

            _controller.loadRequest(
              LoadRequestParams(uri: Uri.parse(widget.initialUrl)),
            );
          });
  }

  @override
  Widget build(BuildContext context) {
    // Offstage so it doesn't show on screen but still builds and loads
    return Offstage(
      offstage: true,
      child: PlatformWebViewWidget(
        PlatformWebViewWidgetCreationParams(controller: _controller),
      ).build(context),
    );
  }
}
