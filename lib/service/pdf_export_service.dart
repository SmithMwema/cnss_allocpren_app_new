// lib/service/pdf_export_service.dart

// LIGNES D'IMPORT CORRIGÉES
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../modele/dossier.dart';
import '../modele/listing.dart';

class PdfExportService {
  
  /// Affiche un aperçu avant impression du PDF, méthode compatible web.
  Future<void> genererListingPdf(Listing listing, List<Dossier> dossiers) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(listing),
          _buildTable(dossiers),
          _buildFooter(dossiers),
        ],
      ),
    );

    // Utilise layoutPdf qui est la méthode standard et sécurisée pour le web.
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save()
    );
  }

  // --- CONTENU COMPLET DES MÉTHODES D'AIDE ---

  pw.Widget _buildHeader(Listing listing) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'CAISSE NATIONALE DE SÉCURITÉ SOCIALE (CNSS)',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
        ),
        pw.Divider(height: 20),
        pw.Text(
          'LISTING DE PAIEMENT - ALLOCATIONS PRÉNATALES',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
        ),
        pw.SizedBox(height: 15),
        pw.Text('Référence: ${listing.id}', style: const pw.TextStyle(fontSize: 12)),
        pw.Text('Date: ${listing.dateCreation.day}/${listing.dateCreation.month}/${listing.dateCreation.year}', style: const pw.TextStyle(fontSize: 12)),
        pw.SizedBox(height: 25),
      ],
    );
  }

  pw.Widget _buildTable(List<Dossier> dossiers) {
    final headers = ['N°', 'N° Sécu', 'Nom Complet de l\'Assurée', 'Signature'];
    final data = dossiers.asMap().entries.map((entry) {
      int index = entry.key + 1;
      Dossier dossier = entry.value;
      return [index.toString(), dossier.numSecuAssure, '${dossier.prenomAssure} ${dossier.nomAssure}', ''];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
      cellStyle: const pw.TextStyle(fontSize: 11),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft, 1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft, 3: pw.Alignment.center,
      },
      cellPadding: const pw.EdgeInsets.all(5),
    );
  }

  pw.Widget _buildFooter(List<Dossier> dossiers) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 60),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          pw.Text('AGENT DE PRESTATIONS\n\n_________________________'),
          pw.Text('LE CAISSIER\n\n_________________________'),
        ]
      )
    );
  }
}