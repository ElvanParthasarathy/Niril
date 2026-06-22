import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NIRIL BACKUP SERVICE — தரவு பாதுகாப்பு (Data Safety)
// ─────────────────────────────────────────────────────────────────────────────
// Keeps a raw copy of the SQLite database in a safe location outside the app's
// internal data directory. This backup survives:
//   • "Erase Data" (which only wipes the main DB)
//   • App uninstall + reinstall (stored in user Documents folder)
//   • Future Firebase glitches
//
// The backup is a plain file copy — no schema rewrite, no extra overhead.

/// Provider for the backup service. Override in main.dart after initialization.
final backupServiceProvider = Provider<NirilBackupService>((ref) {
  throw UnimplementedError(
      'backupServiceProvider must be overridden in ProviderScope');
});

/// Provider that checks if a backup file exists.
/// Used by main.dart to decide whether to show the Restore screen.
final hasBackupProvider = FutureProvider<bool>((ref) async {
  final backupService = ref.watch(backupServiceProvider);
  return backupService.hasBackup();
});

class NirilBackupService {
  /// The path to the main database file (in Application Support).
  final String _mainDbPath;

  /// The path to the backup database file (in user Documents folder).
  final String _backupDbPath;

  NirilBackupService._({
    required String mainDbPath,
    required String backupDbPath,
  })  : _mainDbPath = mainDbPath,
        _backupDbPath = backupDbPath;

  /// Factory constructor that resolves platform-appropriate paths.
  static Future<NirilBackupService> initialize() async {
    // Main DB location: Application Support directory (same as AppDatabase)
    final appSupportDir = await getApplicationSupportDirectory();
    final mainDbPath = p.join(appSupportDir.path, 'elvan_niril.db');

    // Backup location: User's Documents folder (survives app uninstall)
    final backupDir = await _getBackupDirectory();
    final backupDbPath = p.join(backupDir, 'elvan_niril_backup.db');

    return NirilBackupService._(
      mainDbPath: mainDbPath,
      backupDbPath: backupDbPath,
    );
  }

  /// Returns the platform-appropriate backup directory path.
  /// - Windows: %USERPROFILE%/Documents/Niril/backup/
  /// - Android: /storage/emulated/0/Documents/Niril/backup/
  static Future<String> _getBackupDirectory() async {
    String basePath;

    if (Platform.isAndroid) {
      basePath = '/storage/emulated/0/Documents';
    } else {
      // Use path_provider to correctly resolve OneDrive redirects on Windows/Mac/Linux
      final dir = await getApplicationDocumentsDirectory();
      basePath = dir.path;
    }

    final backupDir = p.join(basePath, 'Elvan Niril', 'backup');

    // Ensure the directory exists
    final dir = Directory(backupDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return backupDir;
  }

  Future<void> _safeCopy(String source, String dest) async {
    final sourceFile = File(source);
    if (!await sourceFile.exists()) return;
    try {
      await sourceFile.copy(dest);
    } catch (e) {
      if (Platform.isWindows) {
        // On Windows, File.copy (CopyFileEx) often fails with sharing violations (Error 32)
        // when SQLite holds a lock. Reading bytes manually bypasses this.
        final bytes = await sourceFile.readAsBytes();
        await File(dest).writeAsBytes(bytes, flush: true);
      } else {
        rethrow;
      }
    }
  }

  /// Creates a backup by copying the main database file to the backup location.
  ///
  /// Also copies WAL and SHM journal files if they exist, to ensure
  /// the backup is a complete snapshot.
  Future<void> createBackup() async {
    try {
      final mainFile = File(_mainDbPath);
      if (!await mainFile.exists()) return;

      // Ensure backup directory exists
      final backupDir = Directory(p.dirname(_backupDbPath));
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      // Copy main database file
      await _safeCopy(_mainDbPath, _backupDbPath);

      // Copy WAL journal if it exists (important for in-progress transactions)
      await _safeCopy('$_mainDbPath-wal', '$_backupDbPath-wal');

      // Copy SHM file if it exists
      await _safeCopy('$_mainDbPath-shm', '$_backupDbPath-shm');
    } catch (e) {
      // Backup failure should never crash the app — it's a safety net, not critical path
      print('Backup failed (non-critical): $e');
    }
  }

  /// Restores the backup by copying it back to the main database location.
  ///
  /// Returns `true` if the restore was successful, `false` otherwise.
  Future<bool> restoreFromBackup() async {
    try {
      final backupFile = File(_backupDbPath);
      if (!await backupFile.exists()) return false;

      // Ensure main DB directory exists
      final mainDir = Directory(p.dirname(_mainDbPath));
      if (!await mainDir.exists()) {
        await mainDir.create(recursive: true);
      }

      // Copy backup to main location
      await _safeCopy(_backupDbPath, _mainDbPath);

      // Copy WAL journal if it exists
      await _safeCopy('$_backupDbPath-wal', '$_mainDbPath-wal');

      // Copy SHM file if it exists
      await _safeCopy('$_backupDbPath-shm', '$_mainDbPath-shm');

      return true;
    } catch (e) {
      print('Restore failed: $e');
      return false;
    }
  }

  /// Checks whether a backup file exists and is valid (size > 0).
  Future<bool> hasBackup() async {
    try {
      final backupFile = File(_backupDbPath);
      if (await backupFile.exists()) {
        // Aggressive scan: check if it's a 0-byte ghost file
        final length = await backupFile.length();
        if (length > 0) {
          return true;
        } else {
          // It's a ghost file left by Android OS, clean it up and report no backup
          try { await backupFile.delete(); } catch (_) {}
          return false;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Permanently deletes the backup file. Use with extreme caution.
  Future<void> deleteBackup() async {
    try {
      final backupFile = File(_backupDbPath);
      if (await backupFile.exists()) {
        await backupFile.delete();
      }

      // Also clean up journal files
      final walFile = File('$_backupDbPath-wal');
      if (await walFile.exists()) await walFile.delete();

      final shmFile = File('$_backupDbPath-shm');
      if (await shmFile.exists()) await shmFile.delete();
    } catch (e) {
      print('Delete backup failed: $e');
    }
  }
}
