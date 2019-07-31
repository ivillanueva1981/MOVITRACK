using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Track_AccesoDatos.Models
{
    public class usuarioViewModel
    {
        public string respuesta { get; set; }

        public int IdUsuario { get; set; }
        public string Nombre { get; set; }
        public string Apellidos { get; set; }
        public string Rut { get; set; }
        public string EMail { get; set; }
        public string Usuario { get; set; }
        public string Password { get; set; }
        public int IdRol { get; set; }
        public bool Activo { get; set; }
        public string Transportista { get; set; }
        public Nullable<int> IdAltoTrack { get; set; }





    }
}
