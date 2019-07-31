using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using BusinessEntities;
using BusinessLayer;
using ContextLayer.Model;

using iTextSharp.text.html.simpleparser;
using iTextSharp.text.pdf;
using iTextSharp.text;
using System.IO;
using System.Web;
using System.Net;
using System.Security.Cryptography.X509Certificates;
using System.Net.Security;

namespace BusinessLayer
{
    public class Methods_Export
    {
        private ModelEntities _context = new ModelEntities();

        public static BaseColor Color { get; private set; }

        public static string HTML_Zonas(List<Track_GetZonasAsociadas_Result> _list)
        {

            StringBuilder reportBuilder = new StringBuilder();

            for (int i = 0; i < _list.Count; i++)
            {
                reportBuilder.AppendLine("<br/>");

                reportBuilder.AppendLine("<table border=\"0,5\" width=\"100%\">");

                reportBuilder.AppendLine("  <tr style=\"background-color:#A9E2F3\" >");

                reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Id Zona</span></td>");
                reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Nombre Zona</span></td>");
                reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Tipo Zona</span></td>");
                reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Latitud</span></td>");
                reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Longitud</span></td>");

                reportBuilder.AppendLine("  </tr>");

                reportBuilder.AppendLine("  <tr>");
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].IdZona));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].NombreZona));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].NombreTipoZona));

                Methods_Zonas _obj = new Methods_Zonas();

                List<Track_Vertices> _vertices = _obj.GetVerticesZona(_list[i].IdZona);
                for (int j = 0; j < _vertices.Count; j++)
                {
                    reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _vertices[j].Latitud));
                    reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _vertices[j].Longitud));
                    reportBuilder.AppendLine("  </tr>");

                    if (j < _vertices.Count - 1)
                    {
                        reportBuilder.AppendLine("  <tr>");
                        reportBuilder.AppendLine("  <td style = \"border: 0px\" > </td>");
                        reportBuilder.AppendLine("  <td style = \"border: 0px\" > </td>");
                        reportBuilder.AppendLine("  <td style = \"border: 0px\" > </td>");
                    }

                }

                List<Track_GetClientesAsociados_Result> _clientesAsociados = _obj.GetClientesAsociados(_list[i].IdZona, "", "");
                if (_clientesAsociados.Count > 0)
                {
                    reportBuilder.AppendLine("  <tr>");
                    reportBuilder.AppendLine("  <td colspan = 5 style = \"border: 0px\" > <br/> </td>");
                    reportBuilder.AppendLine("  </tr>");

                    reportBuilder.AppendLine("  <tr>");
                    reportBuilder.AppendLine("      <td colspan = 5 style=\"border: 0px\"><span style=\"font-size:14pt; font-weight:bold\">Clientes asociados</span></td>");
                    reportBuilder.AppendLine("  </tr>");

                    reportBuilder.AppendLine("  <tr>");
                    reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Cod. Cliente</span></td>");
                    reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Nombre</span></td>");
                    reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Tipo</span></td>");
                    reportBuilder.AppendLine("      <td style=\"border: 0px\"><span style=\"font-size:12pt; font-weight:bold\"></span></td>");
                    reportBuilder.AppendLine("      <td style=\"border: 0px\"><span style=\"font-size:12pt; font-weight:bold\"></span></td>");
                    reportBuilder.AppendLine("  </tr>");

                    for (int j = 0; j < _clientesAsociados.Count; j++)
                    {
                        reportBuilder.AppendLine("  <tr>");
                        reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _clientesAsociados[j].CodCliente));
                        reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _clientesAsociados[j].NombreCliente));
                        reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _clientesAsociados[j].NombreTipoCliente));
                        reportBuilder.AppendLine("      <td style=\"border: 0px\"><span style=\"font-size:12pt; font-weight:bold\"></span></td>");
                        reportBuilder.AppendLine("      <td style=\"border: 0px\"><span style=\"font-size:12pt; font-weight:bold\"></span></td>");
                        reportBuilder.AppendLine("  </tr>");
                    }

                }
                /*
                reportBuilder.AppendLine("  <tr>");
                reportBuilder.AppendLine("  <br> &nbsp;</br><hr> ");
                reportBuilder.AppendLine("  </tr>");
                */
                reportBuilder.AppendLine("  <tr>");
                reportBuilder.AppendLine("  <td colspan = 5 style = \"border: 0px\" > <br/> </td>");
                reportBuilder.AppendLine("  </tr>");

                reportBuilder.AppendLine("</table>");

                reportBuilder.AppendLine("<br/>");

            }

            return reportBuilder.ToString();
        }


        public static string HTML_ViajesHistoricos(List<Track_GetViajesHistoricos_Alerce_Result> _list)
        {
            StringBuilder reportBuilder = new StringBuilder();

            reportBuilder.AppendLine("<table border=\"0,5\" width=\"100%\">");

            reportBuilder.AppendLine("  <tr style=\"border: 0px\"><td>   </td></tr>");

            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Guía Despacho</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Patente</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Transportista</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Cod. Origen</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Nombre Origen</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Cliente</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Conductor</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Asignación</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Salida Origen</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Llegada Destino</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Salida Destino</span></td>");

            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Alertas</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Estado</span></td>");

            reportBuilder.AppendLine("  </tr>");

            for (int i = 0; i < _list.Count; i++)
            {
                reportBuilder.AppendLine("  <tr>");
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].NroTransporte));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].PatenteTracto));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].Transportista));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].CodigoOrigen));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].NombreOrigen));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].NombreCliente));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].NombreChofer));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].FHAsignacion));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].FHSalidaOrigen));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].FHLlegadaDestino));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].FHSalidaDestino));

                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].CantidadAlertas));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].EstadoViaje));
            }

            reportBuilder.AppendLine("</table>");

            return reportBuilder.ToString();
        }

        public static string HTML_ViajesControlPanel(List<Track_GetViajesControlPanel_Alerce_Result> _list)
        {
            StringBuilder reportBuilder = new StringBuilder();

            reportBuilder.AppendLine("<table border=\"0,5\" width=\"100%\">");

            reportBuilder.AppendLine("  <tr style=\"border: 0px\"><td>   </td></tr>");

            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Guía Despacho</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Orden Servicio</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Cliente</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Nro. Contenedor</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Fecha viaje</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Fecha presentación</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Fecha llegada cliente</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Fecha salida cliente</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Patente</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Conductor</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Último reporte</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Vel(Km/h)</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">ETIS</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Tiempo viaje</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">ETA</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Alertas</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Estado</span></td>");

            reportBuilder.AppendLine("  </tr>");

            for (int i = 0; i < _list.Count; i++)
            {
                reportBuilder.AppendLine("  <tr>");
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].NroTransporte));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].NumeroOrdenServicio));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].NombreCliente));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].NumeroContenedor));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].Fecha));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].FechaHoraPresentacion));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].FHLlegadaDestino));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].FHSalidaDestino));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].PatenteTracto));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].NombreChofer));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].UltReporte));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].Velocidad));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].Etis));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].TiempoViaje));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].ETA));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].CantidadAlertas));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].EstadoViaje));
            }

            reportBuilder.AppendLine("</table>");

            return reportBuilder.ToString();
        }

        public static string HTML_FlotaOnline(List<Track_GetFlotaOnline_Result> _list)
        {
            StringBuilder reportBuilder = new StringBuilder();

            reportBuilder.AppendLine("<table border=\"0,5\" width=\"100%\">");

            reportBuilder.AppendLine("  <tr style=\"border: 0px\"><td>   </td></tr>");

            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Fecha</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Patente</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Transportista</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Ignición</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Velocidad</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Estado GPS</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Estado Viaje</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Latitud</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Longitud</span></td>");

            reportBuilder.AppendLine("  </tr>");

            for (int i = 0; i < _list.Count; i++)
            {
                reportBuilder.AppendLine("  <tr>");
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].UltReporte));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].Patente));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].Transportista));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].Ignicion));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].Velocidad));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].EstadoGPS));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].EstadoViaje));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].Latitud));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].Longitud));
            }

            reportBuilder.AppendLine("</table>");

            return reportBuilder.ToString();
        }

        public static string HTML_RPT_KmsRecorridos(List<Track_GetRpt_KmsRecorridos_Result> _list)
        {
            StringBuilder reportBuilder = new StringBuilder();

            reportBuilder.AppendLine("<table border=\"0,5\" width=\"100%\">");

            reportBuilder.AppendLine("  <tr style=\"border: 0px\"><td>   </td></tr>");

            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Transportista</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Fecha</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Guía Despacho</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Orden Servicio</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Nro. Contenedor</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Tracto</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Rampla</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Origen</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Conductor</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Rut</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Destinos</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Km Recorridos</span></td>");

            reportBuilder.AppendLine("  </tr>");

            for (int i = 0; i < _list.Count; i++)
            {
                reportBuilder.AppendLine("  <tr>");
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].Transportista));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", Convert.ToDateTime(_list[i].FHSalidaOrigen).ToString("yyyy-MM-dd")));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].NroTransporte));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].NumeroOrdenServicio));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].NumeroContenedor));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].PatenteTracto));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].PatenteTrailer));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].NombreOrigen));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].NombreConductor));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].RutConductor));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].Destinos));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].KmRecorridos));
            }

            reportBuilder.AppendLine("</table>");

            return reportBuilder.ToString();
        }

        public static MemoryStream MS_InformeViajes(string nroTransporte, string transportista, string nombreOrigen, string destinos, string tracto, string trailer, string nroContenedor, string conductor, string rutConductor, string score, string nombreCliente, List<Track_GetDetalleTrayecto_Result> _detalleTrayecto, List<Track_GetAlertasInformeViaje_Result> _alertasInformeViaje)
        {
            //Disable SSL certificate security. It´s not working other way
            ServicePointManager.ServerCertificateValidationCallback = delegate (object s, X509Certificate certificate, X509Chain chain, SslPolicyErrors sslPolicyErrors)
            { return true; };

            Document document = new Document();

            MemoryStream memoryStream = new MemoryStream();
            PdfWriter pdfWriter = PdfWriter.GetInstance(document, memoryStream);

            PdfPTable pdfTableResumen = new PdfPTable(2);

            pdfTableResumen.WidthPercentage = 100;
            pdfTableResumen.DefaultCell.Border = Rectangle.NO_BORDER;
            pdfTableResumen.HorizontalAlignment = Element.ALIGN_LEFT;

            float[] widths = new float[] { 1f, 3f };
            pdfTableResumen.SetWidths(widths);

            pdfTableResumen.SpacingBefore = 30f;
            pdfTableResumen.SpacingAfter = 40f;

            pdfTableResumen.AddCell("Guía:");
            pdfTableResumen.AddCell(" " + nroTransporte);
            pdfTableResumen.AddCell("Cliente:");
            pdfTableResumen.AddCell(nombreCliente);
            pdfTableResumen.AddCell("Transportista:");
            pdfTableResumen.AddCell(" " + transportista);
            pdfTableResumen.AddCell("Origen");
            pdfTableResumen.AddCell(" " + nombreOrigen);
            pdfTableResumen.AddCell("Destino/s:");
            pdfTableResumen.AddCell(destinos);
            pdfTableResumen.AddCell("Tracto:");
            pdfTableResumen.AddCell(" " + tracto);
            pdfTableResumen.AddCell("Rampla:");
            pdfTableResumen.AddCell(" " + trailer);
            pdfTableResumen.AddCell("Nro. Contenendor:");
            pdfTableResumen.AddCell(" " + nroContenedor);
            pdfTableResumen.AddCell("Conductor:");
            pdfTableResumen.AddCell(" " + conductor);
            pdfTableResumen.AddCell("Rut Conductor:");
            pdfTableResumen.AddCell(" " + rutConductor);
            pdfTableResumen.AddCell("Score:");
            pdfTableResumen.AddCell(" " + score);

            document.Open();

            var server = HttpContext.Current.Server;
            var imagePath = server.MapPath("Images");
            Image logo = Image.GetInstance(imagePath + "/logo_white_1500x789.png");
            logo.ScalePercent(7f);

            document.Add(logo);

            var boldTitle = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 20);

            Paragraph title = new Paragraph("Informe de Viaje", boldTitle);
            title.Alignment = Element.ALIGN_CENTER;

            document.Add(title);

            document.Add(pdfTableResumen);

            var boldFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 12);

            var tituloDetalle = new Phrase();
            tituloDetalle.Add(new Chunk("Detalle de trayecto:", boldFont));
            document.Add(new Paragraph(tituloDetalle));

            PdfPTable pdfTableDetalleTrayecto = new PdfPTable(2);
            pdfTableDetalleTrayecto.WidthPercentage = 100;
            pdfTableDetalleTrayecto.HorizontalAlignment = Element.ALIGN_LEFT;
            pdfTableDetalleTrayecto.DefaultCell.Border = Rectangle.NO_BORDER;
            float[] widthsTableDetalleTrayecto = new float[] { 3f, 6f };
            pdfTableDetalleTrayecto.SetWidths(widthsTableDetalleTrayecto);
            pdfTableDetalleTrayecto.SpacingBefore = 10;
            pdfTableDetalleTrayecto.SpacingAfter = 20;
            //pdfTableDetalleTrayecto.AddCell("Fecha");
            //pdfTableDetalleTrayecto.AddCell("Detalle");

            for (int j = 0; j < _detalleTrayecto.Count; j++)
            {
                pdfTableDetalleTrayecto.AddCell(_detalleTrayecto[j].Fecha);
                pdfTableDetalleTrayecto.AddCell(_detalleTrayecto[j].Detalle);
            }
            document.Add(pdfTableDetalleTrayecto);

            var tituloAlertas = new Phrase();
            tituloAlertas.Add(new Chunk("Alertas:", boldFont));

            var tituloObservaciones = new Phrase();
            tituloObservaciones.Add(new Chunk("Observaciones:", boldFont));

            if (_alertasInformeViaje.Count > 0)
            {
                document.NewPage();
                document.Add(new Paragraph(tituloAlertas));
            }

            int countMapPag = 0;

            for (int i = 0; i < _alertasInformeViaje.Count; i++)
            {
                PdfPTable pdfTableAlertas = new PdfPTable(5);
                pdfTableAlertas.WidthPercentage = 100;
                pdfTableAlertas.HorizontalAlignment = Element.ALIGN_LEFT;
                //float[] widthsTableAlertas = new float[] { 1f, 3f, 2f, 5f };
                //pdfTableResumen.SetWidths(widths);

                pdfTableAlertas.SpacingBefore = 40;
                pdfTableAlertas.SpacingAfter = 10f;

                Anchor anchor = new Anchor("Link");

                anchor.Reference = "https://maps.google.com/maps?q=" + _alertasInformeViaje[i].Latitud.ToString() + ',' + _alertasInformeViaje[i].Longitud.ToString();

                pdfTableAlertas.AddCell("Fecha Inicio:");
                pdfTableAlertas.AddCell("Fecha Envío:");
                pdfTableAlertas.AddCell("Destino:");
                pdfTableAlertas.AddCell("Descripción");
                pdfTableAlertas.AddCell("Ver en mapa");
                pdfTableAlertas.AddCell(_alertasInformeViaje[i].FechaInicioAlerta.ToString());
                pdfTableAlertas.AddCell(_alertasInformeViaje[i].FechaHoraCreacion.ToString());
                pdfTableAlertas.AddCell(_alertasInformeViaje[i].LocalDestino.ToString());
                pdfTableAlertas.AddCell(_alertasInformeViaje[i].DescripcionAlerta.ToString());
                pdfTableAlertas.AddCell(anchor);

                document.Add(pdfTableAlertas);

                string center = _alertasInformeViaje[i].Latitud + "," + _alertasInformeViaje[i].Longitud;
                string polygon;

                if (_alertasInformeViaje[i].ZoneLocation != -1)
                {
                    int _idZona;
                    _idZona = Convert.ToInt32(_alertasInformeViaje[i].ZoneLocation);

                    polygon = "&path=color:0x000000%7Cweight:2%7Cfillcolor:0x9966FF%7C";

                    Methods_Zonas _obj = new Methods_Zonas();
                    List<Track_Vertices> _vertices = _obj.GetAllVerticesZona(_idZona);
                    for (int k = 0; k < _vertices.Count; k++)
                    {
                        polygon = polygon + _vertices[k].Latitud.ToString().Replace(",", ".") + ',' + _vertices[k].Longitud.ToString().Replace(",", ".");

                        if (k < _vertices.Count - 1)
                        {
                            polygon = polygon + "%7C";
                        }
                    }

                }
                else
                {
                    polygon = "";
                }

                var stringUrlMap = "https://maps.googleapis.com/maps/api/staticmap?zoom=13&maptype=roadmap&size=400x200" + "&markers=color:red%7C" + center + "&key=AIzaSyDKLevfrbLESV7ebpmVxb9P7XRRKE1ypq8" + polygon;

                iTextSharp.text.Image mapImage = iTextSharp.text.Image.GetInstance(stringUrlMap);
                document.Add(mapImage);

                document.Add(new Paragraph(tituloObservaciones));
                if (_alertasInformeViaje[i].Observaciones != "")
                {
                    document.Add(new Paragraph(_alertasInformeViaje[i].Observaciones));
                }
                else
                {
                    document.Add(new Paragraph("Sin observaciones."));
                }

                countMapPag = countMapPag + 1;

                if (countMapPag >= 2)
                {
                    document.NewPage();
                    countMapPag = 0;
                }

            }

            document.Close();

            return memoryStream;

        }

        public static string HTML_RPT_GuiasDespacho(List<Track_GetGuiasDespacho_Result> _list)
        {
            StringBuilder reportBuilder = new StringBuilder();

            reportBuilder.AppendLine("<table border=\"0,5\" width=\"100%\">");

            reportBuilder.AppendLine("  <tr style=\"border: 0px\"><td>   </td></tr>");

            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Guía Despacho</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Orden Servicio</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Línea MO</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Versión MO</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Patente</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Fecha presentación</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Fecha creación</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Usuario Guía</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Usuario MO</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">ETIS</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Tipo MO</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Estado Ruta</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Estado MO</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Estado Móvil</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Estado Viaje</span></td>");

            reportBuilder.AppendLine("  </tr>");

            for (int i = 0; i < _list.Count; i++)
            {
                reportBuilder.AppendLine("  <tr>");
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].NumeroGuiaDespacho));
                //reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", Convert.ToDateTime(_list[i].FHSalidaOrigen).ToString("yyyy-MM-dd")));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].NumeroOrdenServicio));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].NumeroLineaMO));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].VersionMO));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].Patente));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].FechaHoraPresentacion));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].FechaCreacion));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].UsuarioGuia));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].UsuarioMO));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].ETIS));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].TipoMO));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].EstadoRuta));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].EstadoMO));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].EstadoMovil));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].EstadoViaje));
            }

            reportBuilder.AppendLine("</table>");

            return reportBuilder.ToString();
        }

        public static string HTML_MonitoreoOnline(List<Track_GetMonitoreoOnline_Fragil_Result> _list)
        {
            StringBuilder reportBuilder = new StringBuilder();

            reportBuilder.AppendLine("<table border=\"0,5\" width=\"100%\">");

            reportBuilder.AppendLine("  <tr style=\"border: 0px\"><td>   </td></tr>");

            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Fecha</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Patente</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Transportista</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Ignición</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Velocidad</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Estado GPS</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Estado Viaje</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Latitud</span></td>");
            reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Longitud</span></td>");

            reportBuilder.AppendLine("  </tr>");

            for (int i = 0; i < _list.Count; i++)
            {
                reportBuilder.AppendLine("  <tr>");
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].UltReporte));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].Patente));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].Transportista));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].Ignicion));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].Velocidad));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].EstadoGPS));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].EstadoViaje));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].Latitud));
                reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].Longitud));
            }

            reportBuilder.AppendLine("</table>");

            return reportBuilder.ToString();
        }

    public static string HTML_ViajesMineria(List<Track_GetViajesMineria_Result> _list)
    {
      StringBuilder reportBuilder = new StringBuilder();

      reportBuilder.AppendLine("<table border=\"0,5\" width=\"100%\">");

      reportBuilder.AppendLine("  <tr style=\"border: 0px\"><td>   </td></tr>");

      reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">ID_Servicio</span></td>");
      reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Patente_Camion</span></td>");
      reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Patente_Remolque</span></td>");
      reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Transportista</span></td>");
      reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Conductor</span></td>");
      reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Cliente</span></td>");
      reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Origen</span></td>");
      reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Destino</span></td>");
      reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">OTIF</span></td>");
      reportBuilder.AppendLine("      <td style=\"border: 1px\"><span style=\"font-size:12pt; font-weight:bold\">Estado_Viaje</span></td>");

      reportBuilder.AppendLine("  </tr>");

      for (int i = 0; i < _list.Count; i++)
      {
        reportBuilder.AppendLine("  <tr>");
        reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].NroTransporte));
        reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].PatenteTracto));
        reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].PatenteTrailer));
        reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].Transportista));
        reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].NombreConductor));
        reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].NombreCliente));
        reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].NombreOrigen));
        reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].NombreDestino));
        reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].OTIF));
        reportBuilder.AppendLine(string.Format("      <td style=\"border: 0,5px\">{0}</td>", _list[i].EstadoViaje));
      }

      reportBuilder.AppendLine("</table>");

      return reportBuilder.ToString();
    }

  }
}

