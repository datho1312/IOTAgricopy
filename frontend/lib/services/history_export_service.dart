import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/history_data.dart';

enum HistoryExportFormat { csv, pdf }

class HistoryExportFile {
  const HistoryExportFile({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String fileName;
  final String mimeType;
}

class HistoryExportService {
  const HistoryExportService();

  Future<HistoryExportFile> generate({
    required HistoryExportFormat format,
    required String deviceName,
    required HistoryWindow window,
    required Set<HistorySensor> sensors,
    required List<HistorySample> samples,
    required List<PumpHistoryEvent> pumpEvents,
  }) async {
    if (samples.length > 5000) {
      throw const HistoryExportException(
        'Không thể tạo tệp. Hãy thử khoảng ngắn hơn.',
      );
    }
    return switch (format) {
      HistoryExportFormat.csv => _buildCsv(
        deviceName: deviceName,
        sensors: sensors,
        samples: samples,
        pumpEvents: pumpEvents,
      ),
      HistoryExportFormat.pdf => _buildPdf(
        deviceName: deviceName,
        window: window,
        sensors: sensors,
        samples: samples,
        pumpEvents: pumpEvents,
      ),
    };
  }

  HistoryExportFile _buildCsv({
    required String deviceName,
    required Set<HistorySensor> sensors,
    required List<HistorySample> samples,
    required List<PumpHistoryEvent> pumpEvents,
  }) {
    final orderedSensors = HistorySensor.values
        .where(sensors.contains)
        .toList();
    final rows = <List<String>>[
      ['device', 'recorded_at', ...orderedSensors.map((sensor) => sensor.key)],
      for (final sample in samples)
        [
          deviceName,
          sample.recordedAt.toUtc().toIso8601String(),
          ...orderedSensors.map(
            (sensor) => sample.values[sensor]?.toString() ?? '',
          ),
        ],
      [],
      ['pump_event_at', 'is_on', 'status'],
      for (final event in pumpEvents)
        [
          event.at.toUtc().toIso8601String(),
          event.isOn.toString(),
          event.status,
        ],
    ];
    final content = rows
        .map((row) => row.map(_escapeCsv).join(','))
        .join('\r\n');
    return HistoryExportFile(
      bytes: Uint8List.fromList(utf8.encode('\uFEFF$content')),
      fileName: '${_safeName(deviceName)}-history.csv',
      mimeType: 'text/csv',
    );
  }

  Future<HistoryExportFile> _buildPdf({
    required String deviceName,
    required HistoryWindow window,
    required Set<HistorySensor> sensors,
    required List<HistorySample> samples,
    required List<PumpHistoryEvent> pumpEvents,
  }) async {
    final regularFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    );
    final document = pw.Document(
      theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
    );
    final titleStyle = pw.TextStyle(
      font: boldFont,
      fontSize: 20,
      fontWeight: pw.FontWeight.bold,
    );
    final headingStyle = pw.TextStyle(
      font: boldFont,
      fontWeight: pw.FontWeight.bold,
    );
    final bodyStyle = pw.TextStyle(font: regularFont, fontSize: 14);
    final tableHeaderStyle = pw.TextStyle(
      font: boldFont,
      fontSize: 8,
      fontWeight: pw.FontWeight.bold,
    );
    final tableCellStyle = pw.TextStyle(font: regularFont, fontSize: 8);
    final date = DateFormat('dd/MM/yyyy HH:mm');
    final orderedSensors = HistorySensor.values
        .where(sensors.contains)
        .toList();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (_) => [
          pw.Text(
            'Lịch sử cảm biến Aerogreen',
            style: titleStyle,
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            deviceName,
            style: bodyStyle,
          ),
          pw.Text(
            '${date.format(window.from)} - ${date.format(window.to)}',
            style: bodyStyle,
          ),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: [
              'Time',
              ...orderedSensors.map(
                (sensor) =>
                    '${sensor.label} ${sensor.unit}',
              ),
            ],
            data: [
              for (final sample in samples)
                [
                  date.format(sample.recordedAt),
                  ...orderedSensors.map(
                    (sensor) =>
                        sample.values[sensor]?.toStringAsFixed(2) ?? '-',
                  ),
                ],
            ],
            headerStyle: tableHeaderStyle,
            cellStyle: tableCellStyle,
          ),
          if (pumpEvents.isNotEmpty) ...[
            pw.SizedBox(height: 18),
            pw.Text(
              'Sự kiện bơm',
              style: headingStyle,
            ),
            for (final event in pumpEvents)
              pw.Text(
                '${date.format(event.at)} - ${event.isOn ? 'ON' : 'OFF'} (${event.status})',
                style: pw.TextStyle(font: regularFont, fontSize: 9),
              ),
          ],
        ],
      ),
    );
    return HistoryExportFile(
      bytes: await document.save(),
      fileName: '${_safeName(deviceName)}-history.pdf',
      mimeType: 'application/pdf',
    );
  }

  String _escapeCsv(String value) => '"${value.replaceAll('"', '""')}"';

  String _safeName(String value) => _toAscii(value)
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  String _toAscii(String value) {
    const accented =
        'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ'
        'ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ';
    const plain =
        'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiioooooooooooooooooouuuuuuuuuuuyyyyyd'
        'AAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';
    final buffer = StringBuffer();
    for (final rune in value.replaceAll('°', 'deg ').runes) {
      final character = String.fromCharCode(rune);
      final index = accented.indexOf(character);
      buffer.write(index < 0 ? character : plain[index]);
    }
    return buffer.toString();
  }
}

class HistoryExportException implements Exception {
  const HistoryExportException(this.message);

  final String message;

  @override
  String toString() => message;
}
