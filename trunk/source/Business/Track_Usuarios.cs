//------------------------------------------------------------------------------
// <auto-generated>
//    This code was generated from a template.
//
//    Manual changes to this file may cause unexpected behavior in your application.
//    Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace BusinessEntities
{
    using System;
    using System.Collections.Generic;
    
    public partial class Track_Usuarios
    {
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
