import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/state/search_state.dart';
// ─────────────────────────────────────────────────────────────────────────────
// MOCK DATA MODEL
// ─────────────────────────────────────────────────────────────────────────────

class _AlbumMock {
  const _AlbumMock(this.name, this.count, this.color);

  final String name;
  final int count;
  final Color color;
}

const List<_AlbumMock> _albums = [
  _AlbumMock('Camera', 4350, Color(0xFFE8D5C4)),
  _AlbumMock('GANTH', 106, Color(0xFFC5E1A5)),
  _AlbumMock('Nive akka', 776, Color(0xFFB3E5FC)),
  _AlbumMock('Quick Share', 116, Color(0xFFFFCDD2)),
  _AlbumMock('Album 3', 2, Color(0xFFD1C4E9)),
  _AlbumMock('Bell', 6, Color(0xFFFFE0B2)),
  _AlbumMock('Collage', 26, Color(0xFFB2DFDB)),
  _AlbumMock('Facebook', 17, Color(0xFFF8BBD0)),
  _AlbumMock('Happy birthday', 178, Color(0xFFC8E6C9)),
  _AlbumMock('Jai', 8, Color(0xFFBBDEFB)),
  _AlbumMock('Messenger', 3, Color(0xFFFFECB3)),
  _AlbumMock('Map Camera', 94, Color(0xFFD7CCC8)),
  _AlbumMock('New folder', 6, Color(0xFFCFD8DC)),
  _AlbumMock('Pa', 12, Color(0xFFE1BEE7)),
  _AlbumMock('Pendrive', 17, Color(0xFFB2EBF2)),
  _AlbumMock('Pictures', 233, Color(0xFFF0F4C3)),
  _AlbumMock('Downloads', 89, Color(0xFFFFCCBC)),
  _AlbumMock('Screenshots', 512, Color(0xFFE0E0E0)),
  // Duplicated dummy data for long scroll testing
  _AlbumMock('Test Folder 1', 10, Color(0xFFD1C4E9)),
  _AlbumMock('Test Folder 2', 20, Color(0xFFFFE0B2)),
  _AlbumMock('Test Folder 3', 30, Color(0xFFB2DFDB)),
  _AlbumMock('Test Folder 4', 40, Color(0xFFF8BBD0)),
  _AlbumMock('Test Folder 5', 50, Color(0xFFC8E6C9)),
  _AlbumMock('Test Folder 6', 60, Color(0xFFBBDEFB)),
  _AlbumMock('Test Folder 7', 70, Color(0xFFFFECB3)),
  _AlbumMock('Test Folder 8', 80, Color(0xFFD7CCC8)),
  _AlbumMock('Test Folder 9', 90, Color(0xFFCFD8DC)),
  _AlbumMock('Test Folder 10', 100, Color(0xFFE1BEE7)),
  _AlbumMock('Test Folder 11', 110, Color(0xFFB2EBF2)),
  _AlbumMock('Test Folder 12', 120, Color(0xFFF0F4C3)),
  _AlbumMock('Test Folder 13', 130, Color(0xFFFFCCBC)),
  _AlbumMock('Test Folder 14', 140, Color(0xFFE0E0E0)),
  _AlbumMock('Test Folder 15', 150, Color(0xFFC5E1A5)),
  _AlbumMock('Test Folder 16', 160, Color(0xFFB3E5FC)),
  _AlbumMock('Test Folder 17', 170, Color(0xFFFFCDD2)),
  _AlbumMock('Test Folder 18', 180, Color(0xFFE8D5C4)),
  _AlbumMock('Test Folder 19', 190, Color(0xFFD1C4E9)),
  _AlbumMock('Test Folder 20', 200, Color(0xFFFFE0B2)),
  _AlbumMock('Test Folder 21', 210, Color(0xFFB2DFDB)),
  _AlbumMock('Test Folder 22', 220, Color(0xFFFFCCBC)),
  _AlbumMock('Test Folder 23', 230, Color(0xFFD7CCC8)),
  _AlbumMock('Test Folder 24', 240, Color(0xFFCFD8DC)),
  _AlbumMock('Test Folder 25', 250, Color(0xFFF8BBD0)),
  _AlbumMock('Test Folder 26', 260, Color(0xFFC5CAE9)),
  _AlbumMock('Test Folder 27', 270, Color(0xFFB2EBF2)),
  _AlbumMock('Test Folder 28', 280, Color(0xFFDCEDC8)),
  _AlbumMock('Test Folder 29', 290, Color(0xFFFFF9C4)),
  _AlbumMock('Test Folder 30', 300, Color(0xFFFFE082)),
  _AlbumMock('Test Folder 31', 310, Color(0xFFFFCC80)),
  _AlbumMock('Test Folder 32', 320, Color(0xFFBCAAA4)),
  _AlbumMock('Test Folder 33', 330, Color(0xFFB0BEC5)),
  _AlbumMock('Test Folder 34', 340, Color(0xFFF48FB1)),
  _AlbumMock('Test Folder 35', 350, Color(0xFFCE93D8)),
  _AlbumMock('Test Folder 36', 360, Color(0xFF9FA8DA)),
  _AlbumMock('Test Folder 37', 370, Color(0xFF90CAF9)),
  _AlbumMock('Test Folder 38', 380, Color(0xFF81D4FA)),
  _AlbumMock('Test Folder 39', 390, Color(0xFF80DEEA)),
  _AlbumMock('Test Folder 40', 400, Color(0xFF80CBC4)),
  _AlbumMock('Test Folder 41', 410, Color(0xFFA5D6A7)),
  _AlbumMock('Test Folder 42', 420, Color(0xFFC5E1A5)),
  _AlbumMock('Test Folder 43', 430, Color(0xFFE6EE9C)),
  _AlbumMock('Test Folder 44', 440, Color(0xFFFFF59D)),
  _AlbumMock('Test Folder 45', 450, Color(0xFFFFE082)),
  _AlbumMock('Test Folder 46', 460, Color(0xFFFFCC80)),
  _AlbumMock('Test Folder 47', 470, Color(0xFFFFAB91)),
  _AlbumMock('Test Folder 48', 480, Color(0xFFBCAAA4)),
  _AlbumMock('Test Folder 49', 490, Color(0xFFEEEEEE)),
  _AlbumMock('Test Folder 50', 500, Color(0xFFB0BEC5)),
];


