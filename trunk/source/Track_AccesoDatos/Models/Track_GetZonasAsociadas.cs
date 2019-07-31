using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Track_AccesoDatos.Models
{
    public class Track_GetZonasAsociadas
    {
        public int IdZona { get; set; }
        public string CodSitrans { get; set; }
        public string NombreZona { get; set; }
        public int IdTipoZona { get; set; }
        public string NombreTipoZona { get; set; }
        public Nullable<decimal> Latitud { get; set; }
        public Nullable<decimal> Longitud { get; set; }
        public Nullable<int> Radio { get; set; }
        public string Direccion { get; set; }
        public Nullable<int> CantClientesAsociados { get; set; }
    }
}
