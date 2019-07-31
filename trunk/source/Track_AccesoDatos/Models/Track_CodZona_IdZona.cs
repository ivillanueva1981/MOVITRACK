using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Track_AccesoDatos.Models
{
    public class Track_CodZona_IdZona
    {
        public string CodZona { get; set; }
        public int IdZona { get; set; }
        public string Tipo { get; set; }
        public int CodTipoCliente { get; set; }

        public virtual Track_Zonas Track_Zonas { get; set; }
    }
}