class SilkInvoicesPage extends ConsumerWidget {
  const SilkInvoicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(silkInvoicesSearchQueryProvider).toLowerCase();
    final filteredAlbums = query.isEmpty 
        ? _albums 
        : _albums.where((a) => a.name.toLowerCase().contains(query)).toList();

    return SliverPadding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 0,
        bottom: 120, // clearance for the floating pill
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.82,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final album = filteredAlbums[index];
            return _AlbumCard(album: album);
          },
          childCount: filteredAlbums.length,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ALBUM CARD — Sample grid tile mimicking the Samsung Gallery look
// ─────────────────────────────────────────────────────────────────────────────

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({required this.album});

  final _AlbumMock album;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: album.color,
        ),
        clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Placeholder gradient fill ──
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  album.color,
                  Color.lerp(album.color, Colors.black, 0.15)!,
                ],
              ),
            ),
          ),
          // ── Cached Network Image ──
          CachedNetworkImage(
            imageUrl: 'https://picsum.photos/id/${(album.count ~/ 10) % 1000}/300/300',
            fit: BoxFit.cover,
            // Keep the beautiful gradient while it loads
            placeholder: (context, url) => const SizedBox.shrink(),
            errorWidget: (context, url, error) => const Icon(CupertinoIcons.photo, color: Colors.white54),
          ),
          // ── Bottom label overlay ──
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  album.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black38,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${album.count}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    shadows: const [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black38,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
