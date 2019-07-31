using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Track_AccesoDatos.Models
{
    public partial class Track_Movil
    {
        public string Patente { get; set; }
        public int IdTipoMovil { get; set; }
        public string ProveedorGPS { get; set; }
        public string Transportista { get; set; }
        public string RutTransportista { get; set; }
        public string Opcional { get; set; }
    }
}
