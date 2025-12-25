import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:newsappman/core/services/ai_service.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String? title;

  const WebViewScreen({
    super.key,
    required this.url,
    this.title,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _loadingProgress = 0;
  String _pageTitle = '';
  bool _readerMode = false;
  bool _isSummarizing = false;

  // JavaScript to extract page text content
  static const String _extractTextJS = '''
    (function() {
      var article = document.querySelector('article') || 
                    document.querySelector('[role="main"]') ||
                    document.querySelector('.article-content') ||
                    document.querySelector('.post-content') ||
                    document.querySelector('main') ||
                    document.body;
      return article ? article.innerText : document.body.innerText;
    })();
  ''';

  // JavaScript to extract and display only article content
  static const String _readerModeJS = '''
    (function() {
      var article = document.querySelector('article') || 
                    document.querySelector('[role="main"]') ||
                    document.querySelector('.article-content') ||
                    document.querySelector('.post-content') ||
                    document.querySelector('.entry-content') ||
                    document.querySelector('main');
      
      if (article) {
        var title = document.querySelector('h1')?.innerText || '';
        var content = article.innerHTML;
        
        document.body.innerHTML = `
          <div style="
            max-width: 700px;
            margin: 0 auto;
            padding: 20px;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            font-size: 18px;
            line-height: 1.8;
            color: #333;
            background: #fefefe;
          ">
            <h1 style="font-size: 28px; line-height: 1.3; margin-bottom: 24px;">\${title}</h1>
            \${content}
          </div>
        `;
        
        document.querySelectorAll('script, iframe, .ad, .ads, .advertisement, [class*="social"]').forEach(el => el.remove());
        
        document.querySelectorAll('img').forEach(img => {
          img.style.maxWidth = '100%';
          img.style.height = 'auto';
        });
      }
    })();
  ''';

  @override
  void initState() {
    super.initState();
    _pageTitle = widget.title ?? 'loading'.tr();
    _initController();
  }

  void _initController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final uri = Uri.parse(request.url);
            if (uri.scheme == 'http' || uri.scheme == 'https') {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _loadingProgress = 0;
              });
            }
          },
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress / 100;
              });
            }
          },
          onPageFinished: (String url) async {
            if (mounted) {
              final title = await _controller.getTitle();

              if (_readerMode) {
                await _controller.runJavaScript(_readerModeJS);
              }

              setState(() {
                _isLoading = false;
                _loadingProgress = 1;
                if (title != null && title.isNotEmpty) {
                  _pageTitle = title;
                }
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView Error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _toggleReaderMode() async {
    setState(() {
      _readerMode = !_readerMode;
    });

    if (_readerMode) {
      await _controller.runJavaScript(_readerModeJS);
    } else {
      await _controller.reload();
    }
  }

  Future<void> _summarizeWithAI() async {
    if (_isSummarizing) return;

    setState(() => _isSummarizing = true);

    try {
      // Extract text from page
      final result =
          await _controller.runJavaScriptReturningResult(_extractTextJS);
      String textContent = result.toString();

      // Clean the content (remove quotes if present)
      if (textContent.startsWith('"') && textContent.endsWith('"')) {
        textContent = textContent.substring(1, textContent.length - 1);
      }

      // Limit content length to avoid API limits
      if (textContent.length > 10000) {
        textContent = textContent.substring(0, 10000);
      }

      if (textContent.isEmpty || textContent.length < 100) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('no_content_to_summarize'.tr())),
          );
        }
        setState(() => _isSummarizing = false);
        return;
      }

      // Get current language
      final language = context.locale.languageCode;

      // Get AI summary
      final summary = await AiService.summarizeArticle(
        content: textContent,
        language: language,
      );

      if (mounted) {
        _showSummarySheet(summary);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'error'.tr()}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSummarizing = false);
      }
    }
  }

  void _showSummarySheet(String summary) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    'ai_summary'.tr(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Summary content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: SelectableText(
                  summary,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _pageTitle,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              Uri.parse(widget.url).host,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
        actions: [
          // AI Summary Button
          _isSummarizing
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.auto_awesome_outlined),
                  tooltip: 'ai_summary'.tr(),
                  onPressed: _summarizeWithAI,
                ),
          // Reader Mode Toggle
          IconButton(
            icon: Icon(
              _readerMode
                  ? Icons.chrome_reader_mode
                  : Icons.chrome_reader_mode_outlined,
              color: _readerMode ? colorScheme.primary : null,
            ),
            tooltip: 'reader_mode'.tr(),
            onPressed: _toggleReaderMode,
          ),
          // Share button
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'share'.tr(),
            onPressed: () {
              Share.share(widget.url, subject: _pageTitle);
            },
          ),
          // More menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              switch (value) {
                case 'reload':
                  setState(() => _readerMode = false);
                  await _controller.reload();
                  break;
                case 'browser':
                  final uri = Uri.parse(widget.url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'reload',
                child: Row(
                  children: [
                    const Icon(Icons.refresh, size: 20),
                    const SizedBox(width: 12),
                    Text('reload'.tr()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'browser',
                child: Row(
                  children: [
                    const Icon(Icons.open_in_browser, size: 20),
                    const SizedBox(width: 12),
                    Text('open_in_browser'.tr()),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: _isLoading
              ? LinearProgressIndicator(
                  value: _loadingProgress,
                  backgroundColor: Colors.transparent,
                  minHeight: 3,
                )
              : const SizedBox(height: 3),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
