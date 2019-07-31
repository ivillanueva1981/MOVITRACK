using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Track_AccesoDatos.Models
{
    public class Track_GetFlotaOnline_Fragil_Result
    {
        public Nullable<System.DateTime> UltReporte { get; set; }
        public string TextUltReporte { get; set; }
        public string Patente { get; set; }
        public Nullable<int> IdTipoMovil { get; set; }
        public string Transportista { get; set; }
        public Nullable<decimal> Latitud { get; set; }
        public Nullable<decimal> Longitud { get; set; }
        public string Ignicion { get; set; }
        public Nullable<int> Velocidad { get; set; }
        public Nullable<int> Direccion { get; set; }
        public string EstadoGPS { get; set; }
        public string Puerta1 { get; set; }
        public string Temperatura1 { get; set; }
        public string EstadoViaje { get; set; }
        public Nullable<int> NroTransporte { get; set; }
        public Nullable<int> CodigoDestino { get; set; }
        public string ProveedorGPS { get; set; }
        public string RutConductor { get; set; }
        public string NombreConductor { get; set; }
        public string TelefonoConductor { get; set; }
        public Nullable<int> FlagViajeFragil { get; set; }
    }
}
